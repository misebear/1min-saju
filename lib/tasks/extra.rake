# frozen_string_literal: true

require "csv"

# 한글 CSV 읽기 공통 헬퍼
def clean_csv(csv_path)
  raw = File.read(csv_path, encoding: "bom|utf-8")
  in_quote = false
  raw.chars.map do |c|
    if c == '"'
      in_quote = !in_quote; c
    elsif in_quote && (c == "\n" || c == "\r")
      " "
    else
      c
    end
  end.join
end

namespace :extra do
  desc "띠별 운세 CSV 임포트"
  task import_tti: :environment do
    imported = 0
    files = Dir.glob(Rails.root.join("scripts", "tti_fortune_worker_*.csv")) +
            [ Rails.root.join("scripts", "tti_fortune_db.csv").to_s ]

    files.select { |f| File.exist?(f) }.each do |csv_path|
      puts "📂 #{File.basename(csv_path)}"
      CSV.parse(clean_csv(csv_path), headers: true).each do |row|
        animal = row["animal"]&.strip
        iljin = row["iljin"]&.strip
        next if animal.blank? || iljin.blank?

        rec = GeminiTtiFortune.find_or_initialize_by(animal: animal, iljin: iljin)
        rec.assign_attributes(
          headline: row["오늘의_한줄"]&.strip,
          fortune_text: row["운세_텍스트"]&.strip,
          lucky_point: row["럭키_포인트"]&.strip,
          tension_level: row["텐션_레벨"]&.strip&.to_i
        )
        rec.save! && imported += 1
      rescue => e
        puts "  ⚠️ #{e.message}" if imported < 10
      end
    end
    puts "✅ 띠별 임포트: #{imported}개 (DB: #{GeminiTtiFortune.count}개)"
  end

  desc "별자리 운세 CSV 임포트"
  task import_zodiac: :environment do
    imported = 0
    files = Dir.glob(Rails.root.join("scripts", "zodiac_fortune_worker_*.csv")) +
            [ Rails.root.join("scripts", "zodiac_fortune_db.csv").to_s ]

    files.select { |f| File.exist?(f) }.each do |csv_path|
      puts "📂 #{File.basename(csv_path)}"
      CSV.parse(clean_csv(csv_path), headers: true).each do |row|
        sign = row["sign"]&.strip
        iljin = row["iljin"]&.strip
        next if sign.blank? || iljin.blank?

        rec = GeminiZodiacFortune.find_or_initialize_by(sign: sign, iljin: iljin)
        rec.assign_attributes(
          headline: row["오늘의_한줄"]&.strip,
          fortune_text: row["운세_텍스트"]&.strip,
          lucky_point: row["럭키_포인트"]&.strip,
          tension_level: row["텐션_레벨"]&.strip&.to_i
        )
        rec.save! && imported += 1
      rescue => e
        puts "  ⚠️ #{e.message}" if imported < 10
      end
    end
    puts "✅ 별자리 임포트: #{imported}개 (DB: #{GeminiZodiacFortune.count}개)"
  end

  desc "타로 해설 CSV 임포트"
  task import_tarot: :environment do
    imported = 0
    files = Dir.glob(Rails.root.join("scripts", "tarot_reading_worker_*.csv")) +
            [ Rails.root.join("scripts", "tarot_reading_db.csv").to_s ]

    files.select { |f| File.exist?(f) }.each do |csv_path|
      puts "📂 #{File.basename(csv_path)}"
      CSV.parse(clean_csv(csv_path), headers: true).each do |row|
        card = row["card_name"]&.strip
        pos = row["position"]&.strip
        next if card.blank? || pos.blank?

        rec = GeminiTarotReading.find_or_initialize_by(card_name: card, position: pos)
        rec.assign_attributes(
          card_en: row["card_en"]&.strip,
          keyword: row["한줄_키워드"]&.strip,
          reading_text: row["해설_텍스트"]&.strip,
          advice: row["어드바이스"]&.strip,
          lucky_energy: row["럭키_에너지"]&.strip
        )
        rec.save! && imported += 1
      rescue => e
        puts "  ⚠️ #{e.message}" if imported < 10
      end
    end
    puts "✅ 타로 임포트: #{imported}개 (DB: #{GeminiTarotReading.count}개)"
  end

  desc "전체 추가 DB 임포트 (띠별 + 별자리 + 타로)"
  task import_all: [ :import_tti, :import_zodiac, :import_tarot ]

  desc "추가 DB 통계"
  task stats: :environment do
    puts "📊 추가 DB 통계"
    puts "  🐲 띠별: #{GeminiTtiFortune.count}/720 (#{(GeminiTtiFortune.count.to_f/720*100).round(1)}%)"
    puts "  ⭐ 별자리: #{GeminiZodiacFortune.count}/720 (#{(GeminiZodiacFortune.count.to_f/720*100).round(1)}%)"
    puts "  🃏 타로: #{GeminiTarotReading.count}/156 (#{(GeminiTarotReading.count.to_f/156*100).round(1)}%)"
  end
end
