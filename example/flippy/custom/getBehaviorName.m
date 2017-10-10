function ret = getBehaviorName(type)
    if nargin < 1
        error('Not enough arguments');
    end
%     if nargin < 3
%         p_home = [0.65,-0.2,0.25];
%         o_home = [0,0,0];
%     else
%         p_home = nargin(3);
%         o_home = nargin(4);
%     end
    
    switch(type)
        case 'trans'
            ret =  'translate';
        case 'flip'
            ret =  'flip';
        case 'pickup'
            ret = 'pickup';
        case 'j2j'
            ret = 'joint2joint';
    end
end