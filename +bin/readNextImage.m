function [] = readNextImage(app)
app.imageIdx = app.imageIdx + 1;
switch app.isVideo
    case 1
        tmp = readFrame(app.videoObj);
    case 0
        tmp = imread(fullfile(app.IMGDIR,app.imageList{app.imageIdx}));
end
if size(tmp,3)>1
    tmp = double(rgb2gray(tmp));
end
app.RAWIMAGE = mat2gray(tmp);