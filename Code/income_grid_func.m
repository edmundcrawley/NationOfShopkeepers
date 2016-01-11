function [income_grid, income_grid_weights] = income_grid_func(income_grid_size, debt, risky_rate)
%This function caluclates a grid for stochastic income that groups default
%values in one grid point, as income under default does not change
% Inputs:
%   income_grid_size - number of grid points on the output income_grid
%   debt    -  amount of debt
%   risky_rate - interest rate paid on risky debt
% Outputs:
%   income_grid - grid of  random income
%   income_grid_weight - probability weighting for each point on
%   income_grid
    income_grid_boundaries = [0; linspace(debt*risky_rate,1,income_grid_size)'];
    income_grid = (income_grid_boundaries(1:end-1)+income_grid_boundaries(2:end))/2;
    income_grid_weights = income_grid_boundaries(2:end)-income_grid_boundaries(1:end-1);
end