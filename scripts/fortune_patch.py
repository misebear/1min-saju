"""운세 누락 78개만 빠르게 보충 수집 (단일 브라우저, 빠른 딜레이)"""
import os, re, csv, json, time, shutil, random, logging
from datetime import datetime
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager

CHROME_USER_DATA = r"C:\Users\db019\AppData\Local\Google\Chrome\User Data"
OUTPUT_CSV = "fortune_3600_db.csv"
DELAY_MIN = 12
DELAY_MAX = 22
NEW_CHAT_EVERY = 10
MAX_WAIT = 120

SIXTY = [
    ("甲子","갑자"),("乙丑","을축"),("丙寅","병인"),("丁卯","정묘"),("戊辰","무진"),
    ("己巳","기사"),("庚午","경오"),("辛未","신미"),("壬申","임신"),("癸酉","계유"),
    ("甲戌","갑술"),("乙亥","을해"),("丙子","병자"),("丁丑","정축"),("戊寅","무인"),
    ("己卯","기묘"),("庚辰","경진"),("辛巳","신사"),("壬午","임오"),("癸未","계미"),
    ("甲申","갑신"),("乙酉","을유"),("丙戌","병술"),("丁亥","정해"),("戊子","무자"),
    ("己丑","기축"),("庚寅","경인"),("辛卯","신묘"),("壬辰","임진"),("癸巳","계사"),
    ("甲午","갑오"),("乙未","을미"),("丙申","병신"),("丁酉","정유"),("戊戌","무술"),
    ("己亥","기해"),("庚子","경자"),("辛丑","신축"),("壬寅","임인"),("癸卯","계묘"),
    ("甲辰","갑진"),("乙巳","을사"),("丙午","병오"),("丁未","정미"),("戊申","무신"),
    ("己酉","기유"),("庚戌","경술"),("辛亥","신해"),("壬子","임자"),("癸丑","계축"),
    ("甲寅","갑인"),("乙卯","을묘"),("丙辰","병진"),("丁巳","정사"),("戊午","무오"),
    ("己未","기미"),("庚申","경신"),("辛酉","신유"),("壬戌","임술"),("癸亥","계해")
]

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(message)s",
    handlers=[logging.StreamHandler(), logging.FileHandler("fortune_patch.log", encoding="utf-8")])
logger = logging.getLogger()

# 기존 수집 쌍 로드
def load_done():
    done = set()
    files = [OUTPUT_CSV] + [f for f in os.listdir('.') if f.startswith('fortune_worker_') and f.endswith('.csv')]
    for fp in files:
        if not os.path.exists(fp): continue
        try:
            with open(fp,"r",encoding="utf-8-sig") as f:
                for row in csv.DictReader(f):
                    k=(row.get("today_iljin","").strip(), row.get("user_ilju","").strip())
                    if k[0] and k[1]: done.add(k)
        except: pass
    return done

def build_prompt(iljin, ilju):
    return f"""오늘의 일진은 '{iljin}'일, 대상자의 사주 일주는 '{ilju}'일주야.
너는 2026년 틱톡/쇼츠에서 핫한 'Z세대 전담 멘탈 웰니스 코치'야. 명리학 기운을 바탕으로, 2030 세대가 인스타 스토리에 공유하고 싶어질 만큼 힙한 오늘의 운세를 작성해 줘.
[작성 가이드]
1. 금기어: '편관', '역마살' 등 낡은 한자어나 '사고주의', '손재수' 같은 재수 없는 단어 절대 금지.
2. 어휘 믹스: '도파민 파밍/디톡스', '시성비', '추구미', '럭키비키', '오히려 좋아', '억까 방어', '폼 미쳤다' 등 최신 밈을 숏폼 나레이션처럼 리듬감 있게 써.
3. 흉운 방어: 에너지가 안 좋은 날은 "멘탈 디톡스 구간이잖아"처럼 초긍정 마인드셋으로 방어.
4. 부연 설명 금지. 반드시 아래 JSON 포맷으로만 출력해.
{{
  "today_iljin": "{iljin}",
  "user_ilju": "{ilju}",
  "오늘의_바이브": "150자 내외",
  "머니_주파수": "100자 내외",
  "관계_플러팅": "100자 내외",
  "럭키_부적_아이템": "단어 1~2개",
  "오늘의_추구미": "단어 1개"
}}"""

def extract_json(raw):
    cleaned = re.sub(r'```(?:json)?\s*','',raw).strip()
    m = re.search(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}', cleaned, re.DOTALL)
    if m:
        s = m.group()
        try: return json.loads(s)
        except:
            s = re.sub(r',\s*}','}',s)
            try: return json.loads(s)
            except: pass
    return None

def main():
    done = load_done()
    missing = []
    for h,k in SIXTY:
        iljin = f"{h}({k})"
        for h2,k2 in SIXTY:
            ilju = f"{h2}({k2})"
            if (iljin, ilju) not in done:
                missing.append((iljin, ilju))

    logger.info(f"누락: {len(missing)}개")
    if not missing:
        logger.info("✅ 누락 없음!"); return

    # 브라우저
    temp = os.path.join(os.environ["TEMP"], "chrome_fortune_patch")
    if not os.path.exists(temp):
        src = os.path.join(CHROME_USER_DATA, "Default")
        os.makedirs(os.path.join(temp,"Default"), exist_ok=True)
        for f in ["Cookies","Cookies-journal","Login Data","Login Data-journal","Preferences","Secure Preferences"]:
            sp = os.path.join(src, f)
            if os.path.exists(sp):
                try: shutil.copy2(sp, os.path.join(temp,"Default",f))
                except: pass
        ls = os.path.join(CHROME_USER_DATA, "Local State")
        if os.path.exists(ls):
            try: shutil.copy2(ls, os.path.join(temp, "Local State"))
            except: pass

    opts = Options()
    opts.add_argument(f"--user-data-dir={temp}")
    opts.add_argument("--profile-directory=Default")
    opts.add_argument("--disable-blink-features=AutomationControlled")
    opts.add_experimental_option("excludeSwitches",["enable-automation"])
    opts.add_experimental_option("useAutomationExtension", False)
    opts.add_argument("--no-sandbox"); opts.add_argument("--disable-gpu")
    opts.add_argument("--remote-debugging-port=9250")
    opts.add_argument("--window-size=1200,800")

    svc = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=svc, options=opts)
    driver.execute_cdp_cmd("Page.addScriptToEvaluateOnNewDocument",
        {"source":"Object.defineProperty(navigator,'webdriver',{get:()=>undefined});"})
    driver.get("https://gemini.google.com/app")
    time.sleep(7)

    fieldnames = ["today_iljin","user_ilju","오늘의_바이브","머니_주파수","관계_플러팅","럭키_부적_아이템","오늘의_추구미","생성시각"]
    ok = 0; fail = 0

    for idx, (iljin, ilju) in enumerate(missing):
        logger.info(f"[{idx+1}/{len(missing)}] {iljin} × {ilju}")
        try:
            if ok > 0 and ok % NEW_CHAT_EVERY == 0:
                for sel in ["a[aria-label*='새 채팅']","a[aria-label*='New chat']",
                            "button[aria-label*='새 채팅']","button[aria-label*='New chat']"]:
                    try:
                        btn = driver.find_element(By.CSS_SELECTOR, sel)
                        if btn and btn.is_displayed(): btn.click(); time.sleep(4); break
                    except: continue
                else:
                    driver.get("https://gemini.google.com/app"); time.sleep(5)

            # 입력
            el = None
            for sel in ["div.ql-editor[contenteditable='true']","rich-textarea div[contenteditable='true']",
                         "div[contenteditable='true'][role='textbox']","p[data-placeholder]"]:
                try: el = WebDriverWait(driver,10).until(EC.element_to_be_clickable((By.CSS_SELECTOR,sel))); break
                except: continue
            if not el:
                el = WebDriverWait(driver,10).until(EC.element_to_be_clickable((By.XPATH,"//div[@contenteditable='true']")))
            el.click(); time.sleep(0.5)
            prompt = build_prompt(iljin, ilju)
            driver.execute_script("arguments[0].focus();arguments[0].innerText=arguments[1];arguments[0].dispatchEvent(new Event('input',{bubbles:true}));", el, prompt)
            time.sleep(1)
            for sel in ["button[aria-label*='전송']","button[aria-label*='보내기']","button[aria-label*='Send']"]:
                try:
                    btn=driver.find_element(By.CSS_SELECTOR,sel)
                    if btn and btn.is_displayed(): btn.click(); break
                except: continue
            else: el.send_keys(Keys.RETURN)
            time.sleep(3)

            # 응답 대기
            start=time.time(); last=""; stable=0
            while time.time()-start<MAX_WAIT:
                time.sleep(3); txt=""
                for sel in ["model-response .markdown","message-content .markdown","div[data-message-author-role='model']"]:
                    try:
                        els=driver.find_elements(By.CSS_SELECTOR,sel)
                        if els: txt=els[-1].text
                        if txt: break
                    except: continue
                if not txt: continue
                if txt==last and len(txt)>50: stable+=1
                else: stable=0; last=txt
                if stable>=3: break

            parsed = extract_json(last) if last else None
            if parsed:
                parsed.setdefault("today_iljin", iljin)
                parsed.setdefault("user_ilju", ilju)
                row = {fn: parsed.get(fn,"") for fn in fieldnames}
                row["생성시각"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                with open(OUTPUT_CSV, "a", newline="", encoding="utf-8-sig") as f:
                    csv.DictWriter(f, fieldnames=fieldnames).writerow(row)
                ok += 1
                logger.info(f"  ✅ ({ok}/{len(missing)})")
            else:
                fail += 1
                logger.error(f"  ❌ 파싱실패")

            delay = random.uniform(DELAY_MIN, DELAY_MAX)
            time.sleep(delay)
        except Exception as e:
            fail += 1
            logger.error(f"  ❌ {e}")
            try: driver.get("https://gemini.google.com/app"); time.sleep(5)
            except: pass

    logger.info(f"완료: ✅{ok} ❌{fail}")
    driver.quit()

if __name__ == "__main__":
    main()
