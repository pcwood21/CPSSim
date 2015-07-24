function [ cost,flows ] = optimize_cost( linprog_params )
%SINGLE_ACTOR_COST_OPTIMIZE Performs optimization problem given inputs of
%capacity, cost, loss, and edges
%   All of the inputs, except edges, are per-edge vectors in the order of
%   the input edges

f=linprog_params.f;
A=linprog_params.A;


end

