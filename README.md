# Nanoparticle dissolving kinetics assay

A single HTML page that turns a NanoDrop table of MOF dissolution samples
(nanoparticles in cysteine, supernatant vs. whole suspension over time) into
first-order dissolution kinetics: rate constant **k**, **half-life t½**,
plateau, initial rate, with plots and tables. No installation, no internet
needed, everything stays on your computer.

**The maths is explained step by step in [MATH.md](MATH.md).**

## Start it

Get the folder (GitHub Desktop → *Clone repository*, or on GitHub *Code →
Download ZIP* and unzip), then double-click **`Open MOF dissolution
kinetics.bat`**, or the `.html` file itself. It opens in your browser.
(Opening the file on github.com only shows its code.) For a desktop icon:
right-click the `.bat` → *Send to → Desktop*.

## Use it

1. Copy the NanoDrop table (name, λ, absorbance columns) and paste it on the
   left. *Load example* shows the expected format.
2. Sample names need
   - a **time point**: `t1 [5min]` (also `[0.5h]`, `[30s]`),
   - the **fraction**: `sup` (supernatant = dissolved) or `all` (whole
     suspension = total); a t0 sample needs neither,
   - a **replicate**: `Nb_1`, `Nb_2` …
   - Text before the time point is the condition (`Bench t1 [5min] sup Nb_1`).
   Rows without a time point (blanks) are skipped; *Recognised samples* shows
   how every row was read.
   If the table has a second wavelength (columns λ 2 / Abs. 2, e.g. 633 nm),
   it is read too.
3. Choose
   - whether Nb_1, Nb_2 … are **replicates** of one condition (mean ± SD of
     the fits) or **different samples** (each fitted on its own; repeat a name
     for technical replicates),
   - the **signal**: % dissolved as sup ÷ all (default), sup ÷ t0, or raw
     absorbance,
   - the **model**: first order through zero, or with a free start value,
   - the **wavelength**: main peak (λ 1) or a second wavelength (default
     633 nm). With both present, the table *Both wavelengths* shows k, t½ and
     plateau for each next to each other.
4. Read k, t½, plateau, initial rate and R² from *Kinetic parameters*. Click a
   replicate in the legend to leave it out. *Copy table* pastes into Excel;
   when opened from your computer, the plot can be saved as SVG/PNG and the
   tables as CSV.

## Files

| file | |
|---|---|
| `MOF_dissolution_kinetics.html` | the app |
| `Open MOF dissolution kinetics.bat` | Windows launcher |
| `MATH.md` | every formula, the fitting method, error estimates, worked example, assumptions |

## History

See the commit log: the first commit is the app as it was written; every
change after it is a separate commit with its reason.
