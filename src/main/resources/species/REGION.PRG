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