
 path = 'C:\Users\rudra\Downloads\Fwd_ input image\1_L.png';
img = imread(path);
grayImg = rgb2gray(img);
imshow(grayImg);

order = 5; 
Z = zernike_moments(img, order);

disp(Z);


