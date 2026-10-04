function plates = plate_definitions()
% plate_definitions  Pigment indices, labels and designed partitions of the
%                    analysed Ishihara plates.
%
%   plates = plate_definitions() returns a struct array with one element per
%   plate, in the order used throughout the paper:
%     .name      folder / file key used in data/plates/<name>/color<id>.png
%     .ids       column indices into the `reflectance` matrix of
%                Ishihara_reflectance.mat (one per distinct pigment)
%     .type      Ishihara's plate type (2..5)
%     .normal    what a normal trichromat reads ('' = nothing)
%     .protan    what a protan observer reads
%     .deutan    what a deutan observer reads
%     .label     short caption label
%     .design    designed partitions, as logical masks over the pigments
%                (index n refers to pigment ids(n), numbered as in Fig. 1):
%                  .normalFigure  pigments forming the symbol read by normals
%                  .protanFigure  pigments forming the symbol read by protans
%                  .deutanFigure  pigments forming the symbol read by deutans
%                (all false = nothing is designed to be read)
%
%   The designed partitions were read off the per-pigment dot masks
%   (data/plates/<name>/color<id>.png, see fig1_plates.m): a pigment belongs to a figure
%   if its dots lie inside the strokes of that symbol.
%
%   Pigment columns 2..89 of the reflectance file are plate pigments; column
%   1 is the white paper. Only the four plates below have dot masks.

plates = struct('name', {}, 'ids', {}, 'type', {}, 'normal', {}, 'protan', {}, 'deutan', {}, 'label', {}, 'design', {});

% ---- plate74 (Type 2): 10 pigments. Greenish pigments 6-10 form "74" for
%      trichromats; pigments 6,7 alone form "21" (the strokes shared by 74 and
%      21); 8,9,10 are the strokes that vanish for dichromats and regroup with
%      the reddish background 1-5.
d = struct('normalFigure', mask(10, 6:10), 'protanFigure', mask(10, [6 7]), 'deutanFigure', mask(10, [6 7]));
plates(end+1) = struct('name', 'plate74', 'ids', [35:41, 43:44, 89], 'type', 2, ...
    'normal', '74', 'protan', '21', 'deutan', '21', 'label', 'Type 2 ("74"/"21")', 'design', d);

% ---- plate97 (Type 3): 8 pigments. Yellowish pigments 6,7,8 form "97";
%      greens 1-5 are the background. Nothing is designed for dichromats.
d = struct('normalFigure', mask(8, 6:8), 'protanFigure', false(1, 8), 'deutanFigure', false(1, 8));
plates(end+1) = struct('name', 'plate97', 'ids', 45:52, 'type', 3, ...
    'normal', '97', 'protan', '', 'deutan', '', 'label', 'Type 3 ("97")', 'design', d);

% ---- plateCamouflage (Type 4): 9 pigments. Pigments 7,8,9 form the hidden
%      "2" read by dichromats; nothing is designed for trichromats.
d = struct('normalFigure', false(1, 9), 'protanFigure', mask(9, 7:9), 'deutanFigure', mask(9, 7:9));
plates(end+1) = struct('name', 'plateCamouflage', 'ids', 68:76, 'type', 4, ...
    'normal', '', 'protan', '2', 'deutan', '2', 'label', 'Type 4 (hidden "2")', 'design', d);

% ---- plate42 (Type 5, protan/deutan classification): 9 pigments. Reddish
%      pigments 1,2,3 form the "4" (left) and purplish pigments 7,8,9 the "2"
%      (right); greys 4,5,6 are the background. Normals read "42"; protans
%      read the "2" (the red "4" merges with the background), deutans read the
%      "4" (the purple "2" merges). Dot-centroid x positions: pigments 1-3 at
%      ~225-245 px, 7-9 at ~320-370 px of a 600 px wide mask.
d = struct('normalFigure', mask(9, [1 2 3 7 8 9]), 'protanFigure', mask(9, 7:9), 'deutanFigure', mask(9, 1:3));
plates(end+1) = struct('name', 'plate42', 'ids', 77:85, 'type', 5, ...
    'normal', '42', 'protan', '2', 'deutan', '4', 'label', 'Type 5 ("42"/"2"/"4")', 'design', d);
end

function m = mask(n, idx)
m = false(1, n);
m(idx) = true;
end
