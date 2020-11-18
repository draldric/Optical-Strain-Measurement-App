function [] = readNextImage(app)
app.imageIdx = app.imageIdx + 1;
switch app.isVideo
    case 1
        tmp = readFrame(app.videoObj);
    case 0
        tmp = imread(fullfile(app.IMGDIR,app.imageList{app.imageIdx}));
end
app.RAWIMAGE = mat2gray(tmp);