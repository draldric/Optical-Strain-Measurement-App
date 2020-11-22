function updateImage(app,updateROI)
if nargin<2
    updateROI = 0;
end

% Check for inverting the image
if app.invertColor.Value
    tmp = 1 - app.RAWIMAGE;
else
    tmp = app.RAWIMAGE;
end

% Check for the amount of rotation
app.PROIMAGE = rot90(tmp,app.ROTATION);
if nargin>1
    app.IMAGE.CData = app.PROIMAGE;
end
% Update the ROI
switch updateROI
    case  2 %Rotate  90deg CW
        app.ROI.Position = [size(app.PROIMAGE,2)+1 - app.ROI.Position(2) - app.ROI.Position(4),...
                            app.ROI.Position(1),...
                            app.ROI.Position(4),...
                            app.ROI.Position(3)];
        app.LBound.Value = 1;
        app.RBound.Value = size(app.PROIMAGE,2);
    case  1 %Rotate -90deg CW
        app.ROI.Position = [app.ROI.Position(2),...
                            size(app.PROIMAGE,1)+1 - app.ROI.Position(1) - app.ROI.Position(3),...
                            app.ROI.Position(4),...
                            app.ROI.Position(3)];
        app.LBound.Value = 1;
        app.RBound.Value = size(app.PROIMAGE,2);
    case  0 % No Update Needed
        % Do Nothing
    case -1 % Reset ROI
        app.ROI.Position = [0.5,0.5,size(app.PROIMAGE,2),size(app.PROIMAGE,1)];
    case -2
        app.ROI.Position = [0.5,0.5,size(app.PROIMAGE,2),size(app.PROIMAGE,1)];
        app.LBound.Value = 0;
        app.RBound.Value = size(app.PROIMAGE,2);
        app.IBounds = [0,1];
end
axis(app.imageViewer,'image')

if nargin>1
    drawnow
    bin.updateIBounds(app)
else
    bin.updateIntensity(app,0)
end
