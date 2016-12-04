function options = set_options(options, varargin)
    % Sets the options value by parsing input arguments
    %
    % @author ayonga @date 2016-12-01
    %
    % Parameters:
    % options: the option structure to be set @type struct
    % varargin: (option, value) pair of arguments
    
    assert(isstruct(options),'The options must be a struct');
    
    
    p = inputParser;
    option_names = fieldnames(options);
    
    for i=1:length(option_names)
        option = option_names{i};
        p.addParameter(option, options.(option), @islogical);
    end
    
    parse(p,varargin{:});
    
    options = p.Results;
    
end
