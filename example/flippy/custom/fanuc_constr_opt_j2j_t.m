function nlp = fanuc_constr_opt_j2j_t(nlp, bounds, varargin)
%%  Specify burger location. Starting position of spatula is 2cm above burger location
%     p_start = [0.75, -0.0, 0.11];
    x_start = [1.5767    0.9437   -0.3532    0.0069    0.9534    0.3995];
    x_final = [1.5786    0.52369  -0.75852   0.012085  0.44462   0.39629];
    
    %% add aditional custom constraints
    
    plant = nlp.Plant;
    
        
    % relative degree 2 outputs
    % imposing this constraint is very important for getting the apos
    % matrix correct
    plant.VirtualConstraints.pos.imposeNLPConstraint(nlp, [bounds.pos.kp,bounds.pos.kd], [1,1]);

    %% configuration constraints
    x = plant.States.x;
    
    configq = SymFunction(['configq_' plant.Name],x,{x});
    addNodeConstraint(nlp, configq, {'x'}, 'first', x_start, x_start, 'Nonlinear');
    addNodeConstraint(nlp, configq, {'x'}, 'last', x_final, x_final, 'Nonlinear');
    
   
    %%
       
end