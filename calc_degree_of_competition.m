function [ deg_of_com ] = calc_degree_of_competition( impact_matrix, edges, capacity )
%CREATE_IMPACT_MATRIX Summary of this function goes here
%   Positive impacts are gains, negative impacts are losses


nEdges=size(edges,1);
maxIdx=max(max(edges));

deg_of_com=zeros(maxIdx,1);

impact_matrix(impact_matrix<0)=0;

for i=1:maxIdx
    in_edges=[];
    for j=1:nEdges
        if edges(j,2)==i
            in_edges(end+1)=j;
        end
    end
    
    doc=0;
    for j=1:length(in_edges)
        timp=sum(impact_matrix(in_edges(j),:));
        doc=doc+timp;%/capacity(in_edges(j));
    end
    deg_of_com(i)=doc;
    
end

deg_of_com=abs(deg_of_com);

end

