require "grlib"
require "./integratorlib.cr"
require "./mathvector.cr"
require "clop"
include Math
include GR

optionstr= <<-END
  Description: Test integrator for a simple model of epidemic
  Long description:
    Test integrator for a simple model of epidemic
    (c) 2020, Jun Makino

  Short name:		-t
  Long name:  		--end-time-for-integration
  Value type:  		float
  Variable name:	tend
  Default value:	10
  Description:		End time for integration
  Long description:
    End time for integration

  Short name:		-H
  Long name:  		--height-of-plot
  Value type:  		float
  Variable name:	h
  Default value:	1.0
  Description:		max value of plot for x
  Long description:	max value of plot for x

  Short name:		-i
  Long name:  		--value-for-plot
  Value type:  		int
  Variable name:	i
  Default value:	0
  Description:		Index of variable to plot
  Long description:	Index of variable to plot

  Short name:		-r
  Long name:		--r_not
  Value type:		float vector
  Default value:	1.1,1.4,2,2.8,4
  Variable name:	r0
  Description:		The value of r_not
  Long description:     The value of r_not

  Short name:		-x
  Long name:		--x_init
  Default value:	0.01
  Value type:	        float
  Variable name:	x0
  Description:          Initial value of x
  Long description:     Initial value of x

  Short name:		-L
  Long name:		--log_plot
  Value type:	        bool
  Variable name:	ylog
  Description:          Plot x in log 
  Long description:     Plot x in log


  Short name:		-A
  Long name:		--asymptotic-plot
  Value type:	        bool
  Variable name:	asym
  Description:          Plot the final values as a function of R0
  Long description:     Plot the final values as a function of R0


END

clop_init(__LINE__, __FILE__, __DIR__, "optionstr")
options=CLOP.new(optionstr,ARGV)
pp! options

def equations(x,a)
  [(a*(1-x[0]-x[1])-1)*x[0], x[0]].to_mathv
end

h = 0.01
steps = (options.tend/h+0.5).to_i

unless options.asym
  if options.ylog
    setwindow(0, options.tend,options.x0,options.h)
    box(major_y:1, ylog: true)
  else
    setwindow(0, options.tend,0,options.h)
    box
  end
  
  setcharheight(0.03)
  mathtex(0.5, 0.06, "t")
  mathtex(0.06, 0.5,
          ["x", "y", "x+y"][options.i])
end
  

avals = Array(Float64).new
options.r0.each{|rnot|
  t=0.0
  x=[options.x0,0.0].to_mathv
  xx = [x[0],x[1], x[0]+x[1]]
  ff = -> (xx : MathVector(Float64), t : Float64){ equations(xx, rnot)}
  steps.times{|i|
    tp =t
    xp=xx
    x, t = Integrators.rk2(x,t,h,ff)
    xx = [x[0],x[1], x[0]+x[1]]
    polyline([tp,t],[xp[options.i], xx[options.i]]) unless options.asym
  }
  avals.push xx[options.i]
}
if options.asym
  setwindow(1.0, 2, 0,1)
  box
  
  setcharheight(0.03)
  mathtex(0.5, 0.06, "R_0")
  mathtex(0.06, 0.5,
          ["x", "y", "x+y"][options.i])
  polyline(options.r0, avals)
end
c=gets
