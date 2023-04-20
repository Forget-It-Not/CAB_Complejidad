function loop = MP_Loop_Detector(R)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% MP_Loop_Detector: 
%   Detect if a loop has happen in the process of union between 
%   two networks. To detect a loop we use R the matrix with the centralities
%   of each node. For each link that is accepted in the union we update the
%   matrix R, with the new centralities of the new networks. A loop is
%   detected if a row is repeted four times in the matrix R.

%Input:
%   R: Matrix with centrailities of the nodes

% Output:
%   loop: 1 if there is a loop, 0 otherwise.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Number of loops until the result is considered stable. It must be 3 or more.
n_loop = 4; 

R2=R(end,:);
x =bsxfun(@minus,R,R2);
[nx,mx] = size(x);

for i = 1:nx
    for j = 1:mx
        if x(i,j) < 1e-12 
            x(i,j) = 0;
        end
    end
end
    
comp=any(x,2);
D=find(~comp);% D is the list of rows equal to the last one.
tamD=size(D,1);
if tamD>n_loop % To save time only compare if you have done n_loop loops  
    D=D(end-n_loop:end);  %Last (n loops Indices)
    % Imagine that the indices are 5,7,9,11,13. Then the modulus of D
    % with 13-11 is going to be a vector 1,1,1,1,1
    B=mod(D,D(end)-D(end-1)); % If all B is the same then you have to stop.
    if size(unique(B))==1 % Number of different elements in B
    loop=D(end)-D(end-1);
%     fprintf('Hay %d bucles de longitud %d \n',n_bucle,bucle)
    else
        %fprintf('Hay al menos %d bucles pero irregulares\n',n_bucle)
        loop = -1; % Irregular Size
    end
else 
% fprintf(' Hay menos de %d bucles  \n',tamD)  
loop = 0;
end
end