function adj_mat=wheel_graph(N)
%Create a N-Wheel Graph
%Has N vertex

adj_mat=[];
if N<4
    error('N must be >= 4');
end

adj_mat=zeros(N,N);

for i=1:N-1
    adj_mat(i,i+1)=1;
    adj_mat(i+1,i)=1;
end

adj_mat(end-1,1)=1;
adj_mat(1,end-1)=1;

adj_mat(end,:)=ones(1,N);
adj_mat(:,end)=ones(N,1);
adj_mat(end,end)=0;

end