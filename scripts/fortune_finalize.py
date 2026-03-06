"""운세 DB 누락분 분석 + 잔여 워커 CSV 병합"""
import csv, os

MAIN = "fortune_3600_db.csv"
SIXTY = [
    "甲子(갑자)","乙丑(을축)","丙寅(병인)","丁卯(정묘)","戊辰(무진)",
    "己巳(기사)","庚午(경오)","辛未(신미)","壬申(임신)","癸酉(계유)",
    "甲戌(갑술)","乙亥(을해)","丙子(병자)","丁丑(정축)","戊寅(무인)",
    "己卯(기묘)","庚辰(경진)","辛巳(신사)","壬午(임오)","癸未(계미)",
    "甲申(갑신)","乙酉(을유)","丙戌(병술)","丁亥(정해)","戊子(무자)",
    "己丑(기축)","庚寅(경인)","辛卯(신묘)","壬辰(임진)","癸巳(계사)",
    "甲午(갑오)","乙未(을미)","丙申(병신)","丁酉(정유)","戊戌(무술)",
    "己亥(기해)","庚子(경자)","辛丑(신축)","壬寅(임인)","癸卯(계묘)",
    "甲辰(갑진)","乙巳(을사)","丙午(병오)","丁未(정미)","戊申(무신)",
    "己酉(기유)","庚戌(경술)","辛亥(신해)","壬子(임자)","癸丑(계축)",
    "甲寅(갑인)","乙卯(을묘)","丙辰(병진)","丁巳(정사)","戊午(무오)",
    "己未(기미)","庚申(경신)","辛酉(신유)","壬戌(임술)","癸亥(계해)"
]

# 모든 CSV에서 수집된 쌍 취합
done = set()
all_files = [MAIN]
for i in range(5):
    for suffix in [f"fortune_worker_{i}.csv", f"fortune_worker_{i}_merged.csv"]:
        if os.path.exists(suffix):
            all_files.append(suffix)

for fp in all_files:
    if not os.path.exists(fp): continue
    with open(fp, "r", encoding="utf-8-sig") as f:
        for row in csv.DictReader(f):
            k = (row.get("today_iljin","").strip(), row.get("user_ilju","").strip())
            if k[0] and k[1]: done.add(k)

print(f"총 유니크 쌍: {len(done)}/3600")

# 잔여 워커 CSV를 메인에 병합
fieldnames = ["today_iljin","user_ilju","오늘의_바이브","머니_주파수","관계_플러팅","럭키_부적_아이템","오늘의_추구미","생성시각"]
merged = 0
for i in range(5):
    wp = f"fortune_worker_{i}.csv"
    if os.path.exists(wp):
        with open(wp, "r", encoding="utf-8-sig") as rf:
            rows = list(csv.DictReader(rf))
            if rows:
                with open(MAIN, "a", newline="", encoding="utf-8-sig") as wf:
                    writer = csv.DictWriter(wf, fieldnames=fieldnames)
                    for row in rows:
                        writer.writerow(row)
                        merged += 1
        os.remove(wp)
        print(f"  워커{i} 잔여 {len(rows)}개 병합 후 삭제")

print(f"병합 완료: {merged}개")

# 누락 분석
missing = []
for iljin in SIXTY:
    for ilju in SIXTY:
        if (iljin, ilju) not in done:
            missing.append((iljin, ilju))

from collections import Counter
if missing:
    iljin_miss = Counter(m[0] for m in missing)
    print(f"\n누락: {len(missing)}개")
    print("누락 일진별:")
    for ij, cnt in iljin_miss.most_common():
        print(f"  {ij}: {cnt}개")
else:
    print("\n✅ 누락 없음! 3,600개 완전 수집!")
