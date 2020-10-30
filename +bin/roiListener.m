function roiListener(~,evt,app) 
    evname = evt.EventName;
    switch(evname)
        case{'MovingROI'}
            bin.updateIntensity(app)
        case{'ROIMoved'}
            bin.updateIntensity(app)
    end
end