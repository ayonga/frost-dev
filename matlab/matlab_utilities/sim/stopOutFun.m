function stop = stopOutFun(x,optimValues,state)
stop = false;
if optimValues.constrviolation < 1e-9
    stop = true;
end 
end