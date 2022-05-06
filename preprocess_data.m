function img = preprocess(filename)
%read an image from a file
img = imread(filename);
%alter an image from RGB to grayscale
img_gray = rgb2gray(img);
%set a threshold
level = graythresh(img_gray);
img = im2bw(img, level);

img = imresize(img,[128 128]);
imshow(img);
img = reshape(img, [1, 16384]);

