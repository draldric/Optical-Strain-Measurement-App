function processImages(app)
tic
% Convergence Weighting
w = 1.2;
% Error Allowance
errTol = 5e-7;

yData = app.IData;
xData = 1:length(yData);

f  = Classic.fitFunction(xData);
Jf = Classic.fitJacobian(xData); 

cnew = [ (max(yData)-min(yData))/2 , 0.05 , app.LBound.Value , 0.05 , app.RBound.Value , min(yData)]';

outputData = zeros(app.totalImg,5);

for n = 1:app.totalImg
    if n > 1
        bin.readNextImage(app);
        if mod(n,5)
            bin.updateImage(app);
        else
            bin.updateImage(app,0);
        end
        yData = app.IData;
    end
    cold = 1e10*ones(size(cnew));

    r  = @(c) yData(:) - f(c);
    w = 1.2;
    while max(abs(cnew-cold))>errTol
        cold = cnew;
        cnew = cold + w*( (Jf(cold)'*Jf(cold)) \ (Jf(cold)'*r(cold)) );
        if any(isnan(cnew))
            cnew = [ (max(yData)-min(yData))/2 , 0.05 , app.LBound.Value , 0.05 , app.RBound.Value , min(yData)]';
            cold = 1e10*ones(size(cnew));
            w = w-0.1;
        end
    end
    
    if n > 1
        outputData(n,1:4) = [n,cnew(3),cnew(5),(cnew(5)-cnew(3))];
        outputData(n,5) = (outputData(n,4)-outputData(1,4))/outputData(1,4);
        app.ROI.Position = [...
            app.ROI.Position(1)+outputData(n,2)-outputData(n-1,2),...
            app.ROI.Position(2),...
            app.ROI.Position(3)+outputData(n-1,2)-outputData(n,2)+outputData(n,3)-outputData(n-1,3),...
            app.ROI.Position(4)];
        app.LBound.Value = cnew(3);
        app.RBound.Value = cnew(5);
    else
        outputData(1,:) = [1,cnew(3),cnew(5),(cnew(5)-cnew(3)),0];
    end
    
end

if ~exist(fullfile(getenv('temp'),"OSM-APP"),'dir')
    mkdir(fullfile(getenv('temp'),"OSM-APP"))
end

fID = fopen(fullfile(getenv('temp'),"OSM-APP","tmp.dat"),'W');

fprintf(fID,'Image\tx1 (Pixels)\tx2 (Pixels)\tDx (Pixels)\tStrain\n');
fprintf(fID,'%05i\t%.6f\t%.6f\t%.6f\t%.6e\n',outputData');

fclose(fID);

disp('Done')
toc