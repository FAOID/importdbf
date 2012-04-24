Proc tombol
para x,y,ls,ts,cols,cols2
set color to &cols
@x,y clea to x+ts,y+ls
@x,y Say 'Ú'+repl('Ä',ls) 
@x+ts+1,y Say 'À'
if ts<>0
for j=1 to ts
  set color to &cols
  @x+j,y Say '³'
  set color to &cols2
  @x+j,y+ls+1 say '³' 
next j  
Endi
set color to &cols2
@x+ts+1,y+1 Say repl('Ä',ls)+'Ù'
@x,y+ls+1 say '¿' 
set colo to &cols
Retu

