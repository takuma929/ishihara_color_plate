%--------------------------------------------------------------------------
% analysis_classification.m
%
% Unsupervised classification of the pigments of each plate for each observer
% class (standard observer, 6500 K black body): the data of Figure 2.
%
% For every plate and class the pigments are divided into the two groups that
% minimise det(W), the determinant of the pooled within-group scatter, over
% all partitions into two groups of at least two pigments (classify_pigments.m).
% The group of smaller dot area is taken as the figure.
%
% Printed for every plate x class: the pigments of the figure group, the
% agreement with the reading designed for the class (fraction of dot area),
% the rank of the designed split with equal and with dot-area weights, and its
% separation D.
%
% Output: results/classification_6500K.mat
%   U(p, o).plate, .observer   plate name and observer class
%   U(p, o).figureMask         pigments of the figure group
%   U(p, o).area               fraction of dot area of each pigment
%   U(p, o).agreement          agreement with the designed reading (NaN: none designed)
%   U(p, o).weighting          'equal' or 'area' (pigment_weights.m)
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
ill = blackbody_spd(6500, D.wls);

fprintf('%-22s %-10s %-16s %-10s %-11s %-10s %-6s %s\n', 'plate', 'observer', 'figure group', 'agreement', 'rank equal', 'rank area', 'D', 'weights');
for p = 1:numel(plates)
    C = compute_cone_signals(D.reflectance(:, plates(p).ids), ill, D.T_lms, D.T_xyz);
    for o = 1:3
        X = classification_space(C, classes{o});
        [w, wname] = pigment_weights(plates(p), classes{o}, P(p).area);
        r = classify_pigments(X, P(p).masks, P(p).area, P(p).design, o, w);
        re = classify_pigments(X, P(p).masks, P(p).area, P(p).design, o);                 % equal weights
        ra = classify_pigments(X, P(p).masks, P(p).area, P(p).design, o, P(p).area);      % dot-area weights
        U(p, o) = struct('plate', plates(p).name, 'observer', classes{o}, 'figureMask', r.figure, ...
            'area', P(p).area, 'agreement', r.agreement, 'weighting', wname); %#ok<SAGROW>
        fprintf('%-22s %-10s %-16s %-10.3f %-11d %-10d %-6.1f %s\n', plates(p).label, classes{o}, mat2str(find(r.figure)), ...
            r.agreement, re.rank(o), ra.rank(o), r.d(o), wname);
    end
end
save(fullfile(resultsDir, 'classification_6500K.mat'), 'U', 'plates', 'classes');
