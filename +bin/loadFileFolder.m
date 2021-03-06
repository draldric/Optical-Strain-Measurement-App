function [] = loadFileFolder(app)
[fileName,filePath] = uigetfile([fullfile(getenv('USERPROFILE'),'documents'),'\*.*']);
if isfield(app,'UIFigure')
    figure(app.UIFigure)
else
    figure(app.Figure)
end
if fileName
    [~,fileName,fileExt] = fileparts(fileName);
    switch lower(fileExt(2:end))
    % Images
        case {'jpg','jpeg','png','tif','tiff','bmp','gif'}
            app.resetVariables;
            app.isVideo =  0;
            % Generate the image list
            tmp = dir([filePath,'\**\*',fileExt]);
            app.IMGDIR = filePath;
            app.imageList = {tmp(:).name};
            app.totalImg = length(app.imageList);
    % Videos
        case {'avi','mj2','mpg','wmv','asf','asx','mp4','m4v','mov'}
            app.resetVariables;
            app.isVideo =  1;
            % Create the video object
            app.videoObj = VideoReader(fullfile(filePath,[fileName,fileExt]));
            app.totalImg = app.videoObj.NumFrames;
        otherwise
            app.isVideo = -1;
            % Do Nothing
            return
    end
    
    bin.readNextImage(app)
    
    bin.updateImage(app,-2)
end