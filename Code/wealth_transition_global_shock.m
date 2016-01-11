function [ transition_matrix_global_shock ] = wealth_transition_global_shock(c_function, d_function, m_grid, R, wealth_grid, lambda, price_shock)
%wealth_transition_global_shock creates the transition matrix to iterate the distribution of wealth forward
%one period given consumption and borrowing funtions AND given a global
%shock to prices with debt and savings set in nominal terms
% Inputs:
%    c_function - consuption function
%    d_funcion - debt function
%    m_grid - cash-on-hand grid relating to the points of c_function and
%    d_function
%    R - risk free interest rate
%    wealth_grid - discretized grid of wealth
%    lambda - recovery rate on default
%    price_shock - Multiplicative factor for prices (1.1 => 10% increase in
%    prices)
% Outputs:
%    transition_matrix_global_shock - iterates a distribution for wealth defined on
%    wealth_grid forward one unit of time, given the price_shock
consumption = interp1(m_grid, c_function, wealth_grid,'linear','extrap');
debt = interp1(m_grid, d_function, wealth_grid,'linear','extrap');
savings = wealth_grid - consumption + debt;

income_grid_size = 10;
wealth_grid_size = length(wealth_grid);
transition_matrix_global_shock = zeros(wealth_grid_size, wealth_grid_size);

debt_shocked = debt/price_shock;
% ***********Note - more/less defaults will mean 'savings' are no longer
% risk free. This number should account for that eventually.
savings_shocked = savings/price_shock;

for i=1:wealth_grid_size
    risky_rate = risky_rate_func(R, lambda, debt(i));
    [income_grid, income_grid_weights] = income_grid_func(income_grid_size, debt_shocked(i), risky_rate);
    wealth_next = savings_shocked(i)*R + max(income_grid - debt_shocked(i)*risky_rate, 0);
    for j=1:wealth_grid_size-1
        for k=1:income_grid_size
            if wealth_grid(j)<=wealth_next(k) && wealth_next(k)<wealth_grid(j+1)
                transition_matrix_global_shock(j,i) = transition_matrix_global_shock(j,i) + income_grid_weights(k)*(wealth_grid(j+1)-wealth_next(k))/(wealth_grid(j+1)-wealth_grid(j));
                transition_matrix_global_shock(j+1,i) = transition_matrix_global_shock(j+1,i) + income_grid_weights(k)*(wealth_next(k)-wealth_grid(j))/(wealth_grid(j+1)-wealth_grid(j));
            end
            if j==1 && wealth_next(k)<wealth_grid(j)
                transition_matrix_global_shock(j,i) = transition_matrix_global_shock(j,i) + income_grid_weights(k);
            elseif j==wealth_grid_size-1 && wealth_next(k)>=wealth_grid(j+1)
                transition_matrix_global_shock(j+1,i) = transition_matrix_global_shock(j+1,i) + income_grid_weights(k);
            end
        end
    end
end
