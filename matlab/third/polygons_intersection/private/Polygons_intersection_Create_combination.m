function Index = Polygons_intersection_Create_combination(M)
% This function creates a list of all possible overlapping elements
% computed from an intersection area matrix

% Input:    - M    Intersection area matrix between different polygons.

% Output:   -Index Structure containing the list of all possible 
%                  overlapping polygons
%
% A recursive function is used to generate all possible combinations
% between elements
%
% Guillaume JACQUENOT
% 2007 10 14
% guillaume.jacquenot@gmail.com

if nargin==0
    % Example
    M=[     0     2     0     4     9
            0     0     0     3     4
            0     0     0     0     0
            0     0     0     0    12
            0     0     0     0     0];
end

M = triu(M,1);

Index = [];
N_combi = zeros(1,size(M,1)-1);
% Index for the structure Index
j=0;
N_elem_gt_0  = zeros(1,size(M,1)-1);
for i=1:size(M,1)-1
    N_elem_gt_0(i) = numel(find(M(i,:)~=0));
    if N_elem_gt_0(i)>=2
        j=j+1;
        Index(j).data = [i,find(M(i,:)~=0)];
        for i1 = 2:N_elem_gt_0(i)
           N_combi(i) = N_combi(i) + nchoosek(N_elem_gt_0(i),i1); 
        end
    else
        N_combi(i)=0;
    end
end
% Number of combinations to test
% N_combi_total = sum(N_combi)+  sum(N_elem_gt_0);  


N_Index = numel(Index);
for i=1:N_Index
    if numel(Index(i).data)>3
        v = Index(i).data(2:end);
        St = Create_combi(v);
        for t =1:numel(St)
          St(t).data = [Index(i).data(1), St(t).data];
        end
        Index(numel(Index)+1:numel(Index)+numel(St))=St;
        clear St
    end
end

% Reverse Index
Index_ori = Index;
N_Index = numel(Index);
for t=1:N_Index;
    Index(t) = Index_ori(N_Index-t+1);
end
clear Index_ori

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function St = Create_combi(St,v)
% Recursive function
if nargin==0
    v  = [1 2 3 4 5];
    St = [];
elseif nargin==1
    v  = St;
    St = [];
end
n     = numel(v);
N_St  = numel(St);
M     = zeros(n,n-1);
t     = repmat(v,n,1).*(ones(n)-eye(n));
index = 1;
for m=1:numel(v)
    M(m,:)              = t(m,(t(m,:)~=0));    
    St(N_St+index).data = M(m,:);
    index               = index +1;
end

if n-1>2
    for m  = 1:numel(v)
        % Recursive call
        St = Create_combi(St,M(m,:));
    end
end
clear n m t