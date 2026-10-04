%--------------------------------------------------------------------------
% fig1_plates.m
%
% Figure 1: the four analysed plates. For each plate three panels are written:
%   fig_01_<plate>_left_plate          the plate
%   fig_01_<plate>_right_pigments      the dots printed in each pigment, numbered
%   fig_01_<plate>_center_reflectance  spectral reflectance of each pigment
%
% Plates (order and labels from utils/plate_definitions.m):
%   Type 2: plate74 ("74" / "21")
%   Type 3: plate97 ("97")
%   Type 4: plateCamouflage (hidden "2")
%   Type 5: plate42 ("42" / "2" / "4")
%
% Input : data/Ishihara_reflectance.mat, data/plates/<plate>/
% Output: figs/fig_01_*.pdf/png
%
% Author: TM, 2026
%--------------------------------------------------------------------------

clearvars; close all; clc;

projectRoot = fileparts(mfilename('fullpath'));
addpath(fullfile(projectRoot, 'utils'));
dataDir = fullfile(projectRoot, 'data');
figDir = fullfile(projectRoot, 'figs');

if ~exist(figDir, 'dir')
    mkdir(figDir);
end

figp = fig_parameters();

S = load(fullfile(dataDir, 'Ishihara_reflectance.mat'), 'reflectance');
reflectance = S.reflectance;

wls = (390:780)';
if size(reflectance, 1) == numel(wls) + 10
    R = reflectance(11:end, :);
elseif size(reflectance, 1) == numel(wls)
    R = reflectance;
else
    error('Unexpected reflectance size: %d x %d', size(reflectance, 1), size(reflectance, 2));
end

plates = get_plate_definitions();

% Per-plate layout (cm):
%   left  panel = twocolumn/4 (plate image)
%   center panel = twocolumn/4 (reflectance, square)
%   right panel = twocolumn/2 (pigment montage)
rowH = figp.twocolumn / 4;
colW = [figp.twocolumn / 4, figp.twocolumn / 4, figp.twocolumn / 2];

for p = 1:numel(plates)
    plateName = plates(p).name;
    ids = plates(p).ids;

    plateDir = fullfile(dataDir, 'plates', plateName);
    platePath = fullfile(plateDir, [plateName, '.png']);
    fullImg = read_image_on_white(platePath);

    % Left panel: full plate image
    figL = figure('Color', 'w');
    figL.Units = 'centimeters';
    figL.Color = 'w';
    figL.InvertHardcopy = 'off';
    figL.Position = [2, 2, colW(1), rowH];
    axL = axes('Parent', figL, 'Units', 'normalized', 'Position', [0 0 1 1]);
    imshow(fullImg, 'Parent', axL);
    axis(axL, 'off');
    drawnow; pause(0.05);
    exportgraphics(figL, fullfile(figDir, sprintf('fig_01_%s_left_plate.pdf', plateName)), 'ContentType', 'vector');
    exportgraphics(figL, fullfile(figDir, sprintf('fig_01_%s_left_plate.png', plateName)), 'Resolution', 600);
    close(figL);

    % Center panel: reflectance spectra
    figC = figure('Color', 'w');
    figC.Units = 'centimeters';
    figC.Color = 'w';
    figC.InvertHardcopy = 'off';
    figC.Position = [2, 2, colW(2), rowH];
    basePos = [0.27 0.27 0.68 0.68];
    reflectanceScale = 1.2;
    cx = basePos(1) + basePos(3) / 2;
    cy = basePos(2) + basePos(4) / 2;
    newW = basePos(3) * reflectanceScale;
    newH = basePos(4) * reflectanceScale;
    newX = cx - newW / 2;
    newY = cy - newH / 2;

    % Keep margins so axis labels are visible after scaling.
    leftMargin = 0.28;
    bottomMargin = 0.28;
    rightMargin = 0.05;
    topMargin = 0.05;
    newW = min(newW, 1 - leftMargin - rightMargin);
    newH = min(newH, 1 - bottomMargin - topMargin);
    newX = min(max(newX, leftMargin), 1 - rightMargin - newW);
    newY = min(max(newY, bottomMargin), 1 - topMargin - newH);
    axC = axes('Parent', figC, 'Units', 'normalized', 'Position', [newX newY newW newH]);
    hold(axC, 'on');

    R_keep = R(:, ids);
    nSamples = size(R_keep, 2);
    lineColors = pigment_line_colors(plateDir, ids, nSamples);

    for i = 1:nSamples
        plot(axC, wls, R_keep(:, i), 'LineWidth', 0.55, 'Color', lineColors(i, :) * 0.9);
    end

    xlabel(axC, 'Wavelength (nm)', 'FontWeight', 'Bold', 'FontName', figp.fontname, 'FontSize', figp.fontsize_axis);
    ylabel(axC, 'Reflectance', 'FontWeight', 'Bold', 'FontName', figp.fontname, 'FontSize', figp.fontsize_axis);
    xlim(axC, [390 - 10, 780 + 10]);
    yMax = max(1, max(R_keep(:)) * 1.03);
    ylim(axC, [0, yMax]);
    axis(axC, 'square');
    xticks(axC, [400, 500, 600, 700, 780]);
    yticks(axC, [0, yMax/2, yMax]);
    axC.XTickLabel = {'400', '500', '600', '700', '780'};
    axC.YTickLabel = {sprintf('%.2f', 0), sprintf('%.2f', yMax/2), sprintf('%.2f', yMax)};
    axC.FontName = figp.fontname;
    axC.FontSize = figp.fontsize;

    axC.XColor = 'k';
    axC.YColor = 'k';
    axC.LineWidth = 0.5;
    axC.Color = ones(1, 3) * 0.97;
    
    grid(axC, 'off');
    box(axC, 'off');
    ticklengthcm(axC, 0.05);
    drawnow; pause(0.05);
    exportgraphics(figC, fullfile(figDir, sprintf('fig_01_%s_center_reflectance.pdf', plateName)), 'ContentType', 'vector');
    exportgraphics(figC, fullfile(figDir, sprintf('fig_01_%s_center_reflectance.png', plateName)), 'Resolution', 600);
    close(figC);

    % Right panel: pigment montage
    figR = figure('Color', 'w');
    figR.Units = 'centimeters';
    figR.Color = 'w';
    figR.InvertHardcopy = 'off';
    figR.Position = [2, 2, colW(3), rowH];
    axR = axes('Parent', figR, 'Units', 'normalized', 'Position', [0 0 1 1]);
    [montageImg, tileInfo] = make_pigment_montage(plateDir, ids, plateName);
    imshow(montageImg, 'Parent', axR);
    hold(axR, 'on');
    for i = 1:nSamples
        text(axR, tileInfo.x0(i) + 8, tileInfo.y0(i) + 18, sprintf('%d', i), ...
            'Color', 'k', 'FontName', figp.fontname, 'FontSize', figp.fontsize_axis, ...
            'FontWeight', 'bold', ...
            'Interpreter', 'none');
    end
    axis(axR, 'off');
    drawnow; pause(0.05);
    exportgraphics(figR, fullfile(figDir, sprintf('fig_01_%s_right_pigments.pdf', plateName)), 'ContentType', 'vector');
    exportgraphics(figR, fullfile(figDir, sprintf('fig_01_%s_right_pigments.png', plateName)), 'Resolution', 600);
    close(figR);
end

%--------------------------------------------------------------------------
% Local functions
%--------------------------------------------------------------------------
function plates = get_plate_definitions()
% Plate order and labels come from utils/plate_definitions.m
% (Types 2, 3, 4, 5: plate74, plate97, plateCamouflage, plate42).
P = plate_definitions();
plates = struct('name', {P.name}, 'ids', {P.ids}, 'label', {P.label});
end

function colors = pigment_line_colors(plateDir, ids, nSamples)
colors = zeros(nSamples, 3);
for i = 1:nSamples
    f = fullfile(plateDir, sprintf('color%d.png', ids(i)));
    [img, mask] = read_image_for_color_estimate(f);
    px = reshape(img, [], size(img, 3));
    valid = mask(:);
    if any(valid)
        colors(i, :) = mean(px(valid, :), 1);
    else
        colors(i, :) = mean(px, 1);
    end
end

colors = max(min(colors, 1), 0);
end

function [img, validMask] = read_image_for_color_estimate(imgPath)
[imgRaw, ~, alpha] = imread(imgPath);

if size(imgRaw, 3) == 1
    imgRaw = repmat(imgRaw, 1, 1, 3);
end

img = im2double(imgRaw);

if ~isempty(alpha)
    validMask = alpha > 0;
else
    % Fallback for images without alpha: ignore near-black/near-white background.
    lum = mean(img, 3);
    validMask = lum > 0.03 & lum < 0.97;
end
end

function [montageImg, tileInfo] = make_pigment_montage(plateDir, ids, plateName)
n = numel(ids);
nCol = 5; % width
nRow = 2; % height

pad = 0;
cropPx = 10;

tileImgs = cell(1, n);
tileH = 0;
tileW = 0;

for i = 1:n
    f = fullfile(plateDir, sprintf('color%d.png', ids(i)));
    img = read_image_on_white(f);
    if size(img, 3) == 1
        img = repmat(img, 1, 1, 3);
    end
    img = crop_outer_edge(img, cropPx);
    tileImgs{i} = img;
    tileH = max(tileH, size(img, 1));
    tileW = max(tileW, size(img, 2));
end

H = nRow * tileH + (nRow + 1) * pad;
W = nCol * tileW + (nCol + 1) * pad;
montageImg = uint8(255 * ones(H, W, 3));
tileInfo.x0 = zeros(1, n);
tileInfo.y0 = zeros(1, n);

for i = 1:n
    r = floor((i - 1) / nCol);
    c = mod((i - 1), nCol);
    y0 = pad + r * (tileH + pad) + 1;
    x0 = pad + c * (tileW + pad) + 1;
    tileInfo.x0(i) = x0;
    tileInfo.y0(i) = y0;

    img = tileImgs{i};
    h = size(img, 1);
    w = size(img, 2);
    montageImg(y0:y0 + h - 1, x0:x0 + w - 1, :) = img;
end
end

function imgOut = crop_outer_edge(imgIn, cropPx)
[h, w, ~] = size(imgIn);
if h <= 2 * cropPx + 2 || w <= 2 * cropPx + 2
    imgOut = imgIn;
    return;
end
imgOut = imgIn(1 + cropPx:h - cropPx, 1 + cropPx:w - cropPx, :);
end

function imgOut = read_image_on_white(imgPath)
[img, ~, alpha] = imread(imgPath);

if ~isempty(alpha)
    if size(img, 3) == 1
        img = repmat(img, 1, 1, 3);
    end
    img = im2double(img);
    a = im2double(alpha);
    if size(a, 3) == 1
        a = repmat(a, 1, 1, 3);
    end
    img = img .* a + (1 - a); % Composite over white background
    imgOut = im2uint8(img);
else
    imgOut = img;
end

imgOut = normalize_background_white(imgOut);
end

function imgOut = normalize_background_white(imgIn)
imgOut = imgIn;

if size(imgOut, 3) == 1
    imgOut = repmat(imgOut, 1, 1, 3);
end

img01 = im2double(imgOut);
lum = mean(img01, 3);

% Remove dark border-connected halo/background while preserving interior tones.
darkMask = lum < 0.40;
if exist('imclearborder', 'file') == 2
    borderMask = darkMask & ~imclearborder(darkMask);
else
    % Fallback if imclearborder is unavailable.
    borderMask = darkMask;
end

for c = 1:3
    ch = imgOut(:, :, c);
    ch(borderMask) = 255;
    imgOut(:, :, c) = ch;
end
end
