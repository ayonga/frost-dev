function obj = configureCLF(obj, domain)
    % CLF configuration for the controller
    
    % if relative degree one output is defined, then add corresponding
    % function handles
    if ~isempty(domain.outputs.actual.degreeOneOutput) 
        nClf = domain.nOutputs + 1;
        relDegree = [1,2*ones(1,nClf-1)];
    else
        nClf = domain.nOutputs;
        relDegree = 2*ones(1,nClf);
    end

    penalty    = 10*ones(1, nClf);
    relaxation = zeros(1, nClf);
    % relax non-zero outputs
    relaxation(domain.outputs.actual.nonZeroOutputIndices) = -1;
%     relaxation(end-2:end) = zeros(1,3);
%     penalty(1) = 1000;
    ep = obj.ep;
    
    
    clfs = clf_construct(nClf,penalty,relaxation,relDegree,ep);
    
    
    obj.clfs = clfs;
    
    function [clfs] = clf_construct(nClf,penalty,relaxation,relDegree,ep)
        
        
        clfs = struct([]);
        if relDegree(1) == 1
            nDegOne = 1;
        else
            nDegOne = 0;
        end
        
        for i = 1:nClf
            nClfOutputs = 1;
            outputIndices = i;
            
            yIndices = i;
            %     dyIndices = i + nClf;
            clfs(i).penalty = penalty(i);
            clfs(i).relaxation = relaxation(i);
            
            
            % See if it's D1 (only one D1 output)
            if relDegree(i) == 2
                dyIndices = (i-nDegOne) + nClf;
                etaIndices = [yIndices, dyIndices];
                qcare = care_gen(0, nClfOutputs, ep);
            else
                etaIndices = yIndices;
                qcare = [];
            end
            
            
            
            clfs(i).care = qcare;
            clfs(i).nOutputs = nClfOutputs;
            clfs(i).etaIndices = etaIndices;
            clfs(i).outputIndices = outputIndices;
            clfs(i).relDegree = relDegree(i);
            
            
            
            
        end
        
    end

    function [qcare] = care_gen(nD1, nD2, ep)
        
        qcare = struct();
        qcare.nD1 = nD1;
        qcare.nD2 = nD2;
        qcare.G = [
            eye(nD1)         zeros(nD1, nD2);
            zeros(nD2, nD1) zeros(nD2, nD2);
            zeros(nD2, nD1) eye(nD2)
            ];
        qcare.F = [
            zeros(nD1, nD1)  zeros(nD1, 2*nD2);
            zeros(nD2, nD1) zeros(nD2, nD2)   eye(nD2);
            zeros(nD2, nD1) zeros(nD2, 2*nD2)
            ];
        
        if isempty(which('care'))
            return;
        end
        
        qcare.P = care(qcare.F, qcare.G, eye(nD1 + nD2 * 2));
        qcare.C3 = min(eig(eye(nD1 + nD2*2))) /max(eig(qcare.P));
        
        if nargin >= 3
            e = 1 / ep;
            qcare.emat = blkdiag(eye(nD1), 1 / e .* eye(nD2), eye(nD2));
            qcare.Pe = qcare.emat * qcare.P * qcare.emat;
        end
        
    end
end