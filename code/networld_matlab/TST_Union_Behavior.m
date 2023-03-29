Anets = {[0,1,0,0;1,0,1,1;0,1,0,0;0,1,0,0],
     [0,1,1,0,1;1,0,0,1,0;1,0,0,0,0;0,1,0,0,1;1,0,0,1,0],
     [0,1,0,0,0;1,0,1,0,0;0,1,0,1,0;0,0,1,0,1;0,0,0,1,0]};
Bnets = {[0,1;1,0],
     [0,1;1,0],
     [0,1,0;1,0,1;0,1,0]};

ncases = length(Anets);
for i=1:ncases

    A = Anets{i};
    B = Bnets{i};

    subplot(3,ncases,(i-1)*3 + 1)
    GA = graph(A);
    plot(GA)
    
    subplot(3,ncases,(i-1)*3 + 2)
    GB = graph(B);
    plot(GB);
    
    subplot(3,ncases,(i-1)*3 + 3)
    T = MP_Network_Union(A,B, 0.67);
    GT = graph(T);
    plot(GT);
    
end


