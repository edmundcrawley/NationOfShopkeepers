function [ transition_matrix , wealth_loss] = wealth_transition(c_function, d_function, m_grid, R, wealth_grid, lambda)
%wealth_transition creates the transition matrix to iterate the distribution of wealth forward
%one period given consumption and borrowing funtions.
% Inputs:
%    c_function - consuption function
%    d_funcion - debt function
%    m_grid - cash-on-hand grid relating to the points of c_function and
%    d_function
%    R - risk free interest rate
%    wealth_grid - discretized grid of wealth
%    lambda - recovery rate on default
% Outputs:
%    transition_matrix - iterates a distribution for wealth defined on
%    wealth_grid forward one unit of time, assuming agents follow the input
%    policy functions
%    wealth_loss - the amount of income lost to default at each point on
%    wealth_grid
consumption = interp1(m_grid, c_function, wealth_grid,'linear','extrap');
debt = interp1(m_grid, d_function, wealth_grid,'linear','extrap');
savings = wealth_grid - consumption + debt;

income_grid_size = 10;
wealth_grid_size = length(wealth_grid);
transition_matrix = zeros(wealth_grid_size, wealth_grid_size);
wealth_loss = zeros(wealth_grid_size, 1);

for i=1:wealth_grid_size
    risky_rate = risky_rate_func(R, lambda, debt(i));
    [income_grid, income_grid_weights] = income_grid_func(income_grid_size, debt(i), risky_rate);
    wealth_next = savings(i)*R + max(income_grid - debt(i)*risky_rate, 0);
    for j=1:wealth_grid_size-1
        for k=1:income_grid_size
            if wealth_grid(j)<=wealth_next(k) && wealth_next(k)<wealth_grid(j+1)
                transition_matrix(j,i) = transition_matrix(j,i) + income_grid_weights(k)*(wealth_grid(j+1)-wealth_next(k))/(wealth_grid(j+1)-wealth_grid(j));
                transition_matrix(j+1,i) = transition_matrix(j+1,i) + income_grid_weights(k)*(wealth_next(k)-wealth_grid(j))/(wealth_grid(j+1)-wealth_grid(j));
            end
            if j==1 && wealth_next(k)<wealth_grid(j)
                transition_matrix(j,i) = transition_matrix(j,i) + income_grid_weights(k);
            elseif j==wealth_grid_size-1 && wealth_next(k)>=wealth_grid(j+1)
                transition_matrix(j+1,i) = transition_matrix(j+1,i) + income_grid_weights(k);
            end
        end
    end
    wealth_loss(i) = sum(max(debt(i)*risky_rate-income_grid,0))*(1-lambda);
end

