function updateIBounds(app)
app.lowerIBObj.Value = app.IBounds(1)*size(app.PROIMAGE,1);
app.upperIBObj.Value = app.IBounds(2)*size(app.PROIMAGE,1);

bin.updateIntensity(app)