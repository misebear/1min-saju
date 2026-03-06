"""
================================================================
  제미나이 x 만세력 3,600 운세 DB 구축기 v3.0 (병렬)
  ─ 5개 워커가 각각 다른 일진 그룹을 동시 수집
  ─ 워커별 별도 CSV → 최종 병합
================================================================

★ 실행:
  python gemini_parallel.py

★ 각 워커는 별도 크롬 프로필 + 별도 CSV 사용
★ 완료 후 자동으로 메인 CSV에 병합
"""

import os
import re
import csv
import json
import time
import shutil
import random
import logging
import subprocess
import threading
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager

# ╔══════════════════════════════════════════════════════════════╗
# ║  설정                                                        ║
# ╚══════════════════════════════════════════════════════════════╝
NUM_WORKERS = 5          # 병렬 워커 수
DELAY_MIN = 18           # 최소 대기 (초) — 병렬이므로 약간 늘림
DELAY_MAX = 35           # 최대 대기 (초)
NEW_CHAT_EVERY = 8       # N개마다 새 채팅
MAX_WAIT = 120           # 응답 최대 대기 (초)

# 크롬 프로필 원본
CHROME_USER_DATA = r"C:\Users\db019\AppData\Local\Google\Chrome\User Data"
CHROME_PROFILE = "Default"

# 메인 CSV (기존 데이터)
MAIN_CSV = "fortune_3600_db.csv"

# 60갑자
SIXTY_JIAZI = [
    ("甲子", "갑자"), ("乙丑", "을축"), ("丙寅", "병인"), ("丁卯", "정묘"), ("戊辰", "무진"),
    ("己巳", "기사"), ("庚午", "경오"), ("辛未", "신미"), ("壬申", "임신"), ("癸酉", "계유"),
    ("甲戌", "갑술"), ("乙亥", "을해"), ("丙子", "병자"), ("丁丑", "정축"), ("戊寅", "무인"),
    ("己卯", "기묘"), ("庚辰", "경진"), ("辛巳", "신사"), ("壬午", "임오"), ("癸未", "계미"),
    ("甲申", "갑신"), ("乙酉", "을유"), ("丙戌", "병술"), ("丁亥", "정해"), ("戊子", "무자"),
    ("己丑", "기축"), ("庚寅", "경인"), ("辛卯", "신묘"), ("壬辰", "임진"), ("癸巳", "계사"),
    ("甲午", "갑오"), ("乙未", "을미"), ("丙申", "병신"), ("丁酉", "정유"), ("戊戌", "무술"),
    ("己亥", "기해"), ("庚子", "경자"), ("辛丑", "신축"), ("壬寅", "임인"), ("癸卯", "계묘"),
    ("甲辰", "갑진"), ("乙巳", "을사"), ("丙午", "병오"), ("丁未", "정미"), ("戊申", "무신"),
    ("己酉", "기유"), ("庚戌", "경술"), ("辛亥", "신해"), ("壬子", "임자"), ("癸丑", "계축"),
    ("甲寅", "갑인"), ("乙卯", "을묘"), ("丙辰", "병진"), ("丁巳", "정사"), ("戊午", "무오"),
    ("己未", "기미"), ("庚申", "경신"), ("辛酉", "신유"), ("壬戌", "임술"), ("癸亥", "계해")
]

# CSV 쓰기 락
csv_lock = threading.Lock()

# ============================================================
# 로깅 (워커별 식별)
# ============================================================
def get_logger(worker_id):
    logger = logging.getLogger(f"worker-{worker_id}")
    logger.setLevel(logging.INFO)
    if not logger.handlers:
        fh = logging.FileHandler(f"gemini_worker_{worker_id}.log", encoding="utf-8")
        sh = logging.StreamHandler()
        fmt = logging.Formatter(f"%(asctime)s [W{worker_id}] %(message)s")
        fh.setFormatter(fmt)
        sh.setFormatter(fmt)
        logger.addHandler(fh)
        logger.addHandler(sh)
    return logger


# ============================================================
# 기존 CSV에서 수집 완료된 쌍 로드
# ============================================================
def load_all_done() -> set:
    """메인 CSV + 워커별 CSV 모두에서 완료된 쌍 로드"""
    done = set()
    # 메인 CSV
    csvfiles = [MAIN_CSV] + [f"fortune_worker_{i}.csv" for i in range(NUM_WORKERS)]
    for fp in csvfiles:
        if not os.path.exists(fp):
            continue
        try:
            with open(fp, "r", encoding="utf-8-sig") as f:
                reader = csv.DictReader(f)
                for row in reader:
                    k = (row.get("today_iljin", ""), row.get("user_ilju", ""))
                    if k[0] and k[1]:
                        done.add(k)
        except Exception:
            pass
    return done


# ============================================================
# 남은 작업 분배
# ============================================================
def split_work(num_workers):
    """남은 일진을 워커별로 균등 분배"""
    done = load_all_done()
    print(f"📊 전체 완료: {len(done)}개")

    # 남은 (일진, 일주) 쌍 수집
    remaining = []
    for ij_h, ij_k in SIXTY_JIAZI:
        iljin_label = f"{ij_h}({ij_k})"
        for ju_h, ju_k in SIXTY_JIAZI:
            ilju_label = f"{ju_h}({ju_k})"
            if (iljin_label, ilju_label) not in done:
                remaining.append((iljin_label, ilju_label))

    print(f"📋 남은 작업: {len(remaining)}개")

    if not remaining:
        print("✅ 모든 작업 완료!")
        return [[] for _ in range(num_workers)]

    # 워커별 균등 분배
    chunks = [[] for _ in range(num_workers)]
    for i, pair in enumerate(remaining):
        chunks[i % num_workers].append(pair)

    for i, chunk in enumerate(chunks):
        print(f"  워커 {i}: {len(chunk)}개 할당")

    return chunks


# ============================================================
# 프롬프트
# ============================================================
def build_prompt(today_iljin, user_ilju):
    return f"""오늘의 일진은 '{today_iljin}'일, 대상자의 사주 일주는 '{user_ilju}'일주야.
너는 2026년 틱톡/쇼츠에서 핫한 'Z세대 전담 멘탈 웰니스 코치'야. 명리학 기운을 바탕으로, 2030 세대가 인스타 스토리에 공유하고 싶어질 만큼 힙한 오늘의 운세를 작성해 줘.

[작성 가이드]
1. 금기어: '편관', '역마살' 등 낡은 한자어나 '사고주의', '손재수' 같은 재수 없는 단어 절대 금지.
2. 어휘 믹스: '도파민 파밍/디톡스', '시성비', '추구미', '럭키비키', '오히려 좋아', '억까 방어', '폼 미쳤다' 등 최신 밈을 숏폼 나레이션처럼 리듬감 있게 써.
3. 흉운 방어: 에너지가 안 좋은 날은 "멘탈 디톡스 구간이잖아"처럼 초긍정 마인드셋으로 방어.
4. 부연 설명 금지. 반드시 아래 JSON 포맷으로만 출력해.

{{
  "today_iljin": "{today_iljin}",
  "user_ilju": "{user_ilju}",
  "오늘의_바이브": "150자 내외. (하루 에너지 흐름과 텐션 요약)",
  "머니_주파수": "100자 내외. (시성비 소비, 금융치료 등 트렌디한 금전운)",
  "관계_플러팅": "100자 내외. (자만추, 카톡 텐션, 인간관계 도파민 등)",
  "럭키_부적_아이템": "단어 1~2개. (아샷추, 고양이 영상, 인센스 스틱 등 힙한 일상템)",
  "오늘의_추구미": "단어 1개 (예: 방구석요정, 갓생모드, 멘탈수호 등)"
}}"""


# ============================================================
# JSON 추출
# ============================================================
def extract_json(raw_text):
    cleaned = re.sub(r'```(?:json)?\s*', '', raw_text).strip()
    match = re.search(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}', cleaned, re.DOTALL)
    if match:
        s = match.group()
        try:
            return json.loads(s)
        except json.JSONDecodeError:
            s = re.sub(r',\s*}', '}', s)
            s = re.sub(r',\s*]', ']', s)
            try:
                return json.loads(s)
            except:
                pass
    return None


# ============================================================
# CSV 저장 (워커별 파일)
# ============================================================
def save_to_worker_csv(data, worker_id):
    filepath = f"fortune_worker_{worker_id}.csv"
    fieldnames = [
        "today_iljin", "user_ilju",
        "오늘의_바이브", "머니_주파수", "관계_플러팅",
        "럭키_부적_아이템", "오늘의_추구미", "생성시각"
    ]
    file_exists = os.path.exists(filepath)
    row = {
        "today_iljin": data.get("today_iljin", ""),
        "user_ilju": data.get("user_ilju", ""),
        "오늘의_바이브": data.get("오늘의_바이브", ""),
        "머니_주파수": data.get("머니_주파수", ""),
        "관계_플러팅": data.get("관계_플러팅", ""),
        "럭키_부적_아이템": data.get("럭키_부적_아이템", ""),
        "오늘의_추구미": data.get("오늘의_추구미", ""),
        "생성시각": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }
    with csv_lock:
        with open(filepath, "a", newline="", encoding="utf-8-sig") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            if not file_exists:
                writer.writeheader()
            writer.writerow(row)


# ============================================================
# 브라우저 생성 (워커별 독립 프로필)
# ============================================================
def create_browser(worker_id):
    logger = get_logger(worker_id)
    logger.info("🚀 크롬 브라우저 초기화...")

    temp_profile = os.path.join(os.environ["TEMP"], f"chrome_gemini_w{worker_id}")

    # 프로필이 없으면 원본에서 쿠키만 복사
    if not os.path.exists(temp_profile):
        logger.info("  📂 프로필 복사 중...")
        src = os.path.join(CHROME_USER_DATA, CHROME_PROFILE)
        os.makedirs(temp_profile, exist_ok=True)
        td = os.path.join(temp_profile, "Default")
        os.makedirs(td, exist_ok=True)

        for f in ["Cookies", "Cookies-journal", "Login Data", "Login Data-journal",
                   "Web Data", "Web Data-journal", "Preferences", "Secure Preferences"]:
            sp = os.path.join(src, f)
            if os.path.exists(sp):
                try: shutil.copy2(sp, os.path.join(td, f))
                except: pass

        ls = os.path.join(CHROME_USER_DATA, "Local State")
        if os.path.exists(ls):
            try: shutil.copy2(ls, os.path.join(temp_profile, "Local State"))
            except: pass
        logger.info("  ✅ 프로필 복사 완료")

    opts = Options()
    opts.add_argument(f"--user-data-dir={temp_profile}")
    opts.add_argument("--profile-directory=Default")
    opts.add_argument("--disable-blink-features=AutomationControlled")
    opts.add_experimental_option("excludeSwitches", ["enable-automation"])
    opts.add_experimental_option("useAutomationExtension", False)
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-dev-shm-usage")
    opts.add_argument("--disable-gpu")
    # 각 워커별 다른 디버깅 포트
    opts.add_argument(f"--remote-debugging-port={9222 + worker_id}")
    opts.add_argument("--window-size=1200,800")
    # 메모리 절약
    opts.add_argument("--disable-extensions")
    opts.add_argument("--disable-default-apps")
    opts.add_argument("--disable-translate")

    svc = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=svc, options=opts)
    driver.execute_cdp_cmd("Page.addScriptToEvaluateOnNewDocument", {
        "source": "Object.defineProperty(navigator,'webdriver',{get:()=>undefined});"
    })
    logger.info("✅ 브라우저 준비 완료")
    return driver


# ============================================================
# 제미나이 조작
# ============================================================
def send_prompt(driver, text, worker_id):
    logger = get_logger(worker_id)
    selectors = [
        "div.ql-editor[contenteditable='true']",
        "rich-textarea div[contenteditable='true']",
        "div[contenteditable='true'][role='textbox']",
        "p[data-placeholder]",
    ]
    el = None
    for sel in selectors:
        try:
            el = WebDriverWait(driver, 10).until(
                EC.element_to_be_clickable((By.CSS_SELECTOR, sel)))
            if el: break
        except: continue
    if not el:
        try:
            el = WebDriverWait(driver, 10).until(
                EC.element_to_be_clickable((By.XPATH, "//div[@contenteditable='true']")))
        except:
            raise RuntimeError("입력창 미발견")

    el.click()
    time.sleep(0.5)
    driver.execute_script("""
        arguments[0].focus();
        arguments[0].innerText = arguments[1];
        arguments[0].dispatchEvent(new Event('input',{bubbles:true}));
    """, el, text)
    time.sleep(1)

    for sel in ["button[aria-label*='전송']", "button[aria-label*='보내기']",
                "button[aria-label*='Send']"]:
        try:
            btn = driver.find_element(By.CSS_SELECTOR, sel)
            if btn and btn.is_displayed():
                btn.click()
                break
        except: continue
    else:
        el.send_keys(Keys.RETURN)

    time.sleep(3)
    return wait_response(driver, worker_id)


def wait_response(driver, worker_id):
    start = time.time()
    last = ""
    stable = 0

    while time.time() - start < MAX_WAIT:
        time.sleep(3)
        txt = ""
        for sel in ["model-response .markdown", "message-content .markdown",
                     "div[data-message-author-role='model']"]:
            try:
                els = driver.find_elements(By.CSS_SELECTOR, sel)
                if els:
                    txt = els[-1].text
                    if txt: break
            except: continue

        if not txt:
            try:
                els = driver.find_elements(By.XPATH,
                    "//div[contains(@class,'response') or contains(@class,'model')]//div[contains(@class,'markdown') or contains(@class,'text')]")
                if els: txt = els[-1].text
            except: pass

        if not txt: continue
        if txt == last and len(txt) > 50:
            stable += 1
            if stable >= 3: return txt
        else:
            stable = 0
            last = txt

    if last: return last
    raise TimeoutError("응답 타임아웃")


def new_chat(driver, worker_id):
    for sel in ["a[aria-label*='새 채팅']", "a[aria-label*='New chat']",
                "button[aria-label*='새 채팅']", "button[aria-label*='New chat']"]:
        try:
            btn = driver.find_element(By.CSS_SELECTOR, sel)
            if btn and btn.is_displayed():
                btn.click()
                time.sleep(4)
                return
        except: continue
    driver.get("https://gemini.google.com/app")
    time.sleep(5)


# ============================================================
# 워커 함수
# ============================================================
def worker_run(worker_id, tasks):
    logger = get_logger(worker_id)
    logger.info(f"🏁 워커 {worker_id} 시작! 할당: {len(tasks)}개")

    if not tasks:
        logger.info("ℹ️ 할당된 작업 없음. 종료.")
        return (worker_id, 0, 0)

    driver = None
    ok = 0
    fail = 0
    gen_count = 0

    try:
        # 워커별로 시작 딜레이 (동시 접속 방지)
        startup_delay = worker_id * 10
        logger.info(f"  ⏰ 시작 딜레이: {startup_delay}초...")
        time.sleep(startup_delay)

        driver = create_browser(worker_id)
        driver.get("https://gemini.google.com/app")
        time.sleep(7)

        for idx, (iljin_label, ilju_label) in enumerate(tasks):
            logger.info(f"📌 [{idx+1}/{len(tasks)}] {iljin_label} × {ilju_label}")

            try:
                # 새 채팅
                if gen_count > 0 and gen_count % NEW_CHAT_EVERY == 0:
                    logger.info("  🔄 새 채팅...")
                    new_chat(driver, worker_id)

                prompt = build_prompt(iljin_label, ilju_label)
                raw = send_prompt(driver, prompt, worker_id)
                parsed = extract_json(raw)

                if parsed:
                    parsed.setdefault("today_iljin", iljin_label)
                    parsed.setdefault("user_ilju", ilju_label)
                    save_to_worker_csv(parsed, worker_id)
                    ok += 1
                    gen_count += 1
                    logger.info(f"  🎉 성공 (✅{ok} ❌{fail})")
                else:
                    fail += 1
                    logger.error(f"  ❌ 파싱실패 (✅{ok} ❌{fail})")

                # 안티봇 딜레이 (워커마다 약간 다르게)
                delay = random.uniform(DELAY_MIN + worker_id, DELAY_MAX + worker_id)
                logger.info(f"  ⏰ {delay:.1f}초 대기...")
                time.sleep(delay)

            except Exception as e:
                fail += 1
                logger.error(f"  ❌ 에러: {e}")
                try:
                    driver.get("https://gemini.google.com/app")
                    time.sleep(5)
                except: pass

    except Exception as e:
        logger.error(f"💥 워커 {worker_id} 치명적 에러: {e}")
    finally:
        logger.info(f"🏁 워커 {worker_id} 종료: ✅{ok} ❌{fail}")
        if driver:
            try: driver.quit()
            except: pass

    return (worker_id, ok, fail)


# ============================================================
# CSV 병합
# ============================================================
def merge_csvs():
    """워커별 CSV를 메인 CSV로 병합"""
    fieldnames = [
        "today_iljin", "user_ilju",
        "오늘의_바이브", "머니_주파수", "관계_플러팅",
        "럭키_부적_아이템", "오늘의_추구미", "생성시각"
    ]
    merged = 0
    for i in range(NUM_WORKERS):
        worker_csv = f"fortune_worker_{i}.csv"
        if not os.path.exists(worker_csv):
            continue
        try:
            with open(worker_csv, "r", encoding="utf-8-sig") as rf:
                reader = csv.DictReader(rf)
                with open(MAIN_CSV, "a", newline="", encoding="utf-8-sig") as wf:
                    writer = csv.DictWriter(wf, fieldnames=fieldnames)
                    for row in reader:
                        writer.writerow(row)
                        merged += 1
            # 병합 완료 후 워커 CSV 백업
            os.rename(worker_csv, f"fortune_worker_{i}_merged.csv")
            print(f"  ✅ 워커 {i}: {merged}개 병합")
        except Exception as e:
            print(f"  ❌ 워커 {i} 병합 실패: {e}")
    print(f"📊 총 {merged}개 행 메인 CSV에 병합 완료")


# ============================================================
# 실시간 모니터링 스레드
# ============================================================
def monitor_progress():
    """30초마다 전체 진행률 출력"""
    while True:
        time.sleep(60)
        try:
            done = load_all_done()
            pct = len(done) / 3600 * 100
            print(f"\n📊 [모니터] 전체 진행: {len(done)}/3600 ({pct:.1f}%)\n")
        except:
            pass


# ============================================================
# 메인
# ============================================================
def main():
    print("=" * 60)
    print("🌟 3,600 운세 DB 구축기 v3.0 (병렬)")
    print(f"   워커 수: {NUM_WORKERS}개")
    print("=" * 60)

    # 크롬/크롬드라이버 전체 종료
    print("🔧 기존 크롬 프로세스 정리...")
    try:
        subprocess.run(["taskkill", "/F", "/IM", "chrome.exe"], capture_output=True, timeout=10)
        subprocess.run(["taskkill", "/F", "/IM", "chromedriver.exe"], capture_output=True, timeout=10)
        time.sleep(3)
    except:
        pass

    # 작업 분배
    chunks = split_work(NUM_WORKERS)

    total_remaining = sum(len(c) for c in chunks)
    if total_remaining == 0:
        print("✅ 모든 작업이 이미 완료되었습니다!")
        return

    # 모니터링 스레드 시작
    monitor = threading.Thread(target=monitor_progress, daemon=True)
    monitor.start()

    # 병렬 실행
    print(f"\n🚀 {NUM_WORKERS}개 워커 시작! (총 {total_remaining}개 작업)")
    print("=" * 60)

    results = []
    with ThreadPoolExecutor(max_workers=NUM_WORKERS) as executor:
        futures = {
            executor.submit(worker_run, i, chunks[i]): i
            for i in range(NUM_WORKERS)
        }
        for future in as_completed(futures):
            wid, ok, fail = future.result()
            results.append((wid, ok, fail))
            print(f"🏁 워커 {wid} 완료: ✅{ok} ❌{fail}")

    # 결과 요약
    total_ok = sum(r[1] for r in results)
    total_fail = sum(r[2] for r in results)
    print(f"\n{'=' * 60}")
    print(f"📊 최종 결과: ✅성공 {total_ok}개  ❌실패 {total_fail}개")

    # CSV 병합
    print("\n📝 워커별 CSV → 메인 CSV 병합 중...")
    merge_csvs()

    # 최종 통계
    done = load_all_done()
    print(f"\n🎯 전체 진행: {len(done)}/3600 ({len(done)/3600*100:.1f}%)")
    print(f"{'=' * 60}")


if __name__ == "__main__":
    main()
