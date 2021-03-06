%% Nation of Shopkeepers
% Main file for running the code

%% Setup
SetupParams;

%% Recursively iterate the policy functions
for t = [time_periods-1:-1:1]
    R = R_all(t,1);   
    % c_func_it is 'iterated' consumption function, etc
    [c_func_it, d_func_it, a_func_it, m_grid_it] = iterate_policy(R, beta, gamma, lambda, m_grid(:,t+1), c_function(:,t+1), a_grid);
    c_function(:,t) = c_func_it;
    d_function(:,t) = d_func_it;
    a_function(:,t) = a_func_it;
    m_grid(:,t) = m_grid_it;
end

%% Plot some interesting graphs
%plot_policy

%% Now find wealth distribution
wealth_grid_size = 100;
max_wealth = 4;
wealth_grid = linspace(0,max_wealth,wealth_grid_size)';
initial_dist = ones(wealth_grid_size,1)/wealth_grid_size;
[transition_matrix, wealth_loss] = wealth_transition(c_function(:,1), d_function(:,1), m_grid(:,1), R, wealth_grid, lambda);
next_dist = initial_dist;
for i=1:100
    next_dist = transition_matrix*next_dist;
end
bankrupcy_costs_fraction = sum(next_dist.*wealth_loss)/0.5;
excess_wealth = sum(next_dist.*wealth_grid)-(0.5*(1-bankrupcy_costs_fraction));
figure;
plot(wealth_grid,next_dist);
initial_dist = next_dist;

%% Find equilibrium interest rate
time_periods = 10;  %convergence might be faster if we start closer to the solution
R_max = 0.929;
R_min = 0.928;
R = (R_max+R_min)/2;

for i=1:10   %binary search for R
    c_func_it = c_function(:,1);
    m_grid_it = m_grid(:,1);
    for j = 1:20    %first find the policy functions
        [c_func_it, d_func_it, a_func_it, m_grid_it] = iterate_policy(R, beta, gamma, lambda, m_grid_it, c_func_it, a_grid);
    end
    [transition_matrix, wealth_loss] = wealth_transition(c_func_it, d_func_it, m_grid_it, R, wealth_grid, lambda);
    next_dist = initial_dist;
    for j=1:25
        next_dist = transition_matrix*next_dist;
    end
    bankrupcy_costs_fraction = sum(next_dist.*wealth_loss)/0.5;
    excess_wealth = sum(next_dist.*wealth_grid)-(0.5*(1-bankrupcy_costs_fraction))
    if excess_wealth > 0
        R_max=R;
    else
        R_min = R;
    end
    R = (R_max+R_min)/2;
end
dist_eq = next_dist;
R_eq = R;
c_func_eq = c_func_it;
d_func_eq = d_func_it;
a_func_eq = a_func_it;
m_grid_eq = m_grid_it;
bankrupcy_costs_fraction_eq = bankrupcy_costs_fraction;
%% Find equilibrium interest rate in transition after productivity shock
time_periods = 10;
%R_add = [0, 100, 50, 25, 12, 6, 3, 1, 0, 0]';
R_all = R_eq*ones(time_periods, 1);
%R_all = R_all - R_add*0.01/100;
%R_all(2) = R_all(2)-0.036;

m_grid_transition = NaN(a_grid_size+1, time_periods);    
c_function_transition = NaN(a_grid_size+1, time_periods);    
d_function_transition = NaN(a_grid_size+1, time_periods);    
a_function_transition = NaN(a_grid_size+1, time_periods); 

m_grid_transition(:,time_periods) = m_grid_eq;
c_function_transition(:,time_periods) = c_func_eq;
d_function_transition(:,time_periods) = d_func_eq;
a_function_transition(:,time_periods) = a_func_eq;

for t = [time_periods-1:-1:1]
    R = R_all(t,1);   
    % c_func_it is 'iterated' consumption function, etc
    [c_func_it, d_func_it, a_func_it, m_grid_it] = iterate_policy(R, beta, gamma, lambda, m_grid_transition(:,t+1), c_function_transition(:,t+1), a_grid);
    c_function_transition(:,t) = c_func_it;
    d_function_transition(:,t) = d_func_it;
    a_function_transition(:,t) = a_func_it;
    m_grid_transition(:,t) = m_grid_it;
end
wealth_dist_all = NaN(wealth_grid_size, time_periods);
bankrupcy_costs_fraction = NaN(1, time_periods);

R = R_all(1,1); 
price_shock = 2000;  %increase all debts by 10%
[transition_matrix_global_shock, wealth_loss] = wealth_transition_global_shock(c_func_eq, d_func_eq, m_grid_eq, R, wealth_grid, lambda, price_shock, bankrupcy_costs_fraction_eq);
next_dist = transition_matrix_global_shock*dist_eq;
wealth_dist_all(:,1) = next_dist;
bankrupcy_costs_fraction(1) = sum(dist_eq.*wealth_loss)/0.5;

for t=2:time_periods
    R = R_all(t,1); 
    [transition_matrix, wealth_loss] = wealth_transition(c_function_transition(:,t), d_function_transition(:,t), m_grid_transition(:,t), R, wealth_grid, lambda);
    next_dist = transition_matrix*next_dist;
    wealth_dist_all(:,t) = next_dist;
    bankrupcy_costs_fraction(t) = sum(wealth_dist_all(:,t-1).*wealth_loss)/0.5;
end

excess_wealth = sum(wealth_dist_all.*(wealth_grid*ones(1,time_periods)))-(0.5*(1-bankrupcy_costs_fraction));

