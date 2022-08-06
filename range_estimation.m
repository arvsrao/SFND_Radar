% observed beat frequencies in MHz
beat_freqs = [0.0 1.1 13 24]*1e6;

% Radar maximum range 300 meters
R_max = 300; 

% Speed of light
c = 3*10^8;

% TODO : Find the Bsweep of chirp for 1 m resolution
d_res = 1;
Bsweep = c / (2 * d_res);

% TODO : Calculate the chirp time based on the Radar's Max Range
T_chirp = (5.5 * 2 *  R_max) / c;

% TODO : define the frequency shifts 
calculated_range = c * T_chirp * beat_freqs / (2 * Bsweep);

% Display the calculated range
disp(calculated_range);