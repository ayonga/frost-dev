!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
! File snoptmex.F90
! Mex function for SNOPT.
!
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#include "fintrf.h"

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

subroutine mexFunction(nlhs, plhs, nrhs, prhs)
  use mxNLP
  implicit none

  integer*4  :: nlhs, nrhs
  mwPointer  :: prhs(*), plhs(*)
  !=====================================================================
  ! Mex function for SNOPT7
  !
  ! Option      Action
  !    1        Solve the problem
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
  !    17       Compute the Jacobian structure via snJac
  !
  ! 15 Feb 2017: Current version.
  !=====================================================================
  ! Matlab
  mwPointer        :: mxGetN, mxGetPr
  mwSize           :: dim
  integer*4        :: mxIsChar
  double precision :: mxGetScalar

  ! SNOPT
  character        :: filename*80
  integer          :: iOpt, strlen
  double precision :: rOpt, rleniw, rlenrw
  external         :: snInit

  ! Get option.
  if (nrhs < 1) call mexErrMsgIdAndTxt('SNOPT:InputArgs','Need an option input argument')
  rOpt = mxGetScalar(prhs(1))
  iOpt = rOpt

  ! Register exit function.
  call mexAtExit(resetSNOPT)


  ! Deal with on/off screen, print, and summary files first.
  if (iOpt == snOpenP) then

     if (nrhs /= 2) &
          call mexErrMsgIdAndTxt('SNOPT:InputArgs','Wrong number of input arguments')

     if (mxIsChar(prhs(2)) /= 1) &
          call mexErrMsgIdAndTxt('SNOPT:FileArgs','Need a filename string')

     strlen = mxGetN(prhs(2))
     if (strlen > 80) call mexErrMsgIdAndTxt('SNOPT:FileArg','Print filename is too long')

     if (strlen > 0) then
        dim = strlen
        call mxGetString(prhs(2), filename, dim)
     else
        call mexErrMsgIdAndTxt('SNOPT:FileArg','Empty print filename')
     end if

     if (printOpen) close(iPrint)

     open(iPrint, file=filename, status='unknown')
     printOpen= .true.
     return

  else if (iOpt == snOpenS) then

     if (nrhs /= 2) call mexErrMsgIdAndTxt('SNOPT:InputArgs','Wrong number of input arguments')

     if (mxIsChar(prhs(2)) /= 1) &
          call mexErrMsgIdAndTxt('SNOPT:FileArgs','Need a filename string')

     strlen = mxGetN(prhs(2))
     if (strlen > 80) call mexErrMsgIdAndTxt('SNOPT:FileArgs','Summary filename is too long')

     if (strlen > 0) then
        dim = strlen
        call mxGetString(prhs(2), filename, dim)
     else
        call mexErrMsgIdAndTxt('SNOPT:FileArg','Empty print filename')
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
          call mexErrMsgIdAndTxt('SNOPT:Workspace','Workspace size must be at least 500')
     return
  end if

  ! What calls get to this point:
  !  snSolve, snGet, snSet, snSpecs, snJac
  if (firstCall) then
     allocate(cw(lencw), iw(leniw), rw(lenrw))

     callType = userCall
     call snInit (iPrint, iSumm, cw, lencw, iw, leniw, rw, lenrw)
     callType = systemCall

     memCall   = .false.
     firstCall = .false.
  end if

  ! Do whatever we need to do.
  if      (iOpt == snSolve) then

     callType = userCall
     call snmxSolve (nlhs, plhs, nrhs, prhs)
     callType = systemCall

  else if (iOpt == snFindJac) then

     callType = userCall
     call snmxFindJac (nlhs, plhs, nrhs, prhs)
     callType = systemCall

  else if (iOpt == snSetXX .or. &
           iOpt == snSetIX .or. &
           iOpt == snSetRX .or. &
           iOpt == snGetXX .or. &
           iOpt == snGetCX .or. &
           iOpt == snGetIX .or. &
           iOpt == snGetRX) then

     callType = userCall
     call snmxOptions (iOpt, nlhs, plhs, nrhs, prhs)
     callType = systemCall

  else if (iOpt == snSpecs) then

     callType = userCall
     call snmxSpecs (nlhs, plhs, nrhs, prhs)
     callType = systemCall

  else if (iOpt == snEnd) then

     call resetSNOPT

  end if

  return

end subroutine mexFunction

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

subroutine snmxSolve (nlhs, plhs, nrhs, prhs)
  use mxNLP
  implicit none

  integer*4  :: nlhs, nrhs
  mwPointer  :: prhs(*), plhs(*)
  !---------------------------------------------------------------------
  ! Solve the problem
  ! The matlab call is
  !   [x, F, xmul, Fmul, info ] =
  !       snoptmex(solveopt, x, xlow, xupp, xmul, xstate,
  !                           F, Flow, Fupp, Fmul, Fstate, ObjAdd,
  !                ObjRow, A, iAfun, jAvar, iGfun, jGvar, userfun)
  !---------------------------------------------------------------------
  ! Matlab
  mwPointer        :: mxDuplicateArray, mxGetM, mxGetN, mxGetPr, &
                      mxCreateDoubleMatrix, mxCreateDoubleScalar
  mwSize           :: dimx, dimy
  integer*4        :: mxIsChar, mxIsClass, mxIsEmpty, mxIsNumeric
  double precision :: mxGetScalar

  ! SNOPT
  character*8      :: probName
  integer          :: Errors, info
  integer          :: Start, ObjRow, n, nF, lenA, lenG, neA, &
                      mincw, miniw, minrw, nInf, nS
  double precision :: rinfo, ObjAdd, sInf
  external         :: snMemA, snKerA, matlabFG, matlabSTOP
  external         :: snLog, snLog2, sqLog

  double precision, allocatable :: riAfun(:), rjAvar(:), riGfun(:), rjGvar(:)

  integer,          parameter   :: izero = 0
  double precision, parameter   :: zero = 0.0d+0, infBnd = 1.0d+20

  integer,          parameter   :: nxname = 1, nFname = 1
  character*8                   :: xname(1), Fname(1)


  ! Check number of input and output arguments.
  if (nrhs /= 21) &
       call mexErrMsgIdAndTxt('SNOPT:InputArgs','Wrong number of input arguments')


  !---------------------------------------------------------------------
  ! Compute number of variables, constraints, etc
  !---------------------------------------------------------------------
  ! Get number of variables and constraints
  n  = mxGetM(prhs(6))
  nF = mxGetM(prhs(11))

  if (mxIsEmpty(prhs(17)) > 0) then
     neA  = 0
     lenA = 0
  else
     neA  = mxGetM(prhs(17))
     lenA = neA
  end if

  if (mxIsEmpty(prhs(20)) > 0) then
     neG  = 0
     lenG = 0
  else
     neG  = mxGetM(prhs(20))
     lenG = neG
  end if


  !-----------------------------------------------------------------------------
  ! Allocate space for SNOPT
  !-----------------------------------------------------------------------------
  call allocSNOPT(n, nF, lenA, lenG)


  !-----------------------------------------------------------------------------
  ! Start
  !-----------------------------------------------------------------------------
  start = mxGetScalar(prhs(2))


  !-----------------------------------------------------------------------------
  ! STOP function
  !-----------------------------------------------------------------------------
  stopHandle = 0
  if (mxIsNumeric(prhs(3)) /= 1) then
     ! Check if STOP functions is actually a function
     if (mxIsClass(prhs(3), 'function_handle') /= 1) &
          call mexErrMsgIdAndTxt('DNOPT:INputArgs','Wrong input type for dnSTOP')
     stopHandle = mxDuplicateArray(prhs(3))
  end if


  !-----------------------------------------------------------------------------
  ! Problem name
  !-----------------------------------------------------------------------------
  probName = ''
  if (mxIsChar(prhs(4)) /= 1) &
       call mexErrMsgIdAndTxt('DNOPT:InputArg','Wrong input type for problem name')

  if (mxGetN(prhs(4)) > 0) then
     dimx = min(8,mxGetN(prhs(4)))
     call mxGetString(prhs(4), probName, dimx)
  end if

  !-----------------------------------------------------------------------------
  ! userfg function handle
  !-----------------------------------------------------------------------------
  if (mxIsClass(prhs(5), 'function_handle') /= 1) &
       call mexErrMsgIdAndTxt('SNOPT:FunArg','Wrong input type for userfg')
  fgHandle = mxDuplicateArray(prhs(5))


  !-----------------------------------------------------------------------------
  ! Copy x and F info
  !-----------------------------------------------------------------------------
  call copyMxArrayR('x0', n, prhs(6), x(1:n), zero)
  call copyMxArrayR('xlow', n, prhs(7), xlow(1:n), -infBnd)
  call copyMxArrayR('xupp', n, prhs(8), xupp(1:n),  infBnd)
  call copyMxArrayR('xmul', n, prhs(9), xmul(1:n), zero)
  call copyMxArrayI('xstate', n, prhs(10), xstate(1:n), izero)

  call copyMxArrayR('Flow', nF, prhs(11), Flow(1:n), -infBnd)
  call copyMxArrayR('Fupp', nF, prhs(12), Fupp(1:n),  infBnd)
  call copyMxArrayR('Fmul', nF, prhs(13), Fmul(1:n), zero)
  call copyMxArrayI('Fstate', nF, prhs(14), Fstate(1:n), izero)

  ObjAdd  = mxGetScalar(prhs(15))
  ObjRow  = mxGetScalar(prhs(16))


  !---------------------------------------------------------------------
  ! Get the Jacobian structure (linear and nonlinear)
  !---------------------------------------------------------------------
  if (neA > 0) then
     call checkCol(prhs(17),   1, 'A')

     call checkRow(prhs(18), neA, 'iAfun')
     call checkCol(prhs(18),   1, 'iAfun')
     call checkRow(prhs(19), neA, 'jAvar')
     call checkCol(prhs(19),   1, 'jAvar')

     allocate(riAfun(neA), rjAvar(neA))
     call mxCopyPtrToReal8(mxGetPr(prhs(17)),      A, neA)
     call mxCopyPtrToReal8(mxGetPr(prhs(18)), riAfun, neA)
     call mxCopyPtrToReal8(mxGetPr(prhs(19)), rjAvar, neA)
     iAfun(1:neA) = int(riAfun(1:neA))
     jAvar(1:neA) = int(rjAvar(1:neA))
     deallocate(riAfun, rjAvar)
  end if


  if (neG > 0) then
     call checkCol(prhs(20),   1, 'iGfun')
     call checkRow(prhs(21), neG, 'jGvar')
     call checkCol(prhs(21),   1, 'jGvar')

     allocate(riGfun(neG), rjGvar(neG))
     call mxCopyPtrToReal8(mxGetPr(prhs(20)), riGfun, neG)
     call mxCopyPtrToReal8(mxGetPr(prhs(21)), rjGvar, neG)
     iGfun(1:neG) = int(riGfun(1:neG))
     jGvar(1:neG) = int(rjGvar(1:neG))
     deallocate(riGfun, rjGvar)
  end if


  !---------------------------------------------------------------------
  ! Set workspace
  !---------------------------------------------------------------------
100 if (.not. memCall) then
     call snMemA &
          (INFO, nF, n, nxname, nfname, neA, neG, &
            mincw, miniw, minrw, &
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

     call snSeti &
          ('Total character workspace', lencw, 0, 0, Errors, &
             cw, lencw, iw, leniw, rw, lenrw)
     call snSeti &
          ('Total integer   workspace', leniw, 0, 0, Errors, &
             cw, lencw, iw, leniw, rw, lenrw)
     call snSeti &
          ('Total real      workspace', lenrw, 0, 0, Errors, &
             cw, lencw, iw, leniw, rw, lenrw)
  end if

  !---------------------------------------------------------------------
  ! Solve the problem
  !---------------------------------------------------------------------
  call snKerA                                        &
       ( Start, nF, n, nxname, nFname,               &
         objAdd, objRow, probName,                   &
         matlabFG, snLog, snLog2, sqLog, matlabSTOP, &
         iAfun, jAvar, lenA, neA, A,                 &
         iGfun, jGvar, lenG, neG,                    &
         xlow, xupp, xname, Flow, Fupp, Fname,       &
         x, xstate, xmul, F, Fstate, Fmul,           &
         INFO, mincw, miniw, minrw,                  &
         nS, nInf, sInf,                             &
         cw, lencw, iw, leniw, rw, lenrw,            &
         cw, lencw, iw, leniw, rw, lenrw )

  if (INFO == 82 .or. INFO == 83 .or. INFO == 84) then
     memCall = .false.
     go to 100
  end if


  !---------------------------------------------------------------------
  ! Set output
  !---------------------------------------------------------------------
  if (nlhs > 0) then
     dimx = n
     dimy = 1
     plhs(1) = mxCreateDoubleMatrix(dimx, dimy, mxREAL)
     call mxCopyReal8ToPtr(x, mxGetPr(plhs(1)), dimx)
  end if


  ! Constraints
  if (nlhs > 1) then
     dimx = nF
     dimy = 1
     plhs(2) = mxCreateDoubleMatrix(dimx, dimy, mxREAL)
     call mxCopyReal8ToPtr(F, mxGetPr(plhs(2)), dimx)
  end if


  ! Exit flag
  rinfo = info
  if (nlhs > 2) plhs(3) = mxCreateDoubleScalar(rinfo)


  ! Multipliers for bounds
  if (nlhs > 3) then
     dimx = n
     dimy = 1
     plhs(4) = mxCreateDoubleMatrix(dimx, dimy, mxREAL)
     call mxCopyReal8ToPtr(xmul, mxGetPr(plhs(4)), dimx)
  end if


  ! Multipliers for linear inequalities
  if (nlhs > 4) then
     dimx = nF
     dimy = 1
     plhs(5) = mxCreateDoubleMatrix(dimx, dimy, mxREAL)
     call mxCopyReal8ToPtr(Fmul, mxGetPr(plhs(5)), dimx)
  end if

  ! State variables
  if ( nlhs > 5 ) then
     dimx = n
     dimy = 1
     plhs(6) = mxCreateDoubleMatrix(dimx, dimy, mxREAL)
     call mxCopyReal8ToPtr(dble(xstate(1:n)), mxGetPr(plhs(6)), dimx)
  end if

  ! State variables
  if ( nlhs > 6 ) then
     dimx = nF
     dimy = 1
     plhs(7) = mxCreateDoubleMatrix(dimx, dimy, mxREAL)
     call mxCopyReal8ToPtr(dble(Fstate(1:nF)), mxGetPr(plhs(7)), dimx)
  end if

  ! Number of total iterations, major itns
  rinfo = iw(421)
  if (nlhs > 7) plhs(8) = mxCreateDoubleScalar(rinfo)

  rinfo = iw(422)
  if (nlhs > 8) plhs(9) = mxCreateDoubleScalar(rinfo)


  ! Deallocate memory
  call deallocSNOPT

end subroutine snmxSolve

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

subroutine snmxFindJac (nlhs, plhs, nrhs, prhs)
  use mxNLP
  implicit none

  integer*4  :: nlhs, nrhs
  mwPointer  :: prhs(*), plhs(*)
  !---------------------------------------------------------------------
  ! Find the structure of the Jacobian matrix.
  ! The matlab call is
  !  [A,iAfun,jAvar,iGfun,jGvar] = snJac(usrfun, x0, xlow, xupp, nF)
  !
  ! 25 Sep 2013: First Fortran version.
  !---------------------------------------------------------------------
  mwPointer        :: mxGetM, mxGetPr, mxCreateDoubleMatrix, &
                      mxDuplicateArray
  mwSize           :: dimx, dimy
  integer*4        :: mxIsClass
  double precision :: mxGetScalar

  integer          :: iExit, Errors, info, lenA, lenG, n, neA, nF, &
                      mincw, miniw, minrw
  external         :: snMemA, snJac, snjacFG

  double precision, allocatable :: riAfun(:), rjAvar(:), riGfun(:), rjGvar(:)
  integer,           parameter  :: nxname = 1, nFname = 1


  if (nlhs /= 5) &
       call mexErrMsgIdAndTxt('SNOPT:InputArg','Wrong number of output variables')
  if (nrhs /= 6) &
       call mexErrMsgIdAndTxt('SNOPT:InputArg','Wrong number of input arguments')


  ! Set the number of variables and constraints
  n  = mxGetM(prhs(3))
  nF = int(mxGetScalar(prhs(6)))

  if (nF == 0 .or. n == 0) &
       call mexErrMsgIdAndTxt('SNOPT:Input','Empty inputs to snJac')

  ! Allocate space
  lenA = n*nF
  neA  = lenA
  lenG = lenA
  neG  = lenA

  call allocJac(n, lenA, lenG)


  ! Get userfg function
  if (mxIsClass(prhs(2),'function_handle') /= 1) &
       call mexErrMsgIdAndTxt('SNOPT:FunArg','Wrong input type for userfg')
  fgHandle = mxDuplicateArray(prhs(2))


  ! Get x0, lower and upper bounds
  call mxCopyPtrToReal8(mxGetPr(prhs(3)), x, n)
  call mxCopyPtrToReal8(mxGetPr(prhs(4)), xlow, n)
  call mxCopyPtrToReal8(mxGetPr(prhs(5)), xupp, n)


  !---------------------------------------------------------------------
  ! Set workspace
  !---------------------------------------------------------------------
100 if (.not. memCall) then
     call snMemA &
          (INFO, nF, n, nxname, nfname, neA, neG, &
            mincw, miniw, minrw, &
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

     call snSeti &
          ('Total character workspace', lencw, 0, 0, Errors, &
             cw, lencw, iw, leniw, rw, lenrw)
     call snSeti &
          ('Total integer   workspace', leniw, 0, 0, Errors, &
             cw, lencw, iw, leniw, rw, lenrw)
     call snSeti &
          ('Total real      workspace', lenrw, 0, 0, Errors, &
             cw, lencw, iw, leniw, rw, lenrw)
  end if


  !---------------------------------------------------------------------
  ! Compute the structure of the Jacobian
  !---------------------------------------------------------------------
  call snJac(iExit, nF, n, snjacFG,              &
             iAfun, jAvar, lenA, neA, A,         &
             iGfun, jGvar, lenG, neG,            &
             x, xlow, xupp, mincw, miniw, minrw, &
             cw, lencw, iw, leniw, rw, lenrw,    &
             cw, lencw, iw, leniw, rw, lenrw)

  if (INFO == 82 .or. INFO == 83 .or. INFO == 84) then
     memCall = .false.
     go to 100
  end if


  ! Set output [A, iAfun, jAvar, iGfun, jGvar ]
  dimx    = neA
  dimy    = 1
  plhs(1) = mxCreateDoubleMatrix(dimx, dimy, mxREAL)
  plhs(2) = mxCreateDoubleMatrix(dimx, dimy, mxREAL)
  plhs(3) = mxCreateDoubleMatrix(dimx, dimy, mxREAL)
  call mxCopyReal8ToPtr(A(1:neA), mxGetPr(plhs(1)), dimx)
  call mxCopyReal8ToPtr(dble(iAfun(1:neA)), mxGetPr(plhs(2)), dimx)
  call mxCopyReal8ToPtr(dble(jAvar(1:neA)), mxGetPr(plhs(3)), dimx)

  dimx    = neG
  dimy    = 1
  plhs(4) = mxCreateDoubleMatrix(dimx, dimy, mxREAL)
  plhs(5) = mxCreateDoubleMatrix(dimx, dimy, mxREAL)
  call mxCopyReal8ToPtr(dble(iGfun(1:neG)), mxGetPr(plhs(4)), dimx)
  call mxCopyReal8ToPtr(dble(jGvar(1:neG)), mxGetPr(plhs(5)), dimx)

  call deallocJac

end subroutine snmxFindJac

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

subroutine snmxOptions(iOpt, nlhs, plhs, nrhs, prhs)
  use mxNLP
  implicit none

  integer    :: iOpt
  integer*4  :: nlhs, nrhs
  mwPointer  :: prhs(*), plhs(*)
  !---------------------------------------------------------------------
  ! Set/get options.
  !---------------------------------------------------------------------
  mwPointer        :: mxGetN, mxGetPr, mxCreateDoubleScalar, &
                      mxCreateString
  double precision :: mxGetScalar

  character        :: buffer*50, cvalue*8
  integer          :: Errors, ivalue, strlen
  double precision :: rvalue

  integer          :: snGet
  external         :: snSet, snSetI, snSetR, &
                      snGet, snGetC, snGetI, snGetR


  if (iOpt == snSetIX .or. iOpt == snSetRX) then
     if (nrhs /= 3) call mexErrMsgIdAndTxt('SNOPT:InputArg','Wrong number of input arguments')
  else
     if (nrhs /= 2) call mexErrMsgIdAndTxt('SNOPT:InputArg','Wrong number of input arguments')
  end if


  ! Get string
  strlen = mxGetN(prhs(2))
  if (strlen > 50) call mexErrMsgIdAndTxt('SNOPT:InputArg','Option string is too long')

  if (strlen > 0) then
     call mxGetString(prhs(2), buffer, strlen)
  else
     call mexErrMsgIdAndTxt('SNOPT:InputArg','Empty option string')
  end if


  if      (iOpt == snSetXX) then
     call snSet(buffer, iPrint, iSumm, Errors, &
                 cw, lencw, iw, leniw, rw, lenrw)

  else if (iOpt == snSetIX) then

     rvalue = mxGetScalar(prhs(3))
     ivalue = rvalue

     call snSetI(buffer, ivalue, iPrint, iSumm, Errors, &
                  cw, lencw, iw, leniw, rw, lenrw)

  else if (iOpt == snSetRX) then

     rvalue = mxGetScalar(prhs(3))

     call snSetR(buffer, rvalue, iPrint, iSumm, Errors, &
                  cw, lencw, iw, leniw, rw, lenrw)

  else if (iOpt == snGetXX) then

     ivalue  = snGet(buffer, Errors, cw, lencw, iw, leniw, rw, lenrw)

     rvalue  = ivalue
     plhs(1) = mxCreateDoubleScalar(rvalue)

  else if (iOpt == snGetCX) then

     call snGetC(buffer, cvalue, Errors, &
                  cw, lencw, iw, leniw, rw, lenrw)

     plhs(1) = mxCreateString(cvalue)

  else if (iOpt == snGetIX) then

     call snGetI(buffer, ivalue, Errors, &
                  cw, lencw, iw, leniw, rw, lenrw)

     rvalue = ivalue
     plhs(1) = mxCreateDoubleScalar(rvalue)

  else if (iOpt == snGetRX) then

     call snGetR(buffer, rvalue, Errors, &
                  cw, lencw, iw, leniw, rw, lenrw)

     plhs(1) = mxCreateDoubleScalar(rvalue)

  end if

end subroutine snmxOptions

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

subroutine snmxSpecs(nlhs, plhs, nrhs, prhs)
  use mxNLP
  implicit none

  integer*4  :: nlhs, nrhs
  mwPointer  :: prhs(*), plhs(*)
  !---------------------------------------------------------------------
  ! Read specs file.
  !---------------------------------------------------------------------
  ! Matlab
  mwPointer        :: mxCreateDoubleScalar, mxGetN
  mwSize           :: dimx

  character        :: filename*120
  integer          :: info, strlen
  double precision :: rvalue

  external         :: snSpec


  if (nrhs /= 2) call mexErrMsgIdAndTxt('SNOPT:InputArg','Wrong number of input arguments')
  if (nlhs /= 1) call mexErrMsgIdAndTxt('SNOPT:InputArg','Wrong number of output arguments')


  strlen = mxGetN(prhs(2))
  if (strlen > 120) call mexErrMsgIdAndTxt('SNOPT:InputArg','Specs filename is too long')

  if (strlen > 0) then
     dimx = strlen
     call mxGetString(prhs(2), filename, dimx)
  else
     call mexErrMsgIdAndTxt('SNOPT:InputArg','Empty spc filename')
  end if

  open(iSpecs, file=filename, status='unknown')
  call snSpec(iSpecs, info, cw, lencw, iw, leniw, rw, lenrw)
  rewind (iSpecs)
  close(iSpecs)

  ! snSpec will return info == 101 or 107 if successful
  ! The matlab version returns 0 if successful
  if (info == 101 .or. info == 107) then
     rvalue = 0
  else
     rvalue = 1
  end if

  plhs(1) = mxCreateDoubleScalar(rvalue)

end subroutine snmxSpecs

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

subroutine matlabFG(Status, n, x, needF, nF, F, needG, lenG, G, &
                    cu, lencu, iu, leniu, ru, lenru)
  use mxsnWork, only : mxREAL
  use mxNLP,    only : fgHandle, neG, G1
  implicit none

  integer          :: Status, n, nF, needF, needG, lenG, &
                      lencu, leniu, lenru, iu(leniu)
  double precision :: F(nF), G(lenG), x(n), ru(lenru)
  character*8      :: cu(lencu)

  !---------------------------------------------------------------------
  ! Matlab callback to evaluate objective function and gradient at x.
  !---------------------------------------------------------------------
  mwIndex          :: j
  mwSize           :: dimx, dimy
  mwPointer        :: prhs(4), plhs(2)
  mwPointer        :: mxCreateDoubleMatrix, mxCreateDoubleScalar, &
                      mxDuplicateArray, mxGetPr
  integer*4        :: nlhs, nrhs, mxIsEmpty, mxIsNaN
  character(20)    :: str


  if (needF == 0 .and. needG == 0) return

  nlhs    = 2
  nrhs    = 4

  ! Compute functions and gradients
  prhs(1) = mxDuplicateArray(fgHandle)

  dimx = n
  dimy = 1
  prhs(2) = mxCreateDoubleMatrix(dimx, dimy, mxREAL)
  call mxCopyReal8ToPtr(x, mxGetPr(prhs(2)), dimx)

  prhs(3) = mxCreateDoubleScalar(dble(needF))
  prhs(4) = mxCreateDoubleScalar(dble(needG))

  ! Matlab callback
  !   [F,G] = feval(fgHandle,x,needF,needG) <-- snfun wrapper
  call mexCallMatlab(nlhs, plhs, nrhs, prhs, 'feval')


  ! Objective and constraints
  if (needF > 0) then
     dimx = nF
     call mxCopyPtrToReal8(mxGetPr(plhs(1)), F, dimx)
  end if

  ! Gradients
  if (needG > 0) then
     if (mxIsEmpty(plhs(2)) > 0) then
        ! No derivatives are defined
     else
        ! Copy non-NaN entries of G.
        dimx = neG
        call mxCopyPtrToReal8(mxGetPr(plhs(2)), G1, dimx)

        do j = 1, neG
           if (mxIsNaN(G1(j)) == 0) then
              G(j) = G1(j)
           end if
        end do
     end if
  end if


  ! Destroy arrays
  call mxDestroyArray(plhs(1))
  call mxDestroyArray(plhs(2))

  call mxDestroyArray(prhs(1))
  call mxDestroyArray(prhs(2))
  call mxDestroyArray(prhs(3))
  call mxDestroyArray(prhs(4))

end subroutine matlabFG

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

subroutine snjacFG(Status, n, x, needF, nF, F, needG, lenG, G, &
                    cu, lencu, iu, leniu, ru, lenru)
  use mxsnWork, only : mxREAL
  use mxNLP,    only : fgHandle
  implicit none

  integer          :: Status, n, nF, needF, needG, lenG, &
                      lencu, leniu, lenru, iu(leniu)
  double precision :: F(nF), G(lenG), x(n), ru(lenru)
  character*8      :: cu(lencu)

  !---------------------------------------------------------------------
  ! Matlab callback for snJac
  ! User-defined function only returns the function
  !---------------------------------------------------------------------
  mwSize           :: dimx, dimy
  mwPointer        :: prhs(2), plhs(1)
  mwPointer        :: mxCreateDoubleMatrix, mxDuplicateArray, mxGetPr
  integer*4        :: nlhs, nrhs

  if (needF > 0) then
     nlhs    = 1
     nrhs    = 2

     ! Compute functions and gradients
     prhs(1) = mxDuplicateArray(fgHandle)

     dimx = n
     dimy = 1
     prhs(2) = mxCreateDoubleMatrix(dimx, dimy, mxREAL)
     call mxCopyReal8ToPtr(x, mxGetPr(prhs(2)), dimx)


     ! Matlab callback
     !   [F,G] = feval(fgHandle,x,needF,needG) <-- userfun
     call mexCallMatlab(nlhs, plhs, nrhs, prhs, 'feval')


     ! Objective and constraints
     dimx = nF
     call mxCopyPtrToReal8(mxGetPr(plhs(1)), F, dimx)

     ! Destroy arrays
     call mxDestroyArray(plhs(1))
     call mxDestroyArray(prhs(1))
     call mxDestroyArray(prhs(2))
  end if

end subroutine snjacFG

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

subroutine matlabSTOP &
     ( iAbort,                                           &
       KTcond, mjrPrtlvl, minimize,                      &
       m, maxS, n, nb, nnCon0, nnCon, nnObj0, nnObj, nS, &
       itn, nMajor, nMinor, nSwap,                       &
       condZHZ, iObj, scaleObj, objAdd,                  &
       fObj, fMerit, penParm, step,                      &
       primalInf, dualInf, maxVi, maxViRel, hs,          &
       neJ, nlocJ, locJ, indJ, Jcol, negCon,             &
       scales, bl, bu, Fx, fCon, gCon, gObj,             &
       yCon, pi, rc, rg, x,                              &
       cu, lencu, iu, leniu, ru, lenru,                  &
       cw, lencw, iw, leniw, rw, lenrw )

  use mxsnWork, only : stopHandle
  use mxNLP,    only : tF, tFmul, tFlow, tFupp, tFstate, allocF, deallocF
  implicit none

  logical, intent(in) :: KTcond(2)
  integer, intent(in) :: iObj, itn,                                   &
                         lencu, lencw, leniu, leniw, lenru, lenrw,    &
                         mjrPrtlvl, minimize, m, maxS, n, nb, neJ,    &
                         negCon, nlocJ, nnCon0, nnCon, nnObj0, nnObj, &
                         nMajor, nMinor, nS, nSwap,                   &
                         hs(nb), locJ(nlocJ), indJ(neJ),              &
                         iw(leniw)
  double precision, intent(in) ::                                     &
       condZHZ, scaleObj, objAdd, fObj, fMerit, penParm(4),           &
       maxViRel, maxVi, step, primalInf, dualInf,                     &
       scales(nb), bl(nb), bu(nb), Fx(nnCon0),                        &
       fCon(nnCon0), gCon(negCon), gObj(nnObj0), Jcol(neJ), pi(m),    &
       rc(nb), rg(maxS), yCon(nnCon0), x(nb), rw(lenrw)

  character(8), intent(in) :: cw(lencw)*8

  integer,          intent(inout) :: iu(leniu)
  double precision, intent(inout) :: ru(lenru)
  character(8),     intent(inout) :: cu(lencu)

  integer,          intent(out) :: iAbort

  !===================================================================
  ! snSTOP is called every major iteration.
  ! If iAbort > 0 on exit, the run is terminated.
  ! By specifying a custom version of snSTOP, the user can arrange for
  ! snopt to be terminated at any given major iteration.
  !
  ! 14 Oct 2004: First version of   snSTOP.
  ! 29 Aug 2007: Parameter list extended.
  ! 18 Dec 2015: New argument fObj.
  ! 22 Dec 2015: Matlab version
  !===================================================================
  integer*4, parameter :: nlhs = 1, nrhs = 22

  integer          :: i, iN, j, lkxN, nF, ObjRow, nkx
  mwPointer        :: prhs(nrhs), plhs(nlhs)
  mwPointer        :: mxGetPr, mxDuplicateArray, mxCreateDoubleMatrix, &
                      mxCreateDoubleScalar
  double precision :: mxGetScalar

  iAbort = 0

  if ( stopHandle /= 0 ) then
     ! iAbort = snSTOP(...)
     prhs(1)  = mxDuplicateArray(stopHandle)

     ! Set up scalars
     prhs(2)  = mxCreateDoubleScalar(dble(itn))
     prhs(3)  = mxCreateDoubleScalar(dble(nMajor))
     prhs(4)  = mxCreateDoubleScalar(dble(nMinor))

     prhs(5)  = mxCreateDoubleScalar(condZHZ)
     prhs(6)  = mxCreateDoubleScalar(fObj)
     prhs(7)  = mxCreateDoubleScalar(fMerit)
     prhs(8)  = mxCreateDoubleScalar(step)
     prhs(9)  = mxCreateDoubleScalar(primalInf)
     prhs(10) = mxCreateDoubleScalar(dualInf)
     prhs(11) = mxCreateDoubleScalar(maxVi)
     prhs(12) = mxCreateDoubleScalar(maxViRel)

     ! x, xlow, xupp, xmul, xstate
     prhs(13) = mxCreateDoubleMatrix(n,1,0)
     call mxCopyReal8ToPtr(x, mxGetPr(prhs(13)),n)

     prhs(14) = mxCreateDoubleMatrix(n,1,0)
     call mxCopyReal8ToPtr(bl, mxGetPr(prhs(14)),n)

     prhs(15) = mxCreateDoubleMatrix(n,1,0)
     call mxCopyReal8ToPtr(bu, mxGetPr(prhs(15)),n)

     prhs(16) = mxCreateDoubleMatrix(n,1,0)
     call mxCopyReal8ToPtr(rc, mxGetPr(prhs(16)),n)

     prhs(17) = mxCreateDoubleMatrix(n,1,0)
     call mxCopyReal8ToPtr(real(hs,8), mxGetPr(prhs(17)),n)

     ! F, Flow, Fupp, Fmul, Fstate,...
     nF     = iw(248)
     ObjRow = iw(103)
     nkx    = iw(247)
     lkxN   = iw(252) ! jN = kxN(j ) => col j of Jcol is variable jN

     call allocF( nF )

     do j  = n+1, nkx
        i  = j - n
        iN = iw(lkxN-1+j)
         if (iN == ObjRow) then
            if (iObj > 0) then
               tF(ObjRow) = fObj + x(n+iObj)
            else
               tF(ObjRow) = fObj
            end if
         else
            if (i <= nnCon) then
               tF(iN) = Fx(i)
            else
               tF(iN) =  x(j)
            end if
            tFstate(iN) = hs(j)
            tFmul(iN)   = rc(j)
            tFlow(iN)   = bl(j)
            tFupp(iN)   = bu(j)
         end if
      end do

     prhs(18) = mxCreateDoubleMatrix(nF,1,0)
     call mxCopyReal8ToPtr(tF, mxGetPr(prhs(18)), nF)

     prhs(19) = mxCreateDoubleMatrix(nF,1,0)
     call mxCopyReal8ToPtr(tFlow, mxGetPr(prhs(19)), nF)

     prhs(20) = mxCreateDoubleMatrix(nF,1,0)
     call mxCopyReal8ToPtr(tFupp, mxGetPr(prhs(20)), nF)

     prhs(21) = mxCreateDoubleMatrix(nF,1,0)
     call mxCopyReal8ToPtr(tFmul, mxGetPr(prhs(21)), nF)

     prhs(22) = mxCreateDoubleMatrix(nF,1,0)
     call mxCopyReal8ToPtr(real(tFstate,8), mxGetPr(prhs(22)), nF)

     call deallocF

     call mexCallMatlab(nlhs, plhs, nrhs, prhs, 'feval')

     iAbort = mxGetScalar(plhs(1))

     call mxDestroyArray(plhs(1))

     call mxDestroyArray(prhs(1))
     call mxDestroyArray(prhs(2))
     call mxDestroyArray(prhs(3))
     call mxDestroyArray(prhs(4))
     call mxDestroyArray(prhs(5))
     call mxDestroyArray(prhs(6))
     call mxDestroyArray(prhs(7))
     call mxDestroyArray(prhs(8))
     call mxDestroyArray(prhs(9))
     call mxDestroyArray(prhs(10))
     call mxDestroyArray(prhs(11))
     call mxDestroyArray(prhs(12))
     call mxDestroyArray(prhs(13))
     call mxDestroyArray(prhs(14))
     call mxDestroyArray(prhs(15))
     call mxDestroyArray(prhs(16))
     call mxDestroyArray(prhs(17))
     call mxDestroyArray(prhs(18))
     call mxDestroyArray(prhs(19))
     call mxDestroyArray(prhs(20))
     call mxDestroyArray(prhs(21))
     call mxDestroyArray(prhs(22))
  end if

end subroutine matlabSTOP

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
