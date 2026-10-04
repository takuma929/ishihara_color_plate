%--------------------------------------------------------------------------
% generate_observers.m
%
% Generate the population of individual colorimetric observers used for the
% individual-difference robustness analysis of the Ishihara plates.
%
% Model: Asano, Fairchild & Blonde (2016) individual colorimetric observer
% model on the CIE 2006 (CIEPO06) basis, with gene-determined discrete
% lambda_max shifts (utils/generate_coneFund_family_AsanoCIE2006.m).
%
% Settings for this project
%   - 10-deg field (the plates subtend several degrees), N = 10,000
%   - ages drawn uniformly in [18, 70] years
%   - output grid 390:1:780 nm to match Ishihara_reflectance.mat
%   - per-observer, per-cone peak normalisation ('max')
%   - rng seed 0
%
% Output
%   results/observers_asano_10deg.mat
%     wls     1 x 391   wavelength (nm)
%     fund    N x 391 x 3   cone fundamentals (L, M, S), peak-normalised
%     meta    table, one row per observer (age, density deviations, shifts)
%     params  struct with the generator settings
%
% Author: TM, 2026
%--------------------------------------------------------------------------

clearvars; close all; clc;

projectRoot = fileparts(mfilename('fullpath'));
addpath(fullfile(projectRoot, 'utils'));

dataDir = fullfile(projectRoot, 'data');
resultsDir = fullfile(projectRoot, 'results');
if ~exist(resultsDir, 'dir'), mkdir(resultsDir); end

params.N2        = 1;        % the generator needs at least one 2-deg observer; it is discarded below
params.N10       = 10000;    % 10-deg field: the plates subtend several degrees
params.seed      = 0;
params.age_range = [18 70];
params.normalize = 'max';
params.wl_out    = 390:1:780;

t0 = tic;
fprintf('Generating %d individual observers (10 deg, Asano/CIE2006) ...\n', params.N10);
obs = generate_coneFund_family_AsanoCIE2006( ...
    'data_dir',  fullfile(dataDir, 'cie2006'), ...
    'N2',        params.N2, ...
    'N10',       params.N10, ...
    'seed',      params.seed, ...
    'age_range', params.age_range, ...
    'normalize', params.normalize, ...
    'wl_out',    params.wl_out);
fprintf('  done in %.1f s\n', toc(t0));

wls  = obs.wl_out;          % 1 x 391
fund = obs.fund(params.N2 + 1:end, :, :);            % N x 391 x 3, 10-deg observers only
meta = obs.meta(params.N2 + 1:end, :);

% ---- sanity checks ------------------------------------------------------
assert(all(isfinite(fund(:))), 'Non-finite values in cone fundamentals.');
assert(size(fund, 1) == params.N10 && size(fund, 2) == numel(wls) && size(fund, 3) == 3);

[~, iL] = max(squeeze(fund(:, :, 1)), [], 2);
[~, iM] = max(squeeze(fund(:, :, 2)), [], 2);
[~, iS] = max(squeeze(fund(:, :, 3)), [], 2);
fprintf('Peak wavelength (nm), median [min max]:\n');
fprintf('  L: %d [%d %d]\n', median(wls(iL)), min(wls(iL)), max(wls(iL)));
fprintf('  M: %d [%d %d]\n', median(wls(iM)), min(wls(iM)), max(wls(iM)));
fprintf('  S: %d [%d %d]\n', median(wls(iS)), min(wls(iS)), max(wls(iS)));
fprintf('L Ser180 fraction: %.3f   S long-wave fraction: %.3f   age %d-%d\n', ...
    mean(meta.L_ser), mean(meta.S_hi), min(meta.age), max(meta.age));

% ---- save ----------------------------------------------------------------
params.generatedAt = char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));
outFile = fullfile(resultsDir, 'observers_asano_10deg.mat');
save(outFile, 'wls', 'fund', 'meta', 'params', '-v7.3');
fprintf('Saved %s\n', outFile);
