function [risky_rate, drisky_rate_ddebt, max_debt] = risky_rate_func(R, lambda, debt)
% Calculates the risky interest rate paid given a debt level
% inputs:
%       R - risk free interest rate
%       lambda - recovery rate on default
%       debt - amount of debt (can be a vector)
% outputs:
%       risky_rate - the risky rate paid on the debt
%       drisky_rate_ddebt - derivative of risky_rate with respect to debt
%       max_debt - maximum possible amount of debt
%
% Assumes income is uniformly distributed on [0,1]
% Default occurs if income is less than risky_rate*debt
% On default (1-lambda)*income is paid to the bond holder
% Key assumption is that the expected return on the risky debt must be
% equal to the risk free return.

max_debt = 1/(4*R*(1-0.5*lambda));
risky_rate = nan(size(debt));
drisky_rate_ddebt = nan(size(debt));
for i=1:length(risky_rate)
    if debt(i)>0 && debt(i)<max_debt
        risky_rate(i) = (1-sqrt(1-4*R*debt(i)*(1-0.5*lambda)))./(2*debt(i)*(1-0.5*lambda));
        drisky_rate_ddebt(i) = R./(debt(i).*sqrt(1-4*R*debt(i)*(1-0.5*lambda))) - (1-sqrt(1-4*R*debt(i)*(1-0.5*lambda)))./(2*debt(i).^2*(1-0.5*lambda));
    elseif debt(i)<=0   %no debt => risky rate is risk free rate
        risky_rate(i) = R;
        drisky_rate_ddebt(i) = 0;
        if debt(i)==0
            drisky_rate_ddebt(i) = R^2*(1-0.5*lambda);
        end
    elseif debt(i)>=max_debt    %too much debt is not possible
        risky_rate(i) = inf;
        drisky_rate_ddebt(i) = inf;
    end
end
end
