module NonDominateSort

  def self.ranks(fitnesses)
    ranks = Array.new(fitnesses.size, nil)

    rank = 1
    while ranks.any? {|r| r.nil? }
      non_ranked_indexes = []
      ranks.each_with_index {|rank,i| non_ranked_indexes << i if rank.nil? }
      dominating_indexes = select_dominating_among_non_ranked( fitnesses, non_ranked_indexes )
      dominating_indexes.each do |idx|
        ranks[idx] = rank
      end
      rank += 1
    end
    ranks
  end

  def self.select_dominating_among_non_ranked( fitness, non_ranked_indexes )
    non_ranked_fs = non_ranked_indexes.map {|idx| fitness[idx] }

    dominating = []
    fitness.each_with_index do |f,idx|
      next unless non_ranked_indexes.include?(idx)
      dominated = non_ranked_fs.any? do |other_f|
        next if f == other_f
        check_dominance(other_f,f)
      end
      dominating << idx if !dominated
    end
    dominating
  end

  private

  # true if a dominates b
  # false otherwise
  def self.check_dominance(fa, fb)
    fa.size.times do |i|
      return false if (fa[i] > fb[i])
    end
    true
  end
end


def debug
  fit_list = [
    #[0,0],
    [1,2],
    [3,1],
    [2,3],
    [4,2],
    [0,4],
    [6,2],
    [6,0],
    [4,4],
    [1,5],
    [3,5],
    [5,4]
  ]

  ranks = NonDominateSort.ranks(fit_list)

  fit_list.size.times do |i|
    puts "#{fit_list[i].inspect}: #{ranks[i]}"
  end
  
end

if __FILE__ == $0
  require 'pry'

  debug

end
