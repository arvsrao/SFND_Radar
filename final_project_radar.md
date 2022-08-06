# Final Project - Radar

##### Outline

1. [FMCW Waveform Design](#fmcw_waveform)
2. [Simulation Loop](#reps)
   - [Transmit and Receive Signal Representations](#reps)
     - [Implementation](#implementation)
   - [Mixing Signals](#mixing)
3. [Range FFT (1st FFT)](#range_fft)
   - [The DFT of M(t)](#mix_fft)
4. [2D CFAR](#2dcfar)
5. [Appendix](#appendix)
   1. [DFT of $cos(2\pi R/N + C)$](#appendix)
   2. [Frequency Range of DFT](#range)
   3. [2D DFT of $M(t)$](#2dfft)



## FMCW Waveform Design <a name="fmcw_waveform"></a>

From the section on range estimation we learned the chirp bandwidth, $\sf B_{sweep}$ is a function of the desired distance resolution.
$$
{\sf B_{sweep}} = \frac{c}{2 \cdot { d_{res}}},
$$
where $c$ is the speed of light and $d_{res}$ is the distance resolution. For the desired distance resolution of 1 meter ${\sf B_{sweep}} = 150$ MHz. The time over which the chirp frequency ramps, ${\sf T_{chirp}}$, depends on the maximum range detectable by the radar, ${\sf R_{max}}$, and is defined in the range estimation section and the project overview page to be 
$$
{\sf T_{chirp}} = 5.5 \times \frac{2 \cdot  {\sf R_{max}}}{c}.
$$
The radar must detect objects up to 200 meters away, so $\sf T_{chirp} = 7.3333 \ \mu s$. Finally, the chirp slope is
$$
\sf{Slope} = \frac{B_{sweep}}{T_{chirp}} = \frac{150 \ MHz}{7.3333 \ \mu s} = 2.0455 \times 10^{13}.
$$


## Simulation Loop



#### Transmit and Receive Signal Representations <a name="reps"></a>

The transmit signal is a simulated frequency modulated continuous waveform (FMCW) of the form
$$
T(t) = A \cos 2\pi\varphi(t), \\
$$
where $2\pi \varphi(t)$ is the phase and $\varphi(t)$ is the normalized phase. For simplicity I abuse the terminology a bit by also referring to both $2\pi \varphi(t)$ and $\varphi(t)$ as the phase. FMCWs are periodic in frequency as well as time. The transmit frequency increases linearly over each chirp time interval, $\sf T_{chirp}$, sweeping the frequency range $[f_c, f_c + {\sf B_{sweep}}]$. Since the time derivative of phase, $\dot\varphi(t)$, [is the frequency][1] of $T(t)$, it must then be a linear function with boundary values $\dot \varphi(0)= f_c$ and $\dot \varphi({\sf T_{chirp}})= f_c + {\sf{B_{sweep}}}$. Only one linear function satisfies the boundary conditions of the first chirp, $\dot \varphi(t) = f_c + {\sf{Slope}} \cdot t$. Because the FMCW is periodic, $\dot \varphi(t)$ is extended to subsequent chirps by time delaying $\dot \varphi(t)$ integer multiples of the chirp duration. Over say the $(m+1)$-th chirp the frequency would be $\dot \varphi(t - m{\sf{T_{chirp}}})$ for $t \in [m{\sf T_{chirp}}, (m+1){\sf T_{chirp}}].$ For all time and chirps the frequency is defined piecewise,
$$
\dot \varphi(t) = f_c + {\sf{Slope}} \cdot (t - {\sf{T_{chirp}}}\lfloor t/{\sf T_{chirp}} \rfloor).
$$
On each piece the delay ${\sf{T_{chirp}}}\lfloor t/{\sf T_{chirp}} \rfloor$ is constant. Integrating each piece separately with initial conditions $\varphi(m{\sf{T_{chirp}}}) = f_c m{\sf{T_{chirp}}}$ for $m \in \mathbb{Z}^+$ gives
$$
\varphi(t) = f_c t +  \frac{\sf{Slope}}{2}(t - {\sf{T_{chirp}}}\lfloor t/{\sf T_{chirp}} \rfloor)^2 \ \ \text{for all }t.
$$
The received signal is simply modeled as a time delayed instance of $T(t)$ , $R(t) = T(t - \tau)$. 

##### Implementation

The final project walkthrough models transmit and receive signals with non-periodic and linearly increasing frequency modulation, $\dot \varphi(t) = f_c + {\sf{Slope}} \cdot t$. Accordingly the phase  <a name="implementation"></a>
$$
\varphi(t) = f_c t + {\sf{Slope}} \frac{t^2}{2} \ \ \text{for all }t,
$$
isn't time delayed by an integer multiple of the chirp duration as I derived in the proceeding section. I experimented with both the non-periodic and periodic FMCW transmit signal models. Both produce very similar range graphs (see the figures below) with a spike at the beat frequency corresponding to 91 meters (my choice of initial range is 90 meters).

![fmcw_range_estimation_compare](/Users/arvind/projects/sensor_fusion_projects/fmcw_range_estimation_compare.jpg)

However, the 2D FFT graphs differ, with the 2D FFT corresponding to mixed periodic FMCW signals showing artifacts not present in the 2D FFT graph of the mixed non-periodic FMCW signals. Since it is beyond the scope of the final project to probe the differences between chirp signal models, my results for the project are based on the suggested non-periodic FMCW transmit signal model.



![2dfft_compare](/Users/arvind/projects/sensor_fusion_projects/2dfft_compare.jpg)

In my code submission on lines 67 & 68 transmit and received signals are sampled and stored in lists.

<a name="mixing"></a>

#### Mixing Signals

To compute the range the transmitted and received signals are first mixed, which is modeled by multiplication of the signals. Let $M(t)$ be the mixture of the transmitted and received signals, then
$$
\begin{align*}
M(t) &= T(t) \cdot R(t) \\
     &= T(t) \cdot T(t - \tau) \\
     &= A^2 \cos(2\pi\varphi(t)) \cos(2\pi\varphi(t - \tau)). \\ 
\end{align*}
$$
Combining two [angle addition identifies for cosine][2] produces the product identity
$$
\cos(\phi)\cos(\omega) = \frac{1}{2} \cos(\phi + \omega) + \frac{1}{2} \cos(\phi - \omega)  \\
$$
which when applied to $M(t)$ isolates the phase difference in a summand.
$$
M(t) = \frac{A^2}{2} \cos2\pi\Big(\varphi(t) + \varphi(t -\tau) \Big) + \frac{A^2}{2} \cos2\pi\Big(\underbrace{\varphi(t) - \varphi(t -\tau)}_{\Delta \varphi} \Big). \\
$$

The second term of $M(t)$ contains the phase difference to be captured later by the FFT, and it is 
$$
\begin{align}
\Delta \varphi &= {\sf Slope} \cdot \tau t -  \tau\Big[{\sf Slope}\frac{\tau}{2} + {\sf B_{sweep}}\lfloor t / {\sf T_{chirp}}\rfloor - f_c \Big]. \\
\end{align}
$$
The time delay, $\tau$ , is actually a function of time; it is generated from a target that is initially $R_0 = 90$ meters distant from the radar and moving at $v=15 \ m/s$ away. On lines 60 and 61 of my code submission I generated the time delay according to the formula
$$
\require{cancel}
R_t = \frac{c \cdot \tau}{2} = R_0 + v t \quad \Longrightarrow \quad \tau = \frac{2R_0 + 2v t}{c}.
$$
Focusing on the first chirp and substituting the expression for $\tau$ into the phase difference gives
$$
\begin{align}
\Delta \varphi &= {\sf Slope} \cdot \tau t -  \tau\Big[{\sf Slope}\frac{\tau}{2}  - f_c \Big] \\
&= \frac{2v{\sf Slope}}{c^2}(c - v)t^2 + \frac{2}{c^2}({\sf Slope}\cdot cR_0 - 2{\sf Slope}\cdot R_0v + c f_cv)t + \frac{2R_0}{c^2}(cf_c - {\sf Slope}\cdot R_0) \\
&= \frac{2v{\sf Slope}}{c^2}(c - v)t^2 + \frac{2}{c^2}({\sf Slope}\cdot R_0(c - 2v) + c f_cv)t + \frac{2R_0}{c^2}(cf_c - {\sf Slope}\cdot R_0).
\end{align}
$$
Since $c$ dominates $v$ take $c - v \approx c$ and $c - 2v \approx c$; then
$$
\Delta \varphi \approx \frac{2v{\sf Slope}}{c}t^2 + \frac{2}{c}(    
{\sf Slope}\cdot R_0  + f_cv)t + \frac{2R_0}{c^2}(cf_c - {\sf Slope}\cdot R_0).
$$
During the chirp the quadratic term
$$
\frac{2v{\sf Slope}}{c}t^2 < \frac{2v{\sf Slope}}{c}{\sf T^2_{chirp}}  =  1.1000 \times 10^{-4}
$$
 is negligible, so it can be ignored and $\Delta \varphi$ can be further approximated,
$$
\Delta \varphi \approx \frac{2}{c}( {\sf Slope}\cdot R_0  + f_cv)t + \frac{2R_0}{c^2}(cf_c - {\sf Slope}\cdot R_0).
$$
The expected (approximate) beat frequency is the time derivative of the phase difference 
$$
\frac{\Delta \varphi}{dt} \approx \underbrace{\frac{2}{c}    
{\sf Slope}\cdot R_0}_{f_R}  + \underbrace{\frac{2f_cv}{c}}_{f_D}.
$$
It easily separates into frequency due to range, $f_R$, and the doppler frequency, $f_D$. Finally, substituting the phase difference approximation into the mixed signal formula from above, we arrive at an approximation for the mix signal.
$$
M(t) \approx \frac{A^2}{2} \cos2\pi\Big(\varphi(t) + \varphi(t -\tau) \Big) + \frac{A^2}{2} \cos2\pi\Big(\frac{2}{c}( {\sf Slope}\cdot R_0  + f_cv)t + C\Big) \quad  \\
$$
where $C = \frac{2R_0}{c^2}(cf_c - {\sf Slope}\cdot R_0)$. On line 81 of my code submission sampled transmit and receive signals are mixed by element wise multiplication and stored in a 1D array called `Mix`.



## Range FFT (1st FFT)

In lines 90 to 97 the mixed signal array  `Mix` is reshaped into a 2D array of shape $N_r \times N_d$. $N_r$ is the number of samples per chirp and $N_d$ is the number of chirps. The $n$-th column of the 2D `Mix` array are samples of mixed signal during the $n$-th chirp. The Matlab 1D FFT  function evaluated on `Mix`  outputs the 1D FFT of each column. Code in lines 108 to 110 generate a plot, shown below, of the FFT of the mixed signal during the 1st chirp.

<a name="range_fft"></a>

![range_fft](/Users/arvind/projects/sensor_fusion_projects/range_fft.jpg)

The maximum FFT values occurs at index $k=91$, which is within a meter of the initial range $R_0 = 90$ I had configured. To better understand why and how the indices of the range FFT are related to the range, I derive a closed form expression for the range FFT in the next section.

#### The DFT of M(t) <a name="mix_fft"></a>

The summand of $M(t)$ with the summed phases has frequency content $\geq 2f_c$. Given the radar specifications and number of samples per chirp, the largest frequency recognized by the DFT is $f_s \frac{N-1}{N} = 0.14$  GHz, which is much smaller than the $77$ GHz carrier frequency. In an [appendix](#range) I show that the DFT frequency representation of a signal is bounded and sampled. So, for all intents and purposes the DFT is blind to the frequency content of the first term. Therefore, the first term of $M(t)$ can be dropped and <a name="dft_mixed_signal"></a>
$$
M(t) \approx \frac{A^2}{2} \cos2\pi\Big(\frac{2}{c}( {\sf Slope}\cdot R_0  + f_cv)t + C\Big). \\
$$
The discretized phase of $M(t)$ is <a name="eqn1"></a>
$$
\begin{align}
\Delta \varphi\Big(\frac{n{\sf T_{chirp}}}{N_r}\Big) &= \frac{2}{c}( {\sf Slope}\cdot R_0  + f_cv)\frac{n{\sf T_{chirp}}}{N_r} + C \\
&= \frac{n}{N_r} \frac{2}{c}( {\sf Slope}\cdot R_0  + f_cv){\sf T_{chirp}} + C \\
&= \frac{n}{N_r}(\frac{2}{c}{\sf B_{sweep}}\cdot R_0  + \frac{2}{c}f_cv{\sf T_{chirp}}) + C \\
&\approx \frac{n}{N_r}R_0 + C. \\
\end{align}
$$
The last line follows from the relation ${\sf B_{sweep}} = \frac{c}{2 \cdot { d_{res}}}$ and because the term $\frac{2}{c}f_cv{\sf T_{chirp}} = 0.0565$ is negligible. Substituting the sampled phase difference into $M(t)$ results in a formula for the sampled mixed signal,
$$
m[n] \approx \frac{A^2}{2}\cos 2\pi \big(\frac{n}{N_r}R_0 + C \big) \\
$$

with period $N_r$. The DFT of $m[n]$ is
$$
m[n] \overset{DFT}{\large\Longrightarrow} M[k] = \frac{A^2N_r}{4} \Big[ e^{j C}\delta(R_0 - k) + e^{-j C} \delta(R_0 + k - N_r)\Big] \quad \text{for}\quad 0 \leq k < N_r.
$$
I derive $M[k]$ in an [appendix](#appendix) to this report. The DFT is also periodic, but only the period $[0, N_r)$ is relevant. With a closed functional expression for $M[k]$ in hand it is now clear the only frequency content of the mixed signal must occur at indices $k = R_0 = 90$ and $k = N_r - R_0 = 934$. The later impulse lies beyond the $200$ meter maximum detectable range configured for the radar, so when graphing the FFT it makes sense to render only first $200$ values of the DFT. Additionally, it's also clear from the formula of $M[k]$ the amplitude is linear in $N_r$. Normalizing by $N_r$ removes this dependence. For example if $A=2$, then
$$
\Bigg\lvert \frac{M[k]}{N_r} \Bigg\rvert = \delta(R_0 - k) + \delta(R_0 + k - N_r) \quad \text{for}\quad 0 \leq k < N_r.
$$
[At the top](#range_fft) of this section $\Bigg\lvert \frac{M[k]}{N_r} \Bigg\rvert$ is graphed up to $k = 200$, and the graph looks very much like an impulse at $k = 91$, just one meter off from $R_0=90$.



## 2D CFAR <a name="2dcfar"></a>

I computed the RDM adjusted 2D FFT, shown below, in lines 127 - 139 of my code submission. I derive the expected 2D FFT, based on the periodic FMCW model in an [appendix](#2dfft).![2d_fft](/Users/arvind/projects/sensor_fusion_projects/2d_fft.jpg)

The CFAR image of the range-doppler map (resp. the 2D FFT above) is shown below. Implementation steps:

1. An output buffer is created on line 182; it has the same size as the input range-doppler map and all its entries are initially set to zero. 
2. Iterate over the range-doppler map in such a way that non-thresholded cells are avoided. The range and doppler loop boundaries were computed to avoid edges cells for which the threshold mask crosses the image boundary. Therefore, non-thresholded cells in the output buffer remain set to zero.
3. Inside the main loop ( lines 198 - 205 ) the threshold for the specific CUT cell is computed by converting each cell within the mask to linear scale, then summing, and finally averaged by dividing the sum by the number of cells in the mask.
4. Finally, the CUT cell is thresholded and written to the corresponding entry of the output buffer.

I chose the guard cell and train cell dimensions based on the 2D FFT image. While the training mask is square, the guard cells were chosen to be narrow in the doppler direction, because the spike in the range-doppler map is very narrow and appears mostly confined to a few range columns.

![2d_cfar](/Users/arvind/projects/sensor_fusion_projects/2d_cfar.jpg)





<a name="appendix"></a>

### Appendix: DFT of $cos(2\pi R/N + C)$

Before deriving the DFT first a helpful lemma. 

##### Lemma (exercise 8.51 [Oppenheim and Schafer][3])<a name="lemma"></a>

Let
$$
A(l) = \sum^{N-1}_{n=0} e^{j2\pi \frac{l}{N} n}.
$$
Then $A(l) = \sum^{\infty}_{m = -\infty}N\delta(l - mN)$.

***proof***

Suppose  $l$ is a multiple of $N$. Then
$$
A(l) = A(mN) = \sum^{N-1}_{n=0} (e^{j2\pi \cdot \cancelto{m}{\frac{mN}{N}}})^n = N.
$$
Otherwise $l$ is not a multiple of $N$. Because $A(l)$ is periodic assume $0 < l < N$. Recalling finite geometric sums have a closed form $\sum^{N-1}_{n=0}a^n = \frac{a^N - 1}{a-1}.$

Then
$$
\begin{align}
A(l) &=  \sum^{N-1}_{n=0} e^{j2\pi \frac{l}{N} n} =  \frac{\cancelto{0}{e^{j2\pi l} - 1}}{e^{j2\pi\frac{l}{N}} -1} \\
\end{align}
$$
Since $l$ is not a multiple of $N$, the denominator is nonzero and $A(l) = 0$.

***q.e.d***

Now the main result.

##### Lemma

Suppose $x[n] = \cos 2\pi \big(nR/N + C \big) \\$ with period $N$. Then the discrete Fourier series is periodic sequence
$$
X[k] = \frac{N}{2}\Big[e^{j 2\pi C} \delta(R - k) + e^{-j 2\pi C}\delta(R + k - N) \Big]
$$
where $0 \leq k < N$.

***Proof***
$$
\begin{align}
	X[k] &= \sum^{N-1}_{n=0}x[n]e^{-j2\pi kn/N} \\
	     &= \sum^{N-1}_{n=0}\cos  \big( 2\pi\frac{n}{N}R + C \big)e^{-j2\pi kn/N} \\
	     &= \frac{1}{2}e^{j C}\sum^{N-1}_{n=0} e^{j\frac{2\pi}{N}\big(R - k\big)n}+ \frac{1}{2}e^{-j C}\sum^{N-1}_{n=0}e^{-j\frac{2\pi}{N}\big(R + k\big)n} \\
\end{align}
$$
By the [lemma](#lemma)
$$
X[k] = \frac{N}{2}\sum^{\infty}_{m=-\infty}\Big[e^{j C} \delta(R - k - mN) + e^{-j C}\delta(R + k - mN) \Big]. \\
$$
When restricted to $0 \leq k < N$,
$$
X[k] = \frac{N}{2}\Big[e^{j C} \delta(R - k) + e^{-j C}\delta(R + k - N) \Big]. \\
$$


##### Exercise <a name="exercise"></a>

##### What is the DFT of $e^{j2\pi a n/N}$ where $a \in \mathbb{R}$.

**Answer**
$$
\begin{align}
X[k] = \mathcal{F}(e^{j2\pi a n/N})(k) &= \sum^{N-1}_{n=0} e^{j2\pi a n/N}e^{-j2\pi k n/N} \\
 &= \sum^{N-1}_{n=0} e^{j2\pi (a - k )n/N} \\
 &= \frac{e^{j2\pi (a - k)} - 1}{e^{j2\pi (a - k)/N} - 1}\\
 &= \frac{e^{j2\pi a} - 1}{e^{j2\pi (a - k)/N} - 1}
\end{align}
$$
The magnitude of $X[k]$ peaks at $a$ is $N$, while away from $a$ it is 
$$
\begin{align}
 X[k]X[k]^* &= \frac{e^{j2\pi (a - k)} - 1}{e^{j2\pi (a - k)/N} - 1} \frac{e^{-j2\pi (a - k)} - 1}{e^{-j2\pi (a - k)/N} - 1}\\
                   &= \frac{1 - e^{j2\pi (a - k)} - e^{-j2\pi (a - k)} + 1}{1 - e^{j2\pi (a - k)/N} - e^{-j2\pi (a - k)/N} + 1} \\
                   &= \frac{1 - \cos{2\pi a}}{1 - \cos{2\pi (a - k)/N} }. \\
\end{align}
$$
The numerator is constant and when $a \neq k$, the denominator takes values $(0,2]$. As $k \rightarrow a$ the cosine term can be [approximated by small angle](https://en.wikipedia.org/wiki/Small-angle_approximation) $1 - (2\pi (a - k)/N))^2/2$ and
$$
\lvert X[k] \rvert = \frac{\sqrt{2 - 2\cos{2\pi a}}}{2\pi \lvert a - k \rvert/N } =  \frac{N}{\sqrt{2}\pi}\frac{\sqrt{1 - \cos{2\pi a}}}{ \lvert a - k \rvert }.
$$
So, as $k \rightarrow a$ $\lvert X[k] \rvert$ increases asymptotical to $N$. Likewise as $k$ moves away from $a$ the cosine term decreases and the denominator increases toward $2$ and $\lvert X[k] \rvert$ tends toward $\frac{1 - \cos{2\pi a}}{2}$. The graph of $\lvert X[k] \rvert$ looks like a spike around $a$, sharply decreasing immediately around $a$, and farther away monotonically decreasing to $\frac{1 - \cos{2\pi a}}{2}$. See an example [plot](#2dfft) at the end of the 2D FFT appendix. 

***q.e.d***



<a name="range"></a>

### Appendix: Frequency Range of DFT

Let $x(t)$ be some reasonable signal sampled $N$ times every $T_s$ seconds. Necessarily $f_s = 1 / T_s$ is the sampling frequency or the number of samples per second. The $n$th sample is $x[n] = x(t_n)$ where $t_n = nT_s$ and $n < N$.

Letting  $e_k = e^{-j2\pi kn/N}$ the DFT of $x[n]$ is an expression of $x[n]$ in the orthonormal basis $\{e_k\}$, where the    $k$-th DFT coefficient $X[k]$ is essentially the inner product of $x$ and $e_k$.
$$
X[k] = <x[n], e_k[n]> = \sum^{N-1}_{n=0}x[n]e^{-j2\pi kn/N}.
$$
Each $e_k$ represents a different frequency, ${f_k}$
$$
e_k = e^{-j2\pi \frac{k}{T_s}\frac{nT_s}{N}} =  e^{-j2\pi f_s \frac{k}{N} t_n} \quad \Longrightarrow \quad f_k = k\frac{f_s}{N}.
$$
Just as the signal $x(t)$ is sampled in time, the Fourier transform is sampled in frequency $N$ times, from $0$ to  $\frac{N-1}{N}f_s$ every $\frac{f_s}{N}$ Hz.

<a name="2dfft"></a>

### Appendix: 2D DFT of $M(t)$

Computing the 2D FFT of the $M(t)$ requires considering the mixed signal over all chirps. By the same reasoning presented in the section where I derive the [DFT of](#dft_mixed_signal) $M(t)$, only the portion of the mixed signal containing the phase difference is visible to the DFT; so effectively  
$$
M(t) \approx \cos 2\pi\Delta\varphi.
$$
Substituting $\tau =  \frac{2}{c}(R_0 + v t)$ into the phase difference during the $m$th chirp gives
$$
\begin{align}
\Delta \varphi &= {\sf Slope} \cdot \tau t -  \tau\Big[{\sf Slope}\frac{\tau}{2} + m {\sf B_{sweep}}  - f_c \Big] \\
&= \frac{2v{\sf Slope}}{c^2}(c - v)t^2 + \frac{2}{c^2}({\sf Slope}\cdot cR_0 - mcv{\sf B_{sweep}} -  2{\sf Slope}\cdot R_0v + c f_cv)t - 2\frac{mR_0}{c}{\sf B_{sweep}} \\ &+ \frac{2R_0}{c^2}(cf_c - {\sf Slope}\cdot R_0) \\
&= \frac{2v{\sf Slope}}{c^2}(c - v)t^2 + \frac{2}{c^2}({\sf Slope}\cdot R_0(c - 2v) + c f_cv -mcv{\sf B_{sweep}})t  - 2\frac{mR_0}{c}{\sf B_{sweep}}
+ C_0. \\
\end{align}
$$
[Sympy](#sympy) helped me generate the phase difference expression. To decluttered the expression let $C_0 = \frac{2R_0}{c^2}(cf_c - {\sf Slope}\cdot R_0)$. Noticing that $c$ dominates $v$, the expression for $\Delta \varphi$ can be simplified by letting $c - v \approx c$ and $c - 2v \approx c$; and
$$
\Delta \varphi \approx \frac{2v{\sf Slope}}{c}t^2 + \frac{2}{c}(    
{\sf Slope}\cdot R_0  + f_cv)t - \frac{2}{c}mv{\sf B_{sweep}}\cdot t - 2\frac{mR_0}{c}{\sf B_{sweep}} + C_0.
$$
Because $d_{res} = 1$, ${\sf B_{sweep}} = \frac{c}{2}$ and $\Delta \varphi$ further simplifies to
$$
\begin{align}
\Delta \varphi &\approx \frac{2v{\sf Slope}}{c}t^2 + \frac{2}{c}(    
{\sf Slope}\cdot R_0  + f_cv)t - m\Big[v t + R_0\Big] + C_0.
\end{align}
$$
Now $\Delta \varphi$ can be sampled. 
$$
\begin{align}
\Delta \varphi\big(n,m\big) &= \Delta \varphi\Big(\frac{n{\sf T_{chirp}} }{N_r} + m{\sf T_{chirp}}\Big) \\
&\approx \frac{2v{\sf Slope}}{c}\Big(\frac{n{\sf T_{chirp}}}{N_r} + m{\sf T_{chirp}}\Big)^2 + \frac{2}{c}(    
{\sf Slope}\cdot R_0  + f_cv)\Big(\frac{n{\sf T_{chirp}}}{N_r} + m{\sf T_{chirp}}\Big) \\
& - m\Big[v \Big(\frac{n{\sf T_{chirp}} }{N_r} + m{\sf T_{chirp}}\Big)  + R_0\Big] + C_0\\

&\approx  v{\sf T_{chirp}}\Big(\frac{n}{N_r} + m\Big)^2 + 
(R_0  + \frac{2}{c}f_cv{\sf T_{chirp}})\Big(\frac{n}{N_r} + m\Big) - m{\sf T_{chirp}}v \Big(\frac{n }{N_r} + m\Big)\\ 
 & - m R_0 + C_0\\
&\approx  v{\sf T_{chirp}}\Big(\frac{n}{N_r}\Big)^2 +  \colorbox{orange}{$\cancelto{1}{2}v{\sf T_{chirp}}\frac{nm}{N_r}$} +  \cancel{\colorbox{yellow}{$v{\sf T_{chirp}}m^2$}}  + R_0\frac{n}{N_r} + \cancel{\colorbox{lightblue}{$m R_0$}} \\&+ \frac{2}{c}f_cv{\sf T_{chirp}}\Big(\frac{n}{N_r} + m\Big) \cancel{\colorbox{orange}{$-v{\sf T_{chirp}}\frac{n m}{N_r}$}} \cancel{\colorbox{yellow}{$-v{\sf T_{chirp}}m^2$}} \cancel{\colorbox{lightblue}{$- m  R_0$}} + C_0\\
&\approx  v{\sf T_{chirp}}\Big(\frac{n}{N_r}\Big)^2 + v{\sf T_{chirp}}\frac{nm}{N_r}   + R_0\frac{n}{N_r} + \frac{2}{c}f_cv{\sf T_{chirp}}\frac{n}{N_r} +\frac{2m}{c}f_cv{\sf T_{chirp}} + C_0.\\
\end{align}
$$
Several of the remaining terms can be ignored because they are very small.
$$
\begin{align}
v{\sf T_{chirp}}\Big(\frac{n}{N_r}\Big)^2 + v{\sf T_{chirp}}\frac{nm}{N_r} + \frac{2}{c}f_cv{\sf T_{chirp}}\frac{n}{N_r} &< v{\sf T_{chirp}}\Big[m + 1 + \frac{2}{c}f_c\Big]
< 0.0707. \\
\end{align}
$$
Finally,
$$
\begin{align}
\Delta \varphi\big(n,m\big) 
&\approx R_0\frac{n}{N_r} + \frac{2}{c}f_cv \cdot {m\sf T_{chirp}} + C_0.\\
\end{align}
$$
For $0 \leq k < N_r$ and $0 \leq l < N_d$ the 2D FFT is 
$$
\begin{align}
	X[k,l] &= \sum^{N_d-1}_{m=0}\sum^{N_r-1}_{n=0}x[n,m]e^{-j2\pi kn/N_r}e^{-j2\pi lm/N_d} \\
	       &= \sum^{N_d-1}_{m=0}\Big[\sum^{N_r-1}_{n=0}\cos 2\pi\big(R_0\frac{n}{N_r} + \frac{2}{c}f_cv \cdot {m\sf T_{chirp}} + C_0\big)e^{-j2\pi kn/N_r}\Big]e^{-j2\pi lm/N_d}\\
	       &= \frac{1}{2}e^{j C_0}\sum^{N_r-1}_{n=0}e^{j2\pi(R_0\frac{n}{N_r} )} e^{j2\pi(\frac{2}{c}f_cv \cdot {m\sf T_{chirp}})} e^{-j2\pi kn/N_r}+ \frac{1}{2}e^{-j C_0}\sum^{N_r-1}_{n=0}e^{-j2\pi(R_0\frac{n}{N_r} + \frac{2}{c}f_cv \cdot {m\sf T_{chirp}})}e^{-j2\pi kn/N_r} \\
	       &= \frac{N_r}{2}\sum^{N_d-1}_{m=0}\Big[e^{j C_0} e^{j2\pi\frac{2m}{c}f_cv{\sf T_{chirp}}} \delta(R_0 - k) + e^{-j2\pi\frac{2m}{c}f_cv{\sf T_{chirp}}} e^{-jC_0}\delta(R + k - N_r) \Big]e^{-j2\pi lm/N_d} \\
	       &= \frac{N_r}{2}\Big[e^{j C_0}  \delta(R_0 - k)\sum^{N_d-1}_{m=0}e^{j\frac{2\pi}{N_d}(\frac{2}{c}f_cv{\sf T_{chirp}}N_d - l)m} + e^{-jC_0}\delta(R + k - N_r)\sum^{N_d-1}_{m=0}e^{-j\frac{2\pi}{N_d}(\frac{2}{c}f_cv{\sf T_{chirp}}N_d + l)m} \Big]. \\
\end{align}
$$
Focusing on $k < \frac{N_R}{2}$ the magnitude is
$$
\lvert X[k,l] \rvert = \frac{N_r}{2} \delta(R_0 - k)\Big\lvert\sum^{N_d-1}_{m=0}e^{j\frac{2\pi}{N_d}(\frac{2}{c}f_cv{\sf T_{chirp}}N_d - l)m}\Big\rvert = \frac{N_r}{2} \delta(R_0 - k)\big\lvert g(l) \big\rvert.
$$
Following reasoning similar to that used in [exercise](#exercise) $\lvert g(l) \rvert$ achieves its peak at
$$
\begin{align}
\Big\lvert g(\frac{2}{c}f_cv{\sf T_{chirp}}N_d)\Big\rvert &= \Big\lvert \sum^{N_d-1}_{m=0}\big(e^{j\frac{2\pi}{N_d}(\frac{2}{c}f_cv{\sf T_{chirp}}N_d - l)}\big)^m \Big\rvert = N_d.
\end{align}
$$
While away from $\frac{2}{c}f_cv{\sf T_{chirp}}N_d = 7.2277$,
$$
\lvert g(l) \rvert = \sqrt{\frac{1 - \cos2\pi(\frac{2}{c}f_cv{\sf T_{chirp}}N_d)}{1 - \cos \frac{2\pi}{N_d}(\frac{2}{c}f_cv{\sf T_{chirp}}N_d - l)}} = \frac{0.9277}{\sqrt{1 - \cos\frac{2\pi}{N_d}(7.2277 - l)}}.\\
$$
In the figure below $\lvert g(l) \rvert$ is plotted; it is symmetric about $l=7.2277$ and appears like a very narrow gaussian or a fat Dirac delta centered at $7.2277$. It follows that the maximum of $\lvert X[k,l] \rvert$ occurs at $k= R_0$ and $l=7$. Then solving $\frac{2}{c}f_cv{\sf T_{chirp}}N_d = 7$ for $v$ produces the velocity estimate, $v = 14.5274$ m/s. The estimate is close to the chosen velocity $15$ m/s.

![](/Users/arvind/projects/sensor_fusion_projects/magnitude_of_g.jpg)



##### Sympy Code Generating an Expression for the Sampled Phase Difference

<a name="sympy"></a>

```python
from sympy import linsolve, symbols, Matrix, simplify, expand, diff, poly, solve

#fc = symbols('fc')
S, d, v, t, c, f,R,tau,m,B,T = symbols('S, d, v, t, c, f,R, tau, m, B, T')

phase = expand(f*t + 0.5 * S*(t - m *T)**2)
delta = simplify(phase - phase.subs(t, t-tau))
expand(delta.subs(S*T, B))
q = delta.subs(tau, (2/c)*(d+v*t))
simplify(q.subs(S*T, B).as_poly(t))
```



[1]: https://www.radartutorial.eu/11.coherent/co06.de.html
[2]: https://mathworld.wolfram.com/TrigonometricAdditionFormulas.html
[3]: https://www.amazon.de/Discrete-Time-Signal-Processing-Pearson-International/dp/1292025727
[4]: https://essay.utwente.nl/70986/1/Suleymanov_MA_EWI.pdf
