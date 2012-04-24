*Program untuk mengisikan kode species ke dalam tiap-tiap cluster 

Set Talk off
Set Score off
Set Safety off
set proc to lib

Clear
DirectC= Space(35)
DirectU= Space(35)
set color to w+/g,n/w
@0,0,23,78 box repli (chr(178),9)
Do tombol with 9,7,65,4,'b/w','b/w'
Do tombol with 10,9,61,2,'b/w','b/w'
Set color to r/w,r+/b
@11,10 Say 'Nama Direktori Klaster  :'Get DirectC Pict '@!' 
@12,10 Say 'Nama File Unik Gabungan :'Get DirectU Pict '@!'
read
If Lastkey()=27 .Or. Empty(DirectC) .Or. Empty(DirectU)
   Return
Endif
DirectC= Alltrim(DirectC)
If SubStr(DirectC,Len(DirectC),1)<>'\'
   DirectC= DirectC+'\'
Endif
DirectU=alltrim(DirectU)
If .Not. File(DirectU+'.dbf')
   @20,02 Say 'File '+DirectU+' tidak ada ....'
   read
   Return
Endif
FClus= DirectC+'Cluster'
If .Not. File(FClus+'.dbf')
   @21,02 Say 'File '+FClus+' tidak ada ....'
   read
   Return
Endif
Use &FClus
I= 0
Declare NClus(Recc())
Do While .Not. Eof()
   I= I+1
   NClus(I)= DirClus
   Skip
Enddo
Close all
Sele 1
Use &DirectU
Index on Upper(Lokal) to Temp

CLEAR
For K= 1 to I
    @15,16 Say ' Sedang proses cluster '+Upper(NCLus(K)) +' '+Str(K,2)+;
    ' dari '+LTrim(Str(i,4))
    Do Unik with NClus(K)+'\'
Next
Clear
Close all

Procedure UNIK
Para Cl
RtFile1= DirectC+Cl+'RT2'
RtFile2= DirectC+Cl+'RT4'
RtFile3= DirectC+Cl+'RT6(46)'
RtFile4= DirectC+Cl+'RT8(48)'
RtFile5= DirectC+Cl+'RT9(49)'
RtFile6= DirectC+Cl+'RT10'
RtFile7= DirectC+Cl+'RT11(61)'
RtFile8= DirectC+Cl+'RT15'
RtFile9= DirectC+Cl+'RT17'
X= 1
Do While X<=9
   Y= LTrim(Str(X))
   MFile= RtFile&Y+'.DBF'
   If File(MFile)
      Sele 2
      Use &MFile
      Do while .Not. Eof()
         NLoc= Upper(Lokal)
         Sele 1
         Seek NLoc
         If Found()
            MNFI= NFI
            MGen= Genus
            MFam= Famili
         Else
            ?nloc,'  pada unik gabungan belum diberi kode.....'
            MNFI= 0
            MGen= '00'
            MFam= '00'
         Endif
         Sele 2
         Repl NFIcode with MNFI,Genus with MGen,Family with MFam
         Skip
      Enddo
   Endif
   x= x+1
Enddo
Return

Function Same
Para Dr
DirectU=Dr
Return 