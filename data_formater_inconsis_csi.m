function data_formater_inconsis_csi(input_path, output_path)
    % --- Setup and Load Data ---
    % NOTE: 'clear all' removed to preserve function arguments
    
    % Add the path to the linux-80211n-csitool-supplementary/matlab directory
    matlab_tool_path = '/home/mingzhe/linux-80211n-csitool-supplementary/matlab';
    
    % Use arguments passed from Master Script
    csi_filename = input_path;
    output_filename = output_path;
    
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
        error('Failed to read CSI data. Is "%s" correct?', csi_filename);
    end
    fprintf('Successfully read %d packets.\n', length(csi_trace));

    % Get the total number of packets
    num_packets = length(csi_trace);
    num_elements = prod(expected_dims);

    % --- Pre-allocate the final matrix for speed ---
    csi_matrix_output = zeros(num_packets, num_elements);

    % Counter for valid packets
    num_valid_packets = 0;

    % --- Loop through each packet and fill the matrix ---
    for i = 1:num_packets
        if isempty(csi_trace{i}) || ~isfield(csi_trace{i}, 'csi')
            % fprintf('Warning: Skipping empty or invalid packet at index %d\n', i);
            continue;
        end
        
        csi_data = csi_trace{i}.csi;
        
        if ~isequal(size(csi_data), expected_dims)
            % fprintf('Warning: Skipping packet at index %d due to unexpected dimensions\n', i);
            continue;
        end
        
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

    fprintf('Successfully processed %d packets.\n', num_valid_packets);
    fprintf('Saved matrix to %s\n', output_filename);
end