%--------------------------------------------------------------------------
% fig2_classification.m
%
% Figure 2: unsupervised classification of the pigments of each plate for each
% observer class (standard observer, 6500 K black body).
%
% The partition shown is the one found by analysis_classification.m: of all
% partitions of the pigments into two groups, the one with the smallest
% determinant of the pooled within-group scatter. The group of smaller dot
% area is the figure group.
%
% For each plate x class two panels are written:
%   fig_02_<plate>_<class>_scatter.pdf/png
%       The pigments in the space in which they were classified:
%         trichromat : L/(L+M), S/(L+M), log10 luminance (3-D), with the plane
%                      that is the linear discriminant between the two groups
%         protan     : log10 M against log10 S, with the discriminant line
%         deutan     : log10 L against log10 S
%       All coordinates are relative to the plate average (mean over all
%       pigments, weighted by dot area). Squares: figure group; circles:
%       background group; black edge: pigment of the figure designed for
%       that class.
%   fig_02_<plate>_<class>_reading.png
%       The dots of the figure group.
% and fig_02_legend.pdf/png, the symbol legend.
%
% Input : results/classification_6500K.mat (analysis_classification.m)
% Output: figs/fig_02_*.pdf/png
%
% Author: TM, 2026
%--------------------------------------------------------------------------

clearvars; close all; clc;

projectRoot = fileparts(mfilename('fullpath'));
addpath(fullfile(projectRoot, 'utils'));
figDir = fullfile(projectRoot, 'figs');
if ~exist(figDir, 'dir'), mkdir(figDir); end

figp = fig_parameters();
D = load_spectral_data(projectRoot);
UN = load(fullfile(projectRoot, 'results', 'classification_6500K.mat')); U = UN.U;
plates = plate_definitions(); classes = {'trichromat', 'protan', 'deutan'};
nP = numel(plates); nO = numel(classes);

% Panel sizes in cm, as printed (the panels are placed on a page of the
% two-column width without rescaling):
panelW = 3.05; panelH = 2.70;         % 2-D panels (protan, deutan)
triW = 4.30;                          % 3-D trichromat panel, same height
readingField = {'normalFigure', 'protanFigure', 'deutanFigure'};
axisLabel = { {}, {'log_{10} M / M_{mean}', 'log_{10} S / S_{mean}'}, {'log_{10} L / L_{mean}', 'log_{10} S / S_{mean}'} };

ill = blackbody_spd(6500, D.wls);
CC = cell(nP, 1);
for p = 1:nP, CC{p} = compute_cone_signals(D.reflectance(:, plates(p).ids), ill, D.T_lms, D.T_xyz); end

for p = 1:nP
    for o = 1:nO
        rgb = CC{p}.sRGB;
        m = plates(p).design.(readingField{o});          % designed figure of this class (may be empty)
        assert(strcmp(U(p, o).plate, plates(p).name) && strcmp(U(p, o).observer, classes{o}));
        g = U(p, o).figureMask(:)';                      % unsupervised figure group
        if o > 1
            if o == 2, k = 2; else, k = 1; end        % surviving long/middle-wave cone
            aw = U(p, o).area(:);                               % fraction of the plate's dot area in each pigment
            lx = log10(CC{p}.LMS(:, k)); ly = log10(CC{p}.LMS(:, 3));
            xa = lx - aw' * lx; ya = ly - aw' * ly;             % relative to the area-weighted mean of ALL pigments
                                                                % (the plate average): no figure/ground knowledge needed
        end

        % ---- scatter panel -------------------------------------------------
        fig = figure('Color', 'w', 'Visible', 'off');
        fig.Units = 'centimeters'; fig.InvertHardcopy = 'off';
        fig.Position = [2 2 panelW panelH];
        ax = axes(fig); hold(ax, 'on');
        if o == 1
            draw_trichromat_3d(ax, CC{p}.MB, U(p, o).area(:), g, m, rgb, figp, [triW panelH]);
        else
            for n = 1:numel(xa)
                if g(n), mk = 's'; sz = 28; else, mk = 'o'; sz = 24; end          % shape: unsupervised group
                if m(n), ec = 'k'; lw = 0.55; else, ec = 'none'; lw = 0.35; end   % edge only on the designed figure
                scatter(ax, xa(n), ya(n), sz, rgb(n, :), mk, 'filled', 'MarkerEdgeColor', ec, 'LineWidth', lw);
            end
            pad = 0.08;
            xr = [min(xa) max(xa)]; yr = [min(ya) max(ya)];
            xr = xr + [-1 1] * max(diff(xr) * pad, 0.03);
            yr = yr + [-1 1] * max(diff(yr) * pad, 0.03);
            xlim(ax, xr); ylim(ax, yr);
            % ---- linear discriminant between the two unsupervised groups ---------
            %      (pigments weighted as in the classification: equally, or by dot area)
            P = [xa ya]; pw = ones(numel(xa), 1);
            if strcmp(U(p, o).weighting, 'area'), pw = U(p, o).area(:); end
            muA = (pw(g)' * P(g, :)) / sum(pw(g)); muB = (pw(~g)' * P(~g, :)) / sum(pw(~g));
            A = P(g, :) - muA; B = P(~g, :) - muB;
            wb = (A' * (A .* pw(g)) + B' * (B .* pw(~g))) \ (muA - muB)';
            bb = -wb' * (muA + muB)' / 2;
            if abs(wb(2)) > abs(wb(1))
                xb = linspace(xr(1), xr(2), 2); yb = -(wb(1) * xb + bb) / wb(2);
            else
                yb = linspace(yr(1), yr(2), 2); xb = -(wb(2) * yb + bb) / wb(1);
            end
            hb = plot(ax, xb, yb, '-', 'Color', [0.25 0.25 0.25], 'LineWidth', 0.8);
            uistack(hb, 'bottom');
            xlabel(ax, axisLabel{o}{1}, 'FontWeight', 'bold', 'FontName', figp.fontname, 'FontSize', figp.fontsize);
            ylabel(ax, axisLabel{o}{2}, 'FontWeight', 'bold', 'FontName', figp.fontname, 'FontSize', figp.fontsize);
            fig_axis_style(ax, figp);
            ax.Units = 'centimeters';
            ax.Position = [0.92 0.76 panelW - 1.17 panelH - 0.86];
            ticklengthcm(ax, 0.05);
        end
        drawnow; pause(0.05);
        base = fullfile(figDir, sprintf('fig_02_%s_%s_scatter', plates(p).name, classes{o}));
        padOpt = {'Padding', 'figure'};       % keep the full canvas: every panel has exactly the size set above
        exportgraphics(fig, [base '.pdf'], 'ContentType', 'vector', padOpt{:});
        exportgraphics(fig, [base '.png'], 'Resolution', 600, padOpt{:});
        close(fig);

        % ---- reading panel: dots of the unsupervised figure group -----------
        lab = ones(1, numel(g)); lab(g) = 2;
        imgs = reconstruct_partition_image(plates(p), lab, projectRoot, struct('imageSize', 512));
        reading = imgs(:, :, :, 2);
        imwrite(reading, fullfile(figDir, sprintf('fig_02_%s_%s_reading.png', plates(p).name, classes{o})));
    end
end

fprintf('Fig 2 panels written to %s\n', figDir);

% ---- symbol legend (placed above the panels) -----------------------------------
fig = figure('Color', 'w', 'Visible', 'off'); fig.Units = 'centimeters'; fig.InvertHardcopy = 'off';
fig.Position = [2 2 figp.twocolumn 1.0];
ax = axes(fig); hold(ax, 'on'); axis(ax, 'off');
gy = [0.65 0.65 0.65];
h = [scatter(ax, nan, nan, 28, gy, 's', 'filled', 'MarkerEdgeColor', 'none'), ...
     scatter(ax, nan, nan, 24, gy, 'o', 'filled', 'MarkerEdgeColor', 'none'), ...
     scatter(ax, nan, nan, 28, gy, 's', 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 0.55)];
lg = legend(ax, h, {'figure group', 'background group', 'black edge: pigment of the designed figure'}, ...
    'FontName', figp.fontname, 'FontSize', figp.fontsize, 'Box', 'off', 'NumColumns', 3, 'Location', 'north');
lg.ItemTokenSize = [10 10];
exportgraphics(fig, fullfile(figDir, 'fig_02_legend.pdf'), 'ContentType', 'vector');
exportgraphics(fig, fullfile(figDir, 'fig_02_legend.png'), 'Resolution', 600);
close(fig);

function draw_trichromat_3d(ax, MB, aw, g, m, rgb, figp, panelW)
% Trichromat panel: the pigments in the space of the classification,
% L/(L+M), S/(L+M) and log10 luminance, cut by the plane that separates the two
% groups (their linear discriminant, pooled covariance). Coordinates are
% relative to the plate average (dot-area weights aw). Each axis is normalised
% to its own range for display, pigments behind the plane are seen through it,
% and thin stems join every pigment to the plane.
%   MB   n x 3  [L/(L+M), S/(L+M), luminance]     g   figure group (logical)
%   m    pigments of the designed figure           rgb pigment colours
%   panelW  [width height] of the panel in cm
g = logical(g(:)); m = logical(m(:));
Uc = [MB(:, 1:2), log10(MB(:, 3))];
Uc = Uc - aw' * Uc;                     % relative to the area-weighted mean of all pigments (plate average)
axLabel = {'L/(L+M)', 'S/(L+M)', 'log_{10} lum.'}; azRange = -48:1:-18;
A = Uc(g, :) - mean(Uc(g, :), 1); B = Uc(~g, :) - mean(Uc(~g, :), 1);
w = (A' * A + B' * B) \ (mean(Uc(g, :), 1) - mean(Uc(~g, :), 1))';
b0 = -w' * (mean(Uc(g, :), 1) + mean(Uc(~g, :), 1))' / 2;

% normalise every axis to [0 1] (own range, padded), so the box is a cube
lo = min(Uc, [], 1); hi = max(Uc, [], 1); pad = 0.14 * (hi - lo); lo = lo - pad; hi = hi + pad;
N = (Uc - lo) ./ (hi - lo);
wn = w .* (hi - lo)'; bn = b0 + w' * lo';            % plane in box coordinates: wn' * x + bn = 0
nhat = wn / norm(wn);

% polygon of the plane inside the unit cube
V = dec2bin(0:7) - '0'; E = [];
for a = 1:8
    for b = a + 1:8
        if sum(abs(V(a, :) - V(b, :))) == 1
            fa = V(a, :) * wn + bn; fb = V(b, :) * wn + bn;
            if fa * fb < 0, t = fa / (fa - fb); E(end + 1, :) = V(a, :) + t * (V(b, :) - V(a, :)); end %#ok<AGROW>
        end
    end
end
c = mean(E, 1); e1 = E(1, :) - c; e1 = e1 / norm(e1); e2 = cross(nhat', e1);
[~, ord] = sort(atan2((E - c) * e2', (E - c) * e1')); E = E(ord, :);

% camera: the red-green axis always runs left to right, the blue-yellow axis
% into the page and lightness upwards. Within that orientation the azimuth and
% elevation are chosen so that the plane is seen about 20 deg from edge-on: a
% plane that cuts the red-green axis appears as an upright wall, a plane that
% cuts the lightness axis as a floor.
best = inf; d = [-22 17];
for az = azRange
    for el = 10:1:30
        cd_ = [sind(az) * cosd(el), -cosd(az) * cosd(el), sind(el)];
        f = abs(abs(cd_ * nhat) - sind(20));
        if f < best, best = f; d = [az el]; end
    end
end
cdir = [sind(d(1)) * cosd(d(2)), -cosd(d(1)) * cosd(d(2)), sind(d(2))];   % towards the camera
front = (N * wn + bn) * (cdir * wn) > 0;                                  % pigments on the camera side of the plane

% draw back to front: pigments behind the plane, the plane, pigments in front
foot = N - ((N * wn + bn) / (wn' * wn)) * wn';
for pass = 1:2
    if pass == 1, idx = find(~front)'; else, idx = find(front)'; end
    for n = idx
        plot3(ax, [N(n, 1) foot(n, 1)], [N(n, 2) foot(n, 2)], [N(n, 3) foot(n, 3)], '-', 'Color', [0.4 0.4 0.4], 'LineWidth', 0.35);
    end
    for n = idx
        if g(n), mk = 's'; sz = 26; else, mk = 'o'; sz = 22; end
        if m(n), ec = 'k'; lw = 0.55; else, ec = 'none'; lw = 0.35; end      % edge only on the designed figure
        scatter3(ax, N(n, 1), N(n, 2), N(n, 3), sz, rgb(n, :), mk, 'filled', 'MarkerEdgeColor', ec, 'LineWidth', lw);
    end
    if pass == 1
        patch(ax, 'XData', E(:, 1), 'YData', E(:, 2), 'ZData', E(:, 3), 'FaceColor', [0.55 0.55 0.6], ...
            'FaceAlpha', 0.45, 'EdgeColor', [0.3 0.3 0.3], 'LineWidth', 0.5);
    end
end
ax.SortMethod = 'childorder';

fig = ancestor(ax, 'figure'); fig.Position = [2 2 panelW(1) panelW(2)];
view(ax, d(1), d(2)); daspect(ax, [1 1 1]); axis(ax, [0 1 0 1 0 1]);
ax.Projection = 'orthographic'; box(ax, 'on'); grid(ax, 'on');
ax.BoxStyle = 'back'; ax.GridColor = [0.6 0.6 0.6]; ax.GridAlpha = 0.5; ax.Color = [0.97 0.97 0.97];
for q = 1:3
    tk = nice_ticks(lo(q), hi(q));
    if q < 3 && numel(tk) > 2, tk = tk([1 end]); end          % chromaticity axes: two ticks keep the labels apart
    pos = (tk - lo(q)) / (hi(q) - lo(q));
    lbl = arrayfun(@(v) sprintf('%g', v), tk, 'UniformOutput', false);
    switch q
        case 1, ax.XTick = pos; ax.XTickLabel = lbl;
        case 2, ax.YTick = pos; ax.YTickLabel = lbl;
        case 3, ax.ZTick = pos; ax.ZTickLabel = lbl;
    end
end
ax.FontName = figp.fontname; ax.FontSize = figp.fontsize - 1; ax.LineWidth = 0.5; ax.TickLength = [0.02 0.02];
ax.XTickLabelRotation = 0; ax.YTickLabelRotation = 0; ax.ZTickLabelRotation = 0;
xlabel(ax, axLabel{1}, 'FontWeight', 'bold', 'FontName', figp.fontname, 'FontSize', figp.fontsize);
ylabel(ax, axLabel{2}, 'FontWeight', 'bold', 'FontName', figp.fontname, 'FontSize', figp.fontsize);
zlabel(ax, axLabel{3}, 'FontWeight', 'bold', 'FontName', figp.fontname, 'FontSize', figp.fontsize);
ax.Units = 'centimeters'; ax.Position = [1.45 0.72 panelW(1) - 2.65 panelW(2) - 0.92];
end

function tk = nice_ticks(lo, hi)
% two or three round tick values inside [lo, hi]
r = hi - lo; st = 10 ^ floor(log10(r / 2));
for f = [5 2 1]
    tk = ceil(lo / (st * f)) * (st * f):st * f:hi;
    if numel(tk) >= 2, break; end
end
if numel(tk) > 3, tk = tk(1:ceil(numel(tk) / 3):end); end
tk = round(tk, 10) + 0;        % remove floating-point residue (e.g. 5.6e-17, -0)
end
