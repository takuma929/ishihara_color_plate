function masks = two_group_partitions(n, minSize)
% two_group_partitions  All partitions of n items into two groups.
%
%   masks = two_group_partitions(n, minSize) returns a logical matrix with one
%   row per partition (true = first group). Each partition appears once (the
%   last item is always in the second group), and partitions with fewer than
%   minSize items in either group are left out. For minSize = 2 there are
%   119, 246 and 501 partitions of n = 8, 9 and 10 items.

if nargin < 2, minSize = 2; end
c = (1:2^(n - 1) - 1)';
masks = logical(bitget(repmat(c, 1, n), repmat(1:n, numel(c), 1)));
k = sum(masks, 2);
masks = masks(k >= minSize & n - k >= minSize, :);
end
