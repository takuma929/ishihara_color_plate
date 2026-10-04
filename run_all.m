function run_all()
%RUN_ALL Regenerate every result and figure of the paper.
%   Make this repository the current folder in MATLAB (or add it to the
%   path) and call RUN_ALL. The analyses write their results into results/
%   and the figure scripts write their panels into figs/. The values quoted
%   in the paper are printed to the Command Window.
%
%   Each script is run in the base workspace inside try/catch, so one
%   failing step does not stop the others.

scripts = { ...
    'generate_observers', ...        % 10,000 simulated observers (10 deg)
    'analysis_classification', ...   % unsupervised classification at 6500 K
    'analysis_stability', ...        % illuminants and individual observers
    'fig1_plates', ...
    'fig2_classification', ...
    'fig3_illuminant', ...
    'fig4_observers'};

for k = 1:numel(scripts)
    name = scripts{k};
    fprintf('\n===== %s (%d/%d) =====\n', name, k, numel(scripts));
    try
        evalin('base', name);
    catch err
        fprintf(2, 'Skipped %s: %s\n', name, err.message);
    end
end

fprintf('\nDone. Figures written to %s\n', ...
    fullfile(fileparts(mfilename('fullpath')), 'figs'));
end
