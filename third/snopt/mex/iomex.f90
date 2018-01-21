!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
!
!     File  iomex.f90
!
!     snPRNT  ioTRIM  snREAD
!
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

subroutine snPRNT ( mode, string, iw, leniw )
  implicit none
  character*(*) string
  integer       mode, leniw, iw(leniw)

  !=====================================================================
  ! snPRNT  prints a trimmed form of "string" on various files.
  ! If mode = 0,      nothing is output.
  ! If mode = 1,      string is output to iPrint.
  ! If mode = 2,      string is output to iSumm.
  ! If mode = 3 or 4, string is output to iPrint and iSumm.
  ! If mode = 4,      string is output to the screen.
  !                   This mode is intended for error messages.
  ! If mode = 5,      string is output to iStdo (standard output)
  !                   This mode is to be used when the elements of
  !                   the integer work array iw cannot be trusted.
  !
  ! mode 11-15 are the same as mode 1-5 with blank line before output.
  !
  ! If mode > 15 then nothing is printed unless  lvlSys > 0.
  ! mode 21-25 are the same as mode 1-5
  ! mode 31-35 are the same as mode 11-15
  !
  ! 25 Sep 2002: First version of snPRNT.
  ! 31 Jul 2003: mode 11-14 added.  form introduced.
  ! 27 Dec 2003: mode 5 added to allow printing before iw is set.
  ! 12 Mar 2004: s1trim called to trim the string.
  ! 22 Jun 2004: System printing option added.
  ! 14 Oct 2004: Matlab version of snPRNT.
  ! 30 Apr 2006: Files opened and closed in C.
  !=====================================================================
  integer   iPrint, iSumm, length, lvlSys, m, newline, &
            screenOK, summaryOK, printOK
  character Buff*140

  lvlSys = iw( 91) ! > 0   => print system info

  newline = 0
  m       = 0
  if (mode .le.  0) then
     ! Relax
  else if (mode   .lt. 10) then
     m       = mode
  else if (mode   .lt. 20) then ! Blank line first
     m       = mode - 10
     newline = 1
  else if (lvlSys .gt.  0) then ! Print system Info
     if (mode .lt. 30) then
        m       = mode - 20
     else
        m       = mode - 30
        newline = 1
     end if
  end if


  if (m .gt. 0) then

     call iomexfilestatus( screenOK, summaryOK, printOK  )

     ! length = len_trim(string)     ! An F90 intrinsic
     call ioTRIM( string, length ) ! The F77 equivalent
     Buff = string

     if (m .eq. 5) then
        call iomexwritescreen( newline, Buff, length)
     else
        iPrint = iw( 12) ! Print file
        iSumm  = iw( 13) ! Summary file

        if (m .eq. 1  .or.  m .ge. 3) then
           if (printOK .gt. 0) then
              call iomexwritefile( newline, iPrint, Buff, length )
           end if
        end if

        if (m .eq. 2  .or.  m .ge. 3) then
           if (screenOK  .gt. 0) then
              call iomexwritescreen( newline, Buff, length)
           end if
           if (summaryOK .gt. 0) then
              call iomexwritefile( newline, iSumm , Buff, length )
           end if
        end if

        if (m .eq. 4) then
           call iomexwritescreen( newline, Buff, length)
        end if
     end if
  end if

end subroutine snPRNT

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

subroutine ioTrim( buffer, lenbuf )
  implicit none
  character*(*) buffer
  integer       lenbuf

!===================================================================
! ioTrim  returns the length of buffer with trailing blanks omitted.
!
! 02 Dec 2000: First version written for snLog and snLog2.
!===================================================================
  integer k

  lenbuf = len( buffer )
  do k = lenbuf, 2, -1
     if (buffer(k:k) .ne. ' ') go to 100
     lenbuf = lenbuf - 1
  end do

100 return

end subroutine ioTrim

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

subroutine snREAD ( unitno, string, nchar, endfile )
  implicit none
  character*(*) string
  integer       endfile, nchar, unitno
  !===================================================================
  ! snREAD reads a string of length nchar from file  unitno.
  !
  ! 30 Apr 2006: First version of snREAD.
  ! 30 Apr 2006: Matlab version.
  !===================================================================
  call iomexRead ( unitno, string, nchar, endfile )

end subroutine snREAD

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

subroutine iomexFileStatus ( scrnOK, summOK, prntOK )
  use mxsnWork

  implicit none
  integer scrnOK, summOK, prntOK


  if ( screenOn  .and. callType == 1 ) then
     scrnOK = 1
  else
     scrnOK = 0
  end if

  if ( summOpen  .and. callType == 1 ) then
     summOK = 1
  else
     summOK = 0
  end if

  if ( printOpen .and. callType == 1 ) then
     prntOK = 1
  else
     prntOK = 0
  end if

end subroutine iomexFileStatus

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

subroutine iomexwriteScreen ( newline, buffer, length )

  implicit none
  character*(*) buffer
  integer       newline, length

  if ( length > 140 ) &
       call mexErrMsgTxt ( 'Print buffer too long for snPRNT' )

  if ( newline > 0 ) call mexPrintf ( achar(10) )
  call mexPrintf ( buffer(1:length)//achar(10) )

end subroutine iomexwriteScreen

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

subroutine iomexwriteFile ( newline, unitno, buffer, length )
  use mxsnWork

  implicit none
  character*(*) buffer
  integer       newline, unitno, length


  if ( length > 140 ) &
       call mexErrMsgTxt ( 'Print buffer too long for snPRNT' )

  if      ( unitno == iPrint ) then
     if ( newline > 0 ) then
        write(iPrint,'(/,a)') buffer(1:length)
     else
        write(iPrint,'(a)') buffer(1:length)
     end if

  else if ( unitno == iSumm  ) then
     if ( newline > 0 ) then
        write(iSumm,'(/,a)') buffer(1:length)
     else
        write(iSumm,'(a)') buffer(1:length)
     end if

  end if

end subroutine iomexwriteFile

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

subroutine iomexRead ( unitno, string, nchar, endfile )
  implicit none
  character*(*) string
  integer       endfile, nchar, unitno

  character frmt*6

  frmt    = '      '

  if (nchar .ge. 1  .and.  nchar .le. 999) then
     if      (nchar .lt.  10) then
        write(frmt, '(a2,i1,a1)') '(a', nchar, ')'
     else if (nchar .lt. 100) then
        write(frmt, '(a2,i2,a1)') '(a', nchar, ')'
     else
        write(frmt, '(a2,i3,a1)') '(a', nchar, ')'
     end if

     endfile = 0
     read  (unitno, frmt, end = 100) string

     return
  end if

100 endfile = 1

end subroutine iomexRead
