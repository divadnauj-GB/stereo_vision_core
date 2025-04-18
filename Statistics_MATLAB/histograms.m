%                                   CALCULATION OF ACCURACY, PSNR and SNR
% READ GROUND-TRUTH IMAGE
GT  = imread("D:/MASTER/Thesis/IMAGE_DATA/tsukuba/truedisp.row3.col3.pgm");
cropped_GT = GT(19:end-18, 19:end-18, :);
[rows, cols, ~] = size(cropped_GT);

max_gt = double(max(max(cropped_GT)));
min_gt = double(min(min(cropped_GT)));

% DISPARITY MAP IMAGES NAMES
im_uniform      = "DM_tsukuba_uniform_v2.png";
im_nonredundant = "DM_tsukuba_nonredundant_v2.png";
im_full         = "DM_tsukuba_full_v2.png";
im_16point      = "DM_tsukuba_16point_v2.png";
im_12point      = "DM_tsukuba_12point_v2.png";
im_8point       = "DM_tsukuba_8point_v2.png";
im_4point       = "DM_tsukuba_4point_v2.png";
im_2point       = "DM_tsukuba_2point_v2.png";
im_1point       = "DM_tsukuba_1point_v2.png";
% PATH
path = 'D:/MASTER/Thesis/IMAGE_RESULTS/FAULT_FREE/VHDL_7x7_Window/TSUKUBA';
% IMAGE NAMES VECTOR
im_names = [im_uniform,im_nonredundant,im_full,im_16point,im_12point,im_8point,im_4point,im_2point,im_1point];

figure;
set(gcf, 'Position', [100, 100, 1600, 1000]); % Geniþliði artýrýlmýþ figure
labels = 'abcdefghi'; % Harf etiketi için

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
  
    % Subtruct matrixes and take absolute values of the elements
    sub_matrix =   double(cropped_GT) - double(scaled_image);
    sub_matrix_abs = abs(sub_matrix);
    
    % Plot histogram in a subplot
    nexttile;
    histogram(sub_matrix_abs, 'BinWidth', 1);
    xlim([0 90]); % X ekseni limiti (gerekirse deðiþtir)
    
    % Dikey çizgiyi x = 70 konumuna ekle
    hold on;
    yLimits = ylim; % Y ekseni limitlerini al
    plot([70 70], yLimits, 'r--', 'LineWidth', 1.5); % Kýrmýzý kesikli çizgi
    hold off;

    % Y ekseni etiketini ekle
    ylabel('Pixel Count');

    % Harf etiketini ekle
    text(0.5, -0.15, labels(i), 'Units', 'normalized', 'FontSize', 14, ...
         'FontWeight', 'bold', 'HorizontalAlignment', 'center');
end
%sgtitle('Histograms of Absolute Differences'); % Overall title
% fclose(fileID);
