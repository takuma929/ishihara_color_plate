%--------------------------------------------------------------------------
% fig3_illuminant.m
%
% Figure 3: dependence of the designed readings on the colour temperature of
% the illuminant (standard observer).
%
% One panel per plate. x = black-body colour temperature from 3000 to 20000 K
% on a reciprocal (mired) scale, increasing to the right; y = separation D of
% the reading designed for each observer class (trichromat black, protan
% orange, deutan green). Filled symbols: colour temperatures at which the
% unsupervised classification returns that reading (agreement on more than
% 90 % of the dot area); open symbols: another partition is returned.
% Every panel spans the same range of D, with a different origin for Type 3;
% an inset in the Type 4 panel shows the two dichromatic readings on an
% expanded ordinate. Vertical grey line: 6500 K.
%
% Input : results/stability_illuminant.csv (analysis_stability.m)
% Output: figs/fig_03_<plate>.pdf/png, figs/fig_03_legend.pdf/png
%
% Author: TM, 2026
%--------------------------------------------------------------------------

clearvars; close all; clc;

projectRoot = fileparts(mfilename('fullpath'));
addpath(fullfile(projectRoot, 'utils'));
figDir = fullfile(projectRoot, 'figs');
if ~exist(figDir, 'dir'), mkdir(figDir); end

figp = fig_parameters();
T = readtable(fullfile(projectRoot, 'results', 'stability_illuminant.csv'));       % analysis_stability.m
plates = plate_definitions(); ccts = unique(T.cct, 'stable')';
mired = 1e6 ./ ccts;                       % abscissa (reciprocal colour temperature)
tickK = [3000 4000 6500 10000 20000];      % labelled colour temperatures (shown in kK)

colTri = [0.15 0.15 0.15];
colPro = [0.85 0.45 0.10];
colDeu = [0.20 0.60 0.30];
panelW = figp.twocolumn / 4;

pick = @(plate, obs, col) T.(col)(strcmp(T.plate, plate) & strcmp(T.observer, obs));
agreeMin = 0.9;      % filled marker: the unsupervised partition agrees with the designed reading on > 90 % of dot area

for p = 1:numel(plates)
    pn = plates(p).name;
    fig = figure('Color', 'w', 'Visible', 'off');
    fig.Units = 'centimeters'; fig.InvertHardcopy = 'off';
    panelH = panelW * 1.05;
    fig.Position = [2 2 panelW panelH];
    ax = axes(fig); hold(ax, 'on');
    xline(ax, 1e6 / 6500, '-', 'Color', [0.75 0.75 0.75], 'LineWidth', 0.6);

    % separation D of the reading designed for each class; marker filled where the
    % unsupervised classification returns that reading
    cls = {'trichromat', 'protan', 'deutan'}; dcol = {'dN', 'dP', 'dD'}; cols = {colTri, colPro, colDeu};
    for o = 1:3
        d = pick(pn, cls{o}, dcol{o}); ok = pick(pn, cls{o}, 'agreement') > agreeMin;
        if all(isnan(d)), continue; end
        plot(ax, mired, d, '-', 'Color', cols{o}, 'LineWidth', 1.1);
        plot(ax, mired(~ok), d(~ok), 'o', 'Color', cols{o}, 'MarkerSize', 3.4, 'MarkerFaceColor', 'w', 'LineWidth', 0.6);
        plot(ax, mired(ok), d(ok), 'o', 'Color', cols{o}, 'MarkerSize', 3.4, 'MarkerFaceColor', cols{o}, 'LineWidth', 0.6);
    end
    ax.XDir = 'reverse';                  % mired decreasing = CCT increasing to the right
    xlim(ax, [1e6 / 20000 - 18, 1e6 / 3000 + 18]); xticks(ax, sort(1e6 ./ tickK));
    ax.XTickLabel = arrayfun(@(k) sprintf('%g', k / 1000), sort(tickK, 'descend'), 'UniformOutput', false);
    ax.XTickLabelRotation = 0;
    % every panel spans the same range of D (9 units), so that distances are comparable
    % between panels; only the origin differs
    if plates(p).type == 3, yl = [6 15]; else, yl = [0 9]; end
    ylim(ax, yl); yticks(ax, yl(1):2:yl(2));
    xlabel(ax, 'CCT (kK)', 'FontWeight', 'bold', 'FontName', figp.fontname, 'FontSize', figp.fontsize_axis);
    ylabel(ax, 'Separation {\itD}', 'FontWeight', 'bold', 'FontName', figp.fontname, 'FontSize', figp.fontsize_axis);
    text(ax, 0.04, 0.98, plates(p).label, 'Units', 'normalized', 'FontName', figp.fontname, 'FontSize', figp.fontsize, 'VerticalAlignment', 'top');
    fig_axis_style(ax, figp);
    ax.XMinorTick = 'off'; ax.XGrid = 'off';
    ax.Units = 'centimeters';
    ax.Position = [0.95 0.85 panelW - 1.15 panelH - 1.10];
    ticklengthcm(ax, 0.05);
    if plates(p).type == 4
        % inset: the two dichromatic readings differ by only 0.1-0.3, shown on an expanded ordinate
        ap = ax.Position;
        axi = axes(fig, 'Units', 'centimeters', 'Position', [ap(1) + 0.42 * ap(3), ap(2) + 0.09 * ap(4), 0.54 * ap(3), 0.30 * ap(4)]); hold(axi, 'on');
        for o = 2:3
            d = pick(pn, cls{o}, dcol{o}); ok = pick(pn, cls{o}, 'agreement') > agreeMin;
            plot(axi, mired, d, '-', 'Color', cols{o}, 'LineWidth', 0.8);
            plot(axi, mired(~ok), d(~ok), 'o', 'Color', cols{o}, 'MarkerSize', 2.2, 'MarkerFaceColor', 'w', 'LineWidth', 0.5);
            plot(axi, mired(ok), d(ok), 'o', 'Color', cols{o}, 'MarkerSize', 2.2, 'MarkerFaceColor', cols{o}, 'LineWidth', 0.5);
        end
        axi.XDir = 'reverse'; xlim(axi, xlim(ax)); axi.XTick = []; ylim(axi, [4.5 5.05]); yticks(axi, [4.6 4.8 5.0]);
        axi.FontName = figp.fontname; axi.FontSize = figp.fontsize - 1.5; axi.Box = 'on'; axi.Color = 'w'; axi.LineWidth = 0.4;
        axi.TickLength = [0.03 0.03];
    end
    drawnow; pause(0.05);
    base = fullfile(figDir, sprintf('fig_03_%s', pn));
    exportgraphics(fig, [base '.pdf'], 'ContentType', 'vector');
    exportgraphics(fig, [base '.png'], 'Resolution', 600);
    close(fig);
end

% legend strip (separate; placed once above the four panels)
fig = figure('Color', 'w', 'Visible', 'off'); fig.Units = 'centimeters'; fig.InvertHardcopy = 'off';
fig.Position = [2 2 figp.twocolumn 0.9];      % one row across the two-column width (placed above the panels)
ax = axes(fig); hold(ax, 'on'); axis(ax, 'off');
mk = @(c) plot(ax, nan, nan, '-', 'Color', c, 'LineWidth', 1.1, 'Marker', 'o', 'MarkerSize', 3.4, 'MarkerFaceColor', c);
h = [mk(colTri), mk(colPro), mk(colDeu)];
lg = legend(ax, h, {'trichromat reading', 'protan reading', 'deutan reading'}, ...
    'FontName', figp.fontname, 'FontSize', figp.fontsize, 'Box', 'off', 'NumColumns', 3, 'Location', 'north');
lg.ItemTokenSize = [18 10];
exportgraphics(fig, fullfile(figDir, 'fig_03_legend.pdf'), 'ContentType', 'vector');
exportgraphics(fig, fullfile(figDir, 'fig_03_legend.png'), 'Resolution', 600);
close(fig);

fprintf('Fig 3 panels written to %s\n', figDir);
