function [c_func_it, d_func_it, a_func_it, m_grid_it] = iterate_policy(R, beta, gamma, lambda, m_grid_next, c_func_next, a_grid)
%iterate_policy Recursively calculates policy functions
% Inputs:
%   R - risk free interest rate
%   beta - utility discount factor
%   gamma - coefficient risk aversion
%   lambda - recovery rate on default
%   m_grid_next - endogenous grid points for c_func_next
%   c_func_next - consumption function in next period given cash-on-hand
%   given be m_grid_next
%   a_grid - grid of savings to be used to calcute the endogenous m_grid_it
% Outputs:
%    c_func_it - consuption function
%    d_func_it - debt function
%    a_func_it - asset/saving function
%    m_grid_it - cash-on-hand grid

[foo1,foo2, max_debt] = risky_rate_func(R,lambda, 0);   %calculate the maximum debt possible in this period

a_grid_size = size(a_grid,1);
c_func_it = NaN(a_grid_size+1, 1);
d_func_it = NaN(a_grid_size+1, 1);
a_func_it = NaN(a_grid_size+1, 1);
m_grid_it = NaN(a_grid_size+1, 1);
% add point at lowest possible cash-on-hand level
c_func_it(1) = 0;
d_func_it(1) = max_debt;
a_func_it(1) = 0;
m_grid_it(1) = -max_debt;

income_grid_size = 10;

for i = 1:a_grid_size
    %first find the optimal debt, and risky_rate associated with this level of savings
    debt = solve_debt_foc(a_grid(i), R, lambda, gamma, beta, c_func_next, m_grid_next, income_grid_size, 0, max_debt);
    risky_rate = risky_rate_func(R, lambda, debt);
    %next calucate the 'gothic' functions
    [income_grid, income_grid_weights] = income_grid_func(income_grid_size, debt, risky_rate);
    m_next = a_grid(i)*R + max(income_grid - debt*risky_rate, 0);
    c_next = interp1(m_grid_next, c_func_next, m_next, 'linear', 'extrap');
    gothic_va = sum(beta*R*c_next.^(-gamma) .* income_grid_weights);
    gothic_c = gothic_va^(-1/gamma);
    %then input values into the policy functions
    c_func_it(i+1) = gothic_c;
    d_func_it(i+1) = debt;
    a_func_it(i+1) = a_grid(i);
    m_grid_it(i+1) = c_func_it(i+1) + a_func_it(i+1)-d_func_it(i+1);
end
end

%binary search for optimal debt given asset level
%note there is probably a faster and better way of doing this.
function debt = solve_debt_foc(a, R, lambda, gamma, beta, c_func_next, m_grid_next, income_grid_size, min_debt, max_debt)
num_iterations = 20;
min = min_debt;
max = max_debt;
debt = (min+max)/2;
for i = 1:num_iterations
    foc = debt_foc(debt, a, R, lambda, gamma, beta, c_func_next, m_grid_next, income_grid_size);
    if foc<0    %foc<0 indicates too much debt
        max = debt;
    else
        min = debt;
    end
    debt = (min+max)/2;
end
end
%First order condition for debt, given savings level a.
function debt_foc = debt_foc(debt, a, R, lambda, gamma, beta, c_func_next, m_grid_next, income_grid_size)
    [risky_rate, drisky_rate_ddebt] = risky_rate_func(R, lambda, debt);
    [income_grid, income_grid_weights] = income_grid_func(income_grid_size, debt, risky_rate);
    m_next = a*R + max(income_grid - debt*risky_rate, 0);
    c_next = interp1(m_grid_next, c_func_next, m_next, 'linear', 'extrap');
    gothic_va = beta*R*sum(c_next.^(-gamma) .* income_grid_weights);
    income_grid_weights_survival = income_grid_weights;
    income_grid_weights_survival(1) = 0;    %debt only has weight on derivative when there is no default
    gothic_vd = beta*sum((-risky_rate - debt*drisky_rate_ddebt).*c_next.^(-gamma) .* income_grid_weights_survival);
    debt_foc = gothic_va + gothic_vd;
end



