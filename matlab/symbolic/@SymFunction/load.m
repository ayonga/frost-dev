function obj = load(obj, file_path)
    % load the saved symbolic expression from a wolframe MX file
    %
    %
    % Parameters:
    %  obj: the expressions other than the main object 
    %   @type SymExpression
    %  file_path: the path to export the file @type char

   
    
    if nargin < 2
        file_path = pwd;
    end
    
    
    obj = obj.load@SymExpression(file_path, obj.Name);
    
    obj.Status.FunctionLoaded = true;
end  
    



    