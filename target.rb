class Target
  attr_reader :simulator
  attr_reader :host
  attr_reader :num_of_runs
  attr_reader :parameter_names
  attr_reader :ranges  

  def initialize(target_json=nil)
    @definition = JSON.load(open(target_json))
    @simulator = @definition["simulator"]
    @host = @definition["host"]
    @num_of_runs = @definition["num_of_runs"]
    @parameter_names = @definition["input"].keys
    @ranges = Hash[@definition["input"].map{|k,df| 
      [k,(df["domain"].min..df["domain"].max)] }]
    @objectives = @definition["objectives"]
  end
  # ex.) sum 
  def fitness(ps)
    tmp = {}
    ps.runs.each{|r|
      @objectives.each{|k|
        tmp[k] ||= []
        tmp[k] << r.result[k]
      }      
    }
    fitness = @objectives.map{|k| tmp[k].inject(:+) }
  end
end