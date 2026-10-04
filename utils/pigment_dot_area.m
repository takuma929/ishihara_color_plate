function area = pigment_dot_area(plate, projectRoot)
% pigment_dot_area  Fraction of the plate's dot area printed in each pigment.
%
%   area = pigment_dot_area(plate, projectRoot) counts the pixels of the dot
%   mask of every pigment of the plate (data/plates/<plate>/color<id>.png) and
%   returns a 1 x n vector that sums to 1.

n = numel(plate.ids);
imgs = reconstruct_partition_image(plate, 1:n, projectRoot, struct('imageSize', 512));
area = zeros(1, n);
for q = 1:n, area(q) = nnz(min(imgs(:, :, :, q), [], 3) < 250); end
area = area / sum(area);
end
