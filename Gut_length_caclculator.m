%% --- clean previous data ---
clearvars -except i data k N peri; clc; 

%% --- read images into a data-structre  ---
% ask the pictures path from the user, save it into "selectedPath" variable
selectedPath = uigetdir('.');
% take the pictures (.jpg suffix) from selectedPath, save it into "dirOutput" struct
cd(selectedPath);
dirOutput = dir('Composite548B3.png');
% extract data for the variables above, from the fields in "dirOutput" struct
fileNames = {dirOutput.name}';
% read the data of the first picture into the variable "Pic1"
Pic1 = imread(fileNames{1});
% preallocate array - create zeros 4-D uint8 variable, with the size of Pic1 * numFrames
imageSeries = zeros([size(Pic1)],class(Pic1));
% fill the first numerical pixels values of Pic1
imageSeries(:,:,:) = Pic1;

%% --- preprocessing ---
% Short explanation for the software developer:
% Write in the Matlab command line : size(croppedImageSeries). you should
% get 4 numbers. for example: 154   277     3    24. it means:
% height   width   RGB*   number of images in the structe.
% RGB = red, green, blue. for each image, each pixel have those 3 colors, expressed by numerical value.
% in the croppedImageSeries case, the value in index 1 = red values, index 2 = green values, index 3 = blue values. 

greenChannel(:,:,:) = imageSeries(:,:,2);
redChannel(:,:,:) = imageSeries(:,:,1)

% Gaussian filter - Smooth Image. 2 = std
guassGREEN(:,:) = imgaussfilt(greenChannel(:,:),2);
guassRED(:,:) = imgaussfilt(redChannel(:,:),2);

% find threshold
OtsuLevelGREEN(:,:) = graythresh(greenChannel(:,:,:));
OtsuLevelRED(:,:) = graythresh(redChannel(:,:,:))+0.06;

% apply threshold - "bw" conatins pixel values of "1" to the dark areas, "0" to the green areas
bw(:,:,1) = imcomplement(imbinarize(guassGREEN, OtsuLevelGREEN));
bw(:,:,2) = imcomplement(imbinarize(guassRED, OtsuLevelRED));

% Enframe the gut (the unchecked area), 8 pixels away
radius = 1;
decomposition = 0;
% strel command create Morphological structuring element
se = strel('disk', radius, decomposition);
% bw data-structure now conatins the "1" pixels minus 8 pixels
bw(:,:,1) = imerode(bw(:,:,1), se);
%imshow(bw(:,:,1))
bw(:,:,2) = imerode(bw(:,:,2), se);
%imshow(bw(:,:,2))

imshow(Pic1)
% calculate 
roi = drawassisted;
mask = createMask(roi);

AreaTodelete = bw(:,:,1)-mask;
imshow(AreaTodelete) % we want to measure only the white areas in the red channel

% area to calculate
CalArea = bw(:,:,2) - ~AreaTodelete; % remove green area
imshow(CalArea)
CalArea1 = CalArea - mask % remove red area
imshow(CalArea1)

FinalScore = (sum(sum(CalArea1 == 1) / sum(sum(bw(:,:,2) ==1))));
FinalScore

% if we want with the end of the green area:
FinalScore = (sum(sum(CalArea == 1) / sum(sum(bw(:,:,2) ==1))));
FinalScore

