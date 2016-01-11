%% Set Parameters for NationOfShopkeepers

time_periods = 80;
% time independent
lambda = 0.6;       % recovery rate on default
beta = 0.96;        % utility discounting
gamma = 4;          % coefficient of risk aversion
% time varying
R_all = 1.02*ones(time_periods, 1);    % risk free interest rate. Note the final interest rate is not used.

R_all = 0.9344*ones(time_periods, 1);

%% Grids
a_grid_size = 40;               % grid for asset holding going into the following period
a_min = 0.0001;
a_max = 6;
a_grid_theta = 0.25;   % allocate more points to low levels of a
a_grid = a_min + (1-(linspace(1,0, a_grid_size)').^a_grid_theta)*(a_max-a_min);

m_grid = NaN(a_grid_size+1, time_periods);    % this will be endogenously chosen via the method of endogenous grid points
c_function = NaN(a_grid_size+1, time_periods);    % consumption function
d_function = NaN(a_grid_size+1, time_periods);    % debt function
a_function = NaN(a_grid_size+1, time_periods);    % asset, or saving function - will normally be equal to a_grid by the method of endogenous grid points

% setup final policy functions (initial conditions)
final_policy = 'EndOfLife';   % choose the final period consumption policy function
if strcmp(final_policy,'EndOfLife') % EndOfLife indicates that the agent will consume all her wealth and not be able to borrow
    m_grid(:,time_periods) = [0; linspace(a_min, a_max, a_grid_size)'];
    c_function(:,time_periods) = [0; linspace(a_min, a_max, a_grid_size)'];
    d_function(:,time_periods) = 0;
    a_function(:,time_periods) = 0;
elseif strcmp(final_policy,'Load')  % Load indicates that the policy functions will be loaded
    load('policy_functions');
else
    printf('final_policy not valid');
end
