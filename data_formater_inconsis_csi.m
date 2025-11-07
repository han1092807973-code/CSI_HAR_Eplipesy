% --- Setup and Load Data ---
clear all; close all; clc;

% Add the path to the linux-80211n-csitool-supplementary/matlab directory
matlab_tool_path = '/home/mingzhe/linux-80211n-csitool-supplementary/matlab';
% Specify the CSI data file to read
csi_filename = '11_4/walk.dat';
%Specify the output file
output_filename = 'mat_file/11_4_walk.mat';
% Define the expected CSI dimensions (2x2x30)
expected_dims = [2, 2, 30];
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


% Get the total number of packets
num_packets = length(csi_trace);

num_elements = prod(expected_dims);

% --- Pre-allocate the final matrix for speed ---
% Create an empty matrix filled with zeros for the valid packets
csi_matrix_output = zeros(num_packets, num_elements);

% Counter for valid packets
num_valid_packets = 0;

% --- Loop through each packet and fill the matrix ---
for i = 1:num_packets
    % Check if the cell is empty or the csi field is missing
    if isempty(csi_trace{i}) || ~isfield(csi_trace{i}, 'csi')
        fprintf('Warning: Skipping empty or invalid packet at index %d\n', i);
        % This row will be left as all zeros
        continue;
    end
    
    % Get the CSI matrix
    csi_data = csi_trace{i}.csi;
    
    % Skip packets that do not match the expected dimensions
    if ~isequal(size(csi_data), expected_dims)
        fprintf('Warning: Skipping packet at index %d due to unexpected dimensions %s\n', i, mat2str(size(csi_data)));
        continue;
    end
    
    % --- Flatten the matrix and insert it into the output ---
    % reshape(csi_data, 1, []) turns the 3D matrix into a row vector
    num_valid_packets = num_valid_packets + 1;
    csi_matrix_output(num_valid_packets, :) = reshape(csi_data, 1, []);
end

% Trim the matrix to include only valid packets
csi_matrix_output = csi_matrix_output(1:num_valid_packets, :);

if num_valid_packets == 0
    error('No CSI packets with dimensions %s were found in the trace.', mat2str(expected_dims));
end

% --- Save the final matrix to a .mat file ---

save(output_filename, 'csi_matrix_output');

% Display a confirmation message
fprintf('Successfully processed %d packets with dimensions %s.\n', num_valid_packets, mat2str(expected_dims));
fprintf('Saved %dx%d matrix to %s\n', num_valid_packets, num_elements, output_filename);
