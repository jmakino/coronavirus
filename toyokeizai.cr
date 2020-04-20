include Math
require "grlib"
require "clop"
include GR
require "csv"

optionstr= <<-END
  Description: Plot of deaths  coronavirs data
  Long description:
    Plot of deaths by  coronavirs 
    Data from  https://toyokeizai.net/sp/visual/tko/covid19/
               https://github.com/kaz-ogiwara/covid19/
    (c) 2020, Jun Makino
    

  Short name:		-L
  Long name:		--log_plot
  Value type:	        bool
  Variable name:	ylog
  Description:          Plot data in log 
  Long description:     Plot data in log 

END
clop_init(__LINE__, __FILE__, __DIR__, "optionstr")
options=CLOP.new(optionstr,ARGV)


s=File.open("covid19/data/prefectures.csv", "r"){|s| s.gets("")}.to_s.split("\n")

a=s.map{|ss| ss.chomp.split(",")}

#pp! a
header = a.shift
data = {a[0][3]=> a[0][7].to_i}
a.shift

datebase = Time.local(2020, 2, 29)

results=a.map {|x| data[x[3]]= x[7].to_i
  date =(Time.local(x[0].to_i, x[1].to_i, x[2].to_i) - datebase).days
  #  print date, " ", x[0]+x[1]+x[2], " ", data.to_a.map{|x| x.to_a[1].to_i}.sum, "\n"
  [date, data.to_a.map{|x| x.to_a[1].to_i}.sum]
}
p results
newresults= [results[0]]

results.each_with_index{|x,i|
  if x[0]== newresults[newresults.size-1][0]
    newresults[newresults.size-1]=x
  else
    newresults.push x
  end
}
p newresults
x= newresults.map{|x| x[0].to_f}
y= newresults.map{|x| x[1].to_f}

ymax = y[(y.size) -1]
setwindow(options.ylog ?  1:0 , x[x.size-1]+3, 1, options.ylog ?  ymax*1.5 :  ymax*1.1)
box(x_tick:7,y_tick:10,major_y:1, ylog: options.ylog)

#setwindow(0 , x[x.size-1]+3,  0, y[x.size-1]+10)
#box(x_tick:7,y_tick:50,major_y:1, ylog: 0)

polyline(x,y)
text(0.35, 0.1, "days from 2020/2/29")

s=File.open("covid19/data/summary.csv", "r"){|s| s.gets("")}.to_s.split("\n")
s.shift

def mytof(s)
  if s.size == 0
    0.0
  else
    s.to_f
  end
end

    
  
summary=s.map{|ss|x=ss.chomp.split(",")
  [(Time.local(x[0].to_i, x[1].to_i, x[2].to_i) - datebase).days.to_f,
  mytof(x[10]), mytof(x[11])]
}
setlinecolorind(2)

polyline summary.map{|x| x[0]}, summary.map{|x| x[1]}
#polyline summary.map{|x| x[0]}, summary.map{|x| x[2]}

setcharheight(0.025)
settextcolorind(1)
text(0.6, 0.78, "Total")  
settextcolorind(2)
text(0.6, 0.6, "MHLW data")  
settextcolorind(1)
setcharheight(0.02)
text(0.2, 0.91, "Total number of COVID-19 deaths in Japan")

p summary 

c=gets



                               
