Proc tombol
para x,y,ls,ts,cols,cols2
set color to &cols
@x,y clea to x+ts,y+ls
@x,y Say '�'+repl('�',ls) 
@x+ts+1,y Say '�'
if ts<>0
for j=1 to ts
  set color to &cols
  @x+j,y Say '�'
  set color to &cols2
  @x+j,y+ls+1 say '�' 
next j  
Endi
set color to &cols2
@x+ts+1,y+1 Say repl('�',ls)+'�'
@x,y+ls+1 say '�' 
set colo to &cols
Retu

