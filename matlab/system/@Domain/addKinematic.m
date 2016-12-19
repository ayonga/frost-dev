function obj = addKinematic(obj, kins, type)
% Adds a kinematic constraints other than contact constraints to the domain
%
% Parameters:
%  kins: a cell array of kinematic constraints @type Kinematic
%  type: indicates whether it is 'honomonic' or unilateral @type char


% validate input argument
if iscell(kins)
    assert(all(cellfun(@(x)isa(x,'Kinematics')&&~isa(x,'KinematicContact'),kins)),...
        ['The input must be a cell array of objects of type ''Kinematics'' other than ''KinematicContact''\n. '...
        'To add contact constraints, please use %s'], 'KinematicContact');
else
    assert(isa(kins,'Kinematics')&&~isa(kins,'KinematicContact'),...
        ['The input must be a cell array of objects of type ''Kinematics'' other than ''KinematicContact''\n. '...
        'To add contact constraints, please use %s'], 'KinematicContact');
    kins = {kins};
end

n_kin = numel(kins);

switch type
    case 'holonomic'


            
        % add to the holonomic constraints array
        obj.HolonomicConstr(end+1:end+n_kin) = kins;
       
    case 'unilateral'
        
        for i=1:n_kin
            % create an empty table first
            nvars = size(obj.UnilateralConstr, 2);
            
            dim_c = getDimension(kins{i});
            new_cond = cell2table(cell(dim_c,nvars),'VariableNames',...
                obj.UnilateralConstr.Properties.VariableNames);
            new_cond.Name = {kins{i}.Name};
            new_cond.Type = {'Kinematic'};
            new_cond.KinFunction = {struct(...
                'Kin',['h_',new_cond.Name{1}],...
                'Jac',['Jh_',new_cond.Name{1}],...
                'JacDot',['dJh_',new_cond.Name{1}])};
            new_cond.KinObject = kins(i);
            new_cond.Properties.RowNames = new_cond.Name;
            % add to the existing unilateral condition table
            obj.UnilateralConstr = [obj.UnilateralConstr;new_cond];
        end
    otherwise
        error('The type must be one of the followings: %s\n',implode({'holonomic','unilaterl'},', '));
end


end
