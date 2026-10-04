function [w, name] = pigment_weights(plate, observer, area)
% pigment_weights  Weights given to the pigments in the classification.
%
%   Every pigment counts equally, with one exception: for the deutan reading of
%   the Type 4 plate each pigment is weighted by its dot area. With equal
%   weights the designed split of that plate is the second-ranked partition
%   for deutans; with dot-area weights it is the first.

w = ones(1, numel(area)); name = 'equal';
if plate.type == 4 && strcmp(observer, 'deutan'), w = area; name = 'area'; end
end
