# **NetWorld** ![Matlab](https://img.shields.io/badge/Language-Matlab-orange)

NetWorld is a theoretical and computational framework to model the evolution towards complexity of simple networked structures. In NetWorld, complex networks represent simplified chemical compounds, and interact optimizing the dynamical importance of their nodes.

For more information about how NetWorld works, see the attached Supporting Information.



# Main Programme (NetWorld.m):

 Reproduces the proccess of networks interaction for specific conditions. The conditions are given by the parameters:
 - **N**: Numerber of initial nodes.

 - **Beta**: Enviormental parameter.

 - **T_max**: Max time steps allowed

 These parameters can be changed inside the code (line 35).


 ## Input:
  - **Name**: String (File name where the output data is storaged)


 ## Output:
 - **Beta**

 - **T_Max**: Maximum number of time steps allowed.

 - **Table_Time**: Matrix (Each row corresponds to a network and each column to a measure)

 - **Table_Unique**: Matrix with the same information as Table_Time, but only with unique (without repetition) networks.

 - **Networks_Time**: Set of networks associated with Table_Time, i.e, the row i of Table_Time contains the measures of Networks_Time{i}.

 - **Networks_Unique**: Set of networks associated with Table_Unique, i.e, the row i of Table_Unique contains the measures of Networks_Time{i}.


 ## Example:
 ``` matlab
 Networld("Example")
 ```

 # More Parameters:

 There are 2 more parameters that affect the behaviour of the procces. These parameters are related with the process of union between 2 networks

- **"T_Counter"**: Number of  maximum successful links allowed  (Located in line 24 of Union.m )

- **"Min_Cent_Profit"**: Minimun profit in centrality to accept a link (Located in line 29 of Try_Links.m )
