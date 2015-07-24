function [ bg2 ] = create_biograph_obj( capgraph )
% Call this function to create a biograph object for plotting purposes

% Creates a biograph and removes the nodes that aren't connected to
% anything so that viewabiltiy is better. Also turns directional into
% undirected graph for viewing.

constants;


bg=biograph(capgraph,nodeNames,'ShowWeights','on','ShowArrows','off','LayoutType','hierarchical');
[~, c]=conncomp(bg,'Weak','true');
x=1:nNodes;
delnodes=[];
for i=1:length(c);
    if sum(c==c(i)) == 1
        delnodes=[delnodes x(c==c(i))];
    end
end
tNodeNames=nodeNames;
tNodeNames(delnodes,:)=[];
tcapgraph=capgraph;
tcapgraph(delnodes,:)=[];
tcapgraph(:,delnodes)=[];

c_capcnt=tcapgraph;
c_capcnt(c_capcnt>0)=1;
ctmp=tcapgraph;
ctmp=tril(ctmp,-1)'+ctmp;
c_capcnt=tril(c_capcnt,-1)'+c_capcnt;
ctmp(c_capcnt>1)=ctmp(c_capcnt>1)/2;

bgcomb=triu((ctmp));

bg2=biograph(bgcomb,tNodeNames,'ShowWeights','on','ShowArrows','off','LayoutType','hierarchical');

end

