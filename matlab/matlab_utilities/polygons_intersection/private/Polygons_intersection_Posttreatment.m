function Geo = Polygons_intersection_Posttreatment(S,Geo,Display_result,...
                                                                  Accuracy)

% This function splits the original polygons at intersection. Each time
% polygons intersect, a new one is created containing only the 
% intersection of these polygons. Polygons are stored in structure with
% additional data, such the area and the polygons involded in the possible
% intersection.
% 
% The result is a structure containg polygons, with for each the list of
% the polygon involved in the intersection.
% 
% The union of the resulting polygons is equal to the union of the original
% polygons
%
%
% Input :  - S   : Structure containing initial polygon geometry
%                     S(i).P(j).x      : Vector
%                     S(i).P(j).y      : Vector
%                     S(i).P(j).hole   : Binary value (1 = hole, 0= fill)
%
%          - Geo : Structure containing
%                     Geo(m).index gives the indexes of original polygon 
%                                  (S) involved in polygon m.
%                     Geo(m).P     contains the geometrical description of
%                                  polygon m.
%                     Geo(m).area  contains the area of polygon m.
% 
%          - Display_result : Binary number used to display or not the
%                             result
% 
% Output:  Geo structure containing splited polygons and their associated 
%           data( indexes of the polygons involved in this polygon, area of
%           the polygon).
%           The output has exactly the same structure as the Geo given in
%           input.

% Guillaume JACQUENOT
% guillaume at jacquenot at gmail dot com
% 2007_10_08
% 2009_06_16

if nargin==0
    Polygons_intersection_posttreatment_data;
    Display_result = 1;
    Accuracy = 1e-3;
elseif nargin==2
    Display_result = 1;
    Accuracy = 1e-3;    
end


S   = Polygons_intersection_Compute_area(S);
Geo = Polygons_intersection_Compute_area(Geo);

Geo   = [S,Geo];
Geo   = Polygons_intersection_Polygon_cleanup(Geo,Accuracy);
N_Geo =  numel(Geo);

% Reshape elements
for i=1:N_Geo
    for j=1:numel(Geo(i).P)
        Geo(i).P(j).x = reshape(Geo(i).P(j).x,1,numel(Geo(i).P(j).x));
        Geo(i).P(j).y = reshape(Geo(i).P(j).y,1,numel(Geo(i).P(j).y));
    end
end

% Performs geometrical computation.
% One uses the polygon containing the higher number of polygon indexes, and
% one substracts this polygon to polygons containing less indexes.
% 
% It is a top down approach.
for i = numel(Geo(N_Geo).index):-1:1
    N_Geo = numel(Geo);
    N_index = [];
    for j = 1:N_Geo
         N_index(j) = numel(Geo(j).index);
    end
    Ref = (1:N_Geo).*(N_index == i);   Ref(Ref==0)=[];
    Mod = (1:N_Geo).*(N_index <= i-1); Mod(Mod==0)=[];
    To_delete = [];    
    for j = 1:numel(Ref)
        for k = 1:numel(Mod)
            if ~isempty(Geo(Mod(k)).P) && ~isempty(Geo(Ref(j)).P)
                P = PolygonClip(Geo(Mod(k)).P,Geo(Ref(j)).P,0);
                P = Polygons_intersection_Polygon_cleanup(P,Accuracy);
                if ~isempty(P)
                    Geo(Mod(k)).P = P;
                else
                    To_delete = [To_delete,Mod(k)];
                end
            else
                Geo(Mod(k)).P = [];
            end
        end
    end
    Geo(To_delete)=[];
end

% % Each element P containing more than one polygon is split into several
% % elements P
% N_Geo = numel(Geo);
% index = 1;
% for i=1:N_Geo
%     if numel(Geo(i).P)>=2
%         for j=2:numel(Geo(i).P)
%             Geo(N_Geo+index).index = Geo(i).index;
%             Geo(N_Geo+index).P     = Geo(i).P(j);
%             index = index+1;
%         end
%         Geo(i).P(2:numel(Geo(i).P))=[];
%     end
% end

% % Cleaning up the results of the different operations
for i=1:numel(Geo)
    for j=1:numel(Geo(i).P)    
        Geo(i).P(j).x   = reshape(Geo(i).P(j).x,1,numel(Geo(i).P(j).x));
        Geo(i).P(j).y   = reshape(Geo(i).P(j).y,1,numel(Geo(i).P(j).y));
    end
end

[Geo Geo_area] = Polygons_intersection_Compute_area(Geo);
N_Geo = numel(Geo);
To_delete = [];
for i=1:N_Geo  
    for j=1:numel(Geo(i).P)
        if Geo_area(i).A(j)<1e-9,To_delete = [To_delete,[i;j]];end
    end
end
if ~isempty(To_delete)
    for i=size(To_delete,2):-1:1
        Geo(To_delete(1,i)).P(To_delete(2,i)) = [];
        Geo_area(To_delete(1,i)).A(To_delete(2,i)) = [];
    end
end

% Clean up geometry.
N_Geo = numel(Geo);
for i = 1:N_Geo
    for j=1:numel(Geo(i).P)
        % Delete colinear vectors of the geometry, which are useless.
        if Geo(i).P(j).x(1)==Geo(i).P(j).x(end) && ... 
                Geo(i).P(j).y(1)==Geo(i).P(j).y(end)
            Angle = NaN(1,numel(Geo(i).P(j).x)-1);            
            X1 =  Geo(i).P(j).x(1:end-1);
            X2 = [Geo(i).P(j).x(2:end-1) Geo(i).P(j).x(1)];
            X3 = [Geo(i).P(j).x(3:end-1) Geo(i).P(j).x(1:2)];
        
            Y1 =  Geo(i).P(j).y(1:end-1);
            Y2 = [Geo(i).P(j).y(2:end-1)  Geo(i).P(j).y(1)];
            Y3 = [Geo(i).P(j).y(3:end-1)  Geo(i).P(j).y(1:2)];            
        else
            Angle = NaN(1,numel(Geo(i).P(j).x));
            X1 =  Geo(i).P(j).x(1:end);
            X2 = [Geo(i).P(j).x(2:end) Geo(i).P(j).x(1)];
            X3 = [Geo(i).P(j).x(3:end) Geo(i).P(j).x(1:2)];
        
            Y1 =  Geo(i).P(j).y(1:end);
            Y2 = [Geo(i).P(j).y(2:end)  Geo(i).P(j).y(1)];
            Y3 = [Geo(i).P(j).y(3:end)  Geo(i).P(j).y(1:2)];
        end
        
        P1 = (X3-X2).*(X1-X2) + (Y3-Y2).*(Y1-Y2);
        P2 = (X3-X2).*(Y1-Y2) - (Y3-Y2).*(X1-X2);
        
        CL1 = logical((P1==0.0).*(P2==0.0));
        Angle(CL1) = 0;
        Angle(~CL1) = atan2(P2(~CL1),P1(~CL1));
        CL2 = Angle<0.0;
        Angle(CL2) = Angle(CL2)+2*pi;
        
        % If any angle between P1 P2 & P3 is null or equals 2pi or pi, one
        % deletes P2.
        
        % A threshold value is used to detect colinear vectors
        % The smaller the value is , the better it is.
        threshold = 1e-3;
        To_delete = (abs([Angle(end) Angle(1:end-1)])<=threshold) |...
            ((abs([Angle(end) Angle(1:end-1)])<=pi+threshold) & ...
             (abs([Angle(end) Angle(1:end-1)])>=pi-threshold)) | ...
             (abs([Angle(end) Angle(1:end-1)])>=2*pi-threshold);
        Geo(i).P(j).x(To_delete)=[];
        Geo(i).P(j).y(To_delete)=[];
        
        % One closes the polygon
        Geo(i).P(j).x = [Geo(i).P(j).x Geo(i).P(j).x(1)];
        Geo(i).P(j).y = [Geo(i).P(j).y Geo(i).P(j).y(1)];
    end
end

if Display_result
    % Display figures
    N_polygons = numel(S);
    colour(1:N_polygons,1:3) = rand(N_polygons,3);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure
    subplot(1,2,2)
    grid on
    hold on
    box on
    axis equal
    Leg = cell(N_polygons,1);
    h = zeros(1,N_polygons);
    for i=1:N_polygons
        for j=numel(S(i).P):-1:1
        h(i) = plot(S(i).P(j).x,S(i).P(j).y,'color',colour(i,:),'LineWidth',3);
%         text(S(n).x(1)+0.2,S(n).y(1)+0.2,num2str(n),...
%              'color',colour(n,:),'FontSize',14);
            if S(i).P(j).hole==1
                set(h(i),'LineStyle','--');
            end
        end
        Leg{i} = ['Shape ' int2str(i)];
    end
    legend(h,Leg),clear Leg
    for i = 1:N_Geo
        for j=numel(Geo(i).P):-1:1
            if Geo(i).P(j).hole==1
                temp = [1 1 1];
            else
                temp  = rand(1,3);
            end
            patch([Geo(i).P(j).x,Geo(i).P(j).x(1)],...
                  [Geo(i).P(j).y,Geo(i).P(j).y(1)],...
                  temp,'FaceAlpha',0.3)
            geom = center_gravity( Geo(i).P(j).x, Geo(i).P(j).y );
            Str='';
            for g=1:numel(Geo(i).index)
                Str = strcat(Str,int2str(Geo(i).index(g)),',');
            end
            Str = Str(1:end-1);
            if inpolygon(geom(1),geom(2),...
                         [Geo(i).P(j).x,Geo(i).P(j).x(1)],...
                         [Geo(i).P(j).y,Geo(i).P(j).y(1)])
                X1 = geom(1);
                Y1 = geom(2);
            else
                temp1 = axis;
                X1 = min(Geo(i).P(j).x) + (temp1(1)+temp1(2))/100;
                Y1 = min(Geo(i).P(j).y) + (temp1(3)+temp1(4))/100;
            end
            text(X1,Y1,Str,...%'BackgroundColor',[1 1 1],...
                'Color',temp,...
                'FontSize',14,...
                'VerticalAlignment','middle',...
                'HorizontalAlignment','center');
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(1,2,1)
    hold on
    grid on
    box on
    axis equal
    for i=1:N_polygons
        for j=1:numel(S(i).P)
        h = plot(S(i).P(j).x,S(i).P(j).y,'color',colour(i,:),'LineWidth',3);
%         text(S(n).x(1)+0.2,S(n).y(1)+0.2,num2str(n),...
%              'color',colour(n,:),'FontSize',14);
            if S(i).P(j).hole==1
                set(h,'LineStyle','--');
            end
        end
    end
    subplot(1,2,1)
    axis(axis+0.05*[-1 1 -1 1])
    subplot(1,2,2)
    axis(axis+0.05*[-1 1 -1 1])    
end



function Cen = center_gravity( x, y ) 
% This function computes the center gravity of a polygon whose coordinates
% are given with x and y

% This function is extracted from Polygeom function.
% Credit goes to 
% H.J. Sommer III - 02.05.14 - tested under MATLAB v5.2
%
% code available at:
%    http://www.me.psu.edu/sommer/me562/polygeom.m
% derivation of equations available at:
%    http://www.me.psu.edu/sommer/me562/polygeom.doc

% number of vertices
[ x ] = shiftdim( x );
[ y ] = shiftdim( y );
[ n ] = size( x,1 );

% temporarily shift data to mean of vertices for improved accuracy
xm = mean(x);
ym = mean(y);
x = x - xm*ones(n,1);
y = y - ym*ones(n,1);

% delta x and delta y
dx = x( [ 2:n 1 ] ) - x;
dy = y( [ 2:n 1 ] ) - y;

% summations for CW boundary integrals
A = sum( y.*dx - x.*dy )/2;
Axc = sum( 6*x.*y.*dx -3*x.*x.*dy +3*y.*dx.*dx +dx.*dx.*dy )/12;
Ayc = sum( 3*y.*y.*dx -6*x.*y.*dy -3*x.*dy.*dy -dx.*dy.*dy )/12;

% check for CCW versus CW boundary
if A < 0,
  A = -A;
  Axc = -Axc;
  Ayc = -Ayc;
end

% centroidal moments
xc = Axc / A;
yc = Ayc / A;

% replace mean of vertices
Cen = [xc + xm yc + ym];