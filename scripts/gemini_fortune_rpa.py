"""
============================================================
  제미나이 자동화 60갑자 운세 생성기 (gemini_fortune_rpa.py)
  ─ 유료 API 0원, 브라우저 자동화로 Gemini 직접 제어
============================================================

★ 실행 전 필수 설치:
  pip install selenium webdriver-manager

★ 크롬 프로필 경로 확인 방법:
  1. 크롬 주소창에 chrome://version 입력
  2. "프로필 경로" 항목 확인
  3. 예: C:\\Users\\db019\\AppData\\Local\\Google\\Chrome\\User Data
  4. 아래 CHROME_USER_DATA 변수에 입력

★ 중요: 실행 전 크롬 브라우저를 완전히 종료해야 합니다!
  (기존 세션과 충돌 방지)
"""

import os
import re
import csv
import json
import time
import random
import logging
from datetime import datetime

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager

# ============================================================
# 설정 (여기만 수정하세요)
# ============================================================

# 크롬 사용자 데이터 경로 (chrome://version → 프로필 경로에서 확인)
CHROME_USER_DATA = r"C:\Users\db019\AppData\Local\Google\Chrome\User Data"
CHROME_PROFILE = "Default"  # 또는 "Profile 1" 등 사용 중인 프로필

# 오늘의 일진 (매일 변경) — 한자+한글 형식
TODAY_ILJIN = "甲辰(갑진)"

# 저장 파일 경로
OUTPUT_CSV = "fortune_2026_db.csv"

# 안티봇 설정
DELAY_MIN = 15  # 최소 대기 시간 (초)
DELAY_MAX = 30  # 최대 대기 시간 (초)
NEW_CHAT_EVERY = 10  # N개마다 새 채팅 시작
MAX_WAIT_RESPONSE = 120  # 응답 최대 대기 (초)

# 시작 인덱스 (중간부터 재시작할 때 사용, 0부터 시작)
START_INDEX = 0

# ============================================================
# 60갑자 일주 배열 (甲子~癸亥)
# ============================================================
SIXTY_JIAZI = [
    "甲子(갑자)", "乙丑(을축)", "丙寅(병인)", "丁卯(정묘)", "戊辰(무진)",
    "己巳(기사)", "庚午(경오)", "辛未(신미)", "壬申(임신)", "癸酉(계유)",
    "甲戌(갑술)", "乙亥(을해)", "丙子(병자)", "丁丑(정축)", "戊寅(무인)",
    "己卯(기묘)", "庚辰(경진)", "辛巳(신사)", "壬午(임오)", "癸未(계미)",
    "甲申(갑신)", "乙酉(을유)", "丙戌(병술)", "丁亥(정해)", "戊子(무자)",
    "己丑(기축)", "庚寅(경인)", "辛卯(신묘)", "壬辰(임진)", "癸巳(계사)",
    "甲午(갑오)", "乙未(을미)", "丙申(병신)", "丁酉(정유)", "戊戌(무술)",
    "己亥(기해)", "庚子(경자)", "辛丑(신축)", "壬寅(임인)", "癸卯(계묘)",
    "甲辰(갑진)", "乙巳(을사)", "丙午(병오)", "丁未(정미)", "戊申(무신)",
    "己酉(기유)", "庚戌(경술)", "辛亥(신해)", "壬子(임자)", "癸丑(계축)",
    "甲寅(갑인)", "乙卯(을묘)", "丙辰(병진)", "丁巳(정사)", "戊午(무오)",
    "己未(기미)", "庚申(경신)", "辛酉(신유)", "壬戌(임술)", "癸亥(계해)"
]

# ============================================================
# 프롬프트 템플릿
# ============================================================
def build_prompt(today_iljin: str, current_ilju: str) -> str:
    """제미나이에 입력할 프롬프트 생성"""
    return f"""오늘의 일진은 '{today_iljin}'일, 대상자의 사주 일주는 '{current_ilju}'일주야.
너는 2026년 틱톡과 쇼츠에서 가장 핫한 'Z세대 전담 멘탈 웰니스 코치'야. 명리학의 기운을 바탕으로, 2030 세대가 읽자마자 인스타 스토리에 공유하고 싶어질 만큼 힙하고 트렌디한 오늘의 운세를 작성해 줘. 

[작성 가이드 - 🚨매우 중요]
1. 금기어: '편관', '역마살' 같은 낡은 한자어나 '사고주의', '손재수', '구설수' 같은 재수 없는 단어 절대 금지.
2. 2026 트렌드 어휘 믹스: '도파민 파밍/디톡스', '폼 미쳤다', '추구미', '시성비', '갓벽한', '로우키(Low-key)', '에너지 주파수', '럭키비키', '오히려 좋아', '억까 방어' 등 최신 밈과 라이프스타일 용어를 찰지게 섞어 써줘. 문체는 친근한 반말이나 '~잖아', '~해요' 체를 섞어 숏폼 나레이션처럼 리듬감 있게 써.
3. 흉운(나쁜 운)의 재해석: 에너지가 안 좋은 날은 "오늘 약간 억까(억지로 까임) 있을 수 있는데", "에너지 세이브 구간! 오히려 멘탈 디톡스 할 기회잖아"처럼 무조건 긍정적인 '마인드셋 케어'로 부드럽게 방어해 줘.
4. 부연 설명이나 인사말 절대 금지. 반드시 아래 JSON 포맷으로만 출력해.

{{
  "일주": "{current_ilju}", 
  "오늘의_바이브": "150자 내외. (오늘 하루의 전체적인 에너지 흐름과 텐션을 타격감 있게 요약)", 
  "머니_주파수": "100자 내외. (단순 재물이 아니라 시성비 소비, 금융치료, 덕질 지출 방어, N잡 등 트렌디한 금전운)", 
  "관계_플러팅": "100자 내외. (연애뿐 아니라 결이 맞는 사람, 자만추, 카톡 텐션, 인간관계 도파민 등)", 
  "럭키_부적_아이템": "단어 1~2개. (뻔한 색깔 대신 '아바라', '노이즈캔슬링 이어폰', '고양이 영상', '인센스 스틱', '제로 콜라' 등 오늘 당장 소비/행동할 수 있는 힙한 일상템)",
  "오늘의_추구미": "오늘 하루 컨셉을 나타내는 트렌디한 단어 1개 (예: 무지성직진, 스몰럭키, 방구석요정, 갓생모드, 멘탈수호 등)"
}}"""

# ============================================================
# 로깅 설정
# ============================================================
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler("gemini_rpa.log", encoding="utf-8")
    ]
)
logger = logging.getLogger(__name__)

# ============================================================
# 브라우저 초기화
# ============================================================
def kill_chrome():
    """크롬 프로세스 완전 종료"""
    import subprocess
    try:
        subprocess.run(["taskkill", "/F", "/IM", "chrome.exe"], 
                      capture_output=True, timeout=10)
        subprocess.run(["taskkill", "/F", "/IM", "chromedriver.exe"], 
                      capture_output=True, timeout=10)
        time.sleep(2)
    except Exception:
        pass


def create_browser():
    """크롬 브라우저 생성 (쿠키 복사 방식으로 세션 유지)"""
    import shutil
    
    logger.info("🚀 크롬 브라우저 초기화 중...")
    
    # 기존 크롬 완전 종료
    kill_chrome()
    
    # 임시 프로필 디렉토리 (원본 복사)
    temp_profile = os.path.join(os.environ["TEMP"], "chrome_gemini_rpa")
    
    # 이전 임시 프로필이 있으면 재사용 (쿠키 유지)
    if not os.path.exists(temp_profile):
        logger.info("  📂 크롬 프로필 복사 중 (최초 1회, 쿠키 포함)...")
        src_profile = os.path.join(CHROME_USER_DATA, CHROME_PROFILE)
        
        # 필수 파일만 복사 (전체 복사는 너무 오래 걸림)
        os.makedirs(temp_profile, exist_ok=True)
        temp_default = os.path.join(temp_profile, "Default")
        os.makedirs(temp_default, exist_ok=True)
        
        # 로그인 세션 유지에 필요한 핵심 파일 복사
        essential_files = [
            "Cookies", "Cookies-journal",
            "Login Data", "Login Data-journal",
            "Web Data", "Web Data-journal",
            "Preferences", "Secure Preferences",
            "Local State",
        ]
        
        for fname in essential_files:
            src = os.path.join(src_profile, fname)
            if os.path.exists(src):
                try:
                    shutil.copy2(src, os.path.join(temp_default, fname))
                except Exception as e:
                    logger.warning(f"  ⚠️ {fname} 복사 실패: {e}")
        
        # Local State 파일 (상위 디렉토리)
        local_state = os.path.join(CHROME_USER_DATA, "Local State")
        if os.path.exists(local_state):
            try:
                shutil.copy2(local_state, os.path.join(temp_profile, "Local State"))
            except Exception:
                pass
        
        logger.info("  ✅ 프로필 복사 완료")
    else:
        logger.info("  ♻️ 기존 임시 프로필 재사용")
    
    options = Options()
    # 임시 프로필 사용
    options.add_argument(f"--user-data-dir={temp_profile}")
    options.add_argument("--profile-directory=Default")
    
    # 봇 탐지 회피 옵션
    options.add_argument("--disable-blink-features=AutomationControlled")
    options.add_experimental_option("excludeSwitches", ["enable-automation"])
    options.add_experimental_option("useAutomationExtension", False)
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
    options.add_argument("--remote-debugging-port=9222")
    
    # 윈도우 크기 설정
    options.add_argument("--window-size=1400,900")
    
    # ChromeDriver 자동 관리
    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=options)
    
    # navigator.webdriver 속성 제거 (봇 탐지 추가 회피)
    driver.execute_cdp_cmd("Page.addScriptToEvaluateOnNewDocument", {
        "source": """
            Object.defineProperty(navigator, 'webdriver', {get: () => undefined});
            window.chrome = { runtime: {} };
        """
    })
    
    logger.info("✅ 브라우저 초기화 완료")
    return driver

# ============================================================
# 제미나이 조작 함수
# ============================================================
def navigate_to_gemini(driver):
    """제미나이 페이지로 이동"""
    logger.info("🌐 gemini.google.com 접속 중...")
    driver.get("https://gemini.google.com/app")
    time.sleep(5)  # 초기 로딩 대기
    logger.info("✅ 제미나이 페이지 로딩 완료")


def type_like_human(element, text):
    """사람처럼 타이핑 (봇 탐지 방지)"""
    # 긴 텍스트는 자연스럽게 빠르게 입력 (클립보드 방식)
    # Selenium의 send_keys로 한꺼번에 입력 (한글은 청크 방식 불안정)
    element.send_keys(text)
    time.sleep(random.uniform(0.3, 0.8))


def send_prompt(driver, prompt_text: str) -> str:
    """프롬프트 전송 후 응답 텍스트 추출"""
    
    # 1단계: 채팅 입력창 찾기
    # Gemini 입력창 셀렉터 (2026년 기준, 변경될 수 있음)
    input_selectors = [
        "div.ql-editor[contenteditable='true']",     # Quill 에디터
        "rich-textarea div[contenteditable='true']",  # 리치 텍스트
        "textarea[aria-label*='메시지']",             # 일반 textarea
        "div[contenteditable='true'][role='textbox']", # ARIA 텍스트박스
        ".input-area div[contenteditable='true']",    # 입력 영역
        "p[data-placeholder]",                       # 플레이스홀더가 있는 p
    ]
    
    input_el = None
    for selector in input_selectors:
        try:
            input_el = WebDriverWait(driver, 10).until(
                EC.element_to_be_clickable((By.CSS_SELECTOR, selector))
            )
            if input_el:
                logger.info(f"  📝 입력창 발견: {selector}")
                break
        except Exception:
            continue
    
    if not input_el:
        # XPath 폴백
        try:
            input_el = WebDriverWait(driver, 10).until(
                EC.element_to_be_clickable((By.XPATH, "//div[@contenteditable='true']"))
            )
            logger.info("  📝 입력창 발견 (XPath 폴백)")
        except Exception:
            raise RuntimeError("❌ 제미나이 입력창을 찾을 수 없습니다. UI가 변경되었을 수 있습니다.")
    
    # 2단계: 클릭 후 텍스트 입력
    input_el.click()
    time.sleep(0.5)
    
    # JavaScript로 값 설정 (한글 입력 안정성 확보)
    driver.execute_script("""
        arguments[0].focus();
        arguments[0].innerText = arguments[1];
        arguments[0].dispatchEvent(new Event('input', { bubbles: true }));
    """, input_el, prompt_text)
    time.sleep(1)
    
    # 3단계: 전송 (Enter 또는 전송 버튼)
    send_selectors = [
        "button[aria-label*='전송']",
        "button[aria-label*='보내기']",
        "button[aria-label*='Send']",
        "button[aria-label*='submit']",
        "button.send-button",
        "mat-icon[data-mat-icon-name='send']",
    ]
    
    sent = False
    for selector in send_selectors:
        try:
            send_btn = driver.find_element(By.CSS_SELECTOR, selector)
            if send_btn and send_btn.is_displayed():
                send_btn.click()
                sent = True
                logger.info("  📤 전송 버튼 클릭")
                break
        except Exception:
            continue
    
    if not sent:
        # Enter키 전송 폴백
        input_el.send_keys(Keys.RETURN)
        logger.info("  📤 Enter 키 전송")
    
    time.sleep(3)  # 응답 시작 대기
    
    # 4단계: 응답 완료 대기
    logger.info("  ⏳ 응답 대기 중...")
    response_text = wait_for_response(driver)
    
    return response_text


def wait_for_response(driver) -> str:
    """제미나이 응답이 완전히 끝날 때까지 대기"""
    start_time = time.time()
    last_text = ""
    stable_count = 0
    
    while time.time() - start_time < MAX_WAIT_RESPONSE:
        time.sleep(3)
        
        # 응답 텍스트 추출 시도 (여러 셀렉터)
        response_selectors = [
            "model-response .response-content",
            "model-response .markdown",
            "message-content .markdown",
            ".model-response-text",
            "div[data-message-author-role='model']",
            ".response-container .text-content",
        ]
        
        current_text = ""
        for selector in response_selectors:
            try:
                elements = driver.find_elements(By.CSS_SELECTOR, selector)
                if elements:
                    # 마지막 응답 요소 (최신 것)
                    current_text = elements[-1].text
                    if current_text:
                        break
            except Exception:
                continue
        
        if not current_text:
            # XPath 폴백: 모든 응답 텍스트 블록
            try:
                elements = driver.find_elements(By.XPATH, 
                    "//div[contains(@class,'response') or contains(@class,'model')]//div[contains(@class,'markdown') or contains(@class,'text')]"
                )
                if elements:
                    current_text = elements[-1].text
            except Exception:
                pass
        
        if not current_text:
            continue
        
        # 응답이 변하지 않으면 완료로 판단
        if current_text == last_text and len(current_text) > 50:
            stable_count += 1
            if stable_count >= 3:  # 9초간 변화 없으면 완료
                logger.info(f"  ✅ 응답 완료 ({len(current_text)}자)")
                return current_text
        else:
            stable_count = 0
            last_text = current_text
    
    # 타임아웃이지만 텍스트가 있으면 반환
    if last_text:
        logger.warning(f"  ⚠️ 타임아웃, 수집된 텍스트 반환 ({len(last_text)}자)")
        return last_text
    
    raise TimeoutError("❌ 응답 대기 타임아웃")


def start_new_chat(driver):
    """새 채팅 시작 (환각 방지)"""
    logger.info("🔄 새 채팅 시작...")
    
    new_chat_selectors = [
        "a[aria-label*='새 채팅']",
        "a[aria-label*='New chat']",
        "button[aria-label*='새 채팅']",
        "button[aria-label*='New chat']",
        ".new-chat-button",
    ]
    
    clicked = False
    for selector in new_chat_selectors:
        try:
            btn = driver.find_element(By.CSS_SELECTOR, selector)
            if btn and btn.is_displayed():
                btn.click()
                clicked = True
                logger.info("  ✅ 새 채팅 버튼 클릭")
                break
        except Exception:
            continue
    
    if not clicked:
        # 페이지 새로고침 폴백
        logger.info("  🔄 새 채팅 버튼 미발견, 페이지 새로고침")
        driver.get("https://gemini.google.com/app")
    
    time.sleep(4)

# ============================================================
# JSON 파싱
# ============================================================
def extract_json(raw_text: str) -> dict:
    """응답에서 JSON 추출 (마크다운 백틱 제거)"""
    # 마크다운 코드 블록 제거 (```json ... ``` 또는 ``` ... ```)
    cleaned = re.sub(r'```(?:json)?\s*', '', raw_text)
    cleaned = cleaned.strip()
    
    # JSON 객체 패턴 추출
    json_match = re.search(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}', cleaned, re.DOTALL)
    if json_match:
        json_str = json_match.group()
        try:
            return json.loads(json_str)
        except json.JSONDecodeError as e:
            logger.warning(f"  ⚠️ JSON 파싱 실패: {e}")
            # 트레일링 콤마 제거 시도
            json_str = re.sub(r',\s*}', '}', json_str)
            json_str = re.sub(r',\s*]', ']', json_str)
            try:
                return json.loads(json_str)
            except Exception:
                pass
    
    logger.error(f"  ❌ JSON 추출 실패. 원문:\n{raw_text[:500]}")
    return None

# ============================================================
# CSV 저장
# ============================================================
def save_to_csv(data: dict, filepath: str):
    """CSV 파일에 한 줄 추가 (Append)"""
    fieldnames = [
        "날짜", "일진", "일주",
        "오늘의_바이브", "머니_주파수", "관계_플러팅",
        "럭키_부적_아이템", "오늘의_추구미"
    ]
    
    file_exists = os.path.exists(filepath)
    
    row = {
        "날짜": datetime.now().strftime("%Y-%m-%d %H:%M"),
        "일진": TODAY_ILJIN,
        "일주": data.get("일주", ""),
        "오늘의_바이브": data.get("오늘의_바이브", ""),
        "머니_주파수": data.get("머니_주파수", ""),
        "관계_플러팅": data.get("관계_플러팅", ""),
        "럭키_부적_아이템": data.get("럭키_부적_아이템", ""),
        "오늘의_추구미": data.get("오늘의_추구미", "")
    }
    
    with open(filepath, "a", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        if not file_exists:
            writer.writeheader()
        writer.writerow(row)
    
    logger.info(f"  💾 CSV 저장 완료: {data.get('일주', '?')}")

# ============================================================
# 메인 실행
# ============================================================
def main():
    logger.info("=" * 60)
    logger.info("🌟 60갑자 운세 자동생성기 v1.0")
    logger.info(f"   오늘의 일진: {TODAY_ILJIN}")
    logger.info(f"   시작 인덱스: {START_INDEX}")
    logger.info(f"   총 대상: {len(SIXTY_JIAZI) - START_INDEX}개")
    logger.info("=" * 60)
    
    driver = None
    success_count = 0
    fail_count = 0
    
    try:
        driver = create_browser()
        navigate_to_gemini(driver)
        
        # 초기 로딩 대기 (로그인 확인)
        logger.info("⏳ 초기 로딩 대기 (7초)...")
        time.sleep(7)
        
        for i, ilju in enumerate(SIXTY_JIAZI[START_INDEX:], start=START_INDEX):
            attempt = i + 1
            logger.info(f"\n{'─' * 40}")
            logger.info(f"📌 [{attempt}/60] {ilju} 운세 생성 중...")
            
            try:
                # 10개마다 새 채팅 (환각 방지)
                if i > START_INDEX and (i - START_INDEX) % NEW_CHAT_EVERY == 0:
                    start_new_chat(driver)
                
                # 프롬프트 생성 및 전송
                prompt = build_prompt(TODAY_ILJIN, ilju)
                raw_response = send_prompt(driver, prompt)
                
                # JSON 파싱
                parsed = extract_json(raw_response)
                
                if parsed:
                    save_to_csv(parsed, OUTPUT_CSV)
                    success_count += 1
                    logger.info(f"  🎉 성공! (성공: {success_count}, 실패: {fail_count})")
                else:
                    fail_count += 1
                    # 실패 시 원문 저장 (디버깅용)
                    with open("failed_responses.log", "a", encoding="utf-8") as f:
                        f.write(f"\n{'='*40}\n[{ilju}] 파싱 실패\n{raw_response}\n")
                    logger.error(f"  ❌ 파싱 실패 (성공: {success_count}, 실패: {fail_count})")
                
                # 랜덤 딜레이 (안티봇)
                if i < len(SIXTY_JIAZI) - 1:
                    delay = random.uniform(DELAY_MIN, DELAY_MAX)
                    logger.info(f"  ⏰ {delay:.1f}초 대기 (안티봇 딜레이)...")
                    time.sleep(delay)
                    
            except Exception as e:
                fail_count += 1
                logger.error(f"  ❌ 에러 발생: {e}")
                
                # 에러 시 페이지 새로고침 후 재시도 준비
                try:
                    driver.get("https://gemini.google.com/app")
                    time.sleep(5)
                except Exception:
                    pass
                
                continue
        
    except KeyboardInterrupt:
        logger.info("\n\n🛑 사용자에 의해 중단됨")
    except Exception as e:
        logger.error(f"\n💥 치명적 에러: {e}")
    finally:
        logger.info(f"\n{'=' * 60}")
        logger.info(f"📊 최종 결과: 성공 {success_count}개, 실패 {fail_count}개")
        logger.info(f"📁 저장 파일: {os.path.abspath(OUTPUT_CSV)}")
        logger.info(f"{'=' * 60}")
        
        if driver:
            input("\n🔧 브라우저를 닫으려면 Enter를 누르세요...")
            driver.quit()


if __name__ == "__main__":
    main()
