"""
궁합 수집 완료 감지 → 추가 DB (띠별+별자리+타로) 매크로 자동 시작
"""
import os
import csv
import time
import subprocess
import sys

COMPAT_CSV = "compat_3600_db.csv"
COMPAT_WORKERS = [f"compat_worker_{i}.csv" for i in range(5)]
TARGET = 3600

def count_compat():
    total = 0
    for fp in [COMPAT_CSV] + COMPAT_WORKERS:
        if os.path.exists(fp):
            try:
                with open(fp, "r", encoding="utf-8-sig") as f:
                    total += max(0, len(list(csv.reader(f))) - 1)
            except: pass
    return total

print("🔍 궁합 수집 완료 감지 중... (30초마다 확인)")

while True:
    total = count_compat()
    pct = total / TARGET * 100
    print(f"  💕 궁합: {total}/{TARGET} ({pct:.1f}%)")

    if total >= TARGET * 0.98:
        print(f"\n🎉 궁합 수집 거의 완료! ({total}/{TARGET})")
        print("\n🌟 추가 DB 매크로 시작 대기 (30초)...")
        time.sleep(30)

        print("🚀 추가 DB 매크로 (띠별+별자리+타로) 시작!")
        subprocess.Popen(
            [sys.executable, "extra_db_parallel.py"],
            cwd=os.path.dirname(os.path.abspath(__file__))
        )
        print("✅ 추가 DB 매크로 프로세스 시작됨!")
        break

    time.sleep(30)
