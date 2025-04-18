%                                   CALCULATION OF ACCURACY, PSNR and SNR
% READ GROUND-TRUTH IMAGE
GT  = imread("D:/MASTER/Thesis/IMAGE_DATA/teddy/disp2.png");
cropped_GT = GT(19:end-18, 19:end-18, :);
[rows, cols, ~] = size(cropped_GT);

max_gt = double(max(max(cropped_GT)));
min_gt = double(min(min(cropped_GT)));

% DISPARITY MAP IMAGES NAMES
im_uniform      = "DM_teddy_uniform_v2.png";
im_nonredundant = "DM_teddy_nonredundant_v2.png";
im_full         = "DM_teddy_full_v2.png";
im_16point      = "DM_teddy_16point_v2.png";
im_12point      = "DM_teddy_12point_v2.png";
im_8point       = "DM_teddy_8point_v2.png";
im_4point       = "DM_teddy_4point_v2.png";
im_2point       = "DM_teddy_2point_v2.png";
im_1point       = "DM_teddy_1point_v2.png";
% PATH
path = 'D:/MASTER/Thesis/IMAGE_RESULTS/FAULT_FREE/VHDL_7x7_Window/TEDDY';
% IMAGE NAMES VECTOR
im_names = [im_uniform,im_nonredundant,im_full,im_16point,im_12point,im_8point,im_4point,im_2point,im_1point];

% OPEN TXT FILE
 fileID = fopen('accuracies_teddy_7x7_window.txt', 'w');
 if fileID == -1
     error('Error: Unable to open file for writing.');
 end
 fprintf(fileID, 'Accuracies for teddy image for 7x7 Window\n\n');
for i = 1:numel(im_names)
    im_name       = im_names{i};
    im_path       = fullfile(path, im_name);
    disparity_map = imread(im_path);

    cropped_DM = disparity_map(19:end-18, 19:end-18, :);
    gray_disparity_map = rgb2gray(cropped_DM);
    
    max_dm = double(max(max(rgb2gray(cropped_DM)))); 
    min_dm = double(min(min(rgb2gray(cropped_DM))));
    % Scale the image to the new range [80, 224]
    scaled_image = (double(gray_disparity_map) - min_dm) * ((max_gt - min_gt) / (max_dm - min_dm)) + min_gt;

    [peaksnr, snr] = psnr(uint8(scaled_image), cropped_GT);
    % SET THRESHOLD ("1" was used in the article)
    threshold = 42;  
    % Subtruct matrixes and take absolute values of the elements
    sub_matrix =   double(cropped_GT) - double(scaled_image);
    sub_matrix_abs = abs(sub_matrix);
    
   % figure;
   % histogram(sub_matrix_abs);
    % Find the elements greater than threshold
    temp = sub_matrix_abs( sub_matrix_abs > 1);  % v0
    pixelCount = sum(sub_matrix_abs(:) > threshold);     % v1
    % Sum them up
    result = sum(temp(:));
    % Percentage of bad matching pixels
    N = rows*cols;    % total number of pixels
    %percentage = result/N;   %v0
    percentage = 100*pixelCount/double(N);
    % Accuracy: 100 - percentage:
    accuracy_result = 100 - percentage;
    
     fprintf(fileID, 'Accuracy, PSNR and SNR of %s: %.2f, %.2f, %.2f\n', ...
         im_names{i}, round(accuracy_result,2), round(peaksnr,2), round(snr,2));
end
 fclose(fileID);
