function zernike_moments(img, order)
    % Convert the image to double precision
    img = double(img);
    
    % Get the size of the image
    [rows, cols] = size(img);
    
    % Generate the grid
    [X, Y] = meshgrid(1:cols, 1:rows);
    R = sqrt((2*X-cols-1).^2 + (2*Y-rows-1).^2) / rows;
    Theta = atan2((rows-1-2*Y+2), (2*X-cols+1-rows));
    
    % Initialize Zernike moments
    Z = zeros(1, order^2);
    
    % Calculate Zernike moments
    for n = 0:order
        for m = -n:2:n
            v = zeros(size(R));
            for s = 0:(n-abs(m))/2
                c = (-1)^s * factorial(n-s) / (factorial(s) * factorial((n+abs(m))/2 - s) * factorial((n-abs(m))/2 - s));
                v = v + c * R.^(n-2*s);
            end
            Z(n^2 + n + m + 1) = sum(sum(img .* v .* exp(-1i*m*Theta))) * (n + 1) / (pi * rows^2);
        end
    end
end



