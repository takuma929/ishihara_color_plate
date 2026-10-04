# Grouping and camouflage in cone space: the chromatic design of the Ishihara plates

MATLAB code and data to reproduce the analyses and figures of the manuscript
*Grouping and camouflage in cone space: the chromatic design of the Ishihara
plates* (T. Morimoto, Y. Muto, K. Fukuda and K. Uchikawa).

The spectral reflectance of every pigment in four Ishihara plates (one each of
Types 2 to 5) was measured and expressed in the cone signals of normal
trichromats, protans and deutans. For each plate and observer class the
pigments are divided, without knowledge of the design, into the two groups
that minimise the determinant of the pooled within-group scatter, and the
result is compared with the figure that the plate is designed to show to that
class. The analysis is repeated for black-body illuminants from 3000 to
20,000 K and for 10,000 simulated colour-normal observers.

---

## 1. System requirements

* **Operating system:** Windows, macOS or Linux (tested on macOS).
* **MATLAB:** R2020a or newer (the scripts use `exportgraphics`; tested on
  R2025b).
* **Required toolboxes:** Statistics and Machine Learning Toolbox (`prctile`)
  and Image Processing Toolbox (`imresize`, `imshow`).

Nothing else has to be downloaded: every helper function is in
[`utils/`](utils/) and every input is in [`data/`](data/).

## 2. Installation

```
git clone https://github.com/takuma929/ishihara_color_plate.git
```

No build step. Every script resolves its paths relative to its own location
and adds `utils/` to the path, so it can be run from any working folder.

## 3. Regenerate all results and figures

In MATLAB, make the repository the current folder and run:

```matlab
run_all
```

This runs the three analysis scripts and the four figure scripts in turn. The
analyses write their results into `results/` and the figure scripts write
their panels (PDF and PNG) into `figs/`; both folders are created on the first
run. The values quoted in the paper are printed to the Command Window. The
full set takes a few minutes.

A single step can be rerun by name, e.g. `fig3_illuminant`, once the analyses
it depends on have been run.

## 4. Scripts

| Script | Output | Content |
| --- | --- | --- |
| `generate_observers.m` | `results/observers_asano_10deg.mat` | 10,000 simulated colour-normal observers (individual colorimetric observer model of Asano, Fairchild and Blondé on the CIE 2006 basis, 10° field, seed 0) |
| `analysis_classification.m` | `results/classification_6500K.mat` | Unsupervised classification of the pigments of each plate for each observer class at 6500 K |
| `analysis_stability.m` | `results/stability_illuminant.csv`, `results/stability_observers.mat`, `.csv` | The same classification for 16 black-body illuminants (3000–20,000 K) and for the 10,000 observers |
| `fig1_plates.m` | Figure 1 | The four plates, the dots printed in each pigment, and the reflectance spectra |
| `fig2_classification.m` | Figure 2 | Pigments of each plate in the signal space of each observer class, the two groups returned by the classification, and the dots of the figure group |
| `fig3_illuminant.m` | Figure 3 | Separation of each designed reading against colour temperature |
| `fig4_observers.m` | Figure 4 | Cone fundamentals of the simulated observers and the separation of each designed reading across observers |

Every panel is drawn at the size at which it is printed (the page width is
set in `utils/fig_parameters.m`), so the panels of a figure can be placed side
by side without rescaling.

### Method in brief

* **Signal spaces** (`utils/classification_space.m`): L/(L+M), S/(L+M) and
  log luminance for trichromats; log M and log S for protans; log L and log S
  for deutans. Cone excitations are computed with the Stockman–Sharpe 10°
  fundamentals.
* **Classification** (`utils/classify_pigments.m`): all partitions of the
  pigments of a plate into two groups of at least two pigments are ranked by
  the determinant of the pooled within-group scatter matrix (Friedman and
  Rubin, 1967), and the first-ranked partition is returned. The criterion does
  not depend on the scaling of the axes. Every pigment counts equally, except
  for the deutan reading of the Type 4 plate, where each pigment is weighted by
  its dot area (`utils/pigment_weights.m`).
* **Separation** of a designed figure–background split: the Mahalanobis
  distance *D* between its two groups.

## 5. Data

| File | Content |
| --- | --- |
| `data/Ishihara_reflectance.mat` | `reflectance` (401 × 89): measured spectral reflectance, 380–780 nm in 1-nm steps (`wls`), one column per measured sample. Column 1 is the white paper; the columns belonging to each analysed plate are listed in `utils/plate_definitions.m` |
| `data/plates/<plate>/<plate>.png` | Image of the plate |
| `data/plates/<plate>/color<N>.png` | Dots printed in the pigment of reflectance column `N` |
| `data/T_cones_ss10.mat` | Stockman–Sharpe 10° cone fundamentals (as distributed with Psychtoolbox) |
| `data/T_xyz1931.mat` | CIE 1931 colour matching functions (as distributed with Psychtoolbox), used to set the luminance of the illuminant and to render pigment colours |
| `data/cie2006/` | CIE 2006 tables used by the observer model: photopigment absorbance, macular pigment and ocular media densities |

The four plates are `plate74` (Type 2, "74" / "21"), `plate97` (Type 3,
"97"), `plateCamouflage` (Type 4, hidden "2") and `plate42` (Type 5, "42" /
"2" / "4"). `utils/plate_definitions.m` also lists, for each plate, the
pigments that form the figure designed for normal trichromats, protans and
deutans.

## 6. Licence

The code is released under the MIT licence (see [`LICENSE`](LICENSE)).

## 7. Contact

Takuma Morimoto, takuma.morimoto@psy.ox.ac.uk
