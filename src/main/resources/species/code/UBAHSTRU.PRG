**********************************************************
* Program untuk merubah struktur database pada tiap-tiap *
*        cluster yang akan diisi kode species            *
**********************************************************
set safety off
set escape on
set talk off
set status off
set proc to lib
set color to w+/g,n/w
@0,0,23,78 box repli (chr(178),9)
defi window JENDELA from 10,05 to 16,74 none nogr nofl nozo shad colo sche 11
acti window JENDELA
set cursor off
@ 1,3 SAY 'ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป'
@ 2,3 SAY 'บ         Program ini akan menambahkan field Genus dan        บ'
@ 3,3 SAY 'บ            Family pada data klaster yang diproses           บ'
@ 4,3 SAY 'ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ'
=inkey(0)
if lastkey()=27
   deactivate window JENDELA
   clear
   return
endif
lx=0
clear
DRI=space(35)
release window jendela
set cursor on
*set color to n/g,n/w
set color to w+/g,n/w
@0,0,23,78 box repli (chr(178),9)
Do tombol with 9,9,63,5,'b/w','b/w'
Do tombol with 10,11,59,3,'b/w','b/w'
set color to r/w,r+/b
@ 12,12 SAY ' Direktori Cluster : ' GET DRI PICT '@!'
read
If lastkey()=27 .or. empty(DRI)
   clear
   Return
Endif
clear
set color to w+/g,n/w
@0,0,23,78 box repli (chr(178),9)
@11,20 say 'Tunggu, sedang proses .......!!' colo w+*/r
DRI= Alltrim(DRI)
If SubStr(DRI,Len(DRI),1)<>'\'
   DRI= DRI+'\'
Endif

select 1
use (dri+'CLUSTER')
do while .not. eof()
   FDR=ltrim(DRI)+alltrim(DIRCLUS)+'\'
*   RtFile1=FDR+'RT2'
*   RtFile2=FDR+'RT4'
   RtFile1=FDR+'RT6(46)'
*   RtFile2=FDR+'RT8(48)'
*   RtFile3=FDR+'RT9(49)'
*   RtFile6=FDR+'RT10'
*   RtFile7=FDR+'RT11(61)'
*   RtFile8=FDR+'RT15'
*   RtFile9=FDR+'RT17'
*   Rtile1='C:\code\RT2'
*   Rtile2='C:\code\RT4'
   Rtile1='e:\ygd\hd2\code\RT6(46)'
*   Rtile2='C:\code\RT8(48)'
*   Rtile3='C:\code\RT9(49)'
*   Rtile6='C:\code\RT10'
*   Rtile7='C:\code\RT11(61)'
*   Rtile8='C:\code\RT15'
*   Rtile9='C:\code\RT17'
   I=1
   do while I<=9
      y=str(i,1)
      myfile1=Rtfile&y+'.IIS'
      myfile2=Rtfile&y+'.STR'
      myfile3=Rtfile&y+'.DBF'
      set color to r/w
      @20,05 say myfile1+' '+myfile2
      copy file &myfile2 to &myfile1
      select 2
      use &myfile1
      append from &myfile3
      use
      delete file &myfile3
      rename &myfile1 to &myfile3
      I=I+1
   enddo
   select 1
   skip
enddo
set color to 
clear
close all
