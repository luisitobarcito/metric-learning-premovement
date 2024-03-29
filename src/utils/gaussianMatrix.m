function K = gaussianMatrix(X,sigma)
N = size(X,1);
G = X*X';
K = exp(-(1/(2*sigma^2))*(diag(G)*ones(1,N)+ones(N,1)*diag(G)'-2*G)); %Equation 17.5