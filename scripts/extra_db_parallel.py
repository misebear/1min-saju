"""
================================================================
  Gemini 추가 DB 수집기 (병렬)
  ─ 띠별 운세: 12띠 × 60일진 = 720개
  ─ 별자리 운세: 12별자리 × 60일진 = 720개
  ─ 타로 해설: 78장 × 2(정/역) = 156개
  ─ 총 1,596개 → 5워커 병렬 수집
================================================================

★ 실행: python extra_db_parallel.py
★ 궁합 매크로 완료 후 실행
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
NUM_WORKERS = 3
DELAY_MIN = 8
DELAY_MAX = 15
NEW_CHAT_EVERY = 8
MAX_WAIT = 120

CHROME_USER_DATA = r"C:\Users\db019\AppData\Local\Google\Chrome\User Data"
CHROME_PROFILE = "Default"

csv_lock = threading.Lock()

# ============================================================
# 데이터 정의
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

TWELVE_ANIMALS = ["쥐띠", "소띠", "호랑이띠", "토끼띠", "용띠", "뱀띠",
                  "말띠", "양띠", "원숭이띠", "닭띠", "개띠", "돼지띠"]

TWELVE_ZODIAC = ["양자리", "황소자리", "쌍둥이자리", "게자리", "사자자리", "처녀자리",
                 "천칭자리", "전갈자리", "사수자리", "염소자리", "물병자리", "물고기자리"]

# 타로 78장 (메이저 22 + 마이너 56)
TAROT_MAJOR = [
    ("바보", "The Fool"), ("마법사", "The Magician"), ("여사제", "The High Priestess"),
    ("여황제", "The Empress"), ("황제", "The Emperor"), ("교황", "The Hierophant"),
    ("연인", "The Lovers"), ("전차", "The Chariot"), ("힘", "Strength"),
    ("은둔자", "The Hermit"), ("운명의수레바퀴", "Wheel of Fortune"), ("정의", "Justice"),
    ("매달린사람", "The Hanged Man"), ("죽음", "Death"), ("절제", "Temperance"),
    ("악마", "The Devil"), ("탑", "The Tower"), ("별", "The Star"),
    ("달", "The Moon"), ("태양", "The Sun"), ("심판", "Judgement"), ("세계", "The World")
]
TAROT_SUITS = ["완드", "컵", "소드", "펜타클"]
TAROT_RANKS = ["에이스", "2", "3", "4", "5", "6", "7", "8", "9", "10", "시종", "기사", "여왕", "왕"]


# ============================================================
# 프롬프트 빌더
# ============================================================
def build_tti_prompt(animal, iljin_label):
    return f"""오늘의 일진은 '{iljin_label}'이고, 대상자의 띠는 '{animal}'야.
너는 2026년 인스타/틱톡에서 핫한 'Z세대 운세 코치'야. 명리학 12지신 에너지를 바탕으로 힙한 띠별 오늘의 운세를 작성해 줘.

[작성 가이드]
1. 금기어: '삼재', '살' 등 무서운 한자어 절대 금지. 부정적 기운도 긍정 프레이밍.
2. 어휘 믹스: '도파민', '갓생', '럭키비키', '추구미', '시성비' 등 Z세대 밈 활용.
3. 부연 설명 금지. JSON만 출력해.

{{
  "animal": "{animal}",
  "iljin": "{iljin_label}",
  "오늘의_한줄": "30자 내외. 핵심 메시지",
  "운세_텍스트": "150자 내외. 오늘 에너지 흐름 + 조언",
  "럭키_포인트": "단어 2개 (색상/아이템 등)",
  "텐션_레벨": "1~100 숫자"
}}"""


def build_zodiac_prompt(sign, iljin_label):
    return f"""오늘의 일진은 '{iljin_label}'이고, 대상자의 별자리는 '{sign}'야.
너는 2026년 인스타/틱톡에서 핫한 'Z세대 별자리 운세 코치'야. 별자리 원소(불/땅/공기/물)와 명리학 오행 에너지를 결합해서 힙한 별자리 오늘의 운세를 작성해 줘.

[작성 가이드]
1. 금기어: '불길', '재앙' 등 부정적 표현 금지. 초긍정 프레이밍.
2. 어휘 믹스: '바이브', '케미', '폼 미쳤다', '럭키비키', '텐션 세계관' 등 활용.
3. 부연 설명 금지. JSON만 출력해.

{{
  "sign": "{sign}",
  "iljin": "{iljin_label}",
  "오늘의_한줄": "30자 내외. 핵심 메시지",
  "운세_텍스트": "150자 내외. 오늘 에너지 흐름 + 조언",
  "럭키_포인트": "단어 2개 (색상/아이템 등)",
  "텐션_레벨": "1~100 숫자"
}}"""


def build_tarot_prompt(card_name, card_en, position):
    pos_kr = "정위치" if position == "upright" else "역위치"
    return f"""타로 카드 '{card_name}({card_en})'의 {pos_kr} 해설을 작성해 줘.
너는 2026년 인스타/틱톡에서 핫한 'Z세대 타로 리딩 코치'야. 전통 타로 의미를 바탕으로 MZ세대가 캡처해서 공유하고 싶어질 만큼 감성적이고 힙한 해설을 작성해 줘.

[작성 가이드]
1. 역위치라도 공포 유발 금지. "이건 리셋 타임이야!" 같은 긍정 프레이밍.
2. 어휘 믹스: '바이브', '에너지 리딩', '유니버스가 보내는 시그널', '셀프러브' 등 활용.
3. 부연 설명 금지. JSON만 출력해.

{{
  "card_name": "{card_name}",
  "card_en": "{card_en}",
  "position": "{pos_kr}",
  "한줄_키워드": "5자 이내 핵심 키워드",
  "해설_텍스트": "200자 내외. 감성적이고 힙한 카드 해설",
  "어드바이스": "80자 내외. 이 카드를 뽑았을 때 실천 조언",
  "럭키_에너지": "단어 1~2개 (색상/원소/감정 등)"
}}"""


# ============================================================
# 공통 유틸
# ============================================================
def get_logger(worker_id):
    logger = logging.getLogger(f"extra-w{worker_id}")
    logger.setLevel(logging.INFO)
    if not logger.handlers:
        fh = logging.FileHandler(f"extra_worker_{worker_id}.log", encoding="utf-8")
        sh = logging.StreamHandler()
        fmt = logging.Formatter(f"%(asctime)s [E-W{worker_id}] %(message)s")
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
        try: return json.loads(s)
        except:
            s = re.sub(r',\s*}', '}', s)
            try: return json.loads(s)
            except: pass
    return None


def load_done(csv_prefix, num_workers, key_fields):
    done = set()
    files = [f"{csv_prefix}_db.csv"] + [f"{csv_prefix}_worker_{i}.csv" for i in range(num_workers)]
    for fp in files:
        if not os.path.exists(fp): continue
        try:
            with open(fp, "r", encoding="utf-8-sig") as f:
                for row in csv.DictReader(f):
                    k = tuple(row.get(kf, "") for kf in key_fields)
                    if all(k): done.add(k)
        except: pass
    return done


def save_csv(data, fieldnames, filepath):
    file_exists = os.path.exists(filepath)
    with csv_lock:
        with open(filepath, "a", newline="", encoding="utf-8-sig") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            if not file_exists:
                writer.writeheader()
            writer.writerow(data)


# ============================================================
# 작업 생성
# ============================================================
def generate_all_tasks():
    """3가지 DB 작업을 모두 생성"""
    tasks = []

    # 1) 띠별 운세 (720개)
    tti_done = load_done("tti_fortune", NUM_WORKERS, ["animal", "iljin"])
    for animal in TWELVE_ANIMALS:
        for h, k in SIXTY_JIAZI:
            label = f"{h}({k})"
            if (animal, label) not in tti_done:
                tasks.append(("tti", animal, label, None))

    # 2) 별자리 운세 (720개)
    zodiac_done = load_done("zodiac_fortune", NUM_WORKERS, ["sign", "iljin"])
    for sign in TWELVE_ZODIAC:
        for h, k in SIXTY_JIAZI:
            label = f"{h}({k})"
            if (sign, label) not in zodiac_done:
                tasks.append(("zodiac", sign, label, None))

    # 3) 타로 해설 (156개)
    tarot_done = load_done("tarot_reading", NUM_WORKERS, ["card_name", "position"])
    # 메이저 아르카나
    for name, en in TAROT_MAJOR:
        for pos in ["upright", "reversed"]:
            pos_kr = "정위치" if pos == "upright" else "역위치"
            if (name, pos_kr) not in tarot_done:
                tasks.append(("tarot", name, en, pos))
    # 마이너 아르카나
    for suit in TAROT_SUITS:
        for rank in TAROT_RANKS:
            card_name = f"{suit} {rank}"
            card_en = f"{rank} of {suit}"
            for pos in ["upright", "reversed"]:
                pos_kr = "정위치" if pos == "upright" else "역위치"
                if (card_name, pos_kr) not in tarot_done:
                    tasks.append(("tarot", card_name, card_en, pos))

    # 셔플 (다양한 타입이 고르게 분배되도록)
    random.shuffle(tasks)
    return tasks


# ============================================================
# 브라우저 (재사용)
# ============================================================
def create_browser(worker_id):
    logger = get_logger(worker_id)
    logger.info("🚀 크롬 초기화...")
    temp_profile = os.path.join(os.environ["TEMP"], f"chrome_extra_w{worker_id}")
    if not os.path.exists(temp_profile):
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
    opts.add_argument(f"--remote-debugging-port={9242 + worker_id}")
    opts.add_argument("--window-size=1200,800")
    opts.add_argument("--disable-extensions")
    svc = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=svc, options=opts)
    driver.execute_cdp_cmd("Page.addScriptToEvaluateOnNewDocument", {
        "source": "Object.defineProperty(navigator,'webdriver',{get:()=>undefined});"
    })
    return driver


def send_prompt(driver, text, worker_id):
    selectors = ["div.ql-editor[contenteditable='true']",
                 "rich-textarea div[contenteditable='true']",
                 "div[contenteditable='true'][role='textbox']",
                 "p[data-placeholder]"]
    el = None
    for sel in selectors:
        try:
            el = WebDriverWait(driver, 10).until(EC.element_to_be_clickable((By.CSS_SELECTOR, sel)))
            if el: break
        except: continue
    if not el:
        el = WebDriverWait(driver, 10).until(EC.element_to_be_clickable((By.XPATH, "//div[@contenteditable='true']")))
    el.click(); time.sleep(0.5)
    driver.execute_script("arguments[0].focus(); arguments[0].innerText=arguments[1]; arguments[0].dispatchEvent(new Event('input',{bubbles:true}));", el, text)
    time.sleep(1)
    for sel in ["button[aria-label*='전송']", "button[aria-label*='보내기']", "button[aria-label*='Send']"]:
        try:
            btn = driver.find_element(By.CSS_SELECTOR, sel)
            if btn and btn.is_displayed(): btn.click(); break
        except: continue
    else:
        el.send_keys(Keys.RETURN)
    time.sleep(3)
    return wait_response(driver)


def wait_response(driver):
    start = time.time(); last = ""; stable = 0
    while time.time() - start < MAX_WAIT:
        time.sleep(3); txt = ""
        for sel in ["model-response .markdown", "message-content .markdown", "div[data-message-author-role='model']"]:
            try:
                els = driver.find_elements(By.CSS_SELECTOR, sel)
                if els: txt = els[-1].text
                if txt: break
            except: continue
        if not txt:
            try:
                els = driver.find_elements(By.XPATH, "//div[contains(@class,'response') or contains(@class,'model')]//div[contains(@class,'markdown') or contains(@class,'text')]")
                if els: txt = els[-1].text
            except: pass
        if not txt: continue
        if txt == last and len(txt) > 50: stable += 1
        else: stable = 0; last = txt
        if stable >= 3: return txt
    if last: return last
    raise TimeoutError("타임아웃")


def new_chat(driver):
    for sel in ["a[aria-label*='새 채팅']", "a[aria-label*='New chat']", "button[aria-label*='새 채팅']", "button[aria-label*='New chat']"]:
        try:
            btn = driver.find_element(By.CSS_SELECTOR, sel)
            if btn and btn.is_displayed(): btn.click(); time.sleep(4); return
        except: continue
    driver.get("https://gemini.google.com/app"); time.sleep(5)


# ============================================================
# 작업 처리
# ============================================================
TTI_FIELDS = ["animal", "iljin", "오늘의_한줄", "운세_텍스트", "럭키_포인트", "텐션_레벨", "생성시각"]
ZODIAC_FIELDS = ["sign", "iljin", "오늘의_한줄", "운세_텍스트", "럭키_포인트", "텐션_레벨", "생성시각"]
TAROT_FIELDS = ["card_name", "card_en", "position", "한줄_키워드", "해설_텍스트", "어드바이스", "럭키_에너지", "생성시각"]


def process_task(driver, task, worker_id):
    task_type, field1, field2, field3 = task

    if task_type == "tti":
        prompt = build_tti_prompt(field1, field2)
        raw = send_prompt(driver, prompt, worker_id)
        parsed = extract_json(raw)
        if parsed:
            parsed.setdefault("animal", field1)
            parsed.setdefault("iljin", field2)
            parsed["생성시각"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            save_csv(parsed, TTI_FIELDS, f"tti_fortune_worker_{worker_id}.csv")
            return True

    elif task_type == "zodiac":
        prompt = build_zodiac_prompt(field1, field2)
        raw = send_prompt(driver, prompt, worker_id)
        parsed = extract_json(raw)
        if parsed:
            parsed.setdefault("sign", field1)
            parsed.setdefault("iljin", field2)
            parsed["생성시각"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            save_csv(parsed, ZODIAC_FIELDS, f"zodiac_fortune_worker_{worker_id}.csv")
            return True

    elif task_type == "tarot":
        prompt = build_tarot_prompt(field1, field2, field3)
        raw = send_prompt(driver, prompt, worker_id)
        parsed = extract_json(raw)
        if parsed:
            pos_kr = "정위치" if field3 == "upright" else "역위치"
            parsed.setdefault("card_name", field1)
            parsed.setdefault("card_en", field2)
            parsed.setdefault("position", pos_kr)
            parsed["생성시각"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            save_csv(parsed, TAROT_FIELDS, f"tarot_reading_worker_{worker_id}.csv")
            return True

    return False


# ============================================================
# 워커
# ============================================================
def worker_run(worker_id, tasks):
    logger = get_logger(worker_id)
    logger.info(f"🏁 워커 {worker_id} 시작! 할당: {len(tasks)}개")
    if not tasks: return (worker_id, 0, 0)

    driver = None; ok = 0; fail = 0; gen_count = 0
    try:
        time.sleep(worker_id * 10)
        driver = create_browser(worker_id)
        driver.get("https://gemini.google.com/app")
        time.sleep(7)

        for idx, task in enumerate(tasks):
            tt = task[0]
            label = f"{task[1]}×{task[2]}" if tt != "tarot" else f"{task[1]}({task[3]})"
            logger.info(f"📌 [{idx+1}/{len(tasks)}] [{tt}] {label}")

            try:
                if gen_count > 0 and gen_count % NEW_CHAT_EVERY == 0:
                    new_chat(driver)

                if process_task(driver, task, worker_id):
                    ok += 1; gen_count += 1
                    logger.info(f"  🎉 성공 (✅{ok} ❌{fail})")
                else:
                    fail += 1
                    logger.error(f"  ❌ 파싱실패")

                delay = random.uniform(DELAY_MIN + worker_id, DELAY_MAX + worker_id)
                time.sleep(delay)
            except Exception as e:
                fail += 1
                logger.error(f"  ❌ 에러: {e}")
                try: driver.get("https://gemini.google.com/app"); time.sleep(5)
                except: pass
    except Exception as e:
        logger.error(f"💥 치명적: {e}")
    finally:
        logger.info(f"🏁 워커 {worker_id} 종료: ✅{ok} ❌{fail}")
        if driver:
            try: driver.quit()
            except: pass
    return (worker_id, ok, fail)


# ============================================================
# 메인
# ============================================================
def main():
    print("=" * 60)
    print("🌟 추가 DB 구축기 (띠별 + 별자리 + 타로) 병렬")
    print(f"   워커 수: {NUM_WORKERS}개")
    print("=" * 60)

    try:
        subprocess.run(["taskkill", "/F", "/IM", "chrome.exe"], capture_output=True, timeout=10)
        subprocess.run(["taskkill", "/F", "/IM", "chromedriver.exe"], capture_output=True, timeout=10)
        time.sleep(3)
    except: pass

    tasks = generate_all_tasks()
    print(f"📋 총 작업: {len(tasks)}개")
    tti_count = sum(1 for t in tasks if t[0] == "tti")
    zodiac_count = sum(1 for t in tasks if t[0] == "zodiac")
    tarot_count = sum(1 for t in tasks if t[0] == "tarot")
    print(f"  🐲 띠별: {tti_count}개")
    print(f"  ⭐ 별자리: {zodiac_count}개")
    print(f"  🃏 타로: {tarot_count}개")

    if not tasks:
        print("✅ 모든 작업 완료!"); return

    chunks = [[] for _ in range(NUM_WORKERS)]
    for i, t in enumerate(tasks):
        chunks[i % NUM_WORKERS].append(t)

    results = []
    with ThreadPoolExecutor(max_workers=NUM_WORKERS) as executor:
        futures = {executor.submit(worker_run, i, chunks[i]): i for i in range(NUM_WORKERS)}
        for future in as_completed(futures):
            wid, ok, fail = future.result()
            results.append((wid, ok, fail))

    total_ok = sum(r[1] for r in results)
    total_fail = sum(r[2] for r in results)
    print(f"\n📊 최종: ✅{total_ok}  ❌{total_fail}")


if __name__ == "__main__":
    main()
