**********************************************************************
* Program untuk membuat file unik bagi cluster-cluster yang diproses *
**********************************************************************

set talk off
set proc to lib
Clear
set color to w+/g,n/w
@0,0,23,78 box repli (chr(178),9)
Do tombol with 8,10,54,5,'b/w','b/w'
Do tombol with 9,12,50,3,'b/w','b/w'
DirectC= Space(30)
set colo to r/w,r+/b
@11,13 say ' Tulis file UNIK :'Get DirectC pict '@!'
read
If Lastkey()=27 .Or. Empty(DirectC)
   clea
   Return
Endif
DirectC= Alltrim(DirectC)
If .Not. File(DirectC+'.dbf')
   @20,02 Say 'File uniknya tidak ditemukan,coba ulangi lagi..!'
read
*   clea
   return
Endif
Sele 1
Use &DirectC
OutFile= DirectC+Left(KeyUnik,1)+'.DBF'
If .Not. File(OutFile+'.dbf')
   Copy file d:\hd2\Code\Std_clus.dbf to &OutFile
   Sele 2
   Use &OutFile
   Sele 1
   Do while .not. eof()
      Lk= lokal
      Sele 2
      Append blank
      Repl lokal with lk
      Sele 1
      Skip
   Enddo
Endif
Sele 2
@20,01 Say 'File yang dihasilkan adalah  ....'
?outfile
read
Close all
clear
return