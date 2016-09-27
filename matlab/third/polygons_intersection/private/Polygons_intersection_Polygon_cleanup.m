function S = Polygons_intersection_Polygon_cleanup(S,accuracy)
if nargin == 1
    accuracy = 1e-9;
end
if accuracy<eps
    error('Polygons_intersection_Polygon_cleanup:e0',...
          'Accuracy must be a positive real');
end


if isfield(S,'P')
    S_area = struct('A', {});
    for i=1:numel(S)
        S(i).area = 0;
        for j=1:numel(S(i).P)
            S_area(i).A(j) = polyarea(S(i).P(j).x,S(i).P(j).y);
            S(i).area      = S(i).area + (1-2*S(i).P(j).hole) * S_area(i).A(j);        
        end        
        To_delete = S_area(i).A < accuracy;
        S(i).P(To_delete) = [];
        S_area(i).A(To_delete) = [];
    end
elseif isfield(S,'x')
    S_area = zeros(numel(S),1);
    for i=1:numel(S)
        S_area(i) = polyarea(S(i).x,S(i).y);
    end
    To_delete = S_area < accuracy;
    S(To_delete) = [];
    S_area(To_delete) = [];
end