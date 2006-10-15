require 'tk';TkRoot.new;r,c,b=1,1,%w#7 8 9 + 4 5 6 - 1 2 3 * 0 . /#;d=TkEntry.new{
grid("row"=>0,"column"=>1,"columnspan"=>4)};b.each_index{|i|TkButton.new{text b[i]
command proc{d.insert("end",b[i])};grid("row"=>r,"column"=>c)};c+=1;if i&&(i+1)%##
4==0then r+=1;c=1 end};TkButton.new{text"=";command proc{t=d.get;d.delete(0,"end")
d.insert("end",eval(t))};grid("row"=>r,"column"=>c)};Tk.mainloop### by mawe :) ###
