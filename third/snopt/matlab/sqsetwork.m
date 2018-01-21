% function sqsetwork( leniw, lenrw )
%     Modify the initial amount of workspace for SQOPT.
%     Values must be at least 500.
%
%
function sqsetwork( leniw, lenrw )

setoptionI = 14;
sqoptmex( setoptionI, leniw, lenrw );
