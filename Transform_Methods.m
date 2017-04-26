clc;
clear all;
close all;
[fname path] = uigetfile('*.*', 'Enter an Image');
fname = strcat(path,fname);
image = imread(fname);
I = rgb2gray(image);
subplot(1,2,1);
imshow(I,'Border','tight');
title('Original Image');

hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(I), hy, 'replicate');
Ix = imfilter(double(I), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);
subplot(1,2,2);
imshow(gradmag,[]), title('Gradient magnitude (gradmag)');
ScrSize = get(0,'ScreenSize');
set(gcf,'Units','pixels','Position',ScrSize,'Toolbar','none','Menubar','none');

figure;
se = strel('disk', 20);
Io = imopen(I, se);
subplot(1,2,1);
imshow(Io), title('Opening (Io)');
ScrSize = get(0,'ScreenSize');
set(gcf,'Units','pixels','Position',ScrSize,'Toolbar','none','Menubar','none');

Ie = imerode(I, se);
Iobr = imreconstruct(Ie, I);
subplot(1,2,2);
imshow(Iobr), title('Opening-by-reconstruction (Iobr)');
ScrSize = get(0,'ScreenSize');
set(gcf,'Units','pixels','Position',ScrSize,'Toolbar','none','Menubar','none');

Ioc = imclose(Io, se);
figure;
subplot(1,2,1);
imshow(Ioc), title('Opening-closing (Ioc)');
ScrSize = get(0,'ScreenSize');
set(gcf,'Units','pixels','Position',ScrSize,'Toolbar','none','Menubar','none');

Iobrd = imdilate(Iobr, se);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
subplot(1,2,2);
imshow(Iobrcbr), title('Opening-closing by reconstruction (Iobrcbr)');
ScrSize = get(0,'ScreenSize');
set(gcf,'Units','pixels','Position',ScrSize,'Toolbar','none','Menubar','none');

fgm = imregionalmax(Iobrcbr);
figure;
subplot(1,2,1);
imshow(fgm), title('Regional maxima of opening-closing by reconstruction (fgm)');
ScrSize = get(0,'ScreenSize');
set(gcf,'Units','pixels','Position',ScrSize,'Toolbar','none','Menubar','none');

I2 = I;
I2(fgm) = 255;
subplot(1,2,2);
imshow(I2), title('Regional maxima superimposed on original image (I2)');
ScrSize = get(0,'ScreenSize');
set(gcf,'Units','pixels','Position',ScrSize,'Toolbar','none','Menubar','none');

se2 = strel(ones(5,5));
fgm2 = imclose(fgm, se2);
fgm3 = imerode(fgm2, se2);
fgm4 = bwareaopen(fgm3, 20);
I3 = I;
I3(fgm4) = 255;
figure;
subplot(1,2,1);
imshow(I3);
title('Modified regional maxima superimposed on original image (fgm4)');
ScrSize = get(0,'ScreenSize');
set(gcf,'Units','pixels','Position',ScrSize,'Toolbar','none','Menubar','none');

bw = imbinarize(Iobrcbr);
subplot(1,2,2);
imshow(bw), title('Thresholded opening-closing by reconstruction (bw)');
ScrSize = get(0,'ScreenSize');
set(gcf,'Units','pixels','Position',ScrSize,'Toolbar','none','Menubar','none');

D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;
figure;
subplot(1,2,1);
imshow(bgm), title('Watershed ridge lines (bgm)');
ScrSize = get(0,'ScreenSize');
set(gcf,'Units','pixels','Position',ScrSize,'Toolbar','none','Menubar','none');

gradmag2 = imimposemin(gradmag, bgm | fgm4);
L = watershed(gradmag2);

I4 = I;
I4(imdilate(L == 0, ones(3, 3)) | bgm | fgm4) = 255;
subplot(1,2,2);
imshow(I4);
title('Markers and object boundaries superimposed on original image (I4)');
ScrSize = get(0,'ScreenSize');
set(gcf,'Units','pixels','Position',ScrSize,'Toolbar','none','Menubar','none');

Lrgb = label2rgb(L, 'jet', 'w', 'shuffle');
figure
imshow(Lrgb);
title('Colored watershed label matrix (Lrgb)')
ScrSize = get(0,'ScreenSize');
set(gcf,'Units','pixels','Position',ScrSize,'Toolbar','none','Menubar','none');

figure
imshow(I)
hold on
himage = imshow(Lrgb);
himage.AlphaData = 0.3;
title('Lrgb superimposed transparently on original image');
ScrSize = get(0,'ScreenSize');
set(gcf,'Units','pixels','Position',ScrSize,'Toolbar','none','Menubar','none');