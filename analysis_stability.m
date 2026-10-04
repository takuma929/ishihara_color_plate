%--------------------------------------------------------------------------
% analysis_stability.m
%
% Stability of the unsupervised classification across illuminants and across
% individual observers: the data of Figures 3 and 4.
%
% The classification of analysis_classification.m is repeated
%   (1) for black-body illuminants from 3000 to 20000 K at 16 colour
%       temperatures spaced evenly in mired (6500 K included), standard observer;
%   (2) for 10,000 simulated colour-normal observers (generate_observers.m) at
%       6500 K; their dichromatic projections serve as protans and deutans.
%
% For every condition and plate x class (classify_pigments.m):
%   same       the partition returned equals that of the standard observer at 6500 K
%   agreement  fraction of dot area assigned as in the reading designed for the class
%   rankN/P/D  rank of the normal / protan / deutan designed split (1 = returned)
%   dN/dP/dD   separation D of that split
%
% Output: results/stability_illuminant.csv
%         results/stability_observers.mat (same, agreement, rk, dd) and .csv (summary)
%
% Author: TM, 2026
%--------------------------------------------------------------------------
clearvars; clc;
projectRoot = fileparts(mfilename('fullpath'));
addpath(fullfile(projectRoot, 'utils'));
resultsDir = fullfile(projectRoot, 'results');
if ~exist(resultsDir, 'dir'), mkdir(resultsDir); end

D = load_spectral_data(projectRoot); plates = plate_definitions(); P = plate_setup(plates, projectRoot);
classes = {'trichromat', 'protan', 'deutan'};
nP = numel(plates); nO = 3;
W = cell(nP, nO);                                  % pigment weights of each plate x class
for p = 1:nP, for o = 1:nO, W{p, o} = pigment_weights(plates(p), classes{o}, P(p).area); end, end

% ---- reference: standard observer, 6500 K
ref = cell(nP, nO);
for p = 1:nP
    C = compute_cone_signals(D.reflectance(:, plates(p).ids), blackbody_spd(6500, D.wls), D.T_lms, D.T_xyz);
    for o = 1:nO
        r = classify_pigments(classification_space(C, classes{o}), P(p).masks, P(p).area, P(p).design, o, W{p, o});
        ref{p, o} = r.best;
    end
end

% ---- (1) illuminant: black bodies 3000-20000 K, evenly spaced in mired
miredList = sort(unique([linspace(1e6 / 20000, 1e6 / 3000, 15), 1e6 / 6500]));
rows = {};
for cct = 1e6 ./ miredList
    for p = 1:nP
        C = compute_cone_signals(D.reflectance(:, plates(p).ids), blackbody_spd(cct, D.wls), D.T_lms, D.T_xyz);
        for o = 1:nO
            r = classify_pigments(classification_space(C, classes{o}), P(p).masks, P(p).area, P(p).design, o, W{p, o});
            rows(end+1, :) = {cct, plates(p).name, classes{o}, isequal(r.best, ref{p, o}), r.agreement, ...
                r.rank(1), r.rank(2), r.rank(3), r.d(1), r.d(2), r.d(3), mat2str(find(r.figure))}; %#ok<SAGROW>
        end
    end
end
TI = cell2table(rows, 'VariableNames', {'cct', 'plate', 'observer', 'same', 'agreement', ...
    'rankN', 'rankP', 'rankD', 'dN', 'dP', 'dD', 'figureGroup'});
writetable(TI, fullfile(resultsDir, 'stability_illuminant.csv'));

fprintf('\nILLUMINANT: colour temperatures (of 16) at which the designed reading is returned\n');
fprintf('(agreement > 90 %% of dot area), and range of the separation D of that reading\n');
dcol = {'dN', 'dP', 'dD'};
for p = 1:nP
    for o = 1:nO
        s = TI(strcmp(TI.plate, plates(p).name) & strcmp(TI.observer, classes{o}), :);
        if all(isnan(s.agreement)), continue; end
        fprintf('%-18s %-10s returned at %2d   D %5.1f - %-5.1f\n', plates(p).name, classes{o}, sum(s.agreement > 0.9), min(s.(dcol{o})), max(s.(dcol{o})));
    end
end

% ---- (2) individual observers, 6500 K
OBS = load(fullfile(resultsDir, 'observers_asano_10deg.mat'), 'wls', 'fund');
assert(isequal(OBS.wls(:), D.wls(:)), 'Observer and reflectance wavelength grids differ.');
nObs = size(OBS.fund, 1); ill = blackbody_spd(6500, D.wls);
same = false(nObs, nP, nO); agreement = nan(nObs, nP, nO); rk = nan(nObs, nP, nO, 3); dd = nan(nObs, nP, nO, 3);
for i = 1:nObs
    T_lms = squeeze(OBS.fund(i, :, :))';
    for p = 1:nP
        C = compute_cone_signals(D.reflectance(:, plates(p).ids), ill, T_lms, D.T_xyz);
        for o = 1:nO
            r = classify_pigments(classification_space(C, classes{o}), P(p).masks, P(p).area, P(p).design, o, W{p, o});
            same(i, p, o) = isequal(r.best, ref{p, o}); agreement(i, p, o) = r.agreement; rk(i, p, o, :) = r.rank; dd(i, p, o, :) = r.d;
        end
    end
end
save(fullfile(resultsDir, 'stability_observers.mat'), 'same', 'agreement', 'rk', 'dd', 'plates', 'classes');

rows = {};
fprintf('\nOBSERVERS (N = %d): %% with the partition of the standard observer, and separation D of the\n', nObs);
fprintf('reading designed for the class (median, 2.5th - 97.5th percentile)\n');
for p = 1:nP
    for o = 1:nO
        d = dd(:, p, o, o); if all(isnan(d)), continue; end
        q = prctile(d, [2.5 50 97.5]);
        rows(end+1, :) = {plates(p).name, classes{o}, 100 * mean(same(:, p, o)), q(2), q(1), q(3)}; %#ok<SAGROW>
        fprintf('%-18s %-10s same %5.1f%%   D %5.1f (%.1f - %.1f)\n', rows{end, :});
    end
end
writetable(cell2table(rows, 'VariableNames', {'plate', 'observer', 'pctSame', 'dMedian', 'dLo', 'dHi'}), ...
    fullfile(resultsDir, 'stability_observers.csv'));
