function [fHandle] = fitFunction(x)
fHandle = @(c) c(1)*( erf(c(2)*(x(:)-c(3))) - erf(c(4)*(x(:)-c(5))) ) + c(6);