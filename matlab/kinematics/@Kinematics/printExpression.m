function printExpression(obj, file)
    % This function prints out the symbolic expression from the
    % Mathematica to Matlab screen.
    %
    % @todo better implementation ...
    
    if nargin < 2 % print to screen
        if check_var_exist({obj.symbol,obj.jac_symbol,obj.jacdot_symbol})
            fprintf('%s: \n',obj.symbol);
            math(obj.symbol)
            
            fprintf('%s: \n',obj.jac_symbol);
            math(obj.jac_symbol)
            
            fprintf('%s: \n',obj.jacdot_symbol);
            math(obj.jacdot_symbol)
        else
            warning('The symbolic expressions do not exist.');
        end
        
    else % print to a file
        
        
        if check_var_exist({obj.symbol,obj.jac_symbol,obj.jacdot_symbol})
            
            f = fopen(file, 'w+');
            
            kin = math(['InputForm[',obj.symbol,']']);
            fprintf(f,'%s: \n',obj.symbol);
            fprintf(f,kin);
            fprintf(f,'\n \n \n');
            
            
            jac = math(['InputForm[',obj.jac_symbol,']']);
            fprintf(f,'%s: \n',obj.jac_symbol);
            fprintf(f,jac);
            fprintf(f,'\n \n \n');
            
            
            jdot = math(['InputForm[',obj.jacdot_symbol,']']);
            fprintf(f,'%s: \n',obj.jacdot_symbol);
            fprintf(f,jdot);
            fprintf(f,'\n \n \n');
            
            fclose(f);
        else
            warning('The symbolic expressions do not exist.');
        end
    end
end
