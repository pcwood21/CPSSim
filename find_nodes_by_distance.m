[ edges,capacity,cost,loss,extras ] = map_ng_elec_model();

G=zeros(size(edges,1),size(edges,1));

for i=1:size(edges,1)
    x=edges(i,1);
    y=edges(i,2);
    G(x,y)=1;
end
G=sparse(G);

[dist]=graphallshortestpaths(G);

nodes=unique(edges);

potential_edges=[];
for i=1:length(nodes)
    for j=1:length(nodes)
        if dist(nodes(i),nodes(j)) <= 2 && i ~= j
            potential_edges(end+1,:)=[nodes(i) nodes(j)];
        end
    end
end
