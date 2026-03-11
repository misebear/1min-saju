require 'time'
require 'set'

File.open('railway_logs_large.txt', 'r', encoding: 'UTF-8') do |f|
  # data[date] = {
  #   ips: Set.new,
  #   saju_view_ips: Set.new,
  #   path_counts: Hash.new(0)
  # }
  daily_data = Hash.new { |h, k| h[k] = { ips: Set.new, saju_view_ips: Set.new, path_counts: Hash.new(0) } }

  # To map request UUID to IP and path
  requests = {}

  f.each_line do |line|
    # Example format:
    # [uuid] Started GET "/" for 12.34.56.78 at 2026-03-10 02:03:47 +0000
    if line =~ /\[([a-f0-9\-]+)\] Started ([A-Z]+) "([^"]+)" for ([\d\.]+) at ([\d\-:\s\+]+)/
      req_id = $1
      method = $2
      path = $3
      ip = $4
      time_str = $5

      begin
        # Parse time and convert to KST (+9 hours)
        time_utc = Time.parse(time_str)
        time_kst = time_utc + (9 * 3600)
        date_kst = time_kst.strftime("%Y-%m-%d")

        requests[req_id] = { ip: ip, path: path, date: date_kst, method: method }

        daily_data[date_kst][:ips].add(ip)

        # Checking actual paths related to viewing results (Saju, Compatibility, Fortune, etc.)
        if path.start_with?("/saju") && method == "POST"
          daily_data[date_kst][:saju_view_ips].add(ip)
        end
        if path.start_with?("/saju/result")
          daily_data[date_kst][:saju_view_ips].add(ip)
        end

        daily_data[date_kst][:path_counts][path] += 1
      rescue => e
        # Ignore parse errors
      end
    end
  end

  puts "=== 일별 서버 접속 및 사주 조회 통계 ==="
  daily_data.keys.sort.each do |date|
    stats = daily_data[date]
    puts "\n[#{date}] 방문자(Unique IP): #{stats[:ips].size}명"
    puts "  -> 실제로 사주/운세를 본 사람(Unique IP): #{stats[:saju_view_ips].size}명"

    # top 5 paths
    top_paths = stats[:path_counts].sort_by { |_, count| -count }.first(5)
    puts "  -> 주요 요청 경로:"
    top_paths.each do |p, c|
      puts "      #{p}: #{c}회"
    end
  end
  puts "\n====================================="
end
