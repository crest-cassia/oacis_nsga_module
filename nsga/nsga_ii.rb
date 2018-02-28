# require_relative 'genetic_algorithm'
require_relative 'individual'
require_relative 'non_dominate_sort'
require_relative 'crowding_distance'
require_relative 'selection'
require_relative 'crossover'
require_relative 'mutation'

require 'csv'
require 'optparse'

# 
class NSGA_II
  attr_reader :max_generation
  attr_reader :population

  # 
  def initialize(config=nil, seed=nil)
    read_config(config, seed)
    @population = []
  end

  def select_fit_individuals(individuals, target_size=@pop_size)
    set_rank_crowding_dist_to_individuals(individuals)
    sorted = individuals.sort do |a, b|
      compare_by_feasible_rank_distance(a,b)
    end

    sorted[0...target_size]
  end

  def compare_by_feasible_rank_distance(a,b)
    if a.feasible != b.feasible
      return a.feasible ? -1 : 1
    else
      if a.rank != b.rank
        return (a.rank <=> b.rank)
      else
        return -(a.crowding_dist <=> b.crowding_dist)
      end
    end
  end

  def set_rank_crowding_dist_to_individuals(individuals)
    fitnesses = individuals.map {|ind| ind.fitness }
    ranks = NonDominateSort.ranks(fitnesses)
    individuals.each_with_index {|ind,i| ind.set_rank( ranks[i] ) }

    ranks.uniq.sort.each do |rank|
      ranked_individuals = individuals.select {|ind| ind.rank == rank }
      fitnesses = ranked_individuals.map {|ind| ind.fitness }
      distances = CrowdingDistance.distances(fitnesses)
      ranked_individuals.each_with_index do |ind,i|
        d = distances[i]
        ind.set_crowding_distance(d)
      end
    end
  end

  #
  def calc_hypervolume(individuals,reference_point, max_hv)
    reference_p = reference_point

    tmp = individuals.select{|i| i.rank==1}
    tmp = tmp.sort_by{|i| i.fitness[0]}
    tmp = tmp.map{|i| i.fitness}
    tmp << reference_p
    object_size = individuals.first.fitness.size
    sum = {}

    tmp.each_cons(2){|i1,i2|
      sum[i1] = (i1[0] - i2[0]).abs
      (object_size-1).times.each{|m|
        sum[i1] *= (reference_p[m+1] - i1[m+1]).abs
      }
    }

    hv = sum.map{|k,v| v}.inject(:+) / max_hv
    hv = 0.0 if hv > 1.0
    return hv
  end

  # 
  def generate_new_parameter_combinations(ranges)
    new_parameter_combs = []
    candidates_index = @population.size.times.to_a

    while new_parameter_combs.size < @pop_size
      parents = select_parents(@population, candidates_index)
      break if parents.empty?
      chroms = crossover(parents,ranges)

      chroms.each do |chrom|
        gene = mutation(chrom, ranges)
        new_parameter_combs << gene
      end
    end
    
    new_parameter_combs
  end
  # 
  # new_parameter_sets: with oacis ID
  def generate_offsprings(new_parameter_sets)
    offspring = []
    new_parameter_sets.each do |new_ps|
      offspring << Individual.new(new_ps.values, new_ps.id)
    end
    return offspring
  end

  private
  #
  def select_parents(individuals, candidates_index)
    return [] if candidates_index.size < 2

    parents = []
    2.times do |i|
      cand1,cand2 = candidates_index.sample(2, random: @random)
      if cand2
        parent = Selection.nsga_tournament(individuals[cand1], individuals[cand2])
      else
        parent = individuals[cand1]
      end
      parents << parent
      del_idx = individuals.index(parent)
      candidates_index.delete(del_idx)
    end
    parents
  end

  def crossover(parents,ranges)
    chromo1 = parents[0].chrom.clone
    chromo2 = parents[1].chrom.clone
    if @use_n_point_xover && !@real_value_xover
      chroms = CrossOver.n_point(chromo1, chromo2, @xover_num_point, @random)
    elsif @real_value_xover && !@use_n_point_xover
      chroms = CrossOver.sbx(chromo1, chromo2, ranges, @random)
    elsif @use_n_point_xover && @real_value_xover
      chroms = CrossOver.mixed_multi_variables(chromo1, chromo2, ranges, @xover_num_point, @random)
    else
      raise "GA Attributes are no implemention in Crossover"
    end
    return chroms
  end
  #
  def mutation(chrom, ranges)
    if @use_n_point_xover && !@real_value_xover
      return Mutation.mutate(chrom, @random)
    elsif @real_value_xover && !@use_n_point_xover
      return Mutation.polynomial_mutation(chrom, ranges, @random)
    elsif @use_n_point_xover && @real_value_xover
      return Mutation.multi_variable_mutate(chrom, ranges, @random)
    else
      raise "other mutation is no implemention"
    end      
  end

  private
  #
  def read_config(config=nil, seed=nil)
    default_config
    unless config.nil?
      init_vars = JSON.parse(File.read(config))
      @max_generation = init_vars["max_generation"] if init_vars.key?("max_generation")
      @pop_size = init_vars["population_size"] if init_vars.key?("population_size")
      @xover_rate = init_vars["crossover_rate"] if init_vars.key?("crossover_rate")
      @real_value_xover = init_vars["use_real_value_xover"] if init_vars.key?("use_real_value_xover")
      @use_n_point_xover = init_vars["use_n_point_xover"] if init_vars.key?("use_n_point_xover")
      @xover_num_point = init_vars["xover_num_point"] if init_vars.key?("xover_num_point")
      @myu_rate = init_vars["mutation_rate"] if init_vars.key?("mutation_rate")
      @seed = init_vars["seed"] if init_vars.key?("seed")
      @x_eta = init_vars["x_eta"] if init_vars.key?("x_eta")
      @m_eta = init_vars["m_eta"] if init_vars.key?("m_eta")
    end
    @seed = seed unless seed.nil?
    set_random_generator(@seed)
  end
  #
  def default_config
    @population = []
    @max_generation = 100
    @pop_size = 100
    @xover_rate = 0.5
    @real_value_xover = false
    @use_n_point_xover = true
    @xover_num_point = 1
    @myu_rate = 0.01
    @x_eta = 15
    @m_eta = 15
    @seed = 0
  end
  # 
  def set_random_generator(seed)
    @random = Random.new(seed)
    CrossOver.set_rate(@x_eta)
    Mutation.set_rate(@myu_rate)
  end
end

def options(args)
  params = args.getopts("s:")
  params["s"] = params["s"].to_i

  return params
end

# ===============

if __FILE__ == $0  
end
