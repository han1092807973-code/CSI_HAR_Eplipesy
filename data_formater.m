% --- Setup and Load Data ---
clear all; close all; clc;

% Add the path to the linux-80211n-csitool-supplementary/matlab directory
matlab_tool_path = '/home/mingzhe/linux-80211n-csitool-supplementary/matlab';
% Specify the CSI data file to read
csi_filename = '10_31/test_4.dat';
%Specify the output file
output_filename = 'mat_file/10_31_4.mat';
addpath(matlab_tool_path);


% Read the CSI trace file
fprintf('Reading CSI data from %s...\n', csi_filename);
try
    csi_trace = read_bf_file(csi_filename);
catch
    error('Failed to execute read_bf_file. Make sure the path is correct: %s', matlab_tool_path);
end

if isempty(csi_trace)
    error('Failed to read CSI data. Is "%s" in the current directory?', csi_filename);
end
fprintf('Successfully read %d packets.\n', length(csi_trace));


% Get the total number of packets (e.g., 60)

num_packets = length(csi_trace);

% Get the dimensions of the CSI matrix from the first packet
% We assume all packets have the same dimensions (2x2x30)
try
    first_csi = csi_trace{1}.csi;
    dims = size(first_csi); % Should be [2, 2, 30]
catch
    error('Could not read csi_trace{1}.csi. Make sure csi_trace is loaded and not empty.');
end

% Calculate the total number of elements for the flattened vector
% e.g., 2 * 2 * 30 = 120
num_elements = numel(first_csi); % numel() is a robust way to get 120

% --- Pre-allocate the final matrix for speed ---
% Create an empty 60x120 matrix filled with zeros
csi_matrix_output = zeros(num_packets, num_elements);

% --- Loop through each packet and fill the matrix ---
for i = 1:num_packets
    % Check if the cell is empty or the csi field is missing
    if isempty(csi_trace{i}) || ~isfield(csi_trace{i}, 'csi')
        fprintf('Warning: Skipping empty or invalid packet at index %d\n', i);
        % This row will be left as all zeros
        continue;
    end
    
    % Get the [2x2x30] CSI matrix
    csi_data = csi_trace{i}.csi;
    
    % --- Flatten the matrix and insert it into the output ---
    % reshape(csi_data, 1, []) turns the 3D matrix into a 1x120 row vector
    % This is the fastest way to assign it to the i-th row.
    csi_matrix_output(i, :) = reshape(csi_data, 1, []);
end

% --- Save the final 60x120 matrix to a .mat file ---

save(output_filename, 'csi_matrix_output');

% Display a confirmation message
fprintf('Successfully processed %d packets.\n', num_packets);
fprintf('Saved 60x120 matrix to %s\n', output_filename);
