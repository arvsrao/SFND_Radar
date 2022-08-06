%Speed of light
c = 3*10^8;


% Find the Bsweep of chirp for 1 m resolution
d_res = 1;
Bsweep = c / (2 * d_res);

% Calculate the chirp time based on the Radar's Max Range
R_max = 200;
Tchirp = (5.5 * 2 *  R_max) / c;