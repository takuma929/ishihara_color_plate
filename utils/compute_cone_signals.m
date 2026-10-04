function C = compute_cone_signals(reflectance, illuminant, T_lms, T_xyz)
% compute_cone_signals  Cone excitations and derived coordinates of surfaces.
%
%   C = compute_cone_signals(reflectance, illuminant, T_lms, T_xyz)
%
%   INPUTS
%     reflectance  nW x nS   surface reflectances (0..1)
%     illuminant   nW x 1    illuminant spectral power distribution; it is
%                            rescaled so that its Y (via T_xyz) = 100
%     T_lms        3 x nW    cone fundamentals (L; M; S), peak-normalised
%     T_xyz        3 x nW    CIE 1931 colour matching functions (for Y, sRGB)
%
%   OUTPUT (nS rows each)
%     C.LMS     nS x 3   cone excitations
%     C.MB      nS x 3   [L/(L+M), S/(L+M), L+M]: MacLeod-Boynton chromaticity
%                        and luminance, with the weights of the 10-deg observer
%     C.XYZ     nS x 3   CIE 1931 tristimulus values (Y of the illuminant = 100)
%     C.sRGB    nS x 3   gamma-corrected sRGB (0..1), for plotting only
%
%   The luminance weights are applied unchanged to the fundamentals of
%   individual observers.

ill = illuminant(:);
ill = ill / (T_xyz(2, :) * ill) * 100;
spectra = reflectance .* ill;               % nW x nS

C.LMS = (T_lms * spectra)';                 % nS x 3
C.XYZ = (T_xyz * spectra)';                 % nS x 3
C.MB = macleod_boynton(C.LMS);
C.sRGB = xyz_to_srgb(C.XYZ / 100);
end

function MB = macleod_boynton(LMS)
% MacLeod-Boynton chromaticity for the 10-deg fundamentals (CIE 170-2:2015):
% luminance = 0.692839 L + 0.349676 M, s = 0.0554786 S / luminance
Lw = 0.692839;
Mw = 0.349676;
Sw = 0.0554786;
lum = Lw * LMS(:, 1) + Mw * LMS(:, 2);
MB = [Lw * LMS(:, 1) ./ lum, Sw * LMS(:, 3) ./ lum, lum];
MB(~isfinite(MB)) = 0;
end

function rgb = xyz_to_srgb(XYZ)
M = [3.2410 -1.5374 -0.4986; -0.9692 1.8760 0.0416; 0.0556 -0.2040 1.0570];
lin = (M * XYZ')';
lin = min(max(lin, 0), 1);
rgb = lin * 12.92;
hi = lin > 0.0031308;
rgb(hi) = 1.055 * lin(hi).^(1 / 2.4) - 0.055;
end
