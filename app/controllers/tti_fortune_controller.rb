# 띠운세 컨트롤러
class TtiFortuneController < ApplicationController
  TTI_DATA = {
    "자" => { name: "쥐띠", emoji: "🐭", years: "1936, 1948, 1960, 1972, 1984, 1996, 2008, 2020" },
    "축" => { name: "소띠", emoji: "🐮", years: "1937, 1949, 1961, 1973, 1985, 1997, 2009, 2021" },
    "인" => { name: "호랑이띠", emoji: "🐯", years: "1938, 1950, 1962, 1974, 1986, 1998, 2010, 2022" },
    "묘" => { name: "토끼띠", emoji: "🐰", years: "1939, 1951, 1963, 1975, 1987, 1999, 2011, 2023" },
    "진" => { name: "용띠", emoji: "🐲", years: "1940, 1952, 1964, 1976, 1988, 2000, 2012, 2024" },
    "사" => { name: "뱀띠", emoji: "🐍", years: "1941, 1953, 1965, 1977, 1989, 2001, 2013, 2025" },
    "오" => { name: "말띠", emoji: "🐴", years: "1942, 1954, 1966, 1978, 1990, 2002, 2014, 2026" },
    "미" => { name: "양띠", emoji: "🐑", years: "1943, 1955, 1967, 1979, 1991, 2003, 2015" },
    "신" => { name: "원숭이띠", emoji: "🐵", years: "1944, 1956, 1968, 1980, 1992, 2004, 2016" },
    "유" => { name: "닭띠", emoji: "🐔", years: "1945, 1957, 1969, 1981, 1993, 2005, 2017" },
    "술" => { name: "개띠", emoji: "🐶", years: "1946, 1958, 1970, 1982, 1994, 2006, 2018" },
    "해" => { name: "돼지띠", emoji: "🐷", years: "1947, 1959, 1971, 1983, 1995, 2007, 2019" }
  }

  def show
    branches = %w[자 축 인 묘 진 사 오 미 신 유 술 해]
    today = Date.today
    seed = today.year * 31 + today.month * 37 + today.day * 41

    @tti_fortunes = branches.map.with_index do |branch, i|
      data = TTI_DATA[branch]
      s = (seed + i * 13) % 100
      score = [s + 30, 100].min
      fortune = tti_fortune(s, data[:name])
      { branch: branch, data: data, score: score, fortune: fortune }
    end
    @date = today
  end

  private

  def tti_fortune(seed, name)
    fortunes = [
      "오늘은 좋은 소식이 찾아오는 날! 적극적으로 행동하면 큰 성과를 얻을 수 있어요.",
      "인간관계에서 행운이 있어요. 주변 사람과의 소통을 늘려보세요.",
      "재물운이 좋은 날! 예상치 못한 수입이 있을 수 있어요.",
      "건강관리에 신경 쓰세요. 가벼운 운동이 큰 도움이 됩니다.",
      "새로운 시작에 좋은 날! 미뤄왔던 일을 시작해보세요.",
      "침착하게 행동하면 좋은 결과가 있어요. 급한 결정은 피하세요.",
      "학업/업무에서 좋은 아이디어가 떠오르는 날! 메모해두세요.",
      "사랑운이 좋은 날! 솔직한 고백이 좋은 결과를 만들어요.",
      "여행운이 좋아요. 가까운 곳이라도 나가보면 기분 전환이 돼요.",
      "오늘은 쉬어가는 날. 무리하지 말고 충분히 쉬세요.",
      "리더십을 발휘할 기회가 와요. 자신감을 가지세요!",
      "감사하는 마음으로 하루를 보내면 더 큰 복이 찾아와요."
    ]
    fortunes[seed % fortunes.size]
  end
end
