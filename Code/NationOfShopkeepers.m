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
plot_policy

%% Now find wealth distribution
wealth_grid_size = 100;
max_wealth = 4;
wealth_grid = linspace(0,max_wealth,wealth_grid_size)';
initial_dist = ones(wealth_grid_size,1)/wealth_grid_size;
transition_matrix = wealth_transition(c_function(:,1), d_function(:,1), m_grid(:,1), R, wealth_grid, lambda);
next_dist = initial_dist;
for i=1:100
    next_dist = transition_matrix*next_dist;
end
excess_wealth = sum(next_dist.*wealth_grid)-0.5;
figure;
plot(wealth_grid,next_dist);
initial_dist = next_dist;

%% Find equilibrium interest rate
time_periods = 10;  %convergence might be faster if we start closer to the solution
R_max = 0.935;
R_min = 0.93;
R = (R_max+R_min)/2;

for i=1:10   %binary search for R
    c_func_it = c_function(:,1);
    m_grid_it = m_grid(:,1);
    for j = 1:10    %first find the policy functions
        [c_func_it, d_func_it, a_func_it, m_grid_it] = iterate_policy(R, beta, gamma, lambda, m_grid_it, c_func_it, a_grid);
    end
    transition_matrix = wealth_transition(c_func_it, d_func_it, m_grid_it, R, wealth_grid, lambda);
    next_dist = initial_dist;
    for i=1:25
        next_dist = transition_matrix*next_dist;
    end
    excess_wealth = sum(next_dist.*wealth_grid)-0.5;
    if excess_wealth > 0
        R_max=R;
    else
        R_min = R;
    end
    R = (R_max+R_min)/2;
end
initial_dist = next_dist;
R_eq = R;
c_func_eq = c_func_it;
d_func_eq = d_func_it;
a_func_eq = a_func_it;
m_grid_eq = m_grid_it;
%% Find equilibrium interest rate in transition after productivity shock
time_periods = 8;
R_add = [100, 50, 25, 12, 6, 3, 1, 0]';
R_all = R_eq*ones(time_periods, 1);
%R_all = R_all - R_add*0.01/100;
R_all(1) = R_all(1)-0.1;

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
next_dist = initial_dist;
for t=1:time_periods
    R = R_all(t,1); 
    transition_matrix = wealth_transition(c_function_transition(:,t), d_function_transition(:,t), m_grid_transition(:,t), R, wealth_grid, lambda);
    next_dist = transition_matrix*next_dist;
    wealth_dist_all(:,t) = next_dist;
end



