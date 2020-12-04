function [] = readNextImage(app)
app.imageIdx = app.imageIdx + 1;
switch app.isVideo
    case 1
        tmp = read(app.videoObj,app.imageIdx);
    case 0
        tmp = imread(fullfile(app.IMGDIR,app.imageList{app.imageIdx}));
end
if size(tmp,3)==3
    tmp = rgb2gray(tmp);
else
    %Do Nothing
end
app.RAWIMAGE = im2double(tmp);
app.RAWIMAGE = app.RAWIMAGE(:,:,1);