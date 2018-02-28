module Selection

  # def self.set_random_generation(rand)
  #   @rand = rand
  # end
  # #
  # def self.reset_random_generation(seed=0)
  #   @rand = Random.new(seed)
  # end

  #
  def self.elite(set, target=:max)
    
    if target == :max
      elite = set.max_by{|indv| indv.fitness }
    elsif target == :min
      elite = set.min_by{|indv| indv.fitness }
    end

    return elite
  end

  #
  def self.roulette(set, random, target=:max)
    # check_random
    if target==:max
      sum = set.inject(0.0){|s, indv| s += indv.fitness }
    elsif target==:min
      sum = set.inject(0.0){|s, indv| s += 1.0/indv.fitness }
    end
    
    needle = random.rand*sum

    select = nil
    sum = 0.0

    set.each{|indv|
      sum += indv.fitness
      if sum > needle
        select = indv
        break
      end
    }

    return select
  end
  #
  def self.nsga_tournament(parents1, parents2)
    if parents1.feasible == parents2.feasible
      if parents1.rank == parents2.rank
        if parents1.crowding_dist > parents2.crowding_dist
          return parents1
        elsif parents1.crowding_dist < parents2.crowding_dist
          return parents2
        else
          return [parents1, parents2].sample
        end
      elsif parents1.rank < parents2.rank
        return parents1
      else
        return parents2
      end
    elsif parents1.feasible==true
      return parents1
    else
      return parents2
    end
  end

  #
  def self.mating(indecies, arity)
    select_size = arity -1
    
  end
  private

end