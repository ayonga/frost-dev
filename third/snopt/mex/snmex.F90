!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
! mxsnWork module for SNOPT Fortran mex
!
! 13 Sep 2013: First version.
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#include "fintrf.h"

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

module mxsnWork
  implicit none
  public

  ! SNOPT workspace
  integer            :: leniw = 5000, lenrw = 5000, lencw = 500
  integer,          allocatable :: iw(:), iw0(:)
  double precision, allocatable :: rw(:), rw0(:)
  character*8,      allocatable :: cw(:), cw0(:)

  ! Matlab
  integer*4, parameter :: mxREAL = 0

  ! SNOPT mex variables
  mwPointer            :: stopHandle

  logical              :: firstCall = .true.,  &
                          memCall   = .false., &
                          printOpen = .false., &
                          summOpen  = .false., &
                          screenON  = .false.

  integer              :: callType = 0


  integer, parameter   :: iPrint     = 9, iSpecs   = 4, iSumm    = 55, &
                          systemCall = 0, userCall = 1
  integer, parameter   :: snSolve    = 1,  &
                          snSetXX    = 2,  &
                          snSetIX    = 3,  &
                          snSetRX    = 4,  &
                          snGetXX    = 5,  &
                          snGetCX    = 6,  &
                          snGetIX    = 7,  &
                          snGetRX    = 8,  &
                          snSpecs    = 9,  &
                          snOpenP    = 10, &
                          snOpenS    = 11, &
                          snClosP    = 12, &
                          snClosS    = 13, &
                          snSetWork  = 14, &
                          snscrnON   = 15, &
                          snscrnOff  = 16, &
                          snFindJac  = 17, &
                          snEnd      = 999

  public :: resetWork, deallocI, deallocR, checkCol, checkRow, &
            copyMxArrayI, copyMxArrayR

contains

  !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  subroutine resetWork
    !---------------------------------------------------------------------------
    ! Reset workspace, output for new problem.f
    !---------------------------------------------------------------------------

    !    if (printOpen) close(iPrint)
    close(iPrint)
    printOpen = .false.

    !    if (summOpen) close(iSumm)
    close(iSumm)
    summOpen  = .false.

    close(iSpecs)

    firstCall = .true.
    memCall   = .false.

    leniw     = 5000
    lenrw     = 5000
    lencw     = 500

    if (allocated(cw)) deallocate(cw)
    if (allocated(iw)) deallocate(iw)
    if (allocated(rw)) deallocate(rw)

    if (allocated(cw0)) deallocate(cw0)
    if (allocated(iw0)) deallocate(iw0)
    if (allocated(rw0)) deallocate(rw0)

  end subroutine resetWork

  !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  subroutine deallocI(array)
    integer, allocatable :: array(:)

    if (allocated(array)) deallocate(array)

  end subroutine deallocI

  !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  subroutine deallocR(array)
    double precision, allocatable :: array(:)

    if (allocated(array)) deallocate(array)

  end subroutine deallocR

  !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  subroutine checkCol(pm, n, name)
    mwPointer     :: pm
    integer       :: n
    character*(*) :: name
    !---------------------------------------------------------------------------
    ! Check column dimension of pm is equal to n.
    !---------------------------------------------------------------------------
    character*80 :: str
    mwSize       :: m, mxGetN

    m = mxGetN(pm)
    if (m /= n) then
       write(str,100) name, m, n
       call mexErrMsgTxt (str)
    end if

    return

100 format (a, ' has incorrect column dimension ', i5, &
                '.  Should be length ', i5)

  end subroutine checkCol

  !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  subroutine checkRow(pm, n, name)
    character*(*) :: name
    mwPointer     :: pm
    integer       :: n
    !---------------------------------------------------------------------------
    ! Check row dimension of pm is equal to n.
    !---------------------------------------------------------------------------
    character*80 :: str
    mwSize       :: m, mxGetM

    m = mxGetM(pm)
    if (m /= n) then
       write(str,100) name, m, n
       call mexErrMsgTxt (str)
    end if

    return

100 format (a, ' has incorrect row dimension ', i5, &
                '.  Should be length ', i5)

  end subroutine checkRow

  !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  subroutine copyMxArrayR(name, n, mxarray, array, defval)
    character*(*)    :: name
    integer          :: n
    mwPointer        :: mxarray
    double precision :: defval, array(n)
    !---------------------------------------------------------------------
    ! Check if matlab array is empty.
    ! If not empty, copy to real array.
    ! Else, set array to default value.
    !---------------------------------------------------------------------
    mwPointer :: mxGetPr
    mwSize    :: dim
    integer*4 :: mxIsEmpty

    if (n <= 0) return

    if (mxIsEmpty(mxarray) > 0) then
       array(1:n) = defval
    else
       call checkRow(mxarray, n, name)
       call checkCol(mxarray, 1, name)

       dim = n
       call mxCopyPtrToReal8(mxGetPr(mxarray), array(1:n), dim)
    end if

  end subroutine copyMxArrayR

  !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  subroutine copyMxArrayI(name, n, mxarray, array, defval)
    character*(*)    :: name
    integer          :: n, defval, array(n)
    mwPointer        :: mxarray
    !---------------------------------------------------------------------
    ! Check if matlab array is empty.
    ! If not empty, copy to real array.
    ! Else, set array to default value.
    !---------------------------------------------------------------------
    mwPointer        :: mxGetPr
    mwSize           :: dim
    integer*4        :: mxIsEmpty
    double precision :: tarray(n)

    if (n <= 0) return

    if (mxIsEmpty(mxarray) > 0) then
       array(1:n) = defval
    else
       call checkRow(mxarray, n, name)
       call checkCol(mxarray, 1, name)

       dim = n
       !call mxCopyPtrToInteger4(mxGetPr(mxarray), array(1:n), dim)
       call mxCopyPtrToReal8(mxGetPr(mxarray), tarray(1:n), dim)
       array(1:n) = int(tarray(1:n))
    end if

  end subroutine copyMxArrayI

  !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

end module mxsnWork

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

module mxNLP
  use mxsnWork
  implicit none
  public

  mwPointer :: fgHandle

  integer   :: neG

  integer,          allocatable :: xstate(:), Fstate(:)
  double precision, allocatable :: x(:), xmul(:), xlow(:), xupp(:), &
                                   F(:), Fmul(:), Flow(:), Fupp(:)

  integer,          allocatable :: iAfun(:), jAvar(:)
  double precision, allocatable :: A(:)
  integer,          allocatable :: iGfun(:), jGvar(:)

  double precision, allocatable :: G1(:)

  integer,          allocatable :: tFstate(:)
  double precision, allocatable :: tF(:), tFmul(:), tFlow(:), tFupp(:)

contains

  !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  subroutine resetSNOPT
    !---------------------------------------------------------------------------
    ! resetSNOPT for new problem.
    ! (Also registered with mexAtExit to deallocate workspace and close files)
    !---------------------------------------------------------------------------
    call resetWork
    call deallocSNOPT

  end subroutine resetSNOPT

  !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  subroutine allocSNOPT(n, nF, lenA, lenG)
    integer, intent(in) :: n, nF, lenA, lenG
    !---------------------------------------------------------------------------
    ! Allocate space for SNOPT solve.
    !---------------------------------------------------------------------------

    call deallocSNOPT()

    allocate(x(n),  xlow(n),  xupp(n),  xmul(n),  xstate(n))
    allocate(F(nF), Flow(nF), Fupp(nF), Fmul(nF), Fstate(nF))

    if (lenA > 0) then
       allocate(iAfun(lenA), jAvar(lenA), A(lenA))
    end if

    if (lenG > 0) then
       allocate(G1(lenG))
       allocate(iGfun(lenG),  jGvar(lenG))
    end if

  end subroutine allocSNOPT

  !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  subroutine deallocSNOPT()
    !---------------------------------------------------------------------------
    ! Deallocate x,F arrays involved in solve routine.
    !---------------------------------------------------------------------------

    if (fgHandle    /= 0) call mxDestroyArray(fgHandle)
    if (stopHandle  /= 0) call mxDestroyArray(stopHandle)

    fgHandle   = 0
    stopHandle = 0

    call deallocR(x)
    call deallocR(xmul)
    call deallocR(xlow)
    call deallocR(xupp)
    call deallocI(xstate)

    call deallocR(F)
    call deallocR(Fmul)
    call deallocR(Flow)
    call deallocR(Fupp)
    call deallocI(Fstate)

    call deallocI(iAfun)
    call deallocI(jAvar)
    call deallocR(A)

    call deallocR(G1)

    call deallocI(iGfun)
    call deallocI(jGvar)

  end subroutine deallocSNOPT

  !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  subroutine allocJac(n, lenA, lenG)
    integer, intent(in) :: n, lenA, lenG
    !---------------------------------------------------------------------------
    ! Allocate space for snJac.
    !---------------------------------------------------------------------------

    call deallocJac

    allocate(x(n), xlow(n), xupp(n))

    allocate(iAfun(lenA), jAvar(lenA), A(lenA))

    allocate(G1(lenG))
    allocate(iGfun(lenG), jGvar(lenG))

  end subroutine allocJac

  !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  subroutine deallocJac()
    !---------------------------------------------------------------------------
    ! Deallocate space for snJac.
    !---------------------------------------------------------------------------

    if (fgHandle /= 0) call mxDestroyArray(fgHandle)
    fgHandle = 0

    call deallocR(x)
    call deallocR(xlow)
    call deallocR(xupp)

    call deallocI(iAfun)
    call deallocI(jAvar)
    call deallocR(A)

    call deallocI(iGfun)
    call deallocI(jGvar)

    call deallocR(G1)
    call deallocI(iGfun)
    call deallocI(jGvar)

  end subroutine deallocJac

  !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  subroutine allocF(nF)
    integer, intent(in) :: nF
    !---------------------------------------------------------------------------
    ! Allocate F space for snSTOP.
    !---------------------------------------------------------------------------

    call deallocF()
    allocate(tF(nF), tFstate(nF), tFmul(nF), tFlow(nF), tFupp(nF))

  end subroutine allocF

  !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  subroutine deallocF()
    !---------------------------------------------------------------------------
    ! Deallocate F space for snSTOP.
    !---------------------------------------------------------------------------

    if (allocated(tF))      deallocate(tF)
    if (allocated(tFmul))   deallocate(tFmul)
    if (allocated(tFlow))   deallocate(tFlow)
    if (allocated(tFupp))   deallocate(tFupp)
    if (allocated(tFstate)) deallocate(tFstate)

  end subroutine deallocF

  !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

end module mxNLP

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

module mxQP
  use mxsnWork
  implicit none
  public

  mwPointer :: HxHandle

  ! SQOPT arrays
  integer,          allocatable :: hEtype(:), hs(:), indA(:), locA(:)
  double precision, allocatable :: x(:), cObj(:), pi(:), rc(:), &
                                   bl(:), bu(:), valA(:)

  integer,          allocatable :: iAfun(:), jAvar(:)
  double precision, allocatable :: A(:)

contains

  !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  subroutine resetSQOPT
    !---------------------------------------------------------------------------
    ! resetSQOPT for new problem.
    ! (Also registered with mexAtExit to deallocate workspace and close files)
    !---------------------------------------------------------------------------
    call resetWork
    call deallocSQOPT

  end subroutine resetSQOPT

  !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  subroutine allocSQOPT(n, m, nnH, ncObj, neA)
    integer, intent(in) :: n, m, nnH, ncObj, neA
    !---------------------------------------------------------------------------
    ! Allocate space for SQOPT solve.
    !---------------------------------------------------------------------------

    allocate(x(n+m), pi(m), rc(n+m))
    allocate(bl(n+m), bu(n+m))

    allocate(hs(n+m), hEtype(n+m))

    if (ncObj > 0) then
       allocate(cObj(ncObj))
    else
       allocate(cObj(1))
    end if

    if (neA > 0) then
       allocate(indA(neA))
       allocate(valA(neA))
       allocate(locA(n+1))
    end if

  end subroutine allocSQOPT

  !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  subroutine deallocSQOPT
    !---------------------------------------------------------------------------
    ! Deallocate space for SQOPT solve.
    !---------------------------------------------------------------------------

    if (HxHandle /= 0) call mxDestroyArray(HxHandle)
    HxHandle = 0

    call deallocR(x)
    call deallocR(pi)
    call deallocR(rc)
    call deallocR(bl)
    call deallocR(bu)
    call deallocR(cObj)

    call deallocI(hs)
    call deallocI(hEtype)

    call deallocI(indA)
    call deallocI(locA)
    call deallocR(valA)

  end subroutine deallocSQOPT

  !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

end module mxQP

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
