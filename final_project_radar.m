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
r_t = d0 + v0 * t;
td  = 2 * r_t / c;
tau = t - td; % apply time delay

% create a step function that clamps the frequency to the sweep bandwidth; 
% otherwise the frequency is not periodic. Create also the transmitted and
% receive signals.
transmit_t = t - Tchirp * floor(t/Tchirp);
receive_t  = tau - Tchirp * floor(tau/Tchirp);

A = 2; % amplitude
Tx = A*cos(2*pi * (fc * t + (0.5*slope) * t.*t));
Rx = A*cos(2*pi * (fc * tau + (0.5*slope) * tau.*tau));

%Tpx = A*cos(2*pi * (fc * t + (0.5*slope) * transmit_t.*transmit_t));
%Rpx = A*cos(2*pi * (fc * tau + (0.5*slope) * receive_t.*receive_t));

% *%TODO* :
%Now by mixing the Transmit and Receive generate the beat signal
%This is done by element wise matrix multiplication of Transmit and
%Receiver Signal
Mix = Tx.*Rx;
%Mixp = Tpx.*Rpx;


%% RANGE MEASUREMENT

 % *%TODO* :
%reshape the vector into Nr*Nd array. Nr and Nd here would also define the size of
%Range and Doppler FFT respectively.
Mix=reshape(Mix,[Nr, Nd]);

% *%TODO* :
%run the FFT on the beat signal along the range bins dimension (Nr) and
%normalize.
% Take the absolute value of FFT output
beatFreqs = abs(fft(Mix))/Nr;

% *%TODO* :
% Output of FFT is double sided signal, but we are interested in only one side of the spectrum.
% Hence we throw out half of the samples.

% Plotting
% plotting the range
figure ('Name','Range from First FFT')

% *%TODO* :
% plot FFT output 
plot(beatFreqs(1:Nr/2+1,1))
xlabel('Range (meters)')
axis ([0 200 0 1.15]);


%% RANGE DOPPLER RESPONSE
% The 2D FFT implementation is already provided here. This will run a 2DFFT
% on the mixed signal (beat signal) output and generate a range doppler
% map.You will implement CFAR on the generated RDM

% Range Doppler Map Generation.

% The output of the 2D FFT is an image that has reponse in the range and
% doppler FFT bins. So, it is important to convert the axis from bin sizes
% to range and doppler based on their Max values.

%Mix=reshape(Mix,[Nr, Nd]);

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

%% CFAR implementation

%Slide Window through the complete Range Doppler Map

% *%TODO* :
%Select the number of Training Cells in both the dimensions.
Tr = 12;
Td = 12;

% *%TODO* :
%Select the number of Guard Cells in both dimensions around the Cell under 
%test (CUT) for accurate estimation
Gr = 7;
Gd = 3;

% *%TODO* :
% offset the threshold by SNR value in dB
offset = 6;

% *%TODO* :
%Create a vector to store noise_level for each iteration on training cells
noise_level = zeros(1,1);


% *%TODO* :
%design a loop such that it slides the CUT across range doppler map by
%giving margins at the edges for Training and Guard Cells.
%For every iteration sum the signal level within all the training
%cells. To sum convert the value from logarithmic to linear using db2pow
%function. Average the summed values for all of the training
%cells used. After averaging convert it back to logarithimic using pow2db.
%Further add the offset to it to determine the threshold. Next, compare the
%signal under CUT with this threshold. If the CUT level > threshold assign
%it a value of 1, else equate it to 0.


% Use RDM[x,y] as the matrix from the output of 2D FFT for implementing
% CFAR


% allocated space for an output buffer
CFAR_BUFFER = zeros(size(RDM));
numCells = (2*Gr + 2*Tr + 1) * (2*Gd + 2*Td + 1) - (2*Gr + 1) * (2*Gd + 1);
[N, M] = size(RDM);

for rangeIdx = 1 + Gr + Tr : N - (Gr + Tr)
    for dopplerIdx = 1 + Gd + Td : M - (Gd + Td)
        CUT = RDM(rangeIdx, dopplerIdx);

%         Alternative approach to summing the threshold. Instead of looping use matlab
%         semantics to sum.
%
%         alternate = sum(RDM(rangeIdx - Gr - Tr : rangeIdx - Gr - 1, dopplerIdx - Gd - Td : dopplerIdx + Gd + Td), "all");
%         alternate = alternate + sum(RDM(rangeIdx + Gr + 1: rangeIdx + Gr + Tr, dopplerIdx - Gd - Td : dopplerIdx + Gd + Td), "all");
%         alternate = alternate + sum(RDM(rangeIdx - Gr : rangeIdx + Gr, dopplerIdx - Gd - Td : dopplerIdx - Gd - 1), "all");
%         alternate = alternate + sum(RDM(rangeIdx - Gr : rangeIdx + Gr, dopplerIdx + Gd + 1 : dopplerIdx + Gd + Td), "all");
       
        threshold = 0;
        for idx = rangeIdx - (Gr + Tr) : rangeIdx + Gr + Tr
            for idy = dopplerIdx - (Gd + Td) : dopplerIdx + Gd + Td
                if (abs(idx - rangeIdx) > Gr || abs(idy - dopplerIdx) > Gd) 
                    threshold = threshold + db2pow(RDM(idx,idy));
                end
            end
        end

%         assert(abs(threshold - alternate) < 1e-5, '%f  %f %d %d', alternate, threshold, rangeIdx , dopplerIdx);
        CFAR_BUFFER(rangeIdx, dopplerIdx) = int8(CUT > offset + pow2db(threshold/numCells)); 
    end
end


% *%TODO* :
% The process above will generate a thresholded block, which is smaller 
%than the Range Doppler Map as the CUT cannot be located at the edges of
%matrix. Hence,few cells will not be thresholded. To keep the map size same
% set those values to 0. 
 


% *%TODO* :
%display the CFAR output using the Surf function like we did for Range
%Doppler Response output.
figure,surf(doppler_axis,range_axis,CFAR_BUFFER);
colorbar;

 