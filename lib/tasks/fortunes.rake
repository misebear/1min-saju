# frozen_string_literal: true

require "csv"

namespace :fortunes do
  desc "CSV에서 Gemini 운세 데이터를 DB로 임포트 (upsert)"
  task import: :environment do
    csv_path = Rails.root.join("scripts", "fortune_3600_db.csv")

    unless File.exist?(csv_path)
      puts "❌ CSV 파일이 없습니다: #{csv_path}"
      exit 1
    end

    puts "📂 CSV 로딩: #{csv_path}"

    # BOM 제거 + 줄바꿈 포함 텍스트 대응 (따옴표 안의 줄바꿈을 공백으로 치환)
    raw = File.read(csv_path, encoding: "bom|utf-8")
    in_quote = false
    cleaned = raw.chars.map do |c|
      if c == '"'
        in_quote = !in_quote
        c
      elsif in_quote && (c == "\n" || c == "\r")
        " "
      else
        c
      end
    end.join

    rows = CSV.parse(cleaned, headers: true)
    total = rows.size
    imported = 0
    skipped = 0
    errors = 0

    puts "📊 총 #{total}개 행 발견"

    rows.each_with_index do |row, idx|
      begin
        # CSV 컬럼명 매핑
        iljin = row["today_iljin"]&.strip
        ilju = row["user_ilju"]&.strip
        vibe = row["오늘의_바이브"]&.strip
        money = row["머니_주파수"]&.strip
        relationship = row["관계_플러팅"]&.strip
        lucky_item = row["럭키_부적_아이템"]&.strip
        style = row["오늘의_추구미"]&.strip

        # 필수 필드 체크
        if iljin.blank? || ilju.blank? || vibe.blank?
          skipped += 1
          next
        end

        # upsert (있으면 업데이트, 없으면 생성)
        fortune = GeminiFortune.find_or_initialize_by(
          today_iljin: iljin,
          user_ilju: ilju
        )
        fortune.assign_attributes(
          vibe: vibe,
          money: money,
          relationship: relationship,
          lucky_item: lucky_item,
          style: style
        )
        fortune.save!
        imported += 1

        # 진행률 표시 (200개마다)
        if (idx + 1) % 200 == 0
          pct = ((idx + 1).to_f / total * 100).round(1)
          puts "  ⏳ #{idx + 1}/#{total} (#{pct}%) - 임포트: #{imported}, 스킵: #{skipped}"
        end
      rescue => e
        errors += 1
        puts "  ⚠️ 행 #{idx + 1} 에러: #{e.message}" if errors <= 10
      end
    end

    puts ""
    puts "✅ 임포트 완료!"
    puts "   📥 임포트: #{imported}개"
    puts "   ⏭️  스킵: #{skipped}개"
    puts "   ❌ 에러: #{errors}개"
    puts "   📊 DB 총: #{GeminiFortune.count}개"
  end

  desc "DB에 저장된 운세 통계 확인"
  task stats: :environment do
    total = GeminiFortune.count
    iljin_count = GeminiFortune.distinct.count(:today_iljin)
    ilju_count = GeminiFortune.distinct.count(:user_ilju)

    puts "📊 Gemini 운세 DB 통계"
    puts "   총 레코드: #{total}개"
    puts "   일진 종류: #{iljin_count}개 / 60"
    puts "   일주 종류: #{ilju_count}개 / 60"
    puts "   완성률: #{(total.to_f / 3600 * 100).round(1)}%"
  end
end
