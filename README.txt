
Instructions:
-------------------

Networld.m is the main program: It reproduces the process of interaction for  specific conditions. The conditions are given by the parameters:
N: Number of initial nodes,  Beta: Temperature/Enviromental parameter,  T_max: Max time steps allowed.
Those parameters can be change inside the code, line 35.

Networld.m needs and input data "name" which will be the name of the file were the output is stored. For each specific conditions (N, Beta, T_max), 
a folder with name ['Data','_N',num2str(N),'_Beta_',num2str(Beta),'_TMax',num2str(T_Max)] is generated. Inside this folder, the file with name "name" is stored.

The output file contains the next variables:
   -Beta
   -N: Number of initial nodes
   -T_Max: Maximum number of time steps allowed

   -Table_Time: Matrix (each row correspond to a network and each column
   correspond to a measures)

   -Table_Unique: Matrix with the same information as Table_Time but only
   with unique (with out repetion) networks

   -Networks_Time: Set of networks corresponding to Table_Time, i.e, row i 
   of Table_Time contains the measures of Networks_Time{i}

   -Networks_Unique: Set of networks corresponding to Table_Unique, i.e, row i 
   of Table_Unique contains the measures of Networks_Time{i}


Example: Networld("Example")

More Parameters:
----------------
There are 2 more parameters that affect the behaviour of the procces. These parameters are related with the process of union between 2 networks

- Number of  maximum successful links allowed  (Located in line 24 of Union  "T_Counter")

- Minimun profit in centrality to accept a link (Located in line 29 of Try_Links.m  "Min_Cent_Profit") 




