function spd = blackbody_spd(T, wls)
% blackbody_spd  Planckian radiator spectrum (relative units).
%
%   spd = blackbody_spd(T, wls) returns the spectral radiant exitance of a
%   black body at temperature T (K) on the wavelength grid wls (nm), as a
%   column vector normalised so that its maximum is 1. One column per T if T
%   is a vector.

c1 = 3.741832e-16;      % 2*pi*h*c^2  (W m^2)
c2 = 1.438786e-2;       % h*c/k       (m K)

lambda = wls(:) * 1e-9;                     % m
T = T(:)';
spd = zeros(numel(lambda), numel(T));
for n = 1:numel(T)
    spd(:, n) = c1 ./ (lambda.^5 .* (exp(c2 ./ (lambda * T(n))) - 1));
    spd(:, n) = spd(:, n) / max(spd(:, n));
end
end
