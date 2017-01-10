function obj = setParameters(obj, varargin)
    % setController - set the controller for the domain
    %
    % Copyright 2014 Texas A&M University AMBER Lab
    % Author: Ayonga Hereid <ayonga@tamu.edu>
    
    %% list all fields in parameter struct
    param_names = {'p','a','v','p_range','p0','pdot0','x_minus','x_plus'};
    
    %% use local variables for faster evaluation
    params = obj.params;
    
    %% Check the object parameter struct, if it is empty struct
    %  then create a struct with above fields, set values to be empty.
    if isempty(params)
        params = struct();
        num_params = numel(param_names);
        for i=1:num_params
            params.(param_names{i}) = [];
        end
    end
    
    %% if input is a structure contains parameters
    if nargin == 2 && isstruct(varargin{1})
        new_params = varargin{1};
        for i=1:num_params
            if isfield(new_params,param_names{i})
                % if input structure contains fields specified in parameter
                % struct, then update that field
                params.(param_names{i}) = new_params.(param_names{i});
                fprintf('%s: The parameter (%s) is updated.\n',obj.name, param_names{i});
                
                if strcmpi(param_names{i},'p')
                    % if parameter p is updated, then update p_range based
                    % on domain index
                    p = params.p;
                   
                   %%% hack -wma
%                    if obj.numDomainsInStep == 1
%                         if obj.indexInStep == obj.numDomainsInStep
%                             % if the domain is the last domain in one step
%                             params.p_range = [p(obj.indexInStep+1); p(1)];
%                         else
%                             params.p_range = p(obj.indexInStep + 1 : ...
%                                                obj.indexInStep + 2);
%                         end
%                    else
                       params.p_range = [p(2); p(1)];
%                    end
                   
                        
                end
            end
        end
    else
        %% otherwise, the parameters should be feeded in pairs of
        %  {name,value}
        assert(mod(nargin-1,2)==0, 'wrong number of arguments.\n');
        
        for i = 1 : 2:nargin-1
            name = varargin{i};
            assert(ischar(name),'argument should be a string');                
            
            if isfield(params,name)
                val  = varargin{i+1};
                params.(name) = val;
                fprintf('%s: The parameter (%s) is updated.\n',obj.domainName, name);
            else
                warning('The field is not defined in parameter struct');
            end
            
            if strcmpi(name,'p')
                % if parameter p is updated, then update p_range based
                % on domain index
                p = params.p;
                if obj.indexInStep == obj.numDomainsInStep
                    % if the domain is the last domain in one step
                    params.p_range = [p(obj.indexInStep+1);p(1)];
                else
                    params.p_range = p(obj.indexInStep+1:obj.indexInStep+2);
                end
                
            end
        end
    end
            
    obj.params = params;

end