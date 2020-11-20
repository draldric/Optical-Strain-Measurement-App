function [fHandle] = fitJacobian(x)
dc1 = @(x,c) erf(c(2).*(x(:)-c(3))) - erf(c(4).*(x(:)-c(5)));
dc2 = @(x,c) c(1).*2./sqrt(pi).*exp(-(c(2).*(x(:)-c(3))).^2).*(x(:)-c(3));
dc3 = @(x,c) c(1).*2./sqrt(pi).*exp(-(c(2).*(x(:)-c(3))).^2).*(-c(2));
dc4 = @(x,c) -c(1).*2./sqrt(pi).*exp(-(c(4).*(x(:)-c(5))).^2).*(x(:)-c(5));
dc5 = @(x,c) -c(1).*2./sqrt(pi).*exp(-(c(4).*(x(:)-c(5))).^2).*(-c(4));
dc6 = @(x,c) ones(size(x(:)));

fHandle = @(c)[dc1(x,c),dc2(x,c),dc3(x,c),dc4(x,c),dc5(x,c),dc6(x,c)];