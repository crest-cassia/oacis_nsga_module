module Mutation
  # @myu = 0.5

  # 
  def self.set_rate(myu=0.01, eta=15)
    @myu = myu
    @eta = eta
  end

  def self.mutate(chrom, random)
    chrom.size.times.each{|i|
      if random.rand < @myu
        if chrom[i] == 0
          chrom[i] = 1
        else
          chrom[i] = 0
        end
      end
    }

    return chrom
  end

  def self.polynomial_mutation(chrom, ranges, random)
    j = chrom.length*random.rand
    tmp = chrom.clone
    chrom.size.times.each{|i|
      if random.rand < @myu
        tmp[i] = pm_mute(chrom[i], ranges[i], random)
      end
    }
    return tmp
  end

  def self.multi_variable_mutate(chrom, ranges, random)
    j = chrom.length*random.rand
    tmp = chrom.clone
    chrom.size.times.each{|i|
      if random.rand < @myu
        if chrom[i].class == String
          tmp[i] = multi_label_mute(chrom[i], ranges[i], random)
        elsif chrom[i].class == Float
          tmp[i] = pm_mute(chrom[i], ranges[i], random)
        else # binary
          if chrom[i] == 0
            chrom[i] = 1
          else
            chrom[i] = 0
          end
        end
      end
    }
    return tmp
  end

  private
  def self.pm_mute(x, range, random)

    lb, ub = range.min, range.max
    dx = ub - lb
    delta = 0.0

    u = random.rand

    if u < 0.5
      bl = (x - lb)/dx
      b = 2.0*u + (1.0 - 2.0*u)*((1.0 - bl)**(@eta + 1.0))
      delta = b**(1.0/(@eta+1.0)) - 1.0
    else
      bu = (ub - x)/dx
      b = 2.0*(1.0-u)+2.0*(u-0.5)*((1.0-bu)**(@eta+1.0))
      delta = 1.0 - b**(1.0/(@eta+1))
    end
    
    mx = x + delta*dx

    if mx < lb
      mx = lb
    elsif ub < x
      mx = ub
    end
    
    return mx
  end

  def self.multi_label_mute(x, range, random)
    return (range - [x]).sample(random: random)
  end
end

def debug
  require 'pry'
  include Mutation
  Mutation.set_rate

  # a = [0,0,0,0,0,0,0,0,0,0]
  # b = [1,1,1,1,1,1,1,1,1,1]
  rand = Random.new(0)
  labels = ["hoge","fuga","bar","aaa","bbb","ccc","ddd"]

  a = 3.times.map{rand.rand} + 3.times.map{labels.sample} + 3.times.map{rand.rand}
  b = 3.times.map{rand.rand} + 3.times.map{labels.sample} + 3.times.map{rand.rand}
  
  ranges = 3.times.map{ [0.0, 1.0] } + 3.times.map{ labels} + 3.times.map{ [0.0, 1.0] }
  # binding.pry

  a2 = Mutation.multi_variable_mutate(a, ranges, rand)
  binding.pry
end

if __FILE__ == $0
  debug
end