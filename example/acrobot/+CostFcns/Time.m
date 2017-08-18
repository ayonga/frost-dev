function nlp = Time(nlp, varargin)
    
    
    
    plant = nlp.Plant;
    T = SymVariable('t',[2,1]);
    
    tf = SymFunction(['time_' plant.Name],T(2),{T});
    addNodeCost(nlp,tf,{'T'},'first');
end