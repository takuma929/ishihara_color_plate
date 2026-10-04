function X = classification_space(C, observer)
% classification_space  Signal space in which the pigments of a plate are classified.
%
%   X = classification_space(C, observer)
%     C         output of compute_cone_signals (one row per pigment)
%     observer  'trichromat', 'protan' or 'deutan'
%
%   trichromat : L/(L+M), S/(L+M), log10 luminance   (MacLeod-Boynton chromaticity
%                and luminance)
%   protan     : log10 M, log10 S     (the two cone signals of a protanope)
%   deutan     : log10 L, log10 S     (the two cone signals of a deuteranope)
%
% The classification criterion (classify_pigments.m) does not depend on the
% units or scaling of these axes.

switch observer
    case 'trichromat', X = [C.MB(:, 1:2), log10(C.MB(:, 3))];
    case 'protan',     X = log10(C.LMS(:, [2 3]));
    case 'deutan',     X = log10(C.LMS(:, [1 3]));
    otherwise, error('Unknown observer class: %s', observer);
end
end
