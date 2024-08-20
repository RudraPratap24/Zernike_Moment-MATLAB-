function main_function()
    
 path = 'C:\Users\rudra\Downloads\Fwd_ input image\1_L.png';
 path2 = 'C:\Users\rudra\Downloads\Fwd_ input image\1_R.png';
img = imread(path);
img2 = imread(path2);
grayImg = rgb2gray(img);
grayImg2 = rgb2gray(img2);
%imshow(grayImg);

    function match = compare_images(grayImg, grayImg2, order, threshold)
    
    Z1 = zernike_moments(grayImg, order);
    Z2 = zernike_moments(grayImg2, order);
    
    
    distance = norm(Z1 - Z2);
    
    
    if distance <= threshold
        match = true;
    else
        match = false;
    end
end

 
    function Z = zernike_moments(grayImg, order)
       
    grayImg = double(grayImg);
    
    
    [rows, cols] = size(grayImg);
    
   
    [X, Y] = meshgrid(1:cols, 1:rows);
    R = sqrt((2*X-cols-1).^2 + (2*Y-rows-1).^2) / rows;
    Theta = atan2((rows-1-2*Y+2), (2*X-cols+1-rows));
    
    
    Z = zeros(1, order^2);
    
   
    for n = 0:order
        for m = -n:2:n
            v = zeros(size(R));
            for s = 0:(n-abs(m))/2
                c = (-1)^s * factorial(n-s) / (factorial(s) * factorial((n+abs(m))/2 - s) * factorial((n-abs(m))/2 - s));
                v = v + c * R.^(n-2*s);
            end
            Z(n^2 + n + m + 1) = sum(sum(grayImg .* v .* exp(-1i*m*Theta))) * (n + 1) / (pi * rows^2);
        end
    end
    end
   

  
    order = 3;
    threshold = 0.1;

  Z1 = zernike_moments(grayImg, order);

  %disp(Z1);

match = compare_images(grayImg, grayImg2, order, threshold);


if match
    disp('Images match.');
else
    disp('Images do not match.');
end


    
   
end