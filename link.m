function link()
    img = imread('liver tumor.jpg');
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    kernel_size = 5; 
    filtered_img = fasi_median_filter(img, kernel_size);
    threshold_value = 127;
    segmented_img = segment_image(filtered_img, threshold_value);
    butterworth_img = butterworth_filter(segmented_img, 30);
    darkened_img = darken_edges(img, butterworth_img, 0.5);
    figure;
    subplot(1, 1, 1), imshow(darkened_img), title('Darkened Edges');
end

function filtered_img = fasi_median_filter(img, kernel_size)
    filtered_img = medfilt2(img, [kernel_size kernel_size]);
end

function segmented_img = segment_image(img, threshold)
    segmented_img = img > threshold;
    segmented_img = uint8(segmented_img) * 255;
end

function output_img = butterworth_filter(input_img, cutoff_freq)
    [rows, cols] = size(input_img);
    [x, y] = meshgrid(1:cols, 1:rows);
    center_x = ceil(cols / 2);
    center_y = ceil(rows / 2);
    distance = sqrt((x - center_x).^2 + (y - center_y).^2);
    n = 2;
    H = 1 ./ (1 + (distance ./ cutoff_freq).^(2 * n));
    fft_img = fft2(double(input_img));
    filtered_fft = fft_img .* H;
    output_img = ifft2(filtered_fft);
    output_img = abs(output_img);
    output_img = uint8(output_img / max(output_img(:)) * 255);
end

function darkened_img = darken_edges(original_img, edge_img, factor)
    edge_mask = edge_img > 0;
    darkened_img = original_img;
    for i = 1:size(original_img, 1)
        for j = 1:size(original_img, 2)
            if edge_mask(i, j)
                darkened_img(i, j) = max(0, original_img(i, j) - factor * 255);
            end
        end
    end
end