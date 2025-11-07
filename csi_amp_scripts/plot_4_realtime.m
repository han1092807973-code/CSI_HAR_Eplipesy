% --- Step 0: Load CSI Data File ---
filepath = '/home/mingzhe/data_collection/10_31/test_3.dat';
csi_trace = read_bf_file(filepath); % Correct function name

% --- Y-Axis Control Settings ---
USE_FIXED_Y_AXIS = true; 
FIXED_Y_MIN = 0;   
FIXED_Y_MAX = 80;  
% ------------------------------------

% --- Step 1: Set Parameters and EXTRACT Data ---
TARGET_S = 30; % Subcarriers (fixed at 30)

num_packets = length(csi_trace);

% Pre-allocate matrix for speed
all_stream1_amps = nan(num_packets, TARGET_S);
timestamps = nan(num_packets, 1); % <-- CHANGED: We now store timestamps
num_valid_packets = 0;

fprintf('Extracting Stream (1,1) and Timestamps from %d packets...\n', num_packets);

for i = 1:num_packets
    if isempty(csi_trace{i})
        continue;
    end
    csi_entry = csi_trace{i};
    if ~isfield(csi_entry, 'csi') || ~isfield(csi_entry, 'timestamp_low')
        continue; 
    end
    
    try
        stream1_data = squeeze(csi_entry.csi(1, 1, :))';
        
        if length(stream1_data) == TARGET_S
            num_valid_packets = num_valid_packets + 1;
            all_stream1_amps(num_valid_packets, :) = abs(stream1_data);
            timestamps(num_valid_packets) = csi_entry.timestamp_low; % <-- NEW: Store the timestamp
        end
    catch
        continue;
    end
end

% Trim the matrices
all_stream1_amps = all_stream1_amps(1:num_valid_packets, :);
timestamps = timestamps(1:num_valid_packets);

if num_valid_packets < 50 
    error('Found only %d valid packets. Check the data file.', num_valid_packets);
else
    fprintf('Extraction complete. Found %d valid packets.\n', num_valid_packets);
end

% --- Step 2: Calculate Averaged Amplitude & Create Time Axis ---
avg_amplitudes = mean(all_stream1_amps, 2); % Size (M, 1)

% --- NEW: Create Time Axis in Seconds ---
% Convert from microseconds to seconds
% Subtract the first timestamp to start the axis at 0
time_axis_seconds = (timestamps - timestamps(1)) / 1e6; % 1e6 = 1,000,000

% =========================================================
%  Plot 1: RAW Averaged Amplitude (vs. Time in Seconds)
% =========================================================
figure; 
plot(time_axis_seconds, avg_amplitudes); % <-- CHANGED X-AXIS
title('Plot 1: RAW Averaged Amplitude (Stream 1,1)');
xlabel('Time (seconds)'); % <-- CHANGED LABEL
ylabel('Average CSI Amplitude');
grid on;
xlim([0, time_axis_seconds(end)]); % <-- CHANGED XLIM
legend('Raw Noisy Signal (Stream 1,1)');

if USE_FIXED_Y_AXIS
    ylim([FIXED_Y_MIN, FIXED_Y_MAX]);
    fprintf('Applied fixed Y-axis [%.2f, %.2f] to Plot 1.\n', FIXED_Y_MIN, FIXED_Y_MAX);
end

% =========================================================
%  Plot 2: Low-Pass Filter (vs. Time in Seconds)
% =========================================================
k_smooth = 20; 
smoothed_amplitudes = movmean(avg_amplitudes, k_smooth);

figure;
plot(time_axis_seconds, smoothed_amplitudes); % <-- CHANGED X-AXIS
title('Plot 2: Low-Pass Filter (Smoothed Stream 1,1)');
xlabel('Time (seconds)'); % <-- CHANGED LABEL
ylabel('Smoothed CSI Amplitude');
grid on;
xlim([0, time_axis_seconds(end)]); % <-- CHANGED XLIM
legend(sprintf('Smoothed Signal (k=%d)', k_smooth));

if USE_FIXED_Y_AXIS
    ylim([FIXED_Y_MIN, FIXED_Y_MAX]);
    fprintf('Applied fixed Y-axis [%.2f, %.2f] to Plot 2.\n', FIXED_Y_MIN, FIXED_Y_MAX);
end