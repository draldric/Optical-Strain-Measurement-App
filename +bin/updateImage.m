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
        if app.toolboxes.imagePro
            app.ROI.Position = [size(app.PROIMAGE,2)+1 - app.ROI.Position(2) - app.ROI.Position(4),...
                                app.ROI.Position(1),...
                                app.ROI.Position(4),...
                                app.ROI.Position(3)];
        else
            tmp1 = app.TROI.Value;
            app.TROI.Value = app.LROI.Value;
            tmp2 = app.RROI.Value;
            app.RROI.Value = size(app.PROIMAGE,2) + 1 - tmp1;
            app.LROI.Value = size(app.PROIMAGE,2) + 1 - app.BROI.Value;
            app.BROI.Value = tmp2;
        end
        app.LBound.Value = 1;
        app.RBound.Value = size(app.PROIMAGE,2);
    case  1 %Rotate -90deg CW
        if app.toolboxes.imagePro
            app.ROI.Position = [app.ROI.Position(2),...
                                size(app.PROIMAGE,1)+1 - app.ROI.Position(1) - app.ROI.Position(3),...
                                app.ROI.Position(4),...
                                app.ROI.Position(3)];
        else
            tmp1 = app.TROI.Value;
            app.TROI.Value = size(app.PROIMAGE,1) + 1 - app.RROI.Value;
            tmp2 = app.LROI.Value;
            app.RROI.Value = app.BROI.Value;
            app.LROI.Value = tmp1;
            app.BROI.Value = size(app.PROIMAGE,1) + 1 - tmp2;
        end
        app.LBound.Value = 1;
        app.RBound.Value = size(app.PROIMAGE,2);
    case  0 % No Update Needed
        % Do Nothing
    case -1 % Reset ROI
        if app.toolboxes.imagePro
            app.ROI.Position = [0.5,0.5,size(app.PROIMAGE,2),size(app.PROIMAGE,1)];
        else
            app.TROI.Value = 1;
            app.RROI.Value = size(app.PROIMAGE,2);
            app.LROI.Value = 1;
            app.BROI.Value = size(app.PROIMAGE,1);
        end
    case -2
        if app.toolboxes.imagePro
            app.ROI.Position = [0.5,0.5,size(app.PROIMAGE,2),size(app.PROIMAGE,1)];
        else
            app.TROI.Value = 1;
            app.RROI.Value = size(app.PROIMAGE,2);
            app.LROI.Value = 1;
            app.BROI.Value = size(app.PROIMAGE,1);
        end
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
