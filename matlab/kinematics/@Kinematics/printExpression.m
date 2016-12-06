function printExpression(obj, file)
    % This function prints out the symbolic expression from the
    % Mathematica to Matlab screen.
    %
    % @todo better implementation ...
    
    if nargin < 2 % print to screen
        if check_var_exist({obj.Symbols.Kin,obj.Symbols.Jac,obj.Symbols.JacDot})
            fprintf('%s: \n',obj.Symbols.Kin);
            math(obj.Symbols.Kin)
            
            fprintf('%s: \n',obj.Symbols.Jac);
            math(obj.Symbols.Jac)
            
            fprintf('%s: \n',obj.Symbols.JacDot);
            math(obj.Symbols.JacDot)
        else
            warning('The symbolic expressions do not exist.');
        end
        
    else % print to a file
        
        
        if check_var_exist({obj.Symbols.Kin,obj.Symbols.Jac,obj.Symbols.JacDot})
            
            f = fopen(file, 'w+');
            
            kin = math(['InputForm[',obj.Symbols.Kin,']']);
            fprintf(f,'%s: \n',obj.Symbols.Kin);
            fprintf(f,kin);
            fprintf(f,'\n \n \n');
            
            
            jac = math(['InputForm[',obj.Symbols.Jac,']']);
            fprintf(f,'%s: \n',obj.Symbols.Jac);
            fprintf(f,jac);
            fprintf(f,'\n \n \n');
            
            
            jdot = math(['InputForm[',obj.Symbols.JacDot,']']);
            fprintf(f,'%s: \n',obj.Symbols.JacDot);
            fprintf(f,jdot);
            fprintf(f,'\n \n \n');
            
            fclose(f);
        else
            warning('The symbolic expressions do not exist.');
        end
    end
end
