
function [T_New,Indices_Save,Col_Num_Rep,IC] = AUX_Del_Repetitions(T,Tol)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUX_Del_Repetitions: 
%   Delete from a table the repiting rows using each row as a
%   vector and computing the Euclidean Distance between the rows. If the
%   distance between two rows is less than a tolerance, the rows are 
%   considered the same.

%%Inputs:
%   T: Table (The las collumn of this table MUST be the number of time each
%   row is repeted (0 for example).
%   Tol: Tolerance
%%Outputs:
%   T: Table without repetitive rows
%   Indices_Save: Indices of the rows from the original table that
%   correspond with rows of the new table.
%   Col_Num_Rep: Num of times the row was reapeted in the original table
%   IC: Indices that recovers the old table from the table, i.e, T =
%   T_New(IC,:)

% Examples:
%T = [ones(1,5);ones(1,5);2*ones(1,5);2*ones(1,5)];
%T = [ones(1,5); 2*ones(1,5); 5*ones(1,5); 2*ones(1,5); 5*ones(1,5)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[nT,mT] = size(T); %Size of the Table


if nT == 1 %Case if the is only one Row
    Indices_Save = 1;
    Col_Num_Rep = T(mT);
    IC = 1;
elseif nT == 0 %Case if the table is empty
    Indices_Save = [];
    Col_Num_Rep = [];    
    IC = [];
else %Case with multiple rows
    T2 = T(:,1:mT-1);
    Inds = speye(nT);
    for i = 1:nT-1
        for j = i+1:nT
        alfa = norm(T2(i,2:end)- T2(j,2:end),2);
            if alfa > Tol  %If the distance is greater than Tol, the rows are diferent.
                Inds(i,j) = 1;
            end
        end
    end

% Rep will be a table nTx2 that puts the same label in the second column
% to rows that are equal

    Rep = [(1:nT)', zeros(nT,1), T(:,mT)];
    c = 0; %c es la etiqueta.
    for i = 1:nT-1
        if Rep(i,2) == 0
           c = c+1;   
           Rep(i,2) = c;    
        end   
        for j = i+1:nT
            if (Inds(i,j)==0) && (Rep(j,2) == 0)
                Rep(j,2) = c;
            end
        end
    end

    if Rep(nT,2) == 0
        Rep(nT,2) = c+1;
    end

IC = zeros(1,nT); % These will be the indices with which I retrieve the table
    % We make 0 those rows j with Ind (i, j) = 0 (the same rows).
    Indices_Save = []; 
    for i = 1:nT-1
        for j = i+1:nT
            if Inds(i,j) == 0 % If the index is 0 they are repeated 
                T2(j,:) = 100*ones(1,mT-1); % This can be improved !!!
            end
        end
    end

    for i = 1:nT
        if isequal(T2(i,:), 100*ones(1,mT-1)) == 0 % If it is not zero, we keep it
            Indices_Save(end+1) = i;
        end
    end

IC = zeros(1,nT); % These will be the indices with which I retrieve the table
    for i = 1:nT
        x = Rep(i,2);
        for j = 1:length(Indices_Save)
            if Rep(Indices_Save(j),2) == x
                IC(i) = j;
            end
        end
    end

   
    % We sift the table
    T = T(Indices_Save,:); % We save the rows that interest us
    n_Ind = length(Indices_Save);
    Col_Num_Rep = zeros(n_Ind,1);
    for i=1:n_Ind  
        x = Rep(Rep(:,2) == Rep(Indices_Save(i),2),3);  
        Col_Num_Rep(i) = sum(x) +length(x)-1;
    end
    T(:,mT) =  Col_Num_Rep;
end
T_New = T;
end