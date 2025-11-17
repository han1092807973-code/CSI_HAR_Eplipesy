function run_csi_pipeline(filename_arg)
    % RUN_CSI_PIPELINE Master script to process CSI data
    % Usage: run_csi_pipeline('ep_1.dat')
    %
    % This script coordinates:
    % 1. data_formater_inconsis_csi.m (extracts dat -> mat)
    % 2. main.m (generates spectrogram from mat)

    % --- CONFIGURATION ---
    % Directory containing the raw .dat files (assuming they are in '11_14' subfolder based on your code)
    base_data_dir = '/home/mingzhe/data_collection/11_14/'; 
    
    % Directory where .mat files should be saved
    output_mat_dir = '/home/mingzhe/data_collection/mat_file/';
    
    % Path to the folder containing 'data_formater_inconsis_csi.m'
    path_to_formatter = '/home/mingzhe/data_collection';
    
    % Path to the folder containing 'main.m'
    path_to_main = '/home/mingzhe/Downloads/WiFiGaitDisorder_scripts-20251023T153247Z-1-001/WiFiGaitDisorder_scripts/Scripts';
    % ---------------------

    % 1. Setup Paths
    addpath(path_to_formatter);
    addpath(path_to_main);

    % 2. Construct Full File Paths
    % Input: /home/mingzhe/data_collection/11_14/ep_1.dat
    full_dat_path = fullfile(base_data_dir, filename_arg); 
    
    % Output: /home/mingzhe/data_collection/mat_file/11_14_ep_1.mat
    % We create a unique name for the mat file based on the input
    [~, name, ~] = fileparts(filename_arg);
    mat_filename = strcat('11_14_', name, '.mat'); 
    full_mat_path = fullfile(output_mat_dir, mat_filename);

    % 3. Run Step 1: Formatter
    fprintf('--- Step 1: Formatting %s ---\n', filename_arg);
    try
        data_formater_inconsis_csi(full_dat_path, full_mat_path);
    catch ME
        fprintf('Error in formatting step: %s\n', ME.message);
        return;
    end

    % 4. Run Step 2: Main Processing
    fprintf('--- Step 2: Running Spectrogram Analysis ---\n');
    try
        main(full_mat_path);
    catch ME
        fprintf('Error in main analysis step: %s\n', ME.message);
        return;
    end
    
    fprintf('--- Pipeline Complete ---\n');
end