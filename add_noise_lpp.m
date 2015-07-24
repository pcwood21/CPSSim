function [ output_lpp ] = add_noise_lpp( linprog_params, deviation )
%ADD_NOISE_LPP Summary of this function goes here
%   Detailed explanation goes here

output_lpp=linprog_params;

%Random variations in Loss
for i=1:size(output_lpp.Aeq,1)
    Atmp=output_lpp.Aeq(i,:);
	Aorig=output_lpp.Aeq(i,:);
    Atmp(Atmp<0)=Atmp(Atmp<0) + deviation.*(Atmp(Atmp<0)+1).*randn(1,size(Atmp(Atmp<0),2));
	%Don't allow flow inversion
	Atmp(Atmp>0 & Aorig < 0) = 0; 
    output_lpp.Aeq(i,:)=Atmp;
end

%Random variations in cost
forig=output_lpp.f;
output_lpp.f=output_lpp.f+deviation.*output_lpp.f.*randn(size(output_lpp.f,1),1);
%Don't allow customer/producer inversion
output_lpp.f(output_lpp.f > 0 & forig < 0) = 0;
output_lpp.f(output_lpp.f < 0 & forig > 0) = 0;

%Random varaitons in capacity
output_lpp.ub=output_lpp.ub+deviation.*output_lpp.ub.*randn(size(output_lpp.ub,1),1);
%Don't allow negative capacity
output_lpp.ub(output_lpp.ub<0)=0;


end

