function D = load_spectral_data(projectRoot)
% load_spectral_data  Reflectances, standard-observer sensitivities, 390:1:780 nm.
%
%   D = load_spectral_data(projectRoot) returns
%     D.wls          391 x 1   wavelength (nm), 390:1:780
%     D.reflectance  391 x 89  measured Ishihara pigment reflectances
%     D.T_lms        3 x 391   Stockman-Sharpe 10-deg cone fundamentals (peak = 1);
%                              the plates subtend several degrees at the reading distance
%     D.T_xyz        3 x 391   CIE 1931 2-deg colour matching functions
%
%   The raw reflectance file holds 380:1:780 nm (401 rows); the first ten rows
%   (380-389 nm) are discarded so everything shares the 390:1:780 grid of the
%   cone fundamentals.

wls = (390:780)';

S = load(fullfile(projectRoot, 'data', 'Ishihara_reflectance.mat'), 'reflectance');
R = S.reflectance;
if size(R, 1) == numel(wls) + 10
    R = R(11:end, :);
elseif size(R, 1) ~= numel(wls)
    error('Unexpected reflectance size: %d x %d', size(R, 1), size(R, 2));
end

C = load(fullfile(projectRoot, 'data', 'T_cones_ss10.mat'));     % T_cones_ss10, S_cones_ss10 = [start step n]
wl_c = C.S_cones_ss10(1) + C.S_cones_ss10(2) * (0:C.S_cones_ss10(3) - 1);
T_lms = interp1(wl_c, C.T_cones_ss10', wls, 'linear', 0)';
T_lms = T_lms ./ max(T_lms, [], 2);

X = load(fullfile(projectRoot, 'data', 'T_xyz1931.mat'));        % T_xyz1931 (3 x 81), S_xyz1931 = [380 5 81]
wl_x = X.S_xyz1931(1) + X.S_xyz1931(2) * (0:X.S_xyz1931(3) - 1);
T_xyz = interp1(wl_x, X.T_xyz1931', wls, 'spline', 0)';
T_xyz(T_xyz < 0) = 0;

D.wls = wls;
D.reflectance = R;
D.T_lms = T_lms;
D.T_xyz = T_xyz;
end
