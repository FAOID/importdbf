clos all
set talk off
set stat off
set exact on
set noti off
set safe off
set cloc on
Set proc to lib
set color to w+/g,n/w
Publ DirectC
@0,0,23,78 box repli (chr(178),9)
Do Tombol with 8,20,37,5,'b/g+','b/g+'
Do Tombol with 9,22,33,3,'b/g+','b/g+'
@11,25 Say 'PROGRAM KODEFIKASI NAMA LOKAL' color r/g
read
rest scre
*save scre
clear
set colo to w+/g,n/w

@0,0,23,78 box repli (chr(178),9)
set colo to b/w,r/w
dimension pilih(7)
Store  '  1. Pembuatan Unik             ' to pilih(1) &&
Store  '  2. Penambahan Unik Gabungan   ' to pilih(2) &&
Store  '  3. Pemberian Kode             ' to pilih(3) &&
Store  '  4. Pengubahan Kode            ' to pilih(4) &&
Store  '  5. Pengubahan Struktur        ' to pilih(5) &&
Store  '  6. Pengisian Kode             ' to pilih(6) &&
Store  '  7. Keluar                     ' to pilih(7) &&
Store 0 to mpilih
*rest scre
save scre

Do while .t.
@08,22 MENU pilih,7
 read MENU TO mpilih
  if lastkey()=27
     return 
  endif   
  Do case
      case mpilih=1
           Do buatunik
      case mpilih=2
           Do addunik
      case mpilih=3
           Do buatkode
      case mpilih=4
           Do ubahkode
      case mpilih=5
           Do ubahstru
      case mpilih=6
           Do isikode
      case mpilih=7
           close all
           clear
           return     
  EndC
  clear
  set colo to w+/g,n/w
  @0,0,23,78 box repli (chr(178),9)
  set colo to b/w,r/w
  rest scre
enddo
set talk on


