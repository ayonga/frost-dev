!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
! File sqoptmex.F90
! Mex function for SQOPT7.
!
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#include "fintrf.h"

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

subroutine mexFunction(nlhs, plhs, nrhs, prhs)
  use mxQP
  implicit none

  integer*4  :: nlhs, nrhs
  mwPointer  :: prhs(*), plhs(*)
  !=====================================================================
  ! Mex function for SQOPT7
  !
  ! Option      Action
  !    1        Solve the problem (quadprog-style)
  !    2        Set option
  !    3        Set integer option
  !    4        Set real option
  !    5        Get option
  !    6        Get character option
  !    7        Get integer option
  !    8        Get real option
  !    9        Read specs file
  !    10       Openprint file
  !    11       Opensummary file
  !    12       Closeprint file
  !    13       Closesummary file
  !    14       Set workspace
  !    15       Screen on
  !    16       Screen off
  !
  ! 15 Feb 2017: Current version.
  !=====================================================================
  ! Matlab
  mwPointer        :: mxGetN, mxGetPr
  mwSize           :: dim
  integer*4        :: mxIsChar
  double precision :: mxGetScalar

  ! SQOPT
  character        :: filename*80
  integer          :: iOpt, strlen
  double precision :: rOpt, rleniw, rlenrw
  external         :: sqInit

  ! Get option.
  if (nrhs < 1) call mexErrMsgIdAndTxt('SQOPT:InputArg','Need an option input argument')
  rOpt = mxGetScalar(prhs(1))
  iOpt = rOpt

  call mexAtExit(resetSQOPT)


  ! Deal with on/off screen, file, summary files first.
  if (iOpt == snOpenP) then

     if (nrhs /= 2) &
          call mexErrMsgIdAndTxt('SQOPT:InputArg','Wrong number of input arguments')

     if (mxIsChar(prhs(2)) /= 1) &
          call mexErrMsgIdAndTxt('SQOPT:InputArg','Need a filename string')

     strlen = mxGetN(prhs(2))
     if (strlen > 80) call mexErrMsgIdAndTxt('SQOPT:InputArg','Print filename is too long')

     if (strlen > 0) then
        dim = strlen
        call mxGetString(prhs(2), filename, dim)
     else
        call mexErrMsgIdAndTxt('SQOPT:InputArg','Empty print filename')
     end if

     if (printOpen) close(iPrint)

     open(iPrint, file=filename, status='unknown')
     printOpen= .true.
     return

  else if (iOpt == snOpenS) then

     if (nrhs /= 2) call mexErrMsgIdAndTxt('SQOPT:InputArg','Wrong number of input arguments')

     if (mxIsChar(prhs(2)) /= 1) &
          call mexErrMsgIdAndTxt('SQOPT:InputArg','Need a filename string')

     strlen = mxGetN(prhs(2))
     if (strlen > 80) call mexErrMsgIdAndTxt('SQOPT:InputArg','Summary filename is too long')

     if (strlen > 0) then
        dim = strlen
        call mxGetString(prhs(2), filename, dim)
     else
        call mexErrMsgIdAndTxt('SQOPT:InputArg','Empty summary filename')
     end if

     if (summOpen) close(iSumm)

     open(iSumm, file=filename, status='unknown')
     summOpen= .true.
     return

  else if (iOpt == snClosP) then
     if (printOpen) close(iPrint)
     printOpen= .false.
     return

  else if (iOpt == snClosS) then
     if (summOpen) close(iSumm)
     summOpen= .false.
     return

  else if (iOpt == snscrnOn) then
     screenOn = .true.
     return

  else if (iOpt == snscrnOff) then
     screenOn = .false.
     return

  else if (iOpt == snsetwork) then
     rleniw = mxGetScalar(prhs(2))
     rlenrw = mxGetScalar(prhs(3))
     leniw  = rleniw
     lenrw  = rlenrw

     if (leniw < 500 .or. lenrw < 500) &
          call mexErrMsgIdAndTxt('SQOPT:Workspace','Workspace size must be at least 500')
     return

  end if

  ! What calls get here:
  !   sqSolve, sqSet, sqGet, sqSpecs

  if (firstCall) then
     allocate(cw(lencw), iw(leniw), rw(lenrw))

     callType = userCall
     call sqInit(iPrint, iSumm, cw, lencw, iw, leniw, rw, lenrw)
     callType = systemCall

     memCall   = .false.
     firstCall = .false.
  end if

  ! Do whatever we need to do.
  if      (iOpt == snSolve) then

     callType = userCall
     call sqmxSolve(nlhs, plhs, nrhs, prhs)
     callType = systemCall

  else if (iOpt == snSetXX .or. &
           iOpt == snSetIX .or. &
           iOpt == snSetRX .or. &
           iOpt == snGetXX .or. &
           iOpt == snGetCX .or. &
           iOpt == snGetIX .or. &
           iOpt == snGetRX) then

     callType = userCall
     call snmxOptions(iOpt, nlhs, plhs, nrhs, prhs)
     callType = systemCall

  else if (iOpt == snSpecs) then

     callType = userCall
     call snmxSpecs(nlhs, plhs, nrhs, prhs)
     callType = systemCall

  else if (iOpt == snEnd) then

     call resetSQOPT

  end if

  return

end subroutine mexFunction

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

subroutine sqmxSolve(nlhs, plhs, nrhs, prhs)
  use mxQP
  implicit none

  integer*4  :: nlhs, nrhs
  mwPointer  :: prhs(*), plhs(*)
  !---------------------------------------------------------------------
  ! Solve the problem
  ! The matlab call iss
  !   [x, fval, exit, itn, y ] =
  !       qpsolve(Hx, c, A, b, Aeq, beq, lb, ub, x0)
  !
  ! where
  !   Hx        is a user-defined subroutine to compute H*x
  !   c         is linear terms of the objective
  !   x0        is the initial point
  !   A, b      are the linear inequality constraints A*x <= b
  !   Aeq, beq  are the linear equality constraints Aeq*x = beq
  !   lb, ub    are the lower and upper bounds on x
  !---------------------------------------------------------------------
  ! Matlab
  mwPointer        :: mxDuplicateArray, mxGetM, mxGetN, mxGetPr, &
                      mxCreateDoubleMatrix, mxCreateDoubleScalar
  mwSize           :: dimx, dimy
  integer*4        :: mxIsChar, mxIsClass, mxIsEmpty
  double precision :: mxGetScalar

  ! SQOPT
  character*8      :: probName, Start
  integer          :: Errors, info, i1, i2, strlen
  integer          :: iObj, m, n, nnH, ncObj, neA, &
                      mincw, miniw, minrw, nInf, nS
  double precision :: Obj, ObjAdd, sInf

  external         :: sqopt, matlabHx

  integer,          parameter :: izero = 0
  double precision, parameter :: zero = 0.0d+0, infBnd = 1.0d+20

  integer,         parameter   :: nNames = 1
  character*8                  :: Names(1)


  ! Check number of input and output arguments.
  if (nrhs /= 20) &
       call mexErrMsgIdAndTxt('SQOPT:InputArg','Wrong number of input arguments')


  !-----------------------------------------------------------------------------
  ! Start option
  !-----------------------------------------------------------------------------
  if (mxIsChar(prhs(2)) /= 1) &
       call mexErrMsgIdAndTxt('SQOPT:InputArg','Wrong input type for start')
  dimx = min(8,mxGetN(prhs(2)))
  call mxGetString(prhs(2), start, dimx)


  !---------------------------------------------------------------------
  ! Problem name
  !---------------------------------------------------------------------
  if (mxIsChar(prhs(3)) /= 1) &
       call mexErrMsgIdAndTxt('SQOPT:InputArg','Wrong input type for problem name')
  probName = ''
  if (mxGetN(prhs(3)) > 0) then
     dimx = min(8,mxGetN(prhs(3)))
     call mxGetString(prhs(3), probName, dimx)
  end if


  !---------------------------------------------------------------------
  ! Number of constraints and variables
  !---------------------------------------------------------------------
  m   = mxGetScalar(prhs(4))
  n   = mxGetScalar(prhs(5))

  nnH   = n
  neA   = mxGetScalar(prhs(13))
  ncObj = mxGetM(prhs(7))


  call allocSQOPT(n, m, nnH, ncObj, neA)


  !---------------------------------------------------------------------
  ! Hessian matrix
  !---------------------------------------------------------------------
  if (mxIsClass(prhs(6), 'function_handle') /= 1) &
       call mexErrMsgIdAndTxt('SQOPT:FunArg','Wrong input type for Hx')
  HxHandle = mxDuplicateArray(prhs(6))


  !---------------------------------------------------------------------
  ! Linear term of objective
  !---------------------------------------------------------------------
  call copyMxArrayR('cObj', ncObj, prhs(7), cObj, zero)


  !---------------------------------------------------------------------
  ! Copy x info
  !---------------------------------------------------------------------
  x(n+1:n+m) = zero
  call copyMxArrayR('x0',     n, prhs(8),   x(1:n), zero)
  call copyMxArrayR('xl',     n, prhs(9),  bl(1:n), -infBnd)
  call copyMxArrayR('xu',     n, prhs(10), bu(1:n), infBnd)
  call copyMxArrayI('xstate', n, prhs(11), hs(1:n), izero)
  call copyMxArrayR('xmul',   n, prhs(12), rc(1:n), zero)


  !---------------------------------------------------------------------
  ! Get the linear constraint matrix
  !---------------------------------------------------------------------
  call copyMxArrayI('indA', neA, prhs(14), indA, izero)
  call copyMxArrayI('locA', n+1, prhs(15), locA, izero)
  call copyMxArrayR('valA', neA, prhs(16), valA, zero)


  !---------------------------------------------------------------------
  ! Set the constraint bounds
  !---------------------------------------------------------------------
  i1 = n+1
  i2 = n+m
  call copyMxArrayR('al',     m, prhs(17), bl(i1:i2), -infBnd)
  call copyMxArrayR('au',     m, prhs(18), bu(i1:i2), infBnd)
  call copyMxArrayI('astate', m, prhs(19), hs(i1:i2), izero)
  call copyMxArrayR('amul',   m, prhs(20), rc(i1:i2), zero)


  !---------------------------------------------------------------------
  ! Set workspace
  !---------------------------------------------------------------------
100 if (.not. memCall) then
     call sqMem &
          (INFO, m, n, neA, ncObj, nnH, &
           mincw, miniw, minrw,         &
           cw, lencw, iw, leniw, rw, lenrw)
     memCall = .true.

     if (leniw .le. miniw) then
        ! Not enough integer space
        leniw = miniw
        allocate(iw0(leniw))
        iw0(1:500) = iw(1:500)

        call move_alloc(from=iw0, to=iw)

     end if

     if (lenrw .le. minrw) then
        ! Not enough real space
        lenrw = minrw
        allocate(rw0(lenrw))
        rw0(1:500) = rw(1:500)

        call move_alloc(from=rw0, to=rw)
     end if

     if (lencw .le. mincw) then
        ! Not enough character space
        lencw = mincw
        allocate(cw0(lencw))
        cw0(1:500) = cw(1:500)

        call move_alloc(from=cw0, to=cw)
     end if

     call sqSeti &
          ('Total character workspace', lencw, 0, 0, Errors, &
             cw, lencw, iw, leniw, rw, lenrw)
     call sqSeti &
          ('Total integer   workspace', leniw, 0, 0, Errors, &
             cw, lencw, iw, leniw, rw, lenrw)
     call sqSeti &
          ('Total real      workspace', lenrw, 0, 0, Errors, &
             cw, lencw, iw, leniw, rw, lenrw)
  end if


  !---------------------------------------------------------------------
  ! Solve the problem
  !---------------------------------------------------------------------
  iObj   = 0
  ObjAdd = 0.0
  hEtype(1:n+m) = 0

  call sqopt                                            &
       (Start, matlabHx, m, n, neA, nNames,             &
        ncObj, nnH, iObj, ObjAdd, probName,             &
        valA, indA, locA, bl, bu, cObj, Names,          &
        hEtype, hs, x, pi, rc,                          &
        INFO, mincw, miniw, minrw, nS, nInf, sInf, Obj, &
        cw, lencw, iw, leniw, rw, lenrw,                &
        cw, lencw, iw, leniw, rw, lenrw)

  if (INFO == 82 .or. INFO == 83 .or. INFO == 84) then
     memCall = .false.
     go to 100
  end if


  !-----------------------------------------------------------------------------
  ! Set output
  !-----------------------------------------------------------------------------
  if (nlhs > 0) then
     dimx  = n
     dimy  = 1

     plhs(1) = mxCreateDoubleMatrix(dimx, dimy, mxREAL)
     call mxCopyReal8ToPtr(x(1:n), mxGetPr(plhs(1)), dimx)
  end if

  ! Final objective
  if (nlhs > 1) plhs(2) = mxCreateDoubleScalar(Obj)

  ! Exit flag
  if (nlhs > 2) plhs(3) = mxCreateDoubleScalar(dble(info))

  ! Iterations
  if (nlhs > 3) plhs(4) = mxCreateDoubleScalar(dble(iw(421)))

  ! Multipliers
  if (nlhs > 4) then
     dimx = n+m
     dimy = 1
     plhs(5) = mxCreateDoubleMatrix(dimx, dimy, mxREAL)
     call mxCopyReal8ToPtr(rc(1:n+m), mxGetPr(plhs(5)), dimx)
  end if

  ! States
  if (nlhs > 5) then
     dimx = n+m
     dimy = 1
     plhs(6) = mxCreateDoubleMatrix(dimx, dimy, mxREAL)
     call mxCopyReal8ToPtr(dble(hs(1:n+m)), mxGetPr(plhs(6)), dimx)
  end if


  ! Deallocate memory
  call deallocSQOPT

end subroutine sqmxSolve

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

subroutine snmxOptions(iOpt, nlhs, plhs, nrhs, prhs)
  use mxQP
  implicit none

  integer    :: iOpt
  integer*4  :: nlhs, nrhs
  mwPointer  :: prhs(*), plhs(*)
  !---------------------------------------------------------------------
  ! Set/get options.
  !---------------------------------------------------------------------
  ! Matlab
  mwPointer        :: mxGetN, mxGetPr, mxCreateDoubleScalar, &
                      mxCreateString
  mwSize           :: dim
  double precision :: mxGetScalar

  character        :: buffer*50, cvalue*8
  integer          :: Errors, ivalue, strlen
  double precision :: rvalue

  integer          :: sqGet
  external         :: sqSet, sqSetI, sqSetR, &
                      sqGet, sqGetC, sqGetI, sqGetR


  if (iOpt == snSetIX .or. iOpt == snSetRX) then
     if (nrhs /= 3) call mexErrMsgIdAndTxt('SQOPT:InputArg','Wrong number of input arguments')
  else
     if (nrhs /= 2) call mexErrMsgIdAndTxt('SQOPT:InputArg','Wrong number of input arguments')
  end if


  ! Get string
  strlen = mxGetN(prhs(2))
  if (strlen > 50) call mexErrMsgIdAndTxt('SQOPT:InputArg','Option string is too long')

  if (strlen > 0) then
     dim = strlen
     call mxGetString(prhs(2), buffer, dim)
  else
     call mexErrMsgIdAndTxt('SQOPT:InputArg','Empty option string')
  end if


  if      (iOpt == snSetXX) then
     call sqSet(buffer, iPrint, iSumm, Errors, &
                cw, lencw, iw, leniw, rw, lenrw)

  else if (iOpt == snSetIX) then

     rvalue = mxGetScalar(prhs(3))
     ivalue = rvalue

     call sqSetI(buffer, ivalue, iPrint, iSumm, Errors, &
                 cw, lencw, iw, leniw, rw, lenrw)

  else if (iOpt == snSetRX) then

     rvalue = mxGetScalar(prhs(3))

     call sqSetR(buffer, rvalue, iPrint, iSumm, Errors, &
                 cw, lencw, iw, leniw, rw, lenrw)

  else if (iOpt == snGetXX) then

     ivalue  = sqGet(buffer, Errors, cw, lencw, iw, leniw, rw, lenrw)

     rvalue  = ivalue
     plhs(1) = mxCreateDoubleScalar (rvalue)

  else if (iOpt == snGetCX) then

     call sqGetC(buffer, cvalue, Errors, &
                 cw, lencw, iw, leniw, rw, lenrw)

     plhs(1) = mxCreateString(cvalue)

  else if (iOpt == snGetIX) then

     call sqGetI(buffer, ivalue, Errors, &
                 cw, lencw, iw, leniw, rw, lenrw)

     rvalue = ivalue
     plhs(1) = mxCreateDoubleScalar (rvalue)

  else if (iOpt == snGetRX) then

     call sqGetR(buffer, rvalue, Errors, &
                 cw, lencw, iw, leniw, rw, lenrw)

     plhs(1) = mxCreateDoubleScalar (rvalue)

  end if

end subroutine snmxOptions

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

subroutine snmxSpecs(nlhs, plhs, nrhs, prhs)
  use mxQP
  implicit none

  integer*4 :: nlhs, nrhs
  mwPointer :: prhs(*), plhs(*)
  !---------------------------------------------------------------------
  ! Read specs file.
  !---------------------------------------------------------------------
  mwPointer        :: mxCreateDoubleScalar, mxGetN
  mwSize           :: dimx

  character        :: filename*120
  integer          :: info, strlen
  double precision :: rvalue

  external         :: sqSpec


  if (nrhs /= 2) call mexErrMsgIdAndTxt('SQOPT:InputArg','Wrong number of input arguments')
  if (nlhs /= 1) call mexErrMsgIdAndTxt('SQOPT:InputArg','Wrong number of output arguments')

  strlen = mxGetN(prhs(2))
  if (strlen > 120) call mexErrMsgIdAndTxt('SQOPT:InputArg','Specs filename is too long')

  if (strlen > 0) then
     dimx = strlen
     call mxGetString(prhs(2), filename, dimx)
  else
     call mexErrMsgIdAndTxt('SQOPT:InputArg','Empty spc filename')
  end if

  open(iSpecs, file=filename, status='unknown')
  call sqSpec(iSpecs, info, cw, lencw, iw, leniw, rw, lenrw)
  rewind (iSpecs)
  close(iSpecs)

  ! sqSpec will return info == 101 or 107 if successful
  ! The matlab version returns 0 if successful
  if (info == 101 .or. info == 107) then
     rvalue = 0
  else
     rvalue = 1
  end if

  plhs(1) = mxCreateDoubleScalar (rvalue)

end subroutine snmxSpecs

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

subroutine matlabHx(nnH, x, Hx, Status, cu, lencu, iu, leniu, ru, lenru)
  use mxsnWork, only : checkCol, checkRow, mxREAL
  use mxQP,     only : HxHandle
  implicit none

  integer          :: Status, nnH, lencu, leniu, lenru, iu(leniu)
  double precision :: x(nnH), Hx(nnH), ru(lenru)
  character*8      :: cu(lencu)

  !---------------------------------------------------------------------
  ! Matlab callback to evaluate H*x.
  !---------------------------------------------------------------------
  integer*4 :: nlhs, nrhs
  mwPointer :: prhs(2), plhs(1)
  mwPointer :: mxCreateDoubleMatrix, mxGetPr, mxDuplicateArray
  mwSize    :: dimx, dimy

  nlhs = 1
  nrhs = 2

  prhs(1) = mxDuplicateArray(HxHandle)

  dimx = nnH
  dimy = 1
  prhs(2) = mxCreateDoubleMatrix (dimx, dimy, mxREAL)
  call mxCopyReal8ToPtr(x, mxGetPr(prhs(2)), dimx)


  ! Call Matlab: [Hx] = userHx(x)
  call mexCallMatlab(nlhs, plhs, nrhs, prhs, 'feval')

  dimx = nnH
  call mxCopyPtrToReal8(mxGetPr(plhs(1)), Hx, dimx)

  ! Destroy arrays
  call mxDestroyArray(plhs(1))
  call mxDestroyArray(prhs(1))
  call mxDestroyArray(prhs(2))

end subroutine matlabHx

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
