% function snsetwork( leniw, lenrw )
%     Modify the initial amount of workspace for SNOPT.
%     Values must be at least 500.
%
%
function snsetwork( leniw, lenrw )

setoptionI = 14;
snoptmex( setoptionI, leniw, lenrw );
