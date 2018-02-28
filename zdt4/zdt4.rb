require 'json'

def function(x)
  f1 = x[0]

  g = x[1..-1].inject(0.0){|s, v| s += v**2 - 10*Math.cos(4.0*Math::PI*v) }
  g += 1.0 + 10.0*(x.size - 1)##

  h = 1.0 - Math.sqrt(f1/g) 
  f2 = g*h
  
  h = {"f1"=>f1, "f2"=>f2}
  return h
end

inputs = JSON.load(open("_input.json"))
x = inputs.map{|k,v| v}
res = function(x)
jstr = JSON.pretty_generate(res)
open("_output.json","w"){|io| io.write(jstr) }