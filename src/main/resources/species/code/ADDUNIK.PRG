*************************************************************
* Program untuk menggabungkan file unik hasil pembuatan     *
* kode species baru ke file unik gabungan (file unik induk) *
*************************************************************

Close all
Set Talk off
Set Score off
Set Safety off
set proc to lib
Clear
DirectC= Space(33)
DirectU= Space(33)
set color to w+/g,n/w
@0,0,23,78 box repli (chr(178),9)
Do tombol with 8,10,56,6,'b/w','b/w'
Do tombol with 9,12,52,4,'b/w','b/w'
Set color to r/w,r+/b
@10,13 Say ' File UNIK BARU :'Get DirectC Pict '@!'
@11,13 Say ' (File hasil proses menu 1)'
@13,13 Say ' File GABUNGAN  :'Get DirectU Pict '@!'
read
If Lastkey()=27 .Or. Empty(DirectC) .Or. Empty(DirectU)
   Return
Endif
DirectC= Alltrim(DirectC)
DirectU= Alltrim(DirectU)
If .Not. File(DirectC+'.dbf') 
   @21,00 Say 'File '+DirectC+' tidak ditemukan ....'
read
   Return
Endif
If .Not. File(DirectU+'.dbf')
   @22,00 Say 'File '+DirectU+' tidak ditemukan ....'
read
   Return

Endif
Sele 2
Use &DirectU
Index on Upper(lokal) to Temp
Sele 1
Use &DirectC
Do While .Not. Eof()
   lk= upper(Lokal)
   sp= species
   Sele 2
   seek lk
   If .not. found()
      appen blank
      repl lokal with uppe(left(lk,1))+lower(right(lk,14)),species with uppe(sp)
   Endif
   sele 1
   Skip
Enddo

return
sele 2
index on upper(lokal) to temp
copy to temp
Close all
copy file temp to DirectU.dbf


close all