function setupViewers(app)
% Create an image object
app.IMAGE = imagesc(app.imageViewer,zeros(2));
hold on
if app.toolboxes.imagePro
    % Create an ROI object
    app.ROI = images.roi.Rectangle(app.imageViewer,...
        'Color','r');
    
    % Add the listeners to the ROI object
    addlistener(app.ROI,'MovingROI',@(src,evt)bin.roiListener(src,evt,app));
    addlistener(app.ROI,'ROIMoved',@(src,evt)bin.roiListener(src,evt,app));
else
    app.LROI = xline(app.imageViewer,0,'--r');
    app.RROI = xline(app.imageViewer,1,'--r');
    app.TROI = yline(app.imageViewer,0,'--r');
    app.BROI = yline(app.imageViewer,1,'--r');
end

% Create the Intensity Plot line
app.INTENSITY = plot(app.intensityViewer,[1,2],[0,0],'-k');
hold on
app.FitLine = plot(app.intensityViewer,[1,2],[0,0],'-b');
hold off

app.lowerIBObj = yline(app.intensityViewer,0,'--r');
app.upperIBObj = yline(app.intensityViewer,1,'--r');

app.LBound = xline(app.intensityViewer,0,'--g');
app.RBound = xline(app.intensityViewer,1,'--g');

% Turn off User interations with the plot
app.imageViewer.Interactions = [];

axis(app.imageViewer,'off')
axis(app.intensityViewer,'off')

colormap(app.imageViewer,'gray')

app.imageViewer.Color = 'none';