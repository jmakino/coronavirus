require "grlib"
require "./integratorlib.cr"
require "./mathvector.cr"
require "clop"
include Math
include GR

optionstr= <<-END
  Description: Test integrator for a simple model of epidemic to reproduce nishiura plot
  Long description:
    Test integrator for a simple model of epidemic with options to reproduce
    Nishiura plot
    (c) 2020, Jun Makino

  Short name:		-t
  Long name:  		--end-time-for-integration
  Value type:  		float
  Variable name:	tend
  Default value:	5
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

  Short name:		-D
  Long name:  		--plot-derivative
  Value type:  		bool
  Variable name:	plot_derivative
  Description:		Plot the time derivative of the variables
  Long description:	Plot the time derivative of the variables

  Short name:		-r
  Long name:		--r_not
  Value type:		float vector
  Default value:	2.5
  Variable name:	r0
  Description:		The value of r_not
  Long description:     The value of r_not

  Short name:		-T
  Long name:		--time-to-intervene
  Value type:		float
  Default value:	3
  Variable name:	tint
  Description:		Time to intervene
  Long description:     Time to intervene

  Short name:		-R
  Long name:		--reduction-factors
  Default value:	0,0.2,0.8
  Value type:	        float vector
  Variable name:	rf
  Description:          Reduction factor of R0
  Long description:     Reduction factor of R0 at time tint

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


END

clop_init(__LINE__, __FILE__, __DIR__, "optionstr")
options=CLOP.new(optionstr,ARGV)
pp! options

def equations(x,a)
  [(a*(1-x[0]-x[1])-1)*x[0], x[0]].to_mathv
end

h = 0.01
steps = (options.tend/h+0.5).to_i

if options.ylog
  setwindow(0, options.tend,options.x0,options.h)
  box(major_y:1, ylog: true)
else
  setwindow(0, options.tend,0,options.h)
  box
end

setcharheight(0.03)
mathtex(0.5, 0.06, "t")
if options.plot_derivative
  mathtex(0.06, 0.5,
          ["dx/dt", "dy/dt", "d(x+y)/dt"][options.i])
else
  mathtex(0.06, 0.5,
          ["x", "y", "x+y"][options.i])
end  

avals = Array(Float64).new
options.r0.each{|rnot|
  options.rf.each{|rf|
    t=0.0
    x=[options.x0,0.0].to_mathv
    xx = [x[0],x[1], x[0]+x[1]]
    ff = -> (xx : MathVector(Float64), t : Float64){
      r=rnot
      r=rnot*rf if t >= options.tint
      equations(xx, r)
    }
    steps.times{|i|
      tp =t
      xp=xx
      x, t = Integrators.rk2(x,t,h,ff)
      xx = [x[0],x[1], x[0]+x[1]]
      if options.plot_derivative
        xx = ff.call(x,t)
        xx.push xx[0]+xx[1]
      end
      polyline([tp,t],[xp[options.i], xx[options.i]]) 
    }
  }
}
c=gets
