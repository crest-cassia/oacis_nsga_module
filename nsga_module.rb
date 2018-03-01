require_relative './nsga/nsga_ii.rb'
require_relative './target.rb'

#
class NSGA_II_Optimizer < NSGA_II
  #
  def initialize(target, conf_f="config.json", seed=nil)
    super(conf_f, seed)

    @target = target
    @sim = Simulator.where(name: @target.simulator).first
    @host = Host.where(name: @target.host).first
    @num_of_runs = @target.num_of_runs

    @ranges = @target.ranges
  end

  # 
  def initial_parameter_sets
    parameter_sets = @pop_size.times.map{
      vs = Hash[@ranges.map{|k,r| [k,rand(r)] }]
      ps = @sim.find_or_create_parameter_set(vs)
      ps.find_or_create_runs_upto(@num_of_runs, submitted_to: @host, host_param: @host.default_host_parameters)
      @population << Individual.new(vs.values, ps.id)
      ps
    }
    
    OacisWatcher.await_all_ps( parameter_sets )
    set_fitness_to_individuals(@population)
  end

  # override
  def set_fitness_to_individuals(individuals)
    individuals.each do |indv|
      ps = ParameterSet.find(indv.ps_id)
      fitness = @target.fitness(ps)
      indv.set_fitness(fitness)
    end
  end
  #
  def evolve
    offspring = []

    new_parameter_combs = generate_new_parameter_combinations(@ranges.values)
    v_names = @target.parameter_names
    new_parameter_sets = new_parameter_combs.map{|ps_val|
      vs = Hash[ps_val.map.with_index{|v,i| [v_names[i],v]}]
      ps = @sim.find_or_create_parameter_set(vs)
      ps.find_or_create_runs_upto(@num_of_runs, submitted_to: @host, host_param: @host.default_host_parameters)
      offspring << Individual.new(vs.values, ps.id)
      ps
    }

    parameter_sets = OacisWatcher.await_all_ps( new_parameter_sets )

    set_fitness_to_individuals(offspring) # evaluation
    @population = select_fit_individuals(@population+offspring) # archive front solution
  end
  # 
  def run
    OacisWatcher::start { |w|
      initial_parameter_sets

      1.upto(max_generation) do |generation|
        evolve
        puts "generation: #{generation}"
      end
    }
  end
end