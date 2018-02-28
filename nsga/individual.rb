class Individual
  attr_reader :ps_id # for oacis
  attr_reader :chrom
  attr_reader :fitness
  attr_reader :rank
  attr_reader :crowding_dist
  attr_reader :feasible

  def initialize(chrom=nil, ps_id=nil)
    set_chrom(chrom) unless chrom.nil?
    @ps_id = ps_id
    @fitness = []
    @rank = 1
    @crowding_dist = 0.0
    @feasible = true
  end
  # 
  def set_chrom(chrom)
    @chrom = chrom
  end
  #
  def set_fitness_object(obj_index, fitness)
    @fitness[obj_index] = fitness
  end

  def set_fitness(fitness)
    @fitness = fitness
  end
  #
  def set_rank(rank)
    @rank = rank
  end

  def set_crowding_distance(distance=0.0)
    @crowding_dist = distance
  end

  def set_fieasibe(flag=true)
    @feasible = flag
  end
  #
  def is_duplicate(individual)
    @chrom.map.with_index{|c,i| c==individual.chrom[i]}.inject(:&)
  end
  #
  def feasible?
    return feasible
  end
end