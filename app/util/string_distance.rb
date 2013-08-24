class StringDistance

  def self.match?(s1, s2, threshhold_percentage=55) # true if s1 and s2 match (loosely by default - 55% )
    return false unless (s1.present? and s2.present?)
    val1 = s1.downcase.gsub(/[^0-9a-z]/i, '') # remove non alphanumerics and compress everything
    val2 = s2.downcase.gsub(/[^0-9a-z]/i, '')
    return true if val1.eql? val2
    return true if val1.include? val2
    return true if val2.include? val1
    distance = damerau_levenshtein_distance val1, val2
    return true if threshhold_percentage > (100*distance)/[val1.length, val2.length].max
    return false
  end

  def self.damerau_levenshtein_distance(s1, s2)
    # levenshtein method from https://www.altamiracorp.com/blog/employee-posts/counting-beignets-soundex-levenshtein-or
    d = {}
    (0..s1.size).each do |row|
      d[[row, 0]] = row
    end
    (0..s2.size).each do |col|
      d[[0, col]] = col
    end
    (1..s1.size).each do |i|
      (1..s2.size).each do |j|
        cost = 0
        if (s1[i-1] != s2[j-1])
          cost = 1
        end
        d[[i, j]] = [d[[i - 1, j]] + 1,
                     d[[i, j - 1]] + 1,
                     d[[i - 1, j - 1]] + cost
        ].min
        if (i > 1 and j > 1 and s1[i-1] == s2[j-2] and s1[i-2] == s2[j-1])
          d[[i, j]] = [d[[i,j]],
                       d[[i-2, j-2]] + cost
          ].min
        end
      end
    end
    d[[s1.size, s2.size]]
  end

end