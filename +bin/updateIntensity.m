function updateIntensity(app,updateI)
if nargin<2
    updateI = 1;
end
switch updateI
    case 0
        app.IData = sum(app.PROIMAGE.*double(createMask(app.ROI)),1)/...
            max(sum(createMask(app.ROI),1))*size(app.PROIMAGE,1);
        app.IData(app.IData<app.lowerIBObj.Value) = app.lowerIBObj.Value;
        app.IData(app.IData>app.upperIBObj.Value) = app.upperIBObj.Value;
    case 1
        app.IData = sum(app.PROIMAGE.*double(createMask(app.ROI)),1)/...
            max(sum(createMask(app.ROI),1))*size(app.PROIMAGE,1);
        app.IData(app.IData<app.lowerIBObj.Value) = app.lowerIBObj.Value;
        app.IData(app.IData>app.upperIBObj.Value) = app.upperIBObj.Value;
        
        app.INTENSITY.XData = 1:size(app.PROIMAGE,2);
        app.INTENSITY.YData = app.IData;

        axis(app.intensityViewer,'image')

        app.intensityViewer.XLim = app.imageViewer.XLim;
        app.intensityViewer.YLim = app.imageViewer.YLim;
end

