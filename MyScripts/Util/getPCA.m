function [W,D] = getPCA(data)
%% Author: Petr Krýže
%% Email: petr.kryze@gmail.com
%%
    covariance = cov(data',1);

    [V,D] = eig(covariance);
    [~,I] = sort(diag(D),'descend'); % Sort eigenvalues
    
    W = zeros(size(V)); % Init transform matrix
    for i = 1 : length(I) 
        W(:,i) = V(:,I(i)); % Construct transfmatrix from eigenvectors
    end

end