require_relative '../target'

class ZDT4 < Target
  # average
  def fitness(ps)
    tmp = {}
    ps.runs.each{|r|
      @objectives.each{|k|
        tmp[k] ||= []
        tmp[k] << r.result[k]
      }      
    }
    fitness = @objectives.map{|k| tmp[k].inject(:+)/tmp[k].size.to_f }
  end
end
