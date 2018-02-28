require_relative './target_zdt4.rb'
require_relative '../nsga_module.rb'
require 'optparse'

###
# $OACIS_ROOT/bin/oacis_ruby nsga_zdt4.rb -c ../nsga.conf.json -t target.json
###

params = ARGV.getopts("c:t:")

conf_f = params["c"] #"nsga.conf.json"
target_f = params["t"] # "target.json"
require 'pry'
binding.pry
@target = ZDT4.new(target_f)  
@optimizer = NSGA_II_Optimizer.new(@target, conf_f)

@optimizer.run