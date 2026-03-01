# frozen_string_literal: true

# Gemini API 서비스 (Google AI Studio 무료 Tier)
# 사주 분석 결과를 컨텍스트로 전달하여 AI 심층 해석을 제공
class GeminiService
  API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

  def initialize
    @api_key = ENV["GEMINI_API_KEY"]
  end

  def available?
    @api_key.present?
  end

  # 사주 기반 AI 심층 해석
  def analyze_saju(question, analysis)
    return nil unless available?

    context = build_saju_context(analysis)

    prompt = <<~PROMPT
      너는 '1분 사주'라는 한국 사주풀이 앱의 AI 상담사야.
      사주 분석 결과를 바탕으로 사용자의 질문에 친근하고 따뜻하게 답해줘.
      이모지를 적절히 사용하고, 한국어로 대답해.
      전문적이지만 쉽게 풀어서 설명해줘.
      답변은 3-5문장으로 간결하게 해줘.

      [사주 분석 결과]
      #{context}

      [사용자 질문]
      #{question}
    PROMPT

    call_api(prompt)
  end

  # 꿈해몽 AI 심층 해석
  def analyze_dream(dream_text, basic_result)
    return nil unless available?

    prompt = <<~PROMPT
      너는 한국 전통 꿈해몽 전문가야.
      사용자의 꿈 내용과 기본 해석 결과를 바탕으로 더 깊은 해석을 해줘.
      친근하고 따뜻한 말투로, 이모지를 사용해서 답해줘.
      답변은 3-4문장으로 간결하게 해줘.

      [꿈 내용]
      #{dream_text}

      [기본 해석]
      점수: #{basic_result[:overall_score]}점
      카테고리: #{basic_result[:category]}
      메시지: #{basic_result[:overall_message]}
    PROMPT

    call_api(prompt)
  end

  private

  def build_saju_context(analysis)
    saju = analysis[:saju]
    lines = []
    lines << "일간: #{saju[:day][:stem]} (#{SajuEngine::HeavenlyStems.element(saju[:day][:stem])})"
    lines << "오행분포: #{saju[:distribution].map { |k, v| "#{k}(#{v})" }.join(', ')}"
    lines << "성격: #{analysis[:personality]}"
    lines << "직업: #{analysis[:career]}"
    lines << "연애: #{analysis[:love]}"

    if analysis[:daily_fortune]
      lines << "오늘의 운세 점수: #{analysis[:daily_fortune][:score]}점"
      lines << "오늘의 십성: #{analysis[:daily_fortune][:ten_god]}"
    end

    lines.join("\n")
  end

  def call_api(prompt)
    uri = URI("#{API_URL}?key=#{@api_key}")

    body = {
      contents: [ { parts: [ { text: prompt } ] } ],
      generationConfig: {
        temperature: 0.8,
        maxOutputTokens: 500,
        topP: 0.9
      }
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 15
    http.open_timeout = 10

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = body.to_json

    response = http.request(request)

    if response.code == "200"
      data = JSON.parse(response.body)
      text = data.dig("candidates", 0, "content", "parts", 0, "text")
      text&.strip
    else
      Rails.logger.error("[GeminiService] API 호출 실패: #{response.code} - #{response.body}")
      nil
    end
  rescue StandardError => e
    Rails.logger.error("[GeminiService] 에러: #{e.message}")
    nil
  end
end
