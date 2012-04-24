CLOSE ALL
SET TALK OFF
set proc to lib
DirectC= SPACE(33)
set color to w+/g,n/w
@0,0,23,78 box repli (chr(178),9)
Do tombol with 9,7,65,5,'b/w','b/w'
Do tombol with 10,9,61,3,'b/w','b/w'
Set color to r/w,r+/b
@12,11 SAY 'Nama file unik gabungan :'GET DirectC PICTURE '@!'
READ
 IF LASTKEY()=27 .OR. EMPTY(DirectC)
    RETURN
ENDIF
IF .NOT. FILE(ALLTRIM(DirectC)+'.dbf')
   WAIT ' File tidak ditemukan ...!! ' WINDOW
   RETURN
ENDIF

sele 1
clea
set color to w+/g,n/w
@0,0,23,78 box repli (chr(178),9)
@10,20 say 'Tunggu, sedang proses ........' colo w+*/r
use c:\species\species
index on nfigf to c:\user\temp
sele 2
use &DirectC
do while .not. eof()
   if nfi=5998
      If genus='99'
         gf= int(99000+val(famili))
         sele 1
         seek gf
         mnfi= nfi
         sele 2
         repl nfi with mnfi
      else
         gf= int(1000*val(genus)+val(famili))
         sele 1
         seek gf
         mnfi= nfi
         sele 2
         repl nfi with mnfi
      endif
   else
      if nfi=6999
         do case
            case 'meranti'$lower(lokal)
                 repl nfi with 6990
            case lower(lokal)='keruing'
                 repl nfi with 6991
            otherwise
                 repl nfi with 6997
         endcase
      endif
   endif
   sele 2
   skip
enddo
clea
close all
set talk on
retu