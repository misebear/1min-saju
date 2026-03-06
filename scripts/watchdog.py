"""
매크로 감시견 🐕 - 30분마다 매크로 상태 확인 + 자동 재시작
"""
import os
import sys
import time
import subprocess
from datetime import datetime, timedelta

SCRIPTS_DIR = r"c:\development\saju\scripts"
CSV_PATH = os.path.join(SCRIPTS_DIR, "fortune_3600_db.csv")
MACRO_SCRIPT = "gemini_3600_rpa.py"
CHECK_INTERVAL = 30 * 60  # 30분 (초)
STALE_THRESHOLD = 20 * 60  # 20분 이상 새 데이터 없으면 멈춤으로 판단

def get_csv_count():
    """CSV 줄 수 (헤더 제외)"""
    try:
        with open(CSV_PATH, "r", encoding="utf-8-sig") as f:
            return sum(1 for _ in f) - 1
    except:
        return 0

def get_last_csv_time():
    """CSV 마지막 줄의 생성시각 파싱"""
    try:
        with open(CSV_PATH, "r", encoding="utf-8-sig") as f:
            lines = f.readlines()
            if len(lines) < 2:
                return None
            last = lines[-1].strip()
            # 마지막 컬럼이 생성시각 (YYYY-MM-DD HH:MM:SS)
            time_str = last.split(",")[-1].strip()
            return datetime.strptime(time_str, "%Y-%m-%d %H:%M:%S")
    except:
        return None

def is_python_macro_running():
    """gemini_3600_rpa.py 프로세스 실행 중인지 확인"""
    try:
        result = subprocess.run(
            ["powershell", "-Command",
             "Get-Process python -ErrorAction SilentlyContinue | Select-Object Id"],
            capture_output=True, text=True, timeout=10
        )
        return "python" in result.stdout.lower() or any(c.isdigit() for c in result.stdout)
    except:
        return False

def kill_and_restart():
    """매크로 프로세스 종료 + 재시작"""
    print(f"  🔄 매크로 재시작 중...")

    # 기존 프로세스 종료
    subprocess.run(["powershell", "-Command",
        "Get-Process python -ErrorAction SilentlyContinue | Stop-Process -Force"],
        capture_output=True, timeout=10)
    subprocess.run(["powershell", "-Command",
        "Get-Process chrome* -ErrorAction SilentlyContinue | Stop-Process -Force"],
        capture_output=True, timeout=10)
    time.sleep(3)

    # 임시 프로필 삭제
    temp_profile = os.path.join(os.environ["TEMP"], "chrome_gemini_3600")
    subprocess.run(["powershell", "-Command",
        f'Remove-Item "{temp_profile}" -Recurse -Force -ErrorAction SilentlyContinue'],
        capture_output=True, timeout=10)
    time.sleep(2)

    # 매크로 재시작 (새 프로세스로)
    subprocess.Popen(
        [sys.executable, MACRO_SCRIPT],
        cwd=SCRIPTS_DIR,
        creationflags=subprocess.CREATE_NEW_PROCESS_GROUP
    )
    print(f"  ✅ 매크로 재시작 완료!")

def main():
    print("=" * 50)
    print("🐕 매크로 감시견 시작!")
    print(f"   체크 주기: {CHECK_INTERVAL // 60}분")
    print(f"   멈춤 판단: {STALE_THRESHOLD // 60}분 이상 새 데이터 없으면")
    print("=" * 50)

    last_known_count = get_csv_count()

    while True:
        now = datetime.now()
        count = get_csv_count()
        last_time = get_last_csv_time()
        pct = count / 3600 * 100

        print(f"\n⏰ [{now.strftime('%H:%M:%S')}] 체크!")
        print(f"   📊 수집: {count}/3,600 ({pct:.1f}%)")

        if count >= 3600:
            print(f"   🎉🎉🎉 3,600개 수집 완료! 감시 종료!")
            break

        if last_time:
            elapsed = (now - last_time).total_seconds()
            print(f"   🕐 마지막 수집: {last_time.strftime('%H:%M:%S')} ({elapsed/60:.0f}분 전)")

            if elapsed > STALE_THRESHOLD:
                print(f"   ⚠️ {STALE_THRESHOLD//60}분 넘게 새 데이터 없음! → 재시작")
                kill_and_restart()
            else:
                new_since = count - last_known_count
                print(f"   ✅ 정상 작동 중 (+{new_since}개 신규)")
        else:
            # 시각 파싱 실패 시 프로세스 존재 여부로 판단
            if not is_python_macro_running():
                print(f"   ⚠️ Python 프로세스 없음! → 재시작")
                kill_and_restart()
            else:
                print(f"   ℹ️ 시각 파싱 실패, 프로세스는 실행 중")

        last_known_count = count

        # 30분 대기
        print(f"   💤 다음 체크: {(now + timedelta(seconds=CHECK_INTERVAL)).strftime('%H:%M:%S')}")
        time.sleep(CHECK_INTERVAL)

if __name__ == "__main__":
    main()
