# The maths behind MOF dissolution kinetics

This file explains every number the app (`MOF_dissolution_kinetics.html`)
calculates, in the order it calculates them. Everything was checked against
the code; section 9 shows the example data worked through and compared with an
independent fit in Python (`scipy.optimize.curve_fit`).

---

## 1. What is measured

MOF particles are put into cysteine solution. At each time point *t* two
samples are taken per replicate and measured on the NanoDrop:

| sample | contains | name contains |
|---|---|---|
| **sup** (supernatant) | only what has **dissolved** (particles spun down) | `sup` (also `sub`, `supernatant`, `Überstand`) |
| **all** (whole suspension) | dissolved **plus** undissolved material = the **total** | `all` (also `total`, `tot`) |
| **t0** | the total before dissolution started | no `sup`/`all`, e.g. `t0 [0min] Nb_1` |

The NanoDrop reports the absorbance **A** at the peak wavelength λ (here
≈ 210 nm). Under Beer–Lambert, A = ε · c · d, so A is proportional to the
concentration of the absorbing species. Ratios of absorbances are therefore
ratios of concentrations, and the unknown ε cancels.

## 2. Reading the table

Every row needs a **time point** (`t1`, `t2` …), ideally with the real time in
brackets (`[5min]`, `[0.5h]`, `[30s]`; converted to minutes), a **fraction**
(`sup` / `all`) and a **replicate** (`Nb_1`, `Nb_2` …, the last letters +
number in the name). The text before the time point is the **condition**
(e.g. `Bench`). Rows without a time point (blanks, header) are skipped. If no
time is given in brackets, the time-point index is used as minutes, with a
warning.

**Technical replicates:** rows with exactly the same name are repeated
measurements of the same tube. They are averaged first:

  x̄ = (1/n) Σ xᵢ  s = √( Σ (xᵢ − x̄)² / (n − 1) )

**Two export formats** are recognised:

1. **Peak table**: one row per sample with λ / Abs. columns (the app's
   example).
2. **Spectrum export**: a line `Wavelength (nm) <tab> sample <tab> …`, then
   one row per wavelength (e.g. 200–750 nm) and one column per sample. Each
   sample keeps its whole spectrum, and the value used is taken from it:
   - **main peak** = the **maximum** between 200 and 250 nm (range and
     maximum/mean adjustable) – the same as the NanoDrop's peak column;
   - **second wavelength** = the **mean** over 633 ± 5 nm (centre, ± width
     and mean/maximum adjustable). The mean over a few nm is less noisy than
     a single wavelength; use *maximum* for a narrow band.
   Columns without a time point (Blank 1, …) are skipped.

**Names.** The time point (`t3`, with `[15min]`), the fraction (`sup` /
`all`) and the replicate (`Nb_1`, `sample-1`: letters + number at the end)
are taken out of the name; whatever is left is the **condition**, wherever it
stands: `Bench t1 [5min] sup Nb_1` → Bench, `t1 [5min] sup 20 mM sample-1`
→ 20 mM, `t1 [5min] sup sample-1` → Sample. `t0` without brackets is 0 min.

**t0 for sup ÷ t0.** Each condition / replicate uses its own t0 total. A
series without one (e.g. `20 mM` measured from the same stock) uses the t0
of the only other condition with the same replicate, and the app says so;
with no or several candidates it is left out.

**Several wavelengths (peak table).** A NanoDrop row can hold several λ / Abs. column
pairs (e.g. the peak near 210 nm and 633 nm). With a header row the pairs are
taken by their column names (λ 1 / Abs. 1, λ 2 / Abs. 2, …); without one,
the numbers after the name are read as λ, A, λ, A, … in order.

- **Main peak** = the first pair of each row (λ 1, the peak the NanoDrop
  reports first; ≈ 210–216 nm in the example).
- **Second wavelength** (default **633 nm**, adjustable) = the pair whose λ
  is closest to that value, within ±25 nm. Rows without such a pair are
  skipped for this wavelength.

Everything below (signals, fit, errors) is done in exactly the same way for
the chosen wavelength.

## 3. From absorbance to the signal that is fitted

For replicate *r* at time *t*, with A_sup, A_all the averaged absorbances:

**a) % dissolved, sup ÷ all (default)**

  y(t) = 100 · A_sup(t) / A_all(t)

Both samples come from the same tube at the same time, so pipetting
differences, evaporation or slightly different particle amounts per replicate
cancel. The total at each time is the `all` sample; if there is none, an
unlabelled sample at that time is used.

**b) % dissolved, sup ÷ t0**

  y(t) = 100 · A_sup(t) / A_total(t₀)

where t₀ is the earliest time that has a total sample for that replicate. Uses
one reference per replicate, so drift in the total over time is not corrected.

**c) Raw absorbance of sup**

  y(t) = A_sup(t)  (no normalisation)

**Error bars from technical replicates** (only when a name was measured more
than once). For a ratio y = 100 · S / D the relative errors add in quadrature
(first-order error propagation, S and D independent):

  s_y = |y| · √( (s_S / S̄)² + (s_D / D̄)² )

A term is 0 when that sample was measured only once.

## 4. The model: first-order dissolution

If the particles dissolve at a rate proportional to the amount still
undissolved, M(t):

  dM/dt = −k · M  ⇒  M(t) = M₀ · e^(−kt)

The dissolved amount is what has left the particles, D(t) = M₀ − M(t), so

  **y(t) = y∞ · (1 − e^(−kt))**  (model "starts at zero")

- **k** (min⁻¹) is the rate constant: the fraction of the remaining material
  that dissolves per minute.
- **y∞** is the plateau: the signal when everything that can dissolve has
  dissolved (ideally 100 % in the % signals).

With a **free start value** (some dissolved signal already at t = 0, e.g.
free iron/fumarate in the stock):

  **y(t) = y₀ + (y∞ − y₀) · (1 − e^(−kt))**

This has 3 parameters instead of 2 and needs more time points to be stable
(see section 8).

## 5. Numbers derived from k

| quantity | formula | meaning |
|---|---|---|
| half-life | **t½ = ln 2 / k** | time until half of the dissolvable material is dissolved; independent of y∞ |
| initial rate | **v₀ = k · (y∞ − y₀)** (y₀ = 0 for the first model) | slope of the curve at t = 0, in %/min or A/min |
| (not shown) time constant | τ = 1 / k | time to 63 % |
| (not shown) time to 90 % | t₉₀ = ln 10 / k ≈ 3.3 · t½ | |

v₀ follows from differentiating the model: dy/dt = (y∞ − y₀) · k · e^(−kt),
which is k (y∞ − y₀) at t = 0.

## 6. How the fit works

The parameters minimise the **sum of squared residuals**

  SSE(k, y∞, y₀) = Σᵢ ( yᵢ − f(tᵢ) )²

over all time points, all points weighted equally. No artificial point (0, 0)
is added: in the first model the curve passes through zero by construction.

The trick: for a **fixed k** the model is **linear** in the other parameters.
With gᵢ = 1 − e^(−k tᵢ):

- starts at zero: y = y∞ · g → the best plateau is exact,
  **y∞ = Σ gᵢ yᵢ / Σ gᵢ²**
- free start value: y = y₀ + a · g with a = y∞ − y₀ → ordinary linear
  regression of y on g:
  a = (n Σgy − Σg Σy) / (n Σg² − (Σg)²), y₀ = (Σy − a Σg) / n

So only **k** has to be searched (this is called *variable projection*):

1. **Scan:** SSE is evaluated for 600 values of k, evenly spaced on a log
   scale from 0.01 / t_max (almost no change in the window) to 30 / t_min
   (complete before the first sample).
2. **Refine:** between the two neighbours of the best scan value, a
   **golden-section search** (80 steps) finds the minimum of SSE(k).
3. If the best k is the first or last scan value, the result is flagged:
   *upper limit* → dissolution was already complete at the first sample, k is
   only a lower bound; *lower limit* → too little change to estimate k.

The scan makes the fit robust: it cannot get stuck in a wrong local minimum
the way a gradient method started from a bad guess can.

## 7. Uncertainty and goodness of fit

**Standard error of the parameters** (linearised least squares). J is the
matrix of derivatives of the model at each time point:

- starts at zero, parameters (y∞, k):
  ∂f/∂y∞ = 1 − e^(−kt), ∂f/∂k = y∞ · t · e^(−kt)
- free start, parameters (a, y₀, k):
  ∂f/∂a = 1 − e^(−kt), ∂f/∂y₀ = 1, ∂f/∂k = a · t · e^(−kt)

  Cov = s² · (JᵀJ)⁻¹  with s² = SSE / (n − p)

n = number of time points, p = number of parameters (2 or 3).
SE(k) = √Cov_kk. For the plateau with free start, y∞ = a + y₀, so
Var(y∞) = Var(a) + Var(y₀) + 2 Cov(a, y₀).

**SE of t½** (shown in "different samples" mode), by error propagation of
t½ = ln 2 / k:  SE(t½) = ln 2 · SE(k) / k²

**R²** = 1 − SSE / Σ(yᵢ − ȳ)²: the fraction of the variation over time that
the curve explains.

With n − p ≤ 1 degrees of freedom the SE is unreliable or missing (flagged).

## 8. Replicates: which number to report

**Mode "replicates of one condition"** (Nb_1, Nb_2, Nb_3 are independent
replicates):

- every replicate is fitted on its own;
- **Mean ± SD of fits**: mean and SD (n − 1) of k, t½, plateau and v₀ over the
  replicates. **This is the number to report**: the SD is the real
  replicate-to-replicate variation;
- **Fit to mean curve**: the mean signal at each time (black squares, ± SD)
  fitted once. Gives nearly the same k, but its SE only describes how well the
  curve fits the means, not the spread between replicates;
- clicking a replicate in the legend leaves it out of both.

**Mode "different samples"** (Nb_x are different conditions): every sample is
fitted to the means of its technical replicates. Error bars and SE then only
reflect measurement noise, not independent syntheses.

Note: the mean of t½ over replicates is not exactly ln 2 / (mean k), because
t½ is not linear in k; both are shown, the difference is small when the
replicates agree.

## 8b. Both wavelengths side by side

When the table has values at the second wavelength, the table **Both
wavelengths** fits every replicate (or sample) at both wavelengths with the
same signal and model and lists k, t½ and plateau next to each other: mean ±
SD over the replicates (replicates mode) or one fit per sample (samples
mode). Replicates left out in the legend are left out here too.

Interpretation: if both absorbing species leave the particle by the same
first-order process, k is the same at both wavelengths (within the SD). A
clearly different k means two processes, e.g. a dye released faster than the
framework dissolves.

## 9. Worked example (the app's example data)

Bench, sup ÷ all, replicate Nb_1:

| t (min) | A_sup | A_all | y = 100 · sup/all |
|---|---|---|---|
| 5 | 6.025 | 10.51 | 57.3 % |
| 10 | 8.007 | 10.09 | 79.4 % |
| 15 | 9.892 | 10.01 | 98.8 % |
| 20 | 10.05 | 10.62 | 94.6 % |

Fit y = y∞ (1 − e^(−kt)): k = 0.165 min⁻¹, y∞ = 101.6 %,
t½ = ln 2 / 0.165 = 4.20 min, v₀ = 0.165 · 101.6 = 16.8 %/min, R² = 0.952.

All three replicates (model starts at zero):

| | k (min⁻¹) | SE(k) | t½ (min) | plateau (%) | R² |
|---|---|---|---|---|---|
| Nb_1 | 0.165 | 0.030 | 4.20 | 101.6 | 0.952 |
| Nb_2 | 0.199 | 0.010 | 3.49 | 101.8 | 0.995 |
| Nb_3 | 0.171 | 0.026 | 4.06 | 102.3 | 0.960 |
| **mean ± SD** | **0.178 ± 0.018** | | **3.92 ± 0.38** | 101.9 ± 0.3 | |
| fit to mean curve | 0.178 | 0.008 | 3.89 | 101.7 | 0.997 |

**Check:** fitting the same numbers with `scipy.optimize.curve_fit`
(Levenberg–Marquardt) gives identical k, SE(k), t½, plateau and R² to the
digits shown, for sup ÷ all with both models and for sup ÷ t0 (raw absorbance
gives the same k as sup ÷ t0, because it only differs by a constant factor per
replicate).

## 10. Assumptions and limits

- **Linearity:** A must be proportional to concentration. The NanoDrop
  reports 10 mm-equivalent values measured over a much shorter path; check
  that your highest values (here ≈ 13) are still within the instrument's
  linear range, and measure sup and all the same way.
- **Blank:** cysteine absorbs strongly below ~230 nm. The NanoDrop blank must
  be the same cysteine solution, otherwise its absorbance adds to every
  sample and inflates sup more (relatively) than all.
- **Separation:** "sup" must contain only dissolved material. Small particles
  that do not pellet are counted as dissolved, which makes k look faster.
- **Plateau above 100 %** (e.g. 101–102 % here) is within measurement noise of
  sup and all; it is not real.
- **Sampling times:** with t½ ≈ 4 min, the first sample at 5 min is already
  ~60 % dissolved. k is best defined by points on the rising part of the
  curve, so earlier samples (e.g. 1, 2, 3 min) would narrow it down most.
- **Free start value with 4 points** leaves 1 degree of freedom: in the
  example, Nb_3 gives k = 0.075 ± 0.046 min⁻¹ and a plateau of 121 % with
  that model, against 0.171 ± 0.026 with the model through zero. Use it only
  with more time points or when there is a real dissolved signal at t = 0.
- **Single process:** the model assumes one first-order process. Two phases
  (fast surface dissolution, slow core) or a lag phase show up as systematic
  residuals: points above the curve early and below it later, or the reverse.
