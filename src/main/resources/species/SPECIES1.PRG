close all
set escape off
set talk off
set safety off
set score off
set colo to
set exac off
clear
Public NFile
Nfile='NONE'+space(36)

sele 3
use c:\species\tumbuh index c:\species\tumbuh

sele 1
use c:\species\species index c:\species\species

do while .t.
   set color to b/bg,r/w
   @ 00,00,23,79 box repli(chr(178),9)
   @ 00,00 clear to 00,79
   @ 24,00 clear to 24,79
   @ 24,00 say 'File Selected : '+Upper(Nfile)
   @00,02 prompt 'Region File'
   @ 0,15 prompt 'Search/List'
   @ 0,28 prompt 'Append/Edit'

   menu to main
   if lastkey()=27
      return
   endif
   if main<>1 .and. empty(dbf(2))
      do pesan with 'Region file must be selected !',20
      loop
   endif
   do case
      Case main=1
           do Region
	Case main=1
           do CURREG
    Case main=1
           do ALLREG
   endcase
enddo

Procedure region

SAVE SCREEN TO scrreg
DO WHILE .T.
   @02,02 CLEAR TO 09,10
   @02,02 PROMPT 'KALTIM'
   @03,02 PROMPT 'KALBAR'
   @04,02 PROMPT 'KALSEL'
   @05,02 PROMPT 'SUMATERA'
   @06,02 PROMPT 'IRIAN'
   @07,02 PROMPT 'MALUKU'
   @08,02 PROMPT 'SULAWESI'
   @09,02 PROMPT 'TIMOR'
   MENU TO reg
   IF LASTKEY()=27
      RETURN
   ENDIF
   DO CASE
      CASE reg=1
           nfile= 'c:\species\region\kaltim'
      CASE reg=2
           nfile= 'c:\species\region\kalbar'
      CASE reg=3
           nfile= 'c:\species\region\kalsel'
      CASE reg=4
           nfile= 'c:\species\region\sumatera'
      CASE reg=5
           nfile= 'c:\species\region\irian'
      CASE reg=6
           nfile= 'c:\species\region\maluku'
      CASE reg=7
           nfile= 'c:\species\region\sulawesi'
      CASE reg=8
           nfile= 'c:\species\region\timor'
   ENDCASE
   fexist= chfile(nfile)
   fdbf = nfile+'.dbf'
   fntx1= nfile+'.nam'
   fntx2= nfile+'.nfi'
   SELECT 2
   USE &fdbf index &fntx1,&fntx2
   RESTORE SCREEN FROM scrreg
   EXIT
ENDDO
@24,00 say Upper(Nfile)

FUNCTION chfile
PARAMETER nf
fdbf = nf+'.dbf'
fntx1= nf+'.nam'
fntx2= nf+'.nfi'
SELECT 2
IF .NOT. FILE(fdbf)
   CREATE &fdbf FROM local.str
   INDEX ON UPPER(nama) TO &fntx1
   INDEX ON NFI TO &fntx2
ENDIF
USE &fdbf
IF .NOT. FILE(fntx1)
   INDEX ON UPPER(nama) TO &fntx1
ENDIF
IF .NOT. FILE(fntx2)
   INDEX ON NFI TO &fntx2
ENDIF
RETURN .T.

*--------------
Procedure Pesan
*--------------
para mpesan,mbrs
save screen
prevcolor=set('color')
set color to w+/r
mlen=len(mpesan)
start=(80-mlen)/2
@mbrs-1,start-2 clear to mbrs+1,start+mlen+2
@mbrs,start say mpesan
wait ''
set color to &prevcolor
restore screen

*----------------------
Procedure CurReg
*----------------------
           sele 2
           set color to r/w,n/bg
           @ 6,15 say 'Local      ' get mlokal
           read
           if empty(mlokal)
              return
           endif
           PrevColor=set('Color')
           set color to w+/r*
           @24,70 say 'WAIT'
		   seek ALLTRIM(UPPER(mlokal))
*          locate for upper(nama) = alltrim(upper(mlokal))
           Set Color to &PrevColor
           @24,70 say space(4)

           if .not. found()
              do pesan with 'Species not available in species file  ...',20
           else
              save screen
              brs=10
              set color to r/w
              @ 7,0 clear to 23,79
              @ 7,0 say 'ÚÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
              @ 8,0 say '³Rec. ³    Local Name         ³LK³NFI.³Fam.³ Genus   ³    Species              ³'
              @ 9,0 say 'ÃÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
              do while alltrim(upper(mlokal)) $ alltrim(upper(nama))
*              do while found()
                 mnfi=nfi
                 sele 1
                    seek mnfi
                    mgenus=genus
                    mfamili=famili
                    mspecies=spesies
                 sele 2
                 @brs,0 say '³'+str(recno(),5)+'³ '+substr(nama,1,22)+'³'+tempat+'³'+str(nfi,4)+'³'+substr(mfamili,1,4)+'³'+substr(mgenus,1,9)+'³'+left(mspecies,25)+'³'
                 brs=brs+1
                 if brs>23
                    brs=10
                    wait ''
                    if lastkey()=27
                       exit
                    endif
                    @10,0 clear to 23,79
                 endif
                 PrevColor=set('Color')
                 set color to w+/r*
                 @24,70 say 'WAIT'
*                 continue
                 set color to &PrevColor
                 @24,70 say space(4)
              skip     
              enddo
              wait ''
              restore screen
           endif
           sele 1
           
*----------------------
Procedure AllReg
*----------------------
SELE 3
goto top
clear
do while .t.
   set color to b/bg
   @ 00,00,23,79 box repli(chr(178),9)
   mnama=space(25)
   set color to r/w,n/bg
   @ 0,0 clear to 0,79
   @ 0,0 say '   Local Name : 'get mnama pict '@!'
   read
   set color to
   if lastkey()=27
    retu
   endi
   seek ALLTRIM(UPPER(mnama))
*   loca for ALLTRIM(UPPER(nama))=ALLTRIM(UPPER(mnama))
   I=5
   IF FOUND()
      @1,0 clea to 23,80
      set color to gr+/br
      @1,0 say 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÑÍÍÍÍÑÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
      @2,0 say 'º    Local Name      ³Kode³Kode³Fami-³    Genus      ³        Species          º'
      @3,0 say 'º                    ³NFI ³Prop³li   ³               ³                         º'
      @4,0 say 'ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍØÍÍÍÍØÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹' color gr+/br
      *ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´' color gr/g
      DO WHILE alltrim(upper(mnama)) $ alltrim(UPPER(nama))
*      DO WHILE alltrim(upper(nama))=alltrim(UPPER(mnama))
         namaku=nama
         nfiku=nfi
         tempatku=tempat
         der=recno()
         sele 1
         seek nfiku
         @ I,0 say 'º' color gr+/b
         @ I,2 say substr(namaku,1,19)+'³'+str(nfi,4)+'³ '+tempatku+' ³'+substr(famili,1,4)+'.³'+substr(genus,1,15)+'³'+substr(spesies,1,25) color g+/b
         @ i,79 say 'º' color gr+/b
         sele 3
         goto der
         if I=22
            =inkey(0)
             if lastkey()=27
                exit
             endif
             Set Colo To w+/b
             @5,0 clea to 23,80
             I=4
         endi
         I=I+1
         skip
      endD
      =inkey(0)
    else
      do pesan with 'Local Name not found ...',20
    endif
enddo