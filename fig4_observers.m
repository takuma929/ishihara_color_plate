%--------------------------------------------------------------------------
% fig4_observers.m
%
% Figure 4: the designed readings across individual colour-normal observers
% (10,000 simulated observers, 10-deg field).
%
% (a) fig_04a_cone_fundamentals.pdf/png
%     Peak-normalised L, M, S cone fundamentals of every 20th simulated
%     observer (thin), the population median (bold) and the Stockman-Sharpe
%     10-deg fundamentals (dashed).
% (b) fig_04b_separation_boxes.pdf/png
%     Separation D of the reading designed for each observer class, per plate:
%     median (symbol) and 2.5th-97.5th percentile range (bar) over observers,
%     for the trichromat (black), protan (orange) and deutan (green) reading.
%
% Input : results/observers_asano_10deg.mat (generate_observers.m),
%         results/stability_observers.mat (analysis_stability.m)
% Output: figs/fig_04a_*.pdf/png, figs/fig_04b_*.pdf/png
%
% Author: TM, 2026
%--------------------------------------------------------------------------

clearvars; close all; clc;

projectRoot = fileparts(mfilename('fullpath'));
addpath(fullfile(projectRoot, 'utils'));
resultsDir = fullfile(projectRoot, 'results');
figDir = fullfile(projectRoot, 'figs');
if ~exist(figDir, 'dir'), mkdir(figDir); end

figp = fig_parameters();
OBS = load(fullfile(resultsDir, 'observers_asano_10deg.mat'), 'wls', 'fund');
R = load(fullfile(resultsDir, 'stability_observers.mat'), 'dd', 'classes');       % analysis_stability.m
plates = plate_definitions(); classes = R.classes;
D = load_spectral_data(projectRoot);

colTri = [0.15 0.15 0.15];
colPro = [0.85 0.45 0.10];
colDeu = [0.20 0.60 0.30];

%% ---- (a) cone fundamental family -----------------------------------------------
panelW = figp.twocolumn / 3;
fig = figure('Color', 'w', 'Visible', 'off'); fig.Units = 'centimeters'; fig.InvertHardcopy = 'off';
fig.Position = [2 2 panelW panelW * 0.85];
ax = axes(fig); hold(ax, 'on');
coneCol = [0.85 0.25 0.25; 0.25 0.65 0.30; 0.25 0.35 0.90];
sub = 1:20:size(OBS.fund, 1);
for c = 1:3
    Y = squeeze(OBS.fund(sub, :, c))';
    plot(ax, OBS.wls, Y, '-', 'Color', [coneCol(c, :) 0.06], 'LineWidth', 0.3);
end
for c = 1:3
    plot(ax, OBS.wls, median(squeeze(OBS.fund(:, :, c)), 1), '-', 'Color', coneCol(c, :), 'LineWidth', 1.0);
    plot(ax, D.wls, D.T_lms(c, :), '--', 'Color', 'k', 'LineWidth', 0.6);
end
xlim(ax, [390 720]); ylim(ax, [0 1.02]);
xticks(ax, 400:100:700); yticks(ax, 0:0.5:1);
xlabel(ax, 'Wavelength (nm)', 'FontWeight', 'bold', 'FontName', figp.fontname, 'FontSize', figp.fontsize_axis);
ylabel(ax, 'Normalised sensitivity', 'FontWeight', 'bold', 'FontName', figp.fontname, 'FontSize', figp.fontsize_axis);
fig_axis_style(ax, figp);
ax.Units = 'centimeters';
ax.Position = [0.95 0.80 panelW - 1.15 panelW * 0.85 - 1.05];
ticklengthcm(ax, 0.05);
drawnow; pause(0.05);
exportgraphics(fig, fullfile(figDir, 'fig_04a_cone_fundamentals.pdf'), 'ContentType', 'vector');
exportgraphics(fig, fullfile(figDir, 'fig_04a_cone_fundamentals.png'), 'Resolution', 600);
close(fig);

%% ---- (b) separation D of each designed reading across observers --------------------
panelW = figp.twocolumn * 2 / 3;
fig = figure('Color', 'w', 'Visible', 'off'); fig.Units = 'centimeters'; fig.InvertHardcopy = 'off';
fig.Position = [2 2 panelW figp.twocolumn / 3 * 0.85 + 0.35];
ax = axes(fig); hold(ax, 'on');

nP = numel(plates);
spacing = 0.24;
iT = find(strcmp(classes, 'trichromat')); iP = find(strcmp(classes, 'protan')); iD = find(strcmp(classes, 'deutan'));
for p = 1:nP
    x0 = p;
    % The spread across observers is small compared with the differences between
    % readings, so each distribution is drawn as a marker at the median with a bar
    % over the central 95 % of observers (2.5th-97.5th percentile).
    draw_range(ax, x0 - spacing, R.dd(:, p, iT, 1), colTri);     % trichromat reading, by trichromats
    draw_range(ax, x0,           R.dd(:, p, iP, 2), colPro);     % protan reading, by protans
    draw_range(ax, x0 + spacing, R.dd(:, p, iD, 3), colDeu);     % deutan reading, by deutans
end
% colour key inside the panel
key = {'trichromat reading', 'protan reading', 'deutan reading'}; kc = {colTri, colPro, colDeu};
for k = 1:3
    plot(ax, 2.45, 13.2 - 1.45 * (k - 1), 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'none', 'MarkerEdgeColor', kc{k}, 'LineWidth', 1.0);
    text(ax, 2.58, 13.2 - 1.45 * (k - 1), key{k}, 'FontName', figp.fontname, 'FontSize', figp.fontsize, 'VerticalAlignment', 'middle');
end
xlim(ax, [0.5 nP + 0.5]); xticks(ax, 1:nP);
ax.XTickLabel = arrayfun(@(pl) type_label(pl), plates, 'UniformOutput', false); ax.XTickLabelRotation = 0;
ylim(ax, [0 14]); yticks(ax, 0:4:12);
ylabel(ax, 'Separation {\itD}', 'FontWeight', 'bold', 'FontName', figp.fontname, 'FontSize', figp.fontsize_axis);
fig_axis_style(ax, figp);
ax.XGrid = 'off';
ax.Units = 'centimeters';
ax.Position = [0.95 1.15 panelW - 1.15 figp.twocolumn / 3 * 0.85 - 1.05];
ticklengthcm(ax, 0.05);
drawnow; pause(0.05);
exportgraphics(fig, fullfile(figDir, 'fig_04b_separation_boxes.pdf'), 'ContentType', 'vector');
exportgraphics(fig, fullfile(figDir, 'fig_04b_separation_boxes.png'), 'Resolution', 600);
close(fig);

% ---- numbers for the text --------------------------------------------------------
fprintf('%-16s %-11s %-8s  median [5th 95th]\n', 'plate', 'class', 'reading');
for p = 1:nP
    pr = @(d, cls, rd) fprintf('%-16s %-11s %-8s  %.3f [%.3f %.3f]\n', plates(p).name, cls, rd, median(d, 'omitnan'), prctile(d, 5), prctile(d, 95));
    if ~all(isnan(R.dd(:, p, iT, 1))), pr(R.dd(:, p, iT, 1), 'trichromat', 'normal'); end
    if ~all(isnan(R.dd(:, p, iP, 2))), pr(R.dd(:, p, iP, 2), 'protan', 'protan'); end
    if ~all(isnan(R.dd(:, p, iD, 3))), pr(R.dd(:, p, iD, 3), 'deutan', 'deutan'); end
    if plates(p).type == 5
        pr(R.dd(:, p, iP, 3), 'protan', 'deutan'); pr(R.dd(:, p, iD, 2), 'deutan', 'protan');
    end
end
fprintf('Fig 4 panels written to %s\n', figDir);

function s = type_label(pl)
r = {pl.normal, pl.protan, pl.deutan};
r = unique(r(~cellfun(@isempty, r)), 'stable');
s = sprintf('Type %d\\newline%s', pl.type, strjoin(cellfun(@(x) ['"' x '"'], r, 'UniformOutput', false), '/'));
end

function draw_range(ax, xc, d, col)
% median (open marker) and central 95 % range (bar) of one distribution
d = d(~isnan(d)); if isempty(d), return; end
q = prctile(d, [2.5 50 97.5]);
line(ax, [xc xc], q([1 3]), 'Color', col, 'LineWidth', 1.2);
plot(ax, xc, q(2), 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'none', ...      % open, so that the bar stays visible
    'MarkerEdgeColor', col, 'LineWidth', 1.0);
end
