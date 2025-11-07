% --- Setup and Load Data ---
clear all; close all; clc;
% --- Step 0: Load CSI Data File ---
filepath = '/home/mingzhe/data_collection/10_27/hand_1.dat';
csi_trace = read_bf_file(filepath); % Correct function name

% --- Y-Axis Control Settings ---
USE_FIXED_Y_AXIS = true; 
FIXED_Y_MIN = 0;   
FIXED_Y_MAX = 80;  
% ------------------------------------

% --- Step 1: Set Parameters and EXTRACT Data ---
TARGET_S = 30; % Subcarriers (fixed at 30)

num_packets = length(csi_trace);

% Pre-allocate matrix for speed. We will store (M, 30) amplitudes
% M is the number of valid packets we find
all_stream1_amps = nan(num_packets, TARGET_S);
packet_indices = nan(num_packets, 1);
num_valid_packets = 0;

fprintf('Extracting Stream (1,1) from %d packets...\n', num_packets);

for i = 1:num_packets
    % Check for valid csi_entry and 'csi' field
    if isempty(csi_trace{i})
        continue;
    end
    csi_entry = csi_trace{i};
    if ~isfield(csi_entry, 'csi')
        continue; 
    end
    
    % --- THIS IS THE KEY CHANGE ---
    % We no longer filter by (R, T). We just TRY to extract stream (1,1).
    % This works for (1,2,30), (2,2,30), (3,3,30), etc.
    try
        % squeeze() turns (1, 1, 30) into (30,)
        % ' transposes it into a row vector (1, 30)
        stream1_data = squeeze(csi_entry.csi(1, 1, :))';
        
        % Check if squeeze worked and gave us 30 subcarriers
        if length(stream1_data) == TARGET_S
            num_valid_packets = num_valid_packets + 1;
            all_stream1_amps(num_valid_packets, :) = abs(stream1_data); % Store amplitudes
            packet_indices(num_valid_packets) = i;
        end
    catch
        % This 'catch' block will skip any packet that is empty 
        % or doesn't have a csi(1, 1, :) (e.g., [0x0x0])
        continue;
    end
end

% Trim the matrices to the actual number of valid packets
all_stream1_amps = all_stream1_amps(1:num_valid_packets, :);
packet_indices = packet_indices(1:num_valid_packets);

if num_valid_packets < 50 
    error('Found only %d valid packets. Check the data file.', num_valid_packets);
else
    fprintf('Extraction complete. Found %d valid packets.\n', num_valid_packets);
end
% 'all_stream1_amps' is now a unified (M x 30) matrix

% --- Step 2: Calculate Averaged Amplitude ---
% We now average across the 30 subcarriers (dimension 2)
avg_amplitudes = mean(all_stream1_amps, 2); % Size (M, 1)


% =========================================================
%  Plot 1: RAW Averaged Amplitude (from Stream 1,1)
% =========================================================
figure; 
plot(packet_indices, avg_amplitudes);
title('Plot 1: RAW Averaged Amplitude (Stream 1,1)');
xlabel('Original Packet Index (Time)');
ylabel('Average CSI Amplitude');
grid on;
xlim([0, num_packets]);
legend('Raw Noisy Signal (Stream 1,1)');

if USE_FIXED_Y_AXIS
    ylim([FIXED_Y_MIN, FIXED_Y_MAX]);
    fprintf('Applied fixed Y-axis [%.2f, %.2f] to Plot 1.\n', FIXED_Y_MIN, FIXED_Y_MAX);
end

% =========================================================
%  Plot 2: Low-Pass Filter (Smoothed Amplitude)
% =========================================================
k_smooth = 20; 
smoothed_amplitudes = movmean(avg_amplitudes, k_smooth);

figure;
plot(packet_indices, smoothed_amplitudes);
title('Plot 2: Low-Pass Filter (Smoothed Stream 1,1)');
xlabel('Original Packet Index (Time)');
ylabel('Smoothed CSI Amplitude');
grid on;
xlim([0, num_packets]);
legend(sprintf('Smoothed Signal (k=%d)', k_smooth));

if USE_FIXED_Y_AXIS
    ylim([FIXED_Y_MIN, FIXED_Y_MAX]);
    fprintf('Applied fixed Y-axis [%.2f, %.2f] to Plot 2.\n', FIXED_Y_MIN, FIXED_Y_MAX);
end