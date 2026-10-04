function P = plate_setup(plates, projectRoot)
% plate_setup  Quantities of each plate that do not depend on the observer or illuminant.
%
%   P(p).area    fraction of the plate's dot area printed in each pigment
%   P(p).masks   all partitions of the pigments into two groups of at least two
%   P(p).design  pigments of the figure designed for normal trichromats, protans and
%                deutans (logical masks; [] where no figure is designed)

designs = {'normalFigure', 'protanFigure', 'deutanFigure'};
for p = numel(plates):-1:1
    P(p).area = pigment_dot_area(plates(p), projectRoot);
    P(p).masks = two_group_partitions(numel(plates(p).ids), 2);
    for s = 1:3
        m = logical(plates(p).design.(designs{s})(:)');
        if any(m) && ~all(m), P(p).design{s} = m; else, P(p).design{s} = []; end
    end
end
end
