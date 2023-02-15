function partition= MP_Partition_Eigenvector(red_inicial)

% CRYPTIC COMMENTS FROM ORIGINAL AUTHOR (disturbing messages from the past?)
    %la red se debe llamar red_inicial y se pinta con > red_inicial=Redes{1,33};Red=graph(Red);plot(Red);
    %Antes de arrancarlo hay que hacer :EJEMPLO:  se lee T_9,
    %red_inicial=Redes{1,33}; partition_eigenvector
    %%% DEVUELVE en red_def (cell) todas las redes nuevas, sean las que
    %%% sean. Pero ojo, que coloca los nodos con 0 en redes simetricas donde le apetece (es
    %%% aleatorio).
    %%%% NEW: NO USA LA ORDEN conncomp (2015), con lo que se puede usar en el SERVIDOR
    %%%% DEL CAB
    %% IMPORTANTE: LE METE 1 EN LA DIAGONAL PARA HACER LA DIVISION PORQUE SI NO SALEN COSAS RARAS Y LUEGO SE LOS QUITA

%%M%% Se pone la diagonal a 1 porque tiene que estar así para que se cumpla
%%la formula de la matriz de modularidad (al final considerar que un nodo
%%esta o no conectado a si mismo es un poco arbitrario y esa formula se
%%obtiene suponiendo que esta codificado de esa forma)
A=red_inicial+diag(ones(size(red_inicial,1),1)); %%OJO, PONE 1 en la diagonal. LUEGO BORRAR SI NO SE USAN.
k=sum(A);
links=sum(sum(A))/2;

%%M%% Matriz de modularidad
B=A-(k'*k)/(2*links);
[V,~]=eigs(B,[],1);

S = V>0;
S2 = V<0;

%%M%% PROBLEMA PARTICION: para algunas redes el autovector tiene valor 0 en
%%algunos nodos, por lo que hay que ver como se separan

zero_resolution_mode = 'ninguno';
% Flag para solucionar manualmente las redes de 2 y 3 nodos (en principio
% son las 2 únicas que dan problemas)
do_manual_resolution = true;

% Flag indicating whether manual solution has been applied
manual_resolution = false;
if do_manual_resolution
    if isequal(size(red_inicial), [2,2])
        S = [true,false];
        S2 = [false,true];
        manual_resolution = true;
        % disp 'Manually solved for 2 nodes'
    elseif isequal(size(red_inicial), [3,3])
        S = [true,false,false];
        S2 = [false,true,true];
        manual_resolution = true;
        % disp 'Manually solved for 3 nodes'
    end
end

%%% METODO 1 - 'compensate' %%%: se envían los nodos a la partición que 
% tiene menos nodos en un momento dado

if isequal(zero_resolution_mode, 'compensate') && ~manual_resolution

    % Number of nodes for each partition
    ns = sum(S); ns2 = sum(S2);

    % Nodes with exact V=0
    for i = find(V==0)
        if ns < ns2
            S(i) = 1;
            ns = ns+1;
        elseif ns2 < ns
            S2(i) = 1;
            ns2 = ns2+1;
        % If both partitions have the same number, random
        else
            x = binornd(1,0.5);
            if x==0
                S(i) = 1;
                ns = ns+1;
            else
                S2(i) = 1;
                ns2 = ns2+1;
            end
        end
    end

%%% METODO 2 - 'partition' %%%: se envia la mitad de nodos a una particion
%%% y la mitad a otra (con impares el extra va a uno o a otro al azar ->
%%% con un solo nodo a 0 puede no haber separacion)

elseif isequal(zero_resolution_mode, 'partition') && ~manual_resolution
    zero_index = find(V==0);
    if isempty(zero_index) == 0
        zero_index = zero_index(randperm(max(size(zero_index))));
        
        first_extra = binornd(1,0.5);
        if first_extra == 1
            stop = ceil(max(size(zero_index))/2);
        else
            stop = floor(max(size(zero_index))/2);
        end
        S(zero_index(1:stop)) = 1;
        S2(zero_index(stop+1:end)) = 1;
    end

%%% METODO 3 - 'random' %%%: se envia cada nodo a una particion o a otra
%%% con probabilidad 0.5 -> puede haber un reparto desigual y puede no
%%% haber rotura

elseif isequal(zero_resolution_mode, 'random') && ~manual_resolution
    for i = find(V==0)
        x = binornd(1,0.5);
        if x==0
            S(i) = 1;
        else
            S2(i) = 1;
        end
    end
elseif isequal(zero_resolution_mode, 'negzero') && ~manual_resolution
    S2 = V<=0;
end


%Q=(s'*B*s)/(4*links);  %modularidad, INNECESARIO
red1=A(S,S);
red2=A(S2,S2);  %%OJO; PUEDEN ESTAR PARTIDAS EN CASOS RAROS COMO ESTRELLAS

%%M%% matriz de adyacencia global, 0s para los enlaces entre ambas
%%componentes
red_nueva = blkdiag(red1, red2);

n=1;
i=0;
red_nueva2=red_nueva;
n_redes=0;

while n>0 %% METODO NUEVO DE DETECTAR COMPONENTES DISCONEXAS EN UNA RED, FEBRERO 2021
    %[V2,D2]=eigs(red_nueva2,1)  %El eigs da a veces un vector ficticio y
    %encima es mas lento!!!

    [V2,D2]=eig(red_nueva2);
    [~,C]=max(diag(D2));
    V2=V2(:,C);
    M=abs(V2)>=1e-10; %valores positivios del autovector
    N=M<1;
    i=i+1;
    red_def{i}=red_nueva2(M,M);%%RESTO PARA PONER 0 EN LA DIAGONAL
    red_nueva2=red_nueva2(N,N);
    n=size(red_nueva2,1);
    n_redes=n_redes+1;
    %     hola=nnz(red_nueva2);
    %      if (hola==n)&&(n>0) %%CURIOSAMENTE SI NO PONGO ESTE IF TAMBIEN FUNCIONA; PERO ES UN 10% MAS LENTO
    %          for j=i+1:i+n
    %              red_def{j}=1; %%PONGO 1 EN LOS NODOS SUELTOS
    %             n_redes=n_redes+1;
    %          end
    %          n=0;n_redes=n_redes+n;
    %      end

end


for i=1:n_redes
    tam=size(red_def{i},1);
    red_def{i}=red_def{i}-eye(tam);  %%LE RESTA LA DIAGONAL; QUITAR SI NO SE NECESITA
    % red=graph(red_def{i});subplot(1,n_redes,i); plot(red); %LAS PINTA; INNECESARIO
end
partition = red_def;

% if min(abs(V)) <1e-12 %% aviso de nodos de s=0 que darian lugar a una tercera red. INNECESARIO
%   fprintf('\n nodos intermedios\n')

end