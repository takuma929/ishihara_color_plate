function figp = fig_parameters()
% fig_parameters  Sizes and fonts shared by all figure scripts.
%
%   figp.twocolumn      two-column width of the journal page (cm)
%   figp.onecolumn      one-column width (cm)
%   figp.fontsize       tick-label font size (pt)
%   figp.fontsize_axis  axis-label font size (pt)
%   figp.fontname       font
%
% Every panel is drawn at the size at which it is printed, so that the panels
% can be placed on a page of width figp.twocolumn without rescaling.

figp.twocolumn = 13.04;
figp.onecolumn = figp.twocolumn / 2;
figp.fontsize = 7;
figp.fontsize_axis = 8;
figp.fontname = 'Arial';
end
