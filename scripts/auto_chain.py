"""
운세 수집 완료 감지 → 운세 CSV 병합 → 궁합 매크로 자동 시작
"""
import os
import csv
import time
import subprocess
import sys

FORTUNE_MAIN = "fortune_3600_db.csv"
FORTUNE_WORKERS = [f"fortune_worker_{i}.csv" for i in range(5)]
TARGET = 3600

def count_fortune_total():
    """운세 메인 + 워커 CSV 합계"""
    total = 0
    for fp in [FORTUNE_MAIN] + FORTUNE_WORKERS:
        if os.path.exists(fp):
            try:
                with open(fp, "r", encoding="utf-8-sig") as f:
                    total += max(0, len(list(csv.reader(f))) - 1)
            except:
                pass
    return total

def merge_fortune_workers():
    """워커 CSV를 메인 CSV로 병합"""
    fieldnames = [
        "today_iljin", "user_ilju",
        "오늘의_바이브", "머니_주파수", "관계_플러팅",
        "럭키_부적_아이템", "오늘의_추구미", "생성시각"
    ]
    merged = 0
    for wp in FORTUNE_WORKERS:
        if not os.path.exists(wp):
            continue
        try:
            with open(wp, "r", encoding="utf-8-sig") as rf:
                reader = csv.DictReader(rf)
                with open(FORTUNE_MAIN, "a", newline="", encoding="utf-8-sig") as wf:
                    writer = csv.DictWriter(wf, fieldnames=fieldnames)
                    for row in reader:
                        writer.writerow(row)
                        merged += 1
            os.rename(wp, wp.replace(".csv", "_merged.csv"))
        except Exception as e:
            print(f"  병합 에러: {e}")
    print(f"✅ 운세 워커 CSV 병합 완료: {merged}개")
    return merged

print("🔍 운세 수집 완료 감지 중... (30초마다 확인)")

while True:
    total = count_fortune_total()
    pct = total / TARGET * 100
    print(f"  📊 운세: {total}/{TARGET} ({pct:.1f}%)")

    if total >= TARGET * 0.98:  # 98% 이상이면 완료로 판단
        print(f"\n🎉 운세 수집 거의 완료! ({total}/{TARGET})")
        print("📝 워커 CSV 병합 시작...")
        merge_fortune_workers()

        print("\n💕 궁합 매크로 시작 대기 (30초)...")
        time.sleep(30)

        print("🚀 궁합 매크로 시작!")
        subprocess.Popen(
            [sys.executable, "compat_parallel.py"],
            cwd=os.path.dirname(os.path.abspath(__file__))
        )
        print("✅ 궁합 매크로 프로세스 시작됨!")
        break

    time.sleep(30)
