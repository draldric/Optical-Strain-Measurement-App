function setupViewers(app)
% Create an image object
app.IMAGE = imagesc(app.imageViewer,zeros(2));

% Create an ROI object
app.ROI = images.roi.Rectangle(app.imageViewer,...
    'Color','r');

% Create the Intensity Plot line
app.INTENSITY = plot(app.intensityViewer,[1,2],[0,0],'-k');
hold on
app.FitLine = plot(app.intensityViewer,[1,2],[0,0],'-b');
hold off

app.lowerIBObj = yline(app.intensityViewer,0,'--r');
app.upperIBObj = yline(app.intensityViewer,1,'--r');

app.LBound = xline(app.intensityViewer,0,'--g');
app.RBound = xline(app.intensityViewer,1,'--g');

% Add the listeners to the ROI object
addlistener(app.ROI,'MovingROI',@(src,evt)bin.roiListener(src,evt,app));
addlistener(app.ROI,'ROIMoved',@(src,evt)bin.roiListener(src,evt,app));

% Turn off User interations with the plot
app.imageViewer.Interactions = [];

axis(app.imageViewer,'off')
axis(app.intensityViewer,'off')

colormap(app.imageViewer,'gray')

app.imageViewer.Color = 'none';