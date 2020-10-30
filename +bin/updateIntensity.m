function updateIntensity(app)
app.INTENSITY.XData = 1:size(app.PROIMAGE,2);

app.INTENSITY.YData = sum(app.PROIMAGE.*double(createMask(app.ROI)),1)/...
    max(sum(createMask(app.ROI),1))*size(app.PROIMAGE,1);

axis(app.intensityViewer,'image')

app.intensityViewer.XLim = app.imageViewer.XLim;
app.intensityViewer.YLim = app.imageViewer.YLim;
