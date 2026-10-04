function imgs = reconstruct_partition_image(plate, labels, projectRoot, cfg)
% reconstruct_partition_image  Render the dots of each cluster as an image.
%
%   imgs = reconstruct_partition_image(plate, labels, projectRoot, cfg)
%     plate        one element of plate_definitions()
%     labels       1 x nS cluster label of each pigment (1..k)
%     projectRoot  repository root (data/plates/<plate.name>/color<id>.png are read)
%     cfg.cutPixel  border crop in pixels (default 40)
%     cfg.imageSize output size (default 256)
%
%     imgs   imageSize x imageSize x 3 x k, white background, uint8
%
%   The per-pigment images are the dot masks of each pigment on a black
%   background; summing them within a cluster and turning the remaining dark
%   pixels white gives the dots of that cluster as they appear on the plate.

if nargin < 4, cfg = struct(); end
if ~isfield(cfg, 'cutPixel'),  cfg.cutPixel = 40; end
if ~isfield(cfg, 'imageSize'), cfg.imageSize = 256; end

k = max(labels);
acc = zeros(cfg.imageSize, cfg.imageSize, 3, k);
for n = 1:numel(plate.ids)
    f = fullfile(projectRoot, 'data', 'plates', plate.name, sprintf('color%d.png', plate.ids(n)));
    img = double(imread(f)) / 255;
    if size(img, 3) == 1, img = repmat(img, 1, 1, 3); end
    img = img(cfg.cutPixel:end - cfg.cutPixel, cfg.cutPixel:end - cfg.cutPixel, :);
    img = imresize(img, [cfg.imageSize, cfg.imageSize]);
    acc(:, :, :, labels(n)) = acc(:, :, :, labels(n)) + img;
end

imgs = zeros(size(acc), 'uint8');
for c = 1:k
    im = acc(:, :, :, c);
    dark = mean(im, 3) < 0.2;
    im = min(im, 1);
    for ch = 1:3
        p = im(:, :, ch);
        p(dark) = 1;
        im(:, :, ch) = p;
    end
    imgs(:, :, :, c) = uint8(round(im * 255));
end
end
