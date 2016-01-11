%% Plot some interesting graphs

%Plot savings and borrowings
figure;
plot(m_grid(:,1), a_function(:,1));
hold on;
plot(m_grid(:,1), d_function(:,1));
xlim([0,1.2]);
title('Saving and borrowing');
legend('Saving','Borrowing');
xlabel('Wealth');

%Plot consumption
figure;
plot(m_grid(:,1), c_function(:,1));
xlim([0,1.5]);
%ylim([0,inf]);
title('Consumption Function');
xlabel('Wealth');

%Plot consumption for different periods in life
figure;
plot(m_grid(:,time_periods), c_function(:,time_periods));
hold on;
plot(m_grid(:,time_periods-1), c_function(:,time_periods-1));
plot(m_grid(:,time_periods-5), c_function(:,time_periods-5));
plot(m_grid(:,time_periods-10), c_function(:,time_periods-10));
plot(m_grid(:,time_periods-20), c_function(:,time_periods-20));
plot(m_grid(:,1), c_function(:,1));
xlim([0,1.5]);
%ylim([0,inf]);
title('Consumption Function');
legend('T = End of Life','T-1','T-5','T-10','T-20','Beginning of life');
xlabel('Wealth');

% %Plot last consumption to see convergence
% figure;
% plot(m_grid(:,2), c_function(:,2));
% hold on;
% plot(m_grid(:,1), c_function(:,1));
% xlim([0,1.5]);
% %ylim([0,inf]);
% title('Consumption Function');
% xlabel('Wealth');

