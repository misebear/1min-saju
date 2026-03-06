# frozen_string_literal: true

require "csv"

namespace :compatibility do
  desc "CSV에서 Gemini 궁합 데이터를 DB로 임포트 (upsert)"
  task import: :environment do
    # 메인 CSV + 워커 CSV 모두 임포트
    csv_files = []
    main_csv = Rails.root.join("scripts", "compat_3600_db.csv")
    csv_files << main_csv if File.exist?(main_csv)

    # 워커별 CSV도 확인
    (0..4).each do |i|
      worker_csv = Rails.root.join("scripts", "compat_worker_#{i}.csv")
      csv_files << worker_csv if File.exist?(worker_csv)
    end

    if csv_files.empty?
      puts "❌ 궁합 CSV 파일이 없습니다"
      exit 1
    end

    imported = 0
    skipped = 0
    errors = 0

    csv_files.each do |csv_path|
      puts "📂 CSV 로딩: #{csv_path}"

      raw = File.read(csv_path, encoding: "bom|utf-8")
      # 따옴표 안의 줄바꿈을 공백으로 치환
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
      puts "  📊 #{rows.size}개 행"

      rows.each_with_index do |row, idx|
        begin
          ilju_a = row["ilju_a"]&.strip
          ilju_b = row["ilju_b"]&.strip
          score = row["케미_점수"]&.strip&.to_i
          chem_type = row["케미_타입"]&.strip
          analysis = row["종합_분석"]&.strip
          dating = row["연애_스타일"]&.strip
          caution = row["주의_포인트"]&.strip
          lucky = row["럭키_데이트"]&.strip

          if ilju_a.blank? || ilju_b.blank? || analysis.blank?
            skipped += 1
            next
          end

          compat = GeminiCompatibility.find_or_initialize_by(
            ilju_a: ilju_a,
            ilju_b: ilju_b
          )
          compat.assign_attributes(
            chemistry_score: score,
            chemistry_type: chem_type,
            analysis: analysis,
            dating_style: dating,
            caution_point: caution,
            lucky_date: lucky
          )
          compat.save!
          imported += 1

          if (imported) % 200 == 0
            puts "  ⏳ 임포트 #{imported}개 완료..."
          end
        rescue => e
          errors += 1
          puts "  ⚠️ 에러: #{e.message}" if errors <= 10
        end
      end
    end

    puts ""
    puts "✅ 궁합 임포트 완료!"
    puts "   📥 임포트: #{imported}개"
    puts "   ⏭️  스킵: #{skipped}개"
    puts "   ❌ 에러: #{errors}개"
    puts "   📊 DB 총: #{GeminiCompatibility.count}개"
  end

  desc "궁합 DB 통계 확인"
  task stats: :environment do
    total = GeminiCompatibility.count
    a_count = GeminiCompatibility.distinct.count(:ilju_a)
    b_count = GeminiCompatibility.distinct.count(:ilju_b)

    puts "💕 Gemini 궁합 DB 통계"
    puts "   총 레코드: #{total}개"
    puts "   일주A 종류: #{a_count}개 / 60"
    puts "   일주B 종류: #{b_count}개 / 60"
    puts "   완성률: #{(total.to_f / 3600 * 100).round(1)}%"
  end
end
