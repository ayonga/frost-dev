function status = export(obj, export_path, do_build)
    % Export the symbolic expression of functions to C/C++ source
    % files and build them as MEX files. 
    %
    % Overload by KinematicExpr
    %
    % Parameters:
    %  export_path: the complete directory path where the compiled symbolic
    %  function will be exported to @type char
    %  do_build: determine whether build the mex files.
    %  @type logical  @default true
    %
    % Return values:
    % status: indicator of successful export/built process @type logical
    
    if nargin < 3
        do_build = true;
    end
    
    
    
    if isempty(obj.Parameters) || obj.Parameters.Dimension==0
        % if the function does not include any parameter, then use the
        % superclass method directly
        status = export@Kinematics(obj, export_path, do_build);
    else
        % otherwise perform export function with parameter argument
        status = false;
        if ~(exist(export_path,'dir'))
            warning(['The path to export functions does not exist: %s\n',...
                'Please ensure to create the folder, and call this function again.\n',...
                'Aborting ...\n'], export_path);
            return;
        end
        
        
        
        symbols = obj.Symbols;
        funcs   = obj.Funcs;
        
        if ~ check_var_exist(struct2cell(symbols))
            warning(['The robot kinematics has not been compiled in Mathematica.\n',...
                'Please call %s first\n',...
                'Aborting ...\n'],'compileKinematics(domain, model)');
            return;
        end
        
        
        
        
        eval_math('Needs["MathToCpp`"];');
        
        eval_math(['ParamSubs = Join[((',obj.Parameters.Name,'[#+1]->HoldForm@Global`',...
            obj.Parameters.Name,'[[#]]&)/@(Range[',num2str(obj.Parameters.Dimension),']-1))];']);
        
        % necessary settings
        eval_math(['SetOptions[CseWriteCpp,',...
            'ExportDirectory->',str2mathstr(export_path),',',...
            'Namespace->Kinematics,',...
            'SubstitutionRules->Join[GetStateSubs[],ParamSubs]];']);
        eval_math('nDof=First@GetnDof[]');
        
        
        sym_expr_dim = math('math2matlab',['Dimensions[',symbols.Kin,']']);
        kin_dim = getDimension(obj);
        assert(kin_dim == sym_expr_dim, ...
            'Domain:invalidsize',...
            ['The dimension of the symbolic expression is %d.\n',...
            'It should be %d.'],sym_expr_dim,kin_dim);
        
        
        % if exists, export the function
        eval_math(['CseWriteCpp[',str2mathstr(funcs.Kin),',{',symbols.Kin,'},',...
            'ArgumentLists->{q,',obj.Parameters.Name,'},',...
            'ArgumentDimensions->{{nDof,1},{',num2str(obj.Parameters.Dimension),',1}}]']);
        
        fprintf('File  %s.cc has been exported to %s\n', funcs.Kin, export_path);
        
        
        eval_math(['CseWriteCpp[',str2mathstr(funcs.Jac),',{',symbols.Jac,'},',...
            'ArgumentLists->{q,',obj.Parameters.Name,'},',...
            'ArgumentDimensions->{{nDof,1},{',num2str(obj.Parameters.Dimension),',1}}]']);
        
        fprintf('File  %s.cc has been exported to %s\n', funcs.Jac, export_path);
        
        
        eval_math(['CseWriteCpp[',str2mathstr(funcs.JacDot),',{',symbols.JacDot,'},',...
            'ArgumentLists->{q,dq,',obj.Parameters.Name,'},',...
            'ArgumentDimensions->{{nDof,1},{nDof,1},{',num2str(obj.Parameters.Dimension),',1}}]']);
        
        fprintf('File  %s.cc has been exported to %s\n', funcs.JacDot,export_path);
        % build mex file
        if do_build
            build_mex(export_path,struct2cell(funcs));
        end
    
    end
   
    
    
    
end
