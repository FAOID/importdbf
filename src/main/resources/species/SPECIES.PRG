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
      case main=2
           do SearchList
      case main=3
           do AppendEdit
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


*-------------------
Procedure SearchList
*-------------------
do while .t.
   select 1
   set color to b/bg
   @ 02,00,23,79 box repli(chr(178),9)
   set color to b/bg,r/w
   mfamili=space(16)
   mgenus=space(20)
   mspecies=space(26)
   mlokal=space(25)
   @ 2,15 prompt 'Famili       '
   @ 3,15 prompt 'Genus        '
   @ 4,15 prompt 'Species      '
   @ 5,15 prompt 'Fam/Gen/Spec '
   @ 6,15 prompt 'Local        '
   @ 7,15 prompt 'NFI Code     '
   menu to botani
   save screen to LySearch
   if lastkey()=27
      return
   endif
   do case
      case botani=1
           @ 2,15 say 'Famili    ' get mfamili
           read
           if empty(mfamili)
              loop
           endif
           tipe=1
           @ 9,26 prompt 'Current File  '
           @10,26 prompt 'Species File  '
           menu to tipe
           if lastkey()=27
              loop
           endif
           do case
              case tipe=2
                select 1
                locate for alltrim(upper(mfamili)) $ alltrim(upper(famili))
                if .not. found()
                   do pesan with 'Famili tidak ada...',20
                else
                   save screen
                   brs=10
                   set color to r/w
                   @ 7,0 clear to 23,79
                   @ 7,0 say 'ÚÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄ¿'
                   @ 8,0 say '³Rec. ³    Famili      ³       Genus        ³        Species         ³ NFI³'
                   @ 9,0 say 'ÃÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄ´'
                   do while found()
                      @brs,0 say '³'+str(recno(),5)+'³'+famili+'³'+genus+'³'+substr(spesies,1,24)+'³'+str(nfi,4)+'³'
                      brs=brs+1
                      if brs>23
                      brs=10
                      wait ''
                      if lastkey()=27
                         exit
                      endif
                         @10,0 clear to 23,79
                      endif
                      cont
                   enddo
                   wait ''
                   restore screen
                endif

              case tipe=1
                Select 2
                set order to 2
                set relation to nfi into Species
                go top
                locate for alltrim(upper(mfamili)) $ alltrim(upper(species->famili))
                if .not. found()
                   do pesan with 'Famili tidak ada...',20
                else
                   save screen
                   brs=10
                   set color to r/w
                   @ 7,0 clear to 23,79
                   @ 7,0 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄ¿'
                   @ 8,0 say '³  Famili   ³   Genus   ³        Species         ³NFI ³ Local Name    ³LK³'
                   @ 9,0 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄ´'
                   do while .not. eof()
                      if alltrim(upper(mfamili)) $ alltrim(upper(species->famili))
                         @brs,0 say '³'+substr((species->famili),1,11)+'³'+substr((species->genus),1,11)+'³'+;
                                   substr((species->spesies),1,24)+'³'+str(nfi,4)+'³'+substr(nama,1,15)+'³'+tempat+'³'

                         brs=brs+1
                         if brs>23
                            brs=10
                            wait ''
                            if lastkey()=27
                               exit
                            endif
                            @10,0 clear to 23,79
                         endif
                       endif
                       skip
                    enddo
                    wait ''
                    restore screen
                endif
           endcase

      case botani=2
           @ 3,15 say 'Genus    ' get mgenus
           read
           if empty(mgenus)
              loop
           endif
           tipe=1
           @ 9,26 prompt 'Current File  '
           @10,26 prompt 'Species File  '
           menu to tipe
           if lastkey()=27
              loop
           endif
           do case
              case tipe=2
                select 1
                go top
                locate for alltrim(upper(mgenus)) $ alltrim(upper(genus))
                if .not. found()
                   do pesan with 'Genus tidak ada ...',20
                else
                   save screen
                   brs=10
                   set color to r/w
                   @ 7,0 clear to 23,79
                   @ 7,0 say 'ÚÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄ¿'
                   @ 8,0 say '³Rec. ³    Famili      ³       Genus        ³        Species         ³NFI ³'
                   @ 9,0 say 'ÃÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄ´'
                   do while found()
                      @brs,0 say '³'+str(recno(),5)+'³'+famili+'³'+genus+'³'+substr(spesies,1,24)+'³'+str(nfi,4)+'³'
                      brs=brs+1
                      if brs>23
                         brs=10
                         wait ''
                         if lastkey()=27
                            exit
                         endif
                         @10,0 clear to 23,79
                      endif
                      cont
                    enddo
                    wait ''
                    restore screen
                endif

              case tipe=1
                Select 2
                set order to 2
                set relation to nfi into Species

                go top
                locate for alltrim(upper(mgenus)) $ alltrim(upper(species->genus))
                if .not. found()
                   do pesan with 'Genus tidak ada ...',20
                else
                   save screen
                   brs=10
                   set color to r/w
                   @ 7,0 clear to 23,79
                   @ 7,0 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄ¿'
                   @ 8,0 say '³  Famili   ³   Genus   ³        Species         ³NFI ³ Local Name    ³LK³'
                   @ 9,0 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄ´'
                   do while .not. eof()
                      if alltrim(upper(mgenus)) $ alltrim(upper(species->genus))
                         @brs,0 say '³'+substr((species->famili),1,11)+'³'+substr((species->genus),1,11)+'³'+;
                                   substr((species->spesies),1,24)+'³'+str(nfi,4)+'³'+substr(nama,1,15)+'³'+tempat+'³'

                       brs=brs+1
                       if brs>23
                          brs=10
                          wait ''
                          if lastkey()=27
                             exit
                          endif
                             @10,0 clear to 23,79
                          endif
                       endif
                       skip
                    enddo
                    wait ''
                    restore screen
                endif
           endcase

      case botani=3
           @ 4,15 say 'Species    ' get mspecies
           read
           if empty(mspecies)
              loop
           endif
           tipe=1
           @ 9,26 prompt 'Current File  '
           @10,26 prompt 'Species File  '
           menu to tipe
           if lastkey()=27
              loop
           endif
           do case
              case tipe=2
                select 1
                go top
                locate for alltrim(upper(mspecies)) $ alltrim(upper(spesies))
                if .not. found()
                   do pesan with 'Species Tidak ada  ...',20
                else
                   save screen
                   brs=10
                   set color to r/w
                   @ 7,0 clear to 23,79
                   @ 7,0 say 'ÚÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄ¿'
                   @ 8,0 say '³Rec. ³    Famili      ³       Genus        ³        Species         ³NFI ³'
                   @ 9,0 say 'ÃÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄ´'
                   do while found()
                      @brs,0 say '³'+str(recno(),5)+'³'+famili+'³'+genus+'³'+substr(spesies,1,24)+'³'+str(nfi,4)+'³'
                      brs=brs+1
                      if brs>23
                         brs=10
                         wait ''
                         if lastkey()=27
                            exit
                         endif
                         @10,0 clear to 23,79
                      endif
                      cont
                    enddo
                    wait ''
                    restore screen
                 endif

              case tipe=1
                Select 2
                set order to 2
                set relation to nfi into Species
                go top
                locate for alltrim(upper(mspecies)) $ alltrim(upper(species->spesies))
                if .not. found()
                   do pesan with 'Species Tidak ada  ...',20
                else
                   save screen
                   brs=10
                   set color to r/w
                   @ 7,0 clear to 23,79
                   @ 7,0 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄ¿'
                   @ 8,0 say '³  Famili   ³   Genus   ³        Species         ³NFI ³ Local Name    ³LK³'
                   @ 9,0 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄ´'
                   do while .not. eof()
                      if alltrim(upper(mspecies)) $ alltrim(upper(species->spesies))
                         @brs,0 say '³'+substr((species->famili),1,11)+'³'+substr((species->genus),1,11)+'³'+;
                                   substr((species->spesies),1,24)+'³'+str(nfi,4)+'³'+substr(nama,1,15)+'³'+tempat+'³'
                         brs=brs+1
                         if brs>23
                            brs=10
                            wait ''
                            if lastkey()=27
                               exit
                            endif
                            @10,0 clear to 23,79
                         endif
                      endif
                      skip
                   enddo
                   wait ''
                   restore screen
                endif
           endcase

      case botani=4
           do empat
      case botani=5
           save screen to lylocal
           tipe=1
           @ 9,26 prompt 'Current Region '
           @10,26 prompt 'All Region     '
           menu to tipe
           if lastkey()=27
              loop
           endif
           do case
              case tipe=1
                   set color to b/bg
                   @ 08,00,23,79 box repli(chr(178),9)
                   do SpecCurRegion
              case tipe=2
                   do SpecAllRegion
           endcase
           restore screen from lylocal

      case Botani=6
           Mcode=0
           @ 7,15 say  'NFI Code   ' get MCode pict '9999'
           read
           if Mcode=0 .or. lastkey()=27
              loop
           endif
           tipe=1
           @ 9,26 prompt 'Current File  '
           @10,26 prompt 'Species File  '
           menu to tipe
           if lastkey()=27
              loop
           endif
           do case
              case tipe=2
                select 1
                seek Mcode
                if .not. found()
                   do pesan with 'Species Code not available on SPECIES file ',20
                else
                   save screen
                   brs=10
                   set color to r/w
                   @ 7,0 clear to 23,79
                   @ 7,0 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄ¿'
                   @ 8,0 say '³  Famili        ³      Genus     ³        Species         ³NFI ³'
                   @ 9,0 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄ´'
                   do while NFI=Mcode
                      @brs,0 say '³'+species->famili+'³'+substr((species->genus),1,16)+'³'+;
                                     substr((species->spesies),1,24)+'³'+str(nfi,4)+'³'
                      brs=brs+1
                      if brs>23
                         brs=10
                         wait ''
                         if lastkey()=27
                            exit
                         endif
                         @10,0 clear to 23,79
                      endif
                      skip
                    enddo
                    wait ''
                    restore screen
                endif

              case tipe=1
                Select 2
                set order to 2
                set relation to nfi into Species
                seek Mcode
                if .not. found()
                   mess= upper(substr(nfile,rat('\',nfile)+1,len(alltrim(nfile))-rat('\',nfile)))
                   do pesan with 'Species Code not available on '+mess,20
                else
                   save screen
                   brs=10
                   set color to r/w
                   @ 7,0 clear to 23,79
                   @ 7,0 say 'ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄ¿'
                   @ 8,0 say '³  Famili   ³   Genus   ³        Species         ³NFI ³ Local Name    ³LK³'
                   @ 9,0 say 'ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄ´'
                   do while NFI=Mcode
                      @brs,0 say '³'+substr((species->famili),1,11)+'³'+substr((species->genus),1,11)+'³'+;
                                   substr((species->spesies),1,24)+'³'+str(nfi,4)+'³'+substr(nama,1,15)+'³'+tempat+'³'
                      brs=brs+1
                      if brs>23
                         brs=10
                         wait ''
                         if lastkey()=27
                            exit
                         endif
                         @10,0 clear to 23,79
                      endif
                      skip
                   enddo
                   wait ''
                   restore screen
                endif
              endcase
   endcase
enddo

*--------------
Procedure Empat
*--------------
@ 5,28 say 'Fam. ' get mfamili
@ 6,28 say 'Gen. ' get mgenus
@ 7,28 say 'Spec.' get mspecies
read
if empty(mfamili)
   return
endif
locate for alltrim(upper(mfamili)) $ alltrim(upper(famili)) .and. ;
           alltrim(upper(mgenus))  $ alltrim(upper(genus)) .and. ;
           alltrim(upper(mspecies))$ alltrim(upper(spesies))
if .not. found()
   do pesan with 'Data tidak ada ...',20
else
   set color to r/w
   do while found()
      @10,10 say 'Famili      : '+Famili
      @11,10 say 'Genus       : '+genus
      @12,10 say 'Species     : '+spesies
      @13,10 say 'NFI Code    : '+str(NFI,4)
      wait ''
      if lastkey()=27
         exit
      endif
      cont
   enddo
*   @16,10 say 'End of locate'
*   wait ''
endif
wait ''

*-------------------
Procedure AppendEdit
*-------------------
sele 2
go top
do while .t.
   set color to w/bg
   @00,70 say space(9)
   do SaySpec
   key=0
   do while key=0
      set cursor off
      key=inkey()
   enddo
   set cursor on
   do case
      case key=27  && How to Exit (Esc)
           return
      case chr(key)$'Ii'     && Append Record
           set color to w+/r
           @00,70 say 'Append'
           mlokal=space(25)
           mnfi=0
           mtempat=space(2)
           PrevRecord=recno()
           set color to n/g,n/bg
           @06,10 say 'Local Name    :' get mlokal valid mlokal<>space(25)
           read
           if lastkey()=27
              loop
           endif
           seek upper(mlokal)
           if found()
              do pesan with 'Data already exist ...',20
              do SaySpec
           else
              @07,10 say 'NFI Code      :' get mnfi pict '9999'
              @08,10 say 'Place         :' get mtempat pict '99'
              read
              benar='N'
              @22,20 say 'Data baru Oke : ' get benar pict '!' valid(benar$'YN')
              read
              if benar='Y'
                 append Blank
                 repla nama with mlokal,nfi with mnfi,tempat with mtempat
              else
                 do pesan with 'Process aborted...',20
                 go PrevRecord
                 do SaySpec
              endif
           endif
      case chr(key)$'Ee'       && Edit Record
           set color to w+/r
           @00,70 say 'Edit'
           if recno()>0
              do GetSpec
              read
           else
              do Pesan with 'No Data to Edit ...',20
           endif
      case chr(key)$'Dd'    && Delete Record
           set color to w+/r
           @00,70 say 'Delete'
           if recno()>0
              do SaySpec
              mdel='N'
              @22,20 Say 'Are You Sure : ' get Mdel pict '!' valid(Mdel$'YN')
              read
              if MDel='Y'
                 delete
                 pack
                 do pesan with 'Data has been deleted...',20
              else
                 do pesan with 'Process aborted ...',20
              endif
            else
              do Pesan with 'No Data to Delete ...',20
            endif
      Case key=18   && tombol PgUp
           if bof()
              do pesan with 'Begin of Record ...',20
              go top
           else
              skip -1
           endif
      Case key=3    && tombol PgDn
           if eof()
              do pesan with 'End of Record ...',20
              go bottom
           else
              skip
           endif
      Case chr(key)$'Bb'
           Save Screen
           browse noedit noappend
           Restore Screen
      Case chr(key)$'Ss'
           set color to w+/b
           @00,70 say 'Search'
           mlokal=space(25)
           mnfi=0
           mtempat=space(2)
           PrevRecord=recno()
           set color to w+/g,n/bg
           @06,10 say 'Local Name    :' get mlokal valid mlokal<>space(25)
           read
           if lastkey()=27
              loop
           endif
           Tipe=1
           PrevColor=set('color')
           set color to w+/b,w+/gr
           @ 11,60 prompt 'Unique    '
           @ 12,60 prompt 'Non-Unique'
           menu to tipe
           set color to &PrevColor
           do case
              case tipe=1
                   set order to 1
                   Seek upper(mlokal)
                   if .not. found()
                      do pesan with 'Data not found...',20
                   else
                      do SaySpec
                   endif
               case tipe=2
                    PrevColor=set('Color')
                    set color to w+/r*
                    @24,70 say 'WAIT'
                    go top
                    locate for alltrim(upper(mlokal)) $ upper(nama)
                    set color to &PrevColor
                    @24,70 say space(4)
                    if found()
                       do while found() .and. .not. eof()
                          do SaySpec
                          Mcont='Y'
                          @ 22,20 say 'Continue ?' get Mcont pict '!' valid Mcont$'YN'
                          read
                          if Mcont='Y'
                             PrevColor=set('Color')
                             set color to w+/r*
                             @24,70 say 'WAIT'
                             Continue
                             set color to &PrevColor
                             @24,70 say space(4)
                          else
                             exit
                          endif
                       enddo
                       do pesan with 'End of Locate ...',20
                    else
                       do pesan with 'Data not found ...',20
                       go PrevRecord

                    endif
           endcase
      Other
           do Pesan With 'Press I,E,D,S,PgUp/PgDn or Esc to cancel',20
   endcase
enddo

*----------------
Procedure SaySpec
*----------------
set color to b/bg
@ 02,00,23,79 box repli(chr(178),9)
set color to n+/g,n/bg
@05,5 clear to 09,55
@05,5 to 9,55
@06,10 say 'Local Name    : '+nama
@07,10 say 'NFI Code      : '+str(nfi,4)
@08,10 say 'Place         : '+tempat
set color to n+/gr
@15,5 clear to 19,55
@15,5 to 19,55
@16,10 say '[I]nput '
@17,10 say '[E]dit  '
@18,10 say '[D]elete '
@16,25 say '[S]earch '
@17,25 say '[PgUp/PgDn] Move'
@18,25 say '[B]rowse'
set color to b/w+,r/w
@10,5 clear to 14,55
@10,5 to 14,55
mmnfi=nfi
sele 1
seek mmnfi
do SpecSay
sele 2

*----------------
Procedure SpecSay
*----------------
@11,10 say 'Famili        : '+famili
@12,10 say 'Genus         : '+genus
@13,10 say 'Species       : '+spesies

*----------------
Procedure GetSpec
*----------------
set color to n+/g,n/bg
@06,10 say 'Local Name    :' get nama
@07,10 say 'NFI Code      :' get nfi
@08,10 say 'Place         :' get tempat

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
Procedure SpecCurRegion
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
Procedure SpecAllRegion
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