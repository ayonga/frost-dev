function obj = setOuputStructure(obj, outputs, model)
    % configureOuputStructure - configure output structure of domain
    %
    % Copyright 2016 Georgia Tech, AMBER Lab
    % Author: Ayonga Hereid <ayonga@gatech.edu>
    narginchk(3,3);
    
    % output structure from domain configuration
    obj.outputs = outputs;   
    
    
    obj.nOutputs = numel(outputs.actual.degreeTwoOutput);
    
    funcs = {...
        'ya2',...
        'yd2',...
        'Dya2',...
        'DLfya2',...
        'dyd2',...
        'ddyd2',...
        'deltaphip',...
        'Jdeltaphip',...
        'tau',...
        'dtau',...
        'Jtau',...
        'Jdtau'};
    
    % if relative degree one output is defined, then add corresponding
    % function handles
    if ~isempty(obj.outputs.actual.degreeOneOutput) 
        funcs = horzcat({'ya1','Dya1','yd1','dyd1'},funcs);
        nOutputRD1 = 1;
    else
        nOutputRD1 = 0;
    end
    
    
    name = obj.name;
    for i=1:numel(funcs)
        % obtain file name
        filename = strcat(funcs{i},'_',name);
        % check if the mex file exists
%         assert(exist(filename,'file')==3,...
%             'MEX file is not found: %s',filename);
        % assign to domain fields
        obj.(funcs{i}) = str2func(filename);
    end
    
    %% number of parameters
    %  hack. toD): make this generalized -wma
    obj.nParamPhaseVar = 2;
    %    obj.nParamPhaseVar = obj.numDomainsInStep + 1; 
    
    %%
    if ~isempty(obj.outputs.desired.degreeOneOutput)
        type = obj.outputs.desired.degreeOneOutput;
        obj.nParamRD1 = getNumberofParameters(type);
    else
        obj.nParamRD1 = 0;
    end
    
    type = obj.outputs.desired.degreeTwoOutput;
    nParams = getNumberofParameters(type);
    obj.nParamRD2 = nParams * obj.nOutputs;
    
    %%% set actuated joints
    obj.nAct = numel(outputs.actuatedJoints);
    assert(obj.nAct == nOutputRD1 + obj.nOutputs, ...
        'The number of actuated joints is not equal to number of outputs');
    obj.qaIndices = getJointIndices(model, outputs.actuatedJoints, true);
    obj.dqaIndices = obj.qaIndices + model.nDof;
    
    
    % set zero dynamics indices
    %     obj.qzIndices = getJointIndices(model,outputs.zeroDynamics);
    %     obj.dqzIndices = obj.qzIndices + model.nDof;
    %     obj.nZero = numel(obj.qzIndices);
    
    
    function [nParams] = getNumberofParameters(type)
        switch type
            case 'Constant'
                nParams = 1;
            case 'MinJerk'
                nParams = 3;
            case 'CWF'
                nParams = 5;
            case 'ECWF'
                nParams = 7;
            case 'Bezier3thOrder'
                nParams = 3;
            case 'Bezier4thOrder'
                nParams = 4;
            case 'Bezier5thOrder'
                nParams = 5;
            case 'Bezier6thOrder'
                nParams = 6;
            case 'Bezier7thOrder'
                nParams = 7;
            otherwise
                error('invalid function type.\n');
        end
    
    end
end