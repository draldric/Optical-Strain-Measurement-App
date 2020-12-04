function processImages(app)
useImagePro = app.toolboxes.imagePro;
useOptimize = app.toolboxes.Optimize;

% Error Allowance
errTol = 5e-10;
yData = app.IData;
xData = 1:length(yData);
app.FitLine.XData = xData;
app.FitLine.YData = zeros(size(xData));

f  = Classic.fitFunction(xData);
Jf = Classic.fitJacobian(xData); 

cnew = [ (max(yData)-min(yData))/2 , 0.05 , app.LBound.Value , 0.05 , app.RBound.Value , min(yData)]';

outputData = zeros(app.totalImg,5);

lowerBound = [-size(app.PROIMAGE,1),...
    -size(app.PROIMAGE,2),0,-size(app.PROIMAGE,2),0,0];
upperBound = [ size(app.PROIMAGE,1),...
    size(app.PROIMAGE,2),size(app.PROIMAGE,2),...
    size(app.PROIMAGE,2),size(app.PROIMAGE,2),...
    size(app.PROIMAGE,1)];
options = optimoptions('lsqcurvefit',...
    'Display','off',...
    'OptimalityTolerance',1e-9);

msg = sprintf('Processing %05d of %05d',...
            0,app.totalImg);
lib.multiWaitbar(msg, 0/app.totalImg,...
            'Color', [0.8 0.0 0.1] );

dispOptimizer = round(app.totalImg/150);

tmpL = 0;
tmpR = 0;
app.imageIdx = 0;

for n = 1:app.totalImg
    bin.readNextImage(app);
    bin.updateImage(app);
    yData = app.IData;
    cold = 1e10*ones(size(cnew));
    
    if useOptimize
        % Do Nothing
    else
        r  = @(c) yData(:) - f(c);
    end
    
    Exitflag = 0;
    m = 0;
    while max(abs(cnew-cold))>errTol && Exitflag == 0
        cold = cnew;
        
        m = m + 1;
        if useOptimize
            [cnew, ~, ~, Exitflag] = lsqcurvefit(...
                @(cold, xData)  (cold(1)*...
                (erf(cold(2)*(xData-cold(3)))-erf(cold(4)...
                *(xData-cold(5)))))+ cold(6), cold,...
                xData, yData,lowerBound,upperBound,options);
            if m == 25
                Exitflag = 1;
            end
        else
            cnew = cold + ( (Jf(cold)'*Jf(cold)) \ (Jf(cold)'*r(cold)) );
            if any(isnan(cnew))
                cnew = [ (max(yData)-min(yData))/2 , 0.05 ,...
                    app.LBound.Value , 0.05 ,...
                    app.RBound.Value , min(yData)]';
            end
            if m == 250
                Exitflag = 1;
            end
        end
    end
    if ~mod(n,dispOptimizer)
        app.FitLine.YData = f(cnew);
        lib.multiWaitbar(msg,...
            n/app.totalImg,...
            'Relabel',sprintf('Processing %05d of %05d',...
            n,app.totalImg));
        msg = sprintf('Processing %05d of %05d',...
            n,app.totalImg);
    end
    if n > 1
        outputData(n,1:4) = [n,cnew(3),cnew(5),(cnew(5)-cnew(3))];
        outputData(n,5) = (outputData(n,4)-outputData(1,4))/outputData(1,4);
        if useImagePro
            dX1 = outputData(n,2)-outputData(n-1,2);
            dX2 = outputData(n,3)-outputData(n-1,3) - dX1;
            if app.ROI.Position(1) + dX1 < 1
                app.ROI.Position(1) = 1;
            else
                app.ROI.Position(1) = app.ROI.Position(1) + dX1;
            end
            if app.ROI.Position(1) + dX1 + app.ROI.Position(3) + dX2 > size(app.PROIMAGE,2)
                app.ROI.Position(3) = size(app.PROIMAGE,2) - (app.ROI.Position(1) + dX1);
            else
                app.ROI.Position(3) = app.ROI.Position(3) + dX2;
            end
%             app.ROI.Position = [...
%                 app.ROI.Position(1) + dX1,...
%                 app.ROI.Position(2),...
%                 app.ROI.Position(3) + dX2,...
%                 app.ROI.Position(4)];
        else 
           app.LROI.Value = app.LROI.Value + fix(outputData(n,2)-outputData(n-1,2)+tmpL);
           tmpL = rem(outputData(n,2)-outputData(n-1,2)+tmpL,1);
           if app.LROI.Value < 1
               app.LROI.Value = 1;
           end
           app.RROI.Value = app.RROI.Value + fix(outputData(n,3)-outputData(n-1,3)+tmpR);
           tmpR = rem(outputData(n,3)-outputData(n-1,3)+tmpR,1);
           if app.RROI.Value > size(app.PROIMAGE,2)
               app.RROI.Value = size(app.PROIMAGE,2);
           end
        end
        
        if ~mod(n,dispOptimizer)
            app.LBound.Value = cnew(3);
            app.RBound.Value = cnew(5);
            bin.updateImage(app,0);
        end
    else
        outputData(1,:) = [1,cnew(3),cnew(5),(cnew(5)-cnew(3)),0];
    end
end

lib.multiWaitbar('CLOSEALL');

if ~exist(fullfile(getenv('temp'),"OSM-APP"),'dir')
    mkdir(fullfile(getenv('temp'),"OSM-APP"))
end

fID = fopen(fullfile(getenv('temp'),"OSM-APP","tmp.dat"),'W');

fprintf(fID,'Image\tx1 (Pixels)\tx2 (Pixels)\tDx (Pixels)\tStrain\n');
fprintf(fID,'%05i\t%.6f\t%.6f\t%.6f\t%.6e\n',outputData');

fclose(fID);