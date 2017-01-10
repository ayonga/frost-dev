function print(obj, file)
    % This function prints out the symbolic expression from the
    % Mathematica to Matlab screen.
    %
    % @todo better implementation ...
    symbols = obj.Symbols;
    if nargin < 2 % print to screen
        if check_var_exist(struct2cell(obj.Symbols))
            fprintf('%s: \n',symbols.Kin);
            math(symbols.Kin)
            
            fprintf('%s: \n',symbols.Jac);
            math(symbols.Jac)
            
            fprintf('%s: \n',symbols.JacDot);
            math(symbols.JacDot)
        else
            warning('The symbolic expressions do not exist.');
        end
        
    else % print to a file
        
        
        if check_var_exist(struct2cell(obj.Symbols))
            
            f = fopen(file, 'w+');
            
            kin = math(['InputForm[',symbols.Kin,']']);
            fprintf(f,'%s: \n',symbols.Kin);
            fprintf(f,kin);
            fprintf(f,'\n \n \n');
            
            
            jac = math(['InputForm[',symbols.Jac,']']);
            fprintf(f,'%s: \n',symbols.Jac);
            fprintf(f,jac);
            fprintf(f,'\n \n \n');
            
            
            jdot = math(['InputForm[',symbols.JacDot,']']);
            fprintf(f,'%s: \n',symbols.JacDot);
            fprintf(f,jdot);
            fprintf(f,'\n \n \n');
            
            fclose(f);
        else
            warning('The symbolic expressions do not exist.');
        end
    end
end
