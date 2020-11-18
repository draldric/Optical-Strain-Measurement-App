function setupViewers(app)
% Turn off User interations with the plot
app.imageViewer.Interactions = [];

axis(app.imageViewer,'off')

colormap(app.imageViewer,'gray')

app.imageViewer.Color = 'none';

% Create an image object
app.IMAGE = imagesc(app.imageViewer,zeros(2));

% Create an ROI object
app.ROI = images.roi.Rectangle(app.imageViewer,...
    'Color','r');

% Create the Intensity Plot line
app.INTENSITY = plot(app.intensityViewer,[1,2],[0,0],'-k');

app.lowerIBObj = yline(app.intensityViewer,0,'--r');
app.upperIBObj = yline(app.intensityViewer,1,'--r');

% Add the listeners to the ROI object
addlistener(app.ROI,'MovingROI',@(src,evt)bin.roiListener(src,evt,app));
addlistener(app.ROI,'ROIMoved',@(src,evt)bin.roiListener(src,evt,app));