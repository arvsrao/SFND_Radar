clear all
clc;

%% Radar Specifications 
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frequency of operation = 77GHz
% Max Range = 200m
% Range Resolution = 1 m
% Max Velocity = 100 m/s
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%speed of light = 3e8
%% User Defined Range and Velocity of target
% *%TODO* :
% define the target's initial position and velocity. Note : Velocity
% remains contant.

% target initial position (meters) & velocity (m/s)
d0 = 90;
v0 = 15; % approx. 60 km/h

%Speed of light
c = 3*10^8;

%% FMCW Waveform Generation

% *%TODO* :
    %Design the FMCW waveform by giving the specs of each of its parameters.
    % Calculate the Bandwidth (B), Chirp Time (Tchirp) and Slope (slope) of the FMCW
    % chirp using the requirements above.
    
    % Find the Bsweep of chirp for 1 m resolution
    d_res = 1;
    Bsweep = c / (2 * d_res);
    
    % Calculate the chirp time based on the Radar's Max Range
    R_max = 200;
    Tchirp = (5.5 * 2 *  R_max) / c;
    slope = Bsweep / Tchirp;

%Operating carrier frequency of Radar 
fc= 77e9;             %carrier freq
                                                          
%The number of chirps in one sequence. Its ideal to have 2^ value for the ease of running the FFT
%for Doppler Estimation. 
Nd=128;                   % #of doppler cells OR #of sent periods % number of chirps

%The number of samples on each chirp. 
Nr=1024;                  %for length of time OR # of range cells

% Timestamp for running the displacement scenario for every sample on each
% chirp. The spacing between samples is T_chirp / Nr
t=linspace(0,Nd*Tchirp,Nr*Nd); %total time for samples

%% Signal generation and Moving Target simulation
% Running the radar scenario over the time.

% *%TODO* :
%For each time stamp update the Range of the Target for constant velocity. 

Mix = zeros(Nr, Nd);
C = 2*d0 * ( c*fc - slope *d0 ) /c^2;

for n = 1 : Nr
    for m = 1 : Nd
       % Mix signal based on closed form of M(t) based on periodic FMCW
        Mix(n, m) = cos(2*pi * (v0 * Tchirp * m^2 + d0*n/Nr + fc * v0 * Tchirp * (2/c) * m + C ) );
       %Mix(n, m) = cos(2*pi * (2*v0*Tchirp*n*m/Nr + v0 * Tchirp * m^2 + d0*((n/Nr) + m) + fc * v0 * Tchirp * (2/c) * m + C ) );
    end
end

%% RANGE DOPPLER RESPONSE
% The 2D FFT implementation is already provided here. This will run a 2DFFT
% on the mixed signal (beat signal) output and generate a range doppler
% map.You will implement CFAR on the generated RDM

% Range Doppler Map Generation.

% The output of the 2D FFT is an image that has reponse in the range and
% doppler FFT bins. So, it is important to convert the axis from bin sizes
% to range and doppler based on their Max values.

Mix=reshape(Mix,[Nr, Nd]);

% 2D FFT using the FFT size for both dimensions.
sig_fft2 = fft2(Mix,Nr,Nd);

% Taking just one side of signal from Range dimension.
sig_fft2 = sig_fft2(1:Nr/2,1:Nd);
sig_fft2 = fftshift(sig_fft2);
RDM = abs(sig_fft2);
RDM = 10*log10(RDM);

%use the surf function to plot the output of 2DFFT and to show axis in both
%dimensions
doppler_axis = linspace(-100,100,Nd);
range_axis = linspace(-200,200,Nr/2)*((Nr/2)/400);
figure, surf(doppler_axis,range_axis,RDM);

