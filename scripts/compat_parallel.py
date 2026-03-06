"""
================================================================
  제미나이 궁합 3,600 DB 구축기 (병렬 v1.0)
  ─ 60 일주A × 60 일주B = 3,600개 궁합 텍스트
  ─ 5개 병렬 워커로 고속 수집
================================================================

★ 실행: python compat_parallel.py
★ 운세 매크로 완료 후 실행할 것!
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
NUM_WORKERS = 5
DELAY_MIN = 18
DELAY_MAX = 35
NEW_CHAT_EVERY = 8
MAX_WAIT = 120

CHROME_USER_DATA = r"C:\Users\db019\AppData\Local\Google\Chrome\User Data"
CHROME_PROFILE = "Default"

MAIN_CSV = "compat_3600_db.csv"

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

csv_lock = threading.Lock()


# ============================================================
# 궁합 프롬프트 (핵심!)
# ============================================================
def build_prompt(ilju_a, ilju_b):
    return f"""두 사람의 사주 궁합을 분석해 줘.
A의 일주: '{ilju_a}', B의 일주: '{ilju_b}'

너는 2026년 인스타/틱톡에서 핫한 'Z세대 연애 케미 코치'야. 명리학 오행 상생·상극을 바탕으로, 커플이 캡처해서 스토리에 올리고 싶어질 만큼 재미있는 궁합 분석을 작성해 줘.

[작성 가이드]
1. 금기어: '상극', '형살', '원진살' 등 무서운 한자어 절대 금지. 부정적 궁합도 "성장형 케미" 같은 긍정 프레이밍.
2. 어휘 믹스: '찐사랑', '케미 폭발', '밀당 천재', '소울메이트 각', '텐션 세계관', '시너지 미쳤다' 등 Z세대 밈 활용.
3. 나쁜 궁합도 긍정적으로: "서로 다른 에너지라 자극이 되는 성장형 커플!" 식으로.
4. 부연 설명 금지. 반드시 아래 JSON 포맷으로만 출력해.

{{
  "ilju_a": "{ilju_a}",
  "ilju_b": "{ilju_b}",
  "케미_점수": 75,
  "케미_타입": "5자 이내 (예: 불꽃 케미, 힐링 케미, 밀당 케미, 소울메이트, 성장형 커플)",
  "종합_분석": "200자 내외. 두 사람의 오행 에너지 궁합 + 연애 텐션 요약",
  "연애_스타일": "100자 내외. 같이 있을 때 분위기, 데이트 바이브",
  "주의_포인트": "100자 내외. 이것만 조심하면 찐! (긍정적 프레이밍 필수)",
  "럭키_데이트": "단어 2~3개 (예: 한강 피크닉, 카페 투어, 넷플릭스 정주행)"
}}"""


# ============================================================
# 공통 유틸 (운세 매크로와 동일)
# ============================================================
def get_logger(worker_id):
    logger = logging.getLogger(f"compat-w{worker_id}")
    logger.setLevel(logging.INFO)
    if not logger.handlers:
        fh = logging.FileHandler(f"compat_worker_{worker_id}.log", encoding="utf-8")
        sh = logging.StreamHandler()
        fmt = logging.Formatter(f"%(asctime)s [C-W{worker_id}] %(message)s")
        fh.setFormatter(fmt)
        sh.setFormatter(fmt)
        logger.addHandler(fh)
        logger.addHandler(sh)
    return logger


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


def load_all_done():
    done = set()
    csvfiles = [MAIN_CSV] + [f"compat_worker_{i}.csv" for i in range(NUM_WORKERS)]
    for fp in csvfiles:
        if not os.path.exists(fp):
            continue
        try:
            with open(fp, "r", encoding="utf-8-sig") as f:
                reader = csv.DictReader(f)
                for row in reader:
                    k = (row.get("ilju_a", ""), row.get("ilju_b", ""))
                    if k[0] and k[1]:
                        done.add(k)
        except:
            pass
    return done


def save_to_worker_csv(data, worker_id):
    filepath = f"compat_worker_{worker_id}.csv"
    fieldnames = [
        "ilju_a", "ilju_b",
        "케미_점수", "케미_타입", "종합_분석",
        "연애_스타일", "주의_포인트", "럭키_데이트", "생성시각"
    ]
    file_exists = os.path.exists(filepath)
    row = {
        "ilju_a": data.get("ilju_a", ""),
        "ilju_b": data.get("ilju_b", ""),
        "케미_점수": data.get("케미_점수", ""),
        "케미_타입": data.get("케미_타입", ""),
        "종합_분석": data.get("종합_분석", ""),
        "연애_스타일": data.get("연애_스타일", ""),
        "주의_포인트": data.get("주의_포인트", ""),
        "럭키_데이트": data.get("럭키_데이트", ""),
        "생성시각": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }
    with csv_lock:
        with open(filepath, "a", newline="", encoding="utf-8-sig") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            if not file_exists:
                writer.writeheader()
            writer.writerow(row)


def split_work(num_workers):
    done = load_all_done()
    print(f"📊 전체 완료: {len(done)}개")
    remaining = []
    for a_h, a_k in SIXTY_JIAZI:
        a_label = f"{a_h}({a_k})"
        for b_h, b_k in SIXTY_JIAZI:
            b_label = f"{b_h}({b_k})"
            if (a_label, b_label) not in done:
                remaining.append((a_label, b_label))
    print(f"📋 남은 작업: {len(remaining)}개")
    if not remaining:
        return [[] for _ in range(num_workers)]
    chunks = [[] for _ in range(num_workers)]
    for i, pair in enumerate(remaining):
        chunks[i % num_workers].append(pair)
    for i, chunk in enumerate(chunks):
        print(f"  워커 {i}: {len(chunk)}개 할당")
    return chunks


# ============================================================
# 브라우저 (운세와 동일, 프로필명만 다름)
# ============================================================
def create_browser(worker_id):
    logger = get_logger(worker_id)
    logger.info("🚀 크롬 브라우저 초기화...")
    temp_profile = os.path.join(os.environ["TEMP"], f"chrome_compat_w{worker_id}")
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
    opts = Options()
    opts.add_argument(f"--user-data-dir={temp_profile}")
    opts.add_argument("--profile-directory=Default")
    opts.add_argument("--disable-blink-features=AutomationControlled")
    opts.add_experimental_option("excludeSwitches", ["enable-automation"])
    opts.add_experimental_option("useAutomationExtension", False)
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-dev-shm-usage")
    opts.add_argument("--disable-gpu")
    opts.add_argument(f"--remote-debugging-port={9232 + worker_id}")
    opts.add_argument("--window-size=1200,800")
    opts.add_argument("--disable-extensions")
    opts.add_argument("--disable-default-apps")
    svc = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=svc, options=opts)
    driver.execute_cdp_cmd("Page.addScriptToEvaluateOnNewDocument", {
        "source": "Object.defineProperty(navigator,'webdriver',{get:()=>undefined});"
    })
    logger.info("✅ 브라우저 준비 완료")
    return driver


def send_prompt(driver, text, worker_id):
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
    return wait_response(driver)


def wait_response(driver):
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
# 워커
# ============================================================
def worker_run(worker_id, tasks):
    logger = get_logger(worker_id)
    logger.info(f"🏁 궁합 워커 {worker_id} 시작! 할당: {len(tasks)}개")
    if not tasks:
        return (worker_id, 0, 0)
    driver = None
    ok = 0
    fail = 0
    gen_count = 0
    try:
        time.sleep(worker_id * 10)
        driver = create_browser(worker_id)
        driver.get("https://gemini.google.com/app")
        time.sleep(7)
        for idx, (ilju_a, ilju_b) in enumerate(tasks):
            logger.info(f"💕 [{idx+1}/{len(tasks)}] {ilju_a} × {ilju_b}")
            try:
                if gen_count > 0 and gen_count % NEW_CHAT_EVERY == 0:
                    logger.info("  🔄 새 채팅...")
                    new_chat(driver, worker_id)
                prompt = build_prompt(ilju_a, ilju_b)
                raw = send_prompt(driver, prompt, worker_id)
                parsed = extract_json(raw)
                if parsed:
                    parsed.setdefault("ilju_a", ilju_a)
                    parsed.setdefault("ilju_b", ilju_b)
                    save_to_worker_csv(parsed, worker_id)
                    ok += 1
                    gen_count += 1
                    logger.info(f"  🎉 성공 (✅{ok} ❌{fail})")
                else:
                    fail += 1
                    logger.error(f"  ❌ 파싱실패 (✅{ok} ❌{fail})")
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
    fieldnames = [
        "ilju_a", "ilju_b",
        "케미_점수", "케미_타입", "종합_분석",
        "연애_스타일", "주의_포인트", "럭키_데이트", "생성시각"
    ]
    merged = 0
    for i in range(NUM_WORKERS):
        worker_csv = f"compat_worker_{i}.csv"
        if not os.path.exists(worker_csv):
            continue
        try:
            with open(worker_csv, "r", encoding="utf-8-sig") as rf:
                reader = csv.DictReader(rf)
                with open(MAIN_CSV, "a", newline="", encoding="utf-8-sig") as wf:
                    writer = csv.DictWriter(wf, fieldnames=fieldnames)
                    if not os.path.exists(MAIN_CSV) or os.path.getsize(MAIN_CSV) == 0:
                        writer.writeheader()
                    for row in reader:
                        writer.writerow(row)
                        merged += 1
            os.rename(worker_csv, f"compat_worker_{i}_merged.csv")
        except Exception as e:
            print(f"  ❌ 워커 {i} 병합 실패: {e}")
    print(f"📊 총 {merged}개 행 메인 CSV에 병합 완료")


def monitor_progress():
    while True:
        time.sleep(60)
        try:
            done = load_all_done()
            pct = len(done) / 3600 * 100
            print(f"\n💕 [모니터] 궁합 진행: {len(done)}/3600 ({pct:.1f}%)\n")
        except:
            pass


# ============================================================
# 메인
# ============================================================
def main():
    print("=" * 60)
    print("💕 궁합 3,600 DB 구축기 v1.0 (병렬)")
    print(f"   워커 수: {NUM_WORKERS}개")
    print("=" * 60)

    print("🔧 기존 크롬 프로세스 정리...")
    try:
        subprocess.run(["taskkill", "/F", "/IM", "chrome.exe"], capture_output=True, timeout=10)
        subprocess.run(["taskkill", "/F", "/IM", "chromedriver.exe"], capture_output=True, timeout=10)
        time.sleep(3)
    except:
        pass

    chunks = split_work(NUM_WORKERS)
    total_remaining = sum(len(c) for c in chunks)
    if total_remaining == 0:
        print("✅ 모든 궁합 데이터 수집 완료!")
        return

    monitor = threading.Thread(target=monitor_progress, daemon=True)
    monitor.start()

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

    total_ok = sum(r[1] for r in results)
    total_fail = sum(r[2] for r in results)
    print(f"\n{'=' * 60}")
    print(f"📊 최종 결과: ✅성공 {total_ok}개  ❌실패 {total_fail}개")

    print("\n📝 워커별 CSV → 메인 CSV 병합 중...")
    merge_csvs()

    done = load_all_done()
    print(f"\n🎯 전체 진행: {len(done)}/3600 ({len(done)/3600*100:.1f}%)")


if __name__ == "__main__":
    main()
