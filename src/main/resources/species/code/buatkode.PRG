*ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·
*º   BUATKODE.PRG    º
*ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½

SET SAFETY OFF
SET CLOC ON
CLEAR
CLOSE ALL
SET TALK OFF
set proc to lib

DirectC= SPACE(33)
set color to w+/g,n/w
@0,0,23,78 box repli (chr(178),9)
Do tombol with 9,5,67,5,'b/w','b/w'
Do tombol with 10,7,63,3,'b/w','b/w'
Set color to r/w,r+/b
@12,9 SAY 'Nama file unik gabungan :'GET DirectC PICTURE '@!'
READ
IF LASTKEY()=27 .OR. EMPTY(DirectC)
   RETURN
ENDIF
IF .NOT. FILE(ALLTRIM(DirectC)+'.dbf')
   WAIT ' File '+alltrim(directC)+' tidak ditemukan ...!! ' WINDOW
 *  WAIT ' File '+directC+' tidak ditemukan ...!! '
   RETURN
ENDIF
clear

SET COLOR TO
SELECT 1
USE c:\species\species INDEX c:\species\species.idx
SELECT 2
USE c:\species\tumbuh INDEX c:\species\tumbuh.idx
USE c:\species\region\sumatera index c:\species\region\sumatera.nam
USE c:\species\region\kalsel index c:\species\region\kalsel.nam
USE c:\species\region\kaltim index c:\species\region\kaltim.nam
USE c:\species\region\kalbar index c:\species\region\kalbar.nam
USE c:\species\region\sulawesi index c:\species\region\sulawesi.nam
USE c:\species\region\maluku index c:\species\region\maluku.nam
USE c:\species\region\irian index c:\species\region\irian.nam
USE c:\species\region\timor index c:\species\region\timor.nam
***** Untuk BIPHUT 1 & 2 ******
set filter to tempat='07' .or. tempat='08' .or. tempat='10' .or. tempat='11';
.or. tempat='12' .or. tempat='15' .or. tempat='17' .or. tempat='18';
.OR. tempat='09' .or. tempat='11' .or. tempat='13' .or. tempat='14'.or. TEMPAT='16'
****** Untuk BIPHUT 3 ******
set filter to tempat='05' .or. tempat='04' .or. tempat='08' .or. tempat='10'
****** Untuk BIPHUT 4 ******
set filter to tempat='04' .or. tempat='06' .or. tempat='03'
****** Untuk BIPHUT 5 ******
set filter to tempat='02' .or. tempat='03'
****** Untuk BIPHUT 6 ******
set filter to tempat='21' .or. tempat='19' .or. tempat='22'
****** Untuk BIPHUT 7 ******
set filter to tempat='19'.or. tempat='20' .or. tempat='21' .or. tempat='22';
.or. tempat='24' .or. tempat='25' .or. tempat='26'
****** Untuk BIPHUT 8 ******
set filter to tempat='24' .or. tempat='25'
****** Untuk BIPHUT 9 ******
set filter to tempat='22' .or. tempat='26'
****** Untuk BIPHUT 10 *****
set filter to tempat='23' .or. tempat='24' .or. tempat='25' .or. tempat='26'

SELECT 3
USE &DirectC
CLEAR
kondisi= .F.
DO WHILE .T.
  SET COLOR TO
   CLEAR
   SELECT 3
   IF .NOT. kondisi
      MNama= Lokal
      MLoca= ALLTRIM(Lokal)
   ENDIF
   IF EOF()
      SET CURSOR OFF
      SET COLO TO
      CLEAR
      @24,65 SAY '    SELESAI    ' COLO G+*/R
      WAIT ''
      CLEAR
      SET CURSOR ON
      RETURN
   ENDIF
   SET COLOR TO r/W
   @0,0 SAY 'Mencari  : '+Lokal+' record : '+STR(RECNO(),4)+SPACE(30)
   SET COLOR TO
   IF NFI<>0
      SKIP
      LOOP
   ENDIF
   SELECT 2
   SET COLOR TO g+/br
*   SEEK ALLTRIM(UPPER(MNama))
    loca for ALLTRIM(UPPER(Nama))= ALLTRIM(UPPER(MNama))
   I=3
   @1,0  SAY 'Rec.  Nama lokal            NFI    LY     FAMILY        GENUS      SPECIES      '
   SET COLOR TO BG+/B
   @2,0  SAY REPLICATE('Í',80)
   @2,5  SAY 'Ñ'
   @2,26 SAY 'Ñ'
   @2,31 SAY 'Ñ'
   @2,34 SAY 'Ñ'
   @2,37 SAY 'Ñ'
   @2,52 SAY 'Ñ'
   @2,68 SAY 'Ñ'
   IF FOUND()
      DO WHILE ALLTRIM(UPPER(MNama)) $ ALLTRIM(UPPER(Nama))
         Namaku= Nama
         Nfiku= Nfi
         Tempatku= Tempat
         Der= RECNO()
         SELECT 1
         Seek Nfiku
         Rec= RECNO()
         @I,0 SAY STR(Rec,5)+'³'+LEFT(Namaku,20)+'³'+STR(Nfi,4)+'³'+Nilai+'³'+Tempatku+'³'+SUBSTR(Kode,1,3)+' '+LEFT(Famili,10)+'³'+SUBSTR(Kode,4,2)+' '+LEFT(Genus,12)+'³'+LEFT(Spesies,10)
         SELECT 2
         GOTO Der
         IF I=24
            =INKEY(0)
             IF LASTKEY()=27
                EXIT
             ENDIF
             @03,00 CLEAR TO 24,79
             I=2
         ENDIF
         I=I+1
         SKIP
         SAVE SCREEN TO LYR
      ENDDO
      I= I-1
      @I+1,0  SAY ' '
      @I+1,0  SAY REPLICATE('Í',80)
      @I+1,5  SAY 'Ï'
      @I+1,26 SAY 'Ï'
      @I+1,31 SAY 'Ï'
      @I+1,34 SAY 'Ï'
      @I+1,37 SAY 'Ï'
      @I+1,52 SAY 'Ï'
      @I+1,68 SAY 'Ï'
      Cod= 0
      SET COLOR TO n/n
      @18,55 CLEAR TO 22,78
      SET COLOR TO n/g+,bg+/w
      @17,53 CLEAR TO 21,76
      @17,53 TO 21,76 DOUBLE
      @18,56 SAY 'Kode jenis :'GET Cod PICTURE '9999'
      READ
      IF LASTKEY()=27
         EXIT
      ENDIF
      IF Cod=0
         LOOP
      ENDIF
      DO CASE
         CASE Cod=6999 .OR. Cod=6998 .OR. Cod=7998 .OR. Cod=8998
              CGen= '99'
              CFam= '999'
         CASE Cod=5998
              MGen= '00'
              @19,56 SAY 'Kode genus :'GET MGen PICTURE '99'
              READ
              IF LASTKEY()=27 .OR. VAL(MGen)=0
                 LOOP
              ENDIF
              MNFI= 0
              @20,56 SAY 'Kode NFI   :'GET MNFI PICTURE '9999' VALID MNFI>0
              READ
              IF LASTKEY()=27
                 LOOP
              ENDIF
              SELECT 1
              GOTO MNFI
              IF MGen= '99'
                 CGen= MGen
              ELSE
                 CGen= SUBSTR(Kode,4,2)
              ENDIF
              CFam= SUBSTR(Kode,1,3)
         OTHERWISE
              SELECT 1
              IF Cod>RECC()
                 CLEAR
                 REST SCRE FROM LYR
                 WAIT 'Kode tidak valid ....!!!!' WINDOW
                 LOOP
              ENDIF
              GOTO Cod
              CGen= SUBSTR(Kode,4,2)
              CFam= SUBSTR(Kode,1,3)
      ENDCASE
      @03,00 CLEAR TO 24,79
      SELECT 3
      REPLACE Famili WITH CFam,Genus WITH CGen,NFI WITH Cod
      SKIP
    ELSE
      Cod= 0
      CFam= '999'
      CGen= '99'
      SET COLOR TO n/n
      @18,55 CLEAR TO 22,78
      SET COLOR TO n/g+,bg+/w
      @17,53 CLEAR TO 21,76
      @17,53 TO 21,76 DOUBLE
      @18,56 SAY 'Kode jenis :'GET Cod PICTURE '9999'
      READ
      IF LASTKEY()=27
         EXIT
      ENDIF
      IF Cod=0
         MLoca= SUBSTR(MLoca,AT(' ',MLoca)+1,10)
         MNama= LEFT(MLoca,5)
         kondisi= .T.
         LOOP
      ENDIF
      IF Cod=5998
         MGen= '00'
         @19,56 SAY 'Kode genus :'GET MGen PICTURE '99'
         READ
         IF LASTKEY()=27 .OR. VAL(MGen)=0
            LOOP
         ENDIF
         MNFI= 0
         @20,56 SAY 'Kode NFI   :'GET MNFI PICTURE '9999' VALID MNFI>0
         READ
         IF LASTKEY()=27
            LOOP
         ENDIF
         SELECT 1
         GOTO MNFI
         IF MGen= '99'
            CGen= MGen
         ELSE
            CGen= SUBSTR(Kode,4,2)
         ENDIF
         CFam= SUBSTR(Kode,1,3)
      ENDIF
      SELECT 3
      REPLACE Famili WITH CFam,Genus WITH CGen,NFI WITH Cod
      SKIP
    ENDIF
    kondisi= .F.
ENDDO
CLOSE ALL
SET COLO TO
CLEAR
