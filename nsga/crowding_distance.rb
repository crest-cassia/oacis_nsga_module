module CrowdingDistance

  # 
  def self.distances(fitnesses)
    distances = Array.new(fitnesses.size, 0.0) 

    f_id_ary = fitnesses.each_with_index.map {|f,i| [f,i] }
    f_dim = fitnesses[0].size
    f_dim.times do |d|
      sorted = f_id_ary.sort_by {|f,i| f[d] }
      
      min_f = sorted.first[0][d]
      max_f = sorted.last[0][d]
      next if min_f == max_f
      sorted.each.with_index do |(f,id), i|
        if i == 0 || i == sorted.size-1
          distances[id] = Float::MAX
        else
          cd = (sorted[i+1][0][d] - sorted[i-1][0][d]).abs.to_f / (max_f - min_f)
          distances[id] += cd
        end
      end
    end
    distances
  end

end

def debug
  require_relative 'non_dominate_sort'
  fit_list = [
    [1.0,2.0],
    [3.0,1.0],
    [2.0,3.0],
    [4.0,2.0],
    [0.0,4.0],
    [6.0,2.0],
    [6.0,0.0],
    [4.0,4.0],
    [1.0,5.0],
    [3.0,5.0],
    [5.0,4.0],
    [5.0,4.0],
    [7.0,1.0]
  ]

  # NonDominateSort.sort(set, [:max, :max])
  ranks = NonDominateSort.ranks(fit_list)
  rank1_fs = []
  fit_list.size.times do |i|
    rank1_fs << fit_list[i] if ranks[i] == 1
  end
  ds = CrowdingDistance.distances(rank1_fs)

  rank1_fs.size.times do |i|
    puts "#{rank1_fs[i].inspect} : #{ds[i]}"
  end
end


if __FILE__ == $0
  require 'pry'

  debug
end
