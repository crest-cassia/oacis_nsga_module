module CrossOver

  # 
  def self.set_rate(eta=15,f=0.5)
    @eta = eta
    @scale_factor = f # (0<F<2)
  end

  def self.n_point(a, b, n=1, random)
    if a.size < n || b.size < n
      raise "ERROR: Point Size N is over gene length !!"
    end

    points = (1..(a.size-(n-1))).to_a.sample(n, random: random).sort
    points.push(a.size)

    p swap_range = points.each_slice(2).to_a.select{|ary| ary.size > 1}
    
    swap_range.each{|r|
      a[r[0]..r[1]], b[r[0]..r[1]] = b[r[0]..r[1]], a[r[0]..r[1]]
    }

    return a, b
  end

  # simulated binary crossover
  def self.sbx(a, b, ranges, random)
    a.size.times.each{|i|
      x1, x2 = sbx_asymmetric(a[i], b[i], ranges[i].min, ranges[i].max, random)
      # swap
      if random.rand < 0.5
        a[i] = x1
        b[i] = x2
      else
        a[i] = x2
        b[i] = x1
      end
    }
    return a, b
  end

  def self.sbx_symmetric(x1, x2, lb, ub, random)
    return x1, x2 if (x1-x2).abs < 1.0e-14

    alpha, beta, betaq = 0.0, 0.0, 0.0

    # must be v1 < v2 
    if x1 < x2
      v1 = x1
      v2 = x2
    else
      v1 = x2
      v2 = x1
    end

    ###
    # beta
    if (v1 - lb) > (ub - v2)
      beta = 1.0 + ( 2*(ub-v2) / (v2-v1) )
    else
      beta = 1.0 + ( 2*(v1-lb) / (v2-v1) )
    end

    # alpha
    beta = 1.0/ beta
    alpha = 2.0 - beta**(@eta+1.0)
    r = random.rand

    # betaq
    if r <= 1.0/alpha
      alpha = alpha*r
      betaq = alpha**(1.0/(@eta+1.0))
    else
      alpha = alpha*r
      alpha = 1.0 / (2.0-alpha)
      betaq = alpha**(1.0/(@eta+1.0))
    end

    x1 = 0.5*((v1+v2)-betaq*(v2-v1))
    x2 = 0.5*((v1+v2)+betaq*(v2-v1))

    x1 = check_bound(x1, lb, ub)
    x2 = check_bound(x2, lb, ub)

    return x1, x2
  end

  def self.sbx_asymmetric(x1, x2, lb, ub, random)
    return x1, x2 if (x1-x2).abs < 1.0e-14

    alpha, beta, betaq = 0.0, 0.0, 0.0

    # must be v1 < v2 
    if x1 < x2
      v1 = x1
      v2 = x2
    else
      v1 = x2
      v2 = x1
    end

    # x1
    beta = 1.0 + ( 2*(v1-lb) / (v2-v1) )
    beta = 1.0/ beta
    alpha = 2.0 - beta**(@eta+1.0)
    r = random.rand
    if r <= 1.0/alpha
      alpha = alpha*r
      betaq = alpha**(1.0/(@eta+1.0))
    else
      alpha = alpha*r
      alpha = 1.0 / (2.0-alpha)
      betaq = alpha**(1.0/(@eta+1.0))
    end
    x1 = 0.5*((v1+v2)-betaq*(v2-v1))

    # x2
    beta = 1.0 + ( 2*(ub-v2) / (v2-v1) )    
    beta = 1.0/ beta
    alpha = 2.0 - beta**(@eta+1.0)
    
    if r <= 1.0/alpha
      alpha = alpha*r
      betaq = alpha**(1.0/(@eta+1.0))
    else
      alpha = alpha*r
      alpha = 1.0 / (2.0-alpha)
      betaq = alpha**(1.0/(@eta+1.0))
    end
    x2 = 0.5*((v1+v2)+betaq*(v2-v1))

    x1 = check_bound(x1, lb, ub)
    x2 = check_bound(x2, lb, ub)

    return x1, x2
  end

  # blend crossover
  def self.blx_a
    
  end

  # simplex
  def self.simplex
    
  end

  #
  def self.differential_evolution(x, a, b, c, ranges, cr, random)
    jrandom = (random.rand*a.size).floor
    x = []
    a.size.times{|i|
      val = 0.0
      if random.rand < cr || i == jrandom
        val = a[i] + @scale_factor*(b[i]-c[i])
      else
        val = x[i]
      end
      val = check_bound(val, ranges[i].min, ranges[i].max)
      x << val
    }
    return x
  end

  def self.mixed_multi_variables(a, b, ranges, n=1, random)
    a.size.times.each{|i|
      if a[i].class==Float || a[i].class==Integer
        x1, x2 = sbx_asymmetric(a[i], b[i], ranges[i].min, ranges[i].max, random)
        # swap
        if random.rand < 0.5
          a[i] = x1
          b[i] = x2
        else
          a[i] = x2
          b[i] = x1
        end
      end
    }
    return n_point(a, b, n, random)
  end
  
  private

  def self.check_bound(v, lb, ub)
    v = lb if v < lb
    v = ub if ub < v

    return v
  end

end

def debug
  require 'pry'

  include CrossOver
  CrossOver.set_rate

  # a = [0,0,0,0,0,0,0,0,0,0]
  # b = [1,1,1,1,1,1,1,1,1,1]
  rand = Random.new(0)
  
  a = 3.times.map{rand.rand} + ["hoge","fuga","bar"] + 3.times.map{rand.rand}
  b = 3.times.map{rand.rand} + ["aaa","bbb","ccc"] + 3.times.map{rand.rand}
  ranges = 3.times.map{ [0.0, 1.0] } + 3.times.map{ ["min","max"] } + 3.times.map{ [0.0, 1.0] }
  # binding.pry

  a2, b2 = CrossOver.mixed_multi_variables(a.clone, b.clone, ranges, 1, rand)
  binding.pry
  exit(0)
end


if __FILE__ == $0
  debug
end