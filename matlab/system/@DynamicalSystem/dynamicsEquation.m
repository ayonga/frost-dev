function obj = dynamicsEquation(obj, M, vf, gf, G)
    % Configure the dynamical equation of the system
    %
    % Parameters:
    % varargin: variable input arguments of
    %  M:  the mass matrix M(x) @type SymFunction
    %  vf: the f(x) @type cell
    %  gf: the g(x) @type SymFunction
    %  G:  the G(x) @type SymFunction
    
    if nargin < 4
        gf = [];
    end
    if nargin < 5
        G = [];
    end
    
    % validate and set the mass matrix M(x)
    if ~isempty(M)
        assert(isa(M,'SymFunction'),...
            'The (M) must be a SymFunction object.');
        [nr,nc] = size(M);
        assert(nr==obj.numState && nc==obj.numState,...
            'The size of the (M) is incorrect.');        
    end
    obj.DynamicsEqn.M = M;
    
    
    % validate the inputs vf(x,dx)
    if ~iscell(vf), vf = {vf}; end
    
    assert(all(cellfun(@(x)isa(x,'SymFunction'), vf)),...
        'The vector field (vf) must be a cell array of SymFunction objects.');
    assert(all(cellfun(@(x)(length(x)==obj.numState) && isvector(x), vf)),...
        'The dimension of the (vf) is incorrect.');
    obj.DynamicsEqn.vf = vf;
    
    
    
    % validate the inputs gf(x)
    if nargin > 3 && obj.numControl > 0
        assert(isa(gf,'SymFunction'),...
            'The (gf) must be a SymFunction object.');
        [nr,nc] = size(gf);
        assert(nr==obj.numState && nc==obj.numControl,...
            'The size of the (gf) is incorrect.');        
    else
        if obj.numControl > 0
            error('The control inputs are not empty. (gf) need to be specified.')
        end
        gf = [];
    end
    obj.DynamicsEqn.gf = gf;
    
    
    % validate the inputs G(x)
    if nargin > 4 && obj.numExternal > 0
        assert(isa(G,'SymFunction'),...
            'The vector field (G) must be a SymFunction object.');
        [nr,nc] = size(G);
        assert(nr==obj.numState && nc==obj.numExternal,...
            'The size of the (G) is incorrect.');
        
    else
        if obj.numExternal > 0
            error('The external inputs are not empty. (G) need to be specified.')
        end
        G = [];
    end
    obj.DynamicsEqn.G = G;
    
end