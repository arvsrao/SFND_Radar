### Appendix: 2D DFT of $M(t)$

Substituting $\tau =  \frac{2}{c}(R_0 + v t)$ into the phase difference during the $m$th chirp gives
$$
\begin{align}
\Delta \varphi &= {\sf Slope} \cdot \tau t -  \tau\Big[{\sf Slope}\frac{\tau}{2}  - f_c \Big] \\
&= \frac{2v{\sf Slope}}{c^2}(c - v)t^2 + \frac{2}{c^2}({\sf Slope}\cdot cR_0  -  2{\sf Slope}\cdot R_0v + c f_cv)t + \frac{2R_0}{c^2}(cf_c - {\sf Slope}\cdot R_0) \\
&= \frac{2v{\sf Slope}}{c^2}(c - v)t^2 + \frac{2}{c^2}({\sf Slope}\cdot R_0(c - 2v) + c f_cv )t + C_0. \\
\end{align}
$$
To decluttered the expression let $C_0 = \frac{2R_0}{c^2}(cf_c - {\sf Slope}\cdot R_0)$. Since $c$ dominates $v$ take $c - v \approx c$ and $c - 2v \approx c$; then
$$
\Delta \varphi \approx \frac{2v{\sf Slope}}{c}t^2 + \frac{2}{c}(    
{\sf Slope}\cdot R_0  + f_cv)t + C_0.
$$
Because $d_{res} = 1$, ${\sf B_{sweep}} = \frac{c}{2}$ and $\Delta \varphi$ further simplifies to
$$
\begin{align}
\Delta \varphi &\approx \frac{2v{\sf Slope}}{c}t^2 + \frac{2}{c}(    
{\sf Slope}\cdot R_0  + f_cv)t  + C_0.
\end{align}
$$
Now $\Delta \varphi$ can be sampled.
$$
\begin{align}
\Delta \varphi\big(n,m\big) &= \Delta \varphi\Big(\frac{n{\sf T_{chirp}} }{N_r} + m{\sf T_{chirp}}\Big) \\
&\approx \frac{2v{\sf Slope}}{c}\Big(\frac{n{\sf T_{chirp}}}{N_r} + m{\sf T_{chirp}}\Big)^2 + \frac{2}{c}(    
{\sf Slope}\cdot R_0  + f_cv)\Big(\frac{n{\sf T_{chirp}}}{N_r} + m{\sf T_{chirp}}\Big)  + C_0\\
&\approx  v{\sf T_{chirp}}\Big(\frac{n}{N_r} + m\Big)^2 + 
(R_0  + \frac{2}{c}f_cv{\sf T_{chirp}})\Big(\frac{n}{N_r} + m\Big)  + C_0\\
&\approx  v{\sf T_{chirp}}\Big(\frac{n}{N_r}\Big)^2 +  \colorbox{orange}{$2v{\sf T_{chirp}}\frac{nm}{N_r}$} + \colorbox{yellow}{$v{\sf T_{chirp}}m^2$}  + R_0\frac{n}{N_r} + \colorbox{lightblue}{$m R_0$} \\&+ \frac{2}{c}f_cv{\sf T_{chirp}}\Big(\frac{n}{N_r} + m\Big) + C_0\\
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
&\approx  \colorbox{orange}{$2v{\sf T_{chirp}}\frac{nm}{N_r}$} + \colorbox{yellow}{$v{\sf T_{chirp}}m^2$}  + R_0\frac{n}{N_r} + \frac{2}{c}f_cv{\sf T_{chirp}}m + C_0.\\
\end{align}
$$
Following reasoning similar to that used in [lemma](#lemma)
$$
\begin{align}
\Big\lvert g(l)\Big\rvert &= \Big\lvert \sum^{N_d-1}_{m=0}\big(e^{j\frac{2\pi}{N_d}(\frac{2}{c}f_cv{\sf T_{chirp}}N_d - l)}\big)^m \Big\rvert  \approx N_d\delta\big(\frac{2}{c}f_cv{\sf T_{chirp}}N_d - l\big) 
\end{align}
$$



$$
\begin{align}
X[l] &= \sum^{N_d-1}_{m=0}e^{j\frac{2\pi}{N_d}(\alpha - l)m} \\
     &= \sum^{N_d-1}_{m=0}e^{j\frac{2\pi}{N_d}m\alpha} e^{-j\frac{2\pi}{N_d}lm}\\
     &= \mathcal{F}(e^{j\frac{2\pi}{N_d}m\alpha})
\end{align}
$$



$$
\begin{align}
X[l] &= \sum^{\infty}_{m=-\infty}e^{j (\alpha_0 - \alpha)m} \\
     &= \sum^{\infty}_{m=-\infty}e^{-j (\alpha - \alpha_0)m} \\
     &= \sum^{0}_{m=-\infty}e^{-j (\alpha - \alpha_0)m} + \sum^{\infty}_{m=0}e^{-j (\alpha - \alpha_0)m} \\
     &= \lim_{N \rightarrow \infty} \frac{e^{j (\alpha - \alpha_0)N} - 1}{e^{j (\alpha - \alpha_0)} - 1} + \lim_{N \rightarrow \infty} \frac{e^{-j (\alpha - \alpha_0)N} - 1}{e^{-j (\alpha - \alpha_0)} - 1}
\end{align}
$$
