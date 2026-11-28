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

1. **Load the NanoDrop exports** with *Load files…* or drag them onto the box
   on the left: `.xlsx` as saved by the NanoDrop (the *Values* sheet with the
   spectra is used, otherwise the *Table* sheet with the peaks), or `.csv` /
   `.tsv` / `.txt`. Several files at once: a measurement over two days in two
   exports is read as **one data set** - same sample names, time points from
   both days. Each file shows its measurement date and number of samples,
   can be removed with ×, and stays loaded when the page is reopened.
   Day 1 is listed before day 2 (date inside the file). Pasting a table into
   the box below still works and is combined with the loaded files.

   Or copy the NanoDrop table and paste it on the left. Both exports work:
   the **peak table** (one row per sample: name, λ, absorbance; *Load
   example*) and the **spectrum export** (`Wavelength (nm)` + one column per
   sample). From a spectrum, the main peak is the maximum between 200 and
   250 nm, the second wavelength the mean over 633 ± 5 nm (both adjustable).
2. Sample names need
   - a **time point**: `t1 [5min]` (also `[0.5h]`, `[30s]`),
   - the **fraction**: `sup` (supernatant = dissolved) or `all` (whole
     suspension = total); a t0 sample needs neither,
   - a **replicate**: `Nb_1`, `sample-1`, `sample 1` … (letters + number;
     the last such pair in the name)

   The parts may come in any order: `sample 1 sup t0` and `t0 sup sample-1`
   are read the same way.
   - The rest of the name is the condition, wherever it stands
     (`Bench t1 [5min] sup Nb_1` → Bench, `t1 [5min] sup 20 mM sample-1` → 20 mM).
   - Case and separator do not matter: `sample 1` and `Sample-1` are the
     same replicate (e.g. day 1 and day 2).
   - A fully dissolved reference: `end` or `complete` anywhere in the name,
     with or without time point and sup/all (`t3 [20 min] all sample-2 end`,
     `sample-4end`), for *% of complete dissolution*. It is not used as a
     normal time point; several end samples of one replicate are averaged; a
     replicate without one uses the mean of its condition's end samples.
   - One `all` per replicate is enough (at any time point): time points
     without their own use the mean of that replicate's `all` samples.
   Rows without a time point (blanks) are skipped; *Recognised samples* shows
   how every row was read.
   If the table has a second wavelength (columns λ 2 / Abs. 2, e.g. 633 nm),
   it is read too.
3. Choose
   - whether Nb_1, Nb_2 … are **replicates** of one condition (mean ± SD of
     the fits) or **different samples** (each fitted on its own; repeat a name
     for technical replicates),
   - the **signal**: *released since t0* (default: the supernatant at t0 is
     subtracted, Engelke-style background correction), *% of complete
     dissolution* (needs a fully dissolved sample named `… sample 1 end`;
     with spectra a linear decomposition as in Ploetz, Engelke et al. 2020),
     % dissolved as sup ÷ all, sup ÷ t0, or raw absorbance,
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
