
To do a basic re-experimentation, run the find_impact.m and then go to the lower portion of the file for plotting
Additional comments are in the files.



Files:
constants.m
Defines the enumeration of nodes in the system

create_biograph_obj.m
Some supporting matlab function for visualization

elec_graph.m
Defines nodes/edges in the elec infrastructure (Data Import)

find_impact.m (Study Running)
Main function that does studies

gas_elec_combi.m
Links the two graphs together (Data Merge)

gas_graph.m
DEfines the nodes/edges in the gas infrastructure (Data Import)

mincost_flow.m (Primary LP Function)
The linear programming that takes an input graph and some parameters and finds the maximum flow / min cost
