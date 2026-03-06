"""
================================================================
  제미나이 x 만세력 3,600 운세 DB 구축기 v2.0
  ─ 60 일진 × 60 일주 = 3,600개 이중 루프
  ─ 유료 API 0원, 브라우저 자동화로 Gemini 직접 제어
================================================================

★ 실행 전 필수:
  pip install selenium webdriver-manager

★ 크롬 완전 종료 후 실행! (세션 충돌 방지)

★ 사용법:
  1. SKIP_ILJIN에 이미 뽑은 일진 추가
  2. python gemini_3600_rpa.py 실행
  3. 중간에 끊겨도 CSV 체크포인트로 자동 이어하기
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
from datetime import datetime

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager

# ╔══════════════════════════════════════════════════════════════╗
# ║  🚨🚨🚨 여기만 수정하세요! 🚨🚨🚨                            ║
# ╠══════════════════════════════════════════════════════════════╣
# ║                                                              ║
# ║  SKIP_ILJIN: 이미 60개 다 뽑은 일진을 여기에 추가하세요.      ║
# ║  예) 甲辰 하루치 60개를 다 뽑았으면:                          ║
# ║      SKIP_ILJIN = ["甲辰"]                                   ║
# ║  甲辰과 乙巳 두 개를 다 뽑았으면:                             ║
# ║      SKIP_ILJIN = ["甲辰", "乙巳"]                           ║
# ║                                                              ║
# ╚══════════════════════════════════════════════════════════════╝
SKIP_ILJIN = ["甲辰"]  # ← 이미 뽑은 일진 한자만 추가 (괄호 없이)

# 크롬 프로필 경로
CHROME_USER_DATA = r"C:\Users\db019\AppData\Local\Google\Chrome\User Data"
CHROME_PROFILE = "Default"

# 저장 파일
OUTPUT_CSV = "fortune_3600_db.csv"

# 안티봇 설정
DELAY_MIN = 15      # 최소 대기 시간 (초)
DELAY_MAX = 30      # 최대 대기 시간 (초)
NEW_CHAT_EVERY = 10 # N개마다 새 채팅
MAX_WAIT = 120      # 응답 최대 대기 (초)


# ============================================================
# 60갑자 배열 (한자 + 한글)
# ============================================================
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


# ============================================================
# 프롬프트 템플릿
# ============================================================
def build_prompt(today_iljin: str, user_ilju: str) -> str:
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
# 로깅
# ============================================================
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler("gemini_3600.log", encoding="utf-8")
    ]
)
logger = logging.getLogger(__name__)


# ============================================================
# CSV 체크포인트: 이미 수집한 (일진, 일주) 세트 로드
# ============================================================
def load_checkpoint(filepath: str) -> set:
    """기존 CSV에서 이미 수집된 (today_iljin, user_ilju) 조합 로드"""
    done = set()
    if not os.path.exists(filepath):
        return done
    try:
        with open(filepath, "r", encoding="utf-8-sig") as f:
            reader = csv.DictReader(f)
            for row in reader:
                key = (row.get("today_iljin", ""), row.get("user_ilju", ""))
                if key[0] and key[1]:
                    done.add(key)
        logger.info(f"📋 체크포인트 로드: {len(done)}개 이미 수집됨")
    except Exception as e:
        logger.warning(f"⚠️ 체크포인트 로드 실패: {e}")
    return done


def save_to_csv(data: dict, filepath: str):
    """CSV에 한 줄 Append"""
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
    with open(filepath, "a", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        if not file_exists:
            writer.writeheader()
        writer.writerow(row)


# ============================================================
# JSON 추출
# ============================================================
def extract_json(raw_text: str) -> dict:
    """응답에서 JSON 추출 (마크다운 백틱 제거)"""
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
            except Exception:
                pass
    logger.error(f"  ❌ JSON 추출 실패. 원문: {raw_text[:300]}")
    return None


# ============================================================
# 브라우저
# ============================================================
def kill_chrome():
    try:
        subprocess.run(["taskkill", "/F", "/IM", "chrome.exe"],
                      capture_output=True, timeout=10)
        subprocess.run(["taskkill", "/F", "/IM", "chromedriver.exe"],
                      capture_output=True, timeout=10)
        time.sleep(2)
    except Exception:
        pass


def create_browser():
    """크롬 임시 프로필로 세션 유지 브라우저 생성"""
    logger.info("🚀 크롬 브라우저 초기화...")
    kill_chrome()

    temp_profile = os.path.join(os.environ["TEMP"], "chrome_gemini_3600")

    if not os.path.exists(temp_profile):
        logger.info("  📂 프로필 복사 중 (최초 1회)...")
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
    else:
        logger.info("  ♻️ 기존 임시 프로필 재사용")

    opts = Options()
    opts.add_argument(f"--user-data-dir={temp_profile}")
    opts.add_argument("--profile-directory=Default")
    opts.add_argument("--disable-blink-features=AutomationControlled")
    opts.add_experimental_option("excludeSwitches", ["enable-automation"])
    opts.add_experimental_option("useAutomationExtension", False)
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-dev-shm-usage")
    opts.add_argument("--disable-gpu")
    opts.add_argument("--remote-debugging-port=9222")
    opts.add_argument("--window-size=1400,900")

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
def send_prompt(driver, text: str) -> str:
    """프롬프트 전송 → 응답 텍스트 반환"""
    # 입력창 찾기
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

    # 전송
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


def wait_response(driver) -> str:
    """응답 완료 대기"""
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


def new_chat(driver):
    """새 채팅 시작"""
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
# 메인 실행
# ============================================================
def main():
    # 스킵할 일진의 한자 목록
    skip_hanja = set(SKIP_ILJIN)
    active_iljin = [(h, k) for h, k in SIXTY_JIAZI if h not in skip_hanja]

    total_target = len(active_iljin) * 60
    logger.info("=" * 60)
    logger.info("🌟 3,600 운세 DB 구축기 v2.0")
    logger.info(f"   스킵 일진: {SKIP_ILJIN} ({len(SKIP_ILJIN)}개 × 60 = {len(SKIP_ILJIN)*60}개 스킵)")
    logger.info(f"   남은 일진: {len(active_iljin)}개 × 60 = {total_target}개 대상")
    logger.info("=" * 60)

    # 체크포인트 로드
    done_pairs = load_checkpoint(OUTPUT_CSV)
    remaining = total_target - len([
        1 for h, k in active_iljin
        for h2, k2 in SIXTY_JIAZI
        if (h, h2) in done_pairs or (f"{h}({k})", f"{h2}({k2})") in done_pairs
    ])
    logger.info(f"📊 체크포인트: {len(done_pairs)}개 완료, ~{remaining}개 남음")

    driver = None
    ok = 0
    fail = 0
    gen_count = 0  # 새 채팅 트리거용

    try:
        driver = create_browser()
        driver.get("https://gemini.google.com/app")
        time.sleep(7)

        for iljin_idx, (ij_h, ij_k) in enumerate(active_iljin):
            iljin_label = f"{ij_h}({ij_k})"
            logger.info(f"\n{'═' * 50}")
            logger.info(f"🔥 일진 [{iljin_idx+1}/{len(active_iljin)}]: {iljin_label}")
            logger.info(f"{'═' * 50}")

            for ilju_idx, (ju_h, ju_k) in enumerate(SIXTY_JIAZI):
                ilju_label = f"{ju_h}({ju_k})"
                pair_key = (ij_h, ju_h)
                pair_key2 = (iljin_label, ilju_label)

                # 체크포인트 스킵
                if pair_key in done_pairs or pair_key2 in done_pairs:
                    continue

                attempt_num = ok + fail + 1
                logger.info(f"  📌 [{attempt_num}] {iljin_label} × {ilju_label}")

                try:
                    # 10개마다 새 채팅
                    if gen_count > 0 and gen_count % NEW_CHAT_EVERY == 0:
                        logger.info("  🔄 새 채팅...")
                        new_chat(driver)

                    prompt = build_prompt(iljin_label, ilju_label)
                    raw = send_prompt(driver, prompt)
                    parsed = extract_json(raw)

                    if parsed:
                        # JSON에 키가 없으면 수동 보충
                        parsed.setdefault("today_iljin", iljin_label)
                        parsed.setdefault("user_ilju", ilju_label)
                        save_to_csv(parsed, OUTPUT_CSV)
                        done_pairs.add(pair_key)
                        ok += 1
                        gen_count += 1
                        logger.info(f"  🎉 성공 (✅{ok} ❌{fail})")
                    else:
                        fail += 1
                        with open("failed_3600.log", "a", encoding="utf-8") as f:
                            f.write(f"\n{'='*40}\n[{iljin_label}×{ilju_label}]\n{raw}\n")
                        logger.error(f"  ❌ 파싱실패 (✅{ok} ❌{fail})")

                    # 안티봇 딜레이
                    delay = random.uniform(DELAY_MIN, DELAY_MAX)
                    logger.info(f"  ⏰ {delay:.1f}초 대기...")
                    time.sleep(delay)

                except Exception as e:
                    fail += 1
                    logger.error(f"  ❌ 에러: {e}")
                    try:
                        driver.get("https://gemini.google.com/app")
                        time.sleep(5)
                    except: pass

            logger.info(f"✅ 일진 {iljin_label} 완료! (누적: ✅{ok} ❌{fail})")

    except KeyboardInterrupt:
        logger.info("\n🛑 사용자 중단")
    except Exception as e:
        logger.error(f"\n💥 치명적 에러: {e}")
    finally:
        logger.info(f"\n{'=' * 60}")
        logger.info(f"📊 최종: ✅성공 {ok}개  ❌실패 {fail}개")
        logger.info(f"📁 CSV: {os.path.abspath(OUTPUT_CSV)}")
        logger.info(f"{'=' * 60}")
        if driver:
            driver.quit()


if __name__ == "__main__":
    main()
