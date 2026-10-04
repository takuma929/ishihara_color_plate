function r = classify_pigments(X, masks, area, design, own, w)
% classify_pigments  Unsupervised two-group classification of the pigments of a plate.
%
%   r = classify_pigments(X, masks, area, design, own, w)
%     X       n x d   pigments in the signal space of the observer (classification_space.m)
%     masks   all two-group partitions of the n pigments (two_group_partitions.m)
%     area    1 x n   fraction of the plate's dot area printed in each pigment
%     design  1 x 3 cell: the pigments of the figure designed for normal trichromats,
%             protans and deutans, as logical masks ([] = no figure designed)
%     own     index into design of the reading intended for this observer class
%     w       1 x n   pigment weights of the classification (default: all equal)
%
%   The partition returned is the one that minimises det(W), the determinant of
%   the pooled within-group scatter matrix (Friedman and Rubin, 1967). The
%   criterion is unchanged by any rescaling or linear recombination of the axes.
%   With T the total scatter and d the difference of the two group means,
%   det(W) = det(T) (1 - c a), c = n1 n2 / n, a = d' T^-1 d, so all partitions
%   are ranked from a single inverse.
%
%   r.best       the partition with the smallest det(W) (a row of masks)
%   r.figure     the same partition with true = the group of smaller dot area
%   r.agreement  fraction of dot area that r.figure assigns as the reading designed
%                for this class does (NaN if none is designed)
%   r.rank(s)    rank of designed split s among all partitions (1 = it is returned)
%   r.d(s)       separation of designed split s: the Mahalanobis distance between its
%                two groups, D = sqrt(d' S^-1 d) with S = W / (n - 2), i.e. the
%                distance between figure and background along their linear
%                discriminant in units of the within-group standard deviation

n = size(X, 1);
if nargin < 6 || isempty(w), w = ones(1, n); end
w = w(:); M = double(masks);

% classification, with the pigments weighted by w
Xw = X - (w' * X) / sum(w); Tw = Xw' * (Xw .* w);
w1 = M * w; w2 = sum(w) - w1;
dw = (M * (Xw .* w)) ./ w1 - ((1 - M) * (Xw .* w)) ./ w2;
q = (w1 .* w2 / sum(w)) .* sum((dw / Tw) .* dw, 2);          % det(W) is smallest where q is largest
[~, ib] = max(q);
r.best = masks(ib, :);
r.figure = r.best; if sum(area(r.figure)) > 0.5, r.figure = ~r.figure; end

% designed splits: rank under the weights of the classification, separation D unweighted
Xc = X - mean(X, 1); T = Xc' * Xc;
r.rank = nan(1, 3); r.d = nan(1, 3); r.agreement = NaN;
for s = 1:3
    m = design{s}; if isempty(m), continue; end
    k = find(all(masks == m, 2) | all(masks == ~m, 2), 1);
    r.rank(s) = 1 + sum(q > q(k) * (1 + 1e-9));
    n1 = sum(m); n2 = n - n1;
    d = mean(Xc(m, :), 1) - mean(Xc(~m, :), 1); a = (d / T) * d'; c = n1 * n2 / n;
    r.d(s) = sqrt((n - 2) * a / (1 - c * a));
    if s == own, r.agreement = max(sum(area(r.figure == m)), sum(area(r.figure ~= m))); end
end
end
