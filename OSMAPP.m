classdef OSMAPP < handle
    %% App Components
    properties (Access = public)
        Figure                
        FileMenu                
        NewMenu                
        OpenMenu            
        SaveMenu    
        SaveAsMenu         
        CloseMenu            
        ExitMenu                
        EditMenu            
        HelpMenu              
        AboutMenu             
        VideoConverter      
        osmClassic             
        STARTButton         
        osmClassic2D      
        osmLive                 
        osmLive2D              
        VideoRecorder         
        MainMenu                
        GridLayout              
        OSMSOFTWARESUITELabel   
        VideoProgramsPanel      
        GridLayout2             
        VideoConverterButton   
        VideoRecorderButton     
        VideoExtensometryPanel 
        GridLayout3             
        OSMClassic1DButton      
        OSMClassic2DButton     
        LiveExtensometryPanel   
        GridLayout4           
        OSMLive1DButton         
        OSMLive2DButton         
        SOFTWAREAUTHORLabel   
        imageContainer          
        imageViewer             
        intensityContainer     
        intensityViewer         
        imageManipulation      
        GridLayout5             
        invertColor             
        rotateCCW               
        rotateCW               
        ResetROIButton          
        UpperLimitButton       
        LowerLimitButton        
        ResetLimitsButton       
        LeftButton              
        AutoButton              
        RightButton   
        FitLine
        TopRoiButton
        BottomRoiButton
        LeftRoiButton
        RightRoiButton
        imageTelemetry
    end
    %% Properties
    properties (Access = public)
        toolboxes = []; % Are Toolboxes Available
        ROI             % Region of Interest
        LROI            % Left Region of Interest
        RROI            % Right Region of Interest
        TROI            % Top Region of Interest
        BROI            % Bottom Region of Interest
        ROTATION = 0;   % Image Rotation
        IMAGE           % Image Object
        RAWIMAGE        % Raw Image Data
        PROIMAGE        % Processed Image Data
        INTENSITY       % Intensity Plot
        upperIBObj = -1 % Upper Bound Objects
        lowerIBObj = -1 % Lower Bound Objects
        IBounds = [0,1] % Lower and Upper Bounds
        IData = [];
        LBound = [];    % Left Guess
        RBound = [];    % Right Guess
        IMGDIR          % Image Directory
        imageIdx = 0;   % Current Image/Frame Number
        totalImg = 0;   % Total Number of Images/Frames
        isVideo = -1;   % Video Flag
        imageList = {}; % Image List
        videoObj        % Video Object
        RESDIR = fullfile(cd,'res') % Resource Directory
    end
    %% Functions
    methods (Access = public)
        function hideAllPanels(app)
            app.MainMenu.Visible = 'off';
            app.VideoConverter.Visible = 'off';
            app.VideoRecorder.Visible = 'off';
            app.osmClassic.Visible = 'off';
            app.osmClassic2D.Visible = 'off';
            app.osmLive.Visible = 'off';
            app.osmLive2D.Visible = 'off';
            app.imageContainer.Visible = 'off';
            app.intensityContainer.Visible = 'off';
            app.imageManipulation.Visible = 'off';
        end
        
        function resetVariables(app)
            app.totalImg  =  0;
            app.imageIdx  =  0;
            app.isVideo   = -1;
            app.imageList = {};
            app.videoObj  = [];
            app.ROTATION  =  0;
            app.invertColor.Value = false;
            app.RAWIMAGE = zeros(100);
            app.FitLine.XData = [1 2];
            app.FitLine.YData = [0 0];
        end
    end
    %% Callbacks
    methods (Access = private)
        % Code that executes after component creation
        function startupFcn(app)
                        
            bin.setupViewers(app);
            
            app.openMainMenu;
        end

        % Button pushed function: OSMClassic1DButton
        function tmpTestFunc(app,~,~)
            % TEMPORARY IMAGE TEST

            bin.loadFileFolder(app)
            app.NewMenu.Enable = 'on';
            app.CloseMenu.Enable = 'on';
            app.hideAllPanels;
            app.osmClassic.Visible = 'on';
            app.imageContainer.Visible = 'on';
            app.intensityContainer.Visible = 'on';
            app.imageManipulation.Visible = 'on';
        end

        % Menu selected function: CloseMenu
        function openMainMenu(app,~,~)
            app.hideAllPanels;
            app.resetVariables;
            bin.updateImage(app,-1);
            app.MainMenu.Visible = 'on';
            app.NewMenu.Enable = 'off';
            app.CloseMenu.Enable = 'off';
            drawnow
        end
        
        % Callback function: ExitMenu, Figure
        function UIFigureCloseRequest(app,~,~)
            opt.Interpreter = 'none';
            opt.Default = 'Cancel';
            switch questdlg(...
                    'Are You Sure You Would Like to Close the Program?',...
                    'Confirm Close',...
                    'OK','Cancel',opt)
                case 'OK'
                    delete(app)
                otherwise
                    % Do not close the application
            end
        end
        
        % Value changed function: invertColor
        function invertImage(app,~,~)
            bin.updateImage(app,0);
        end

        % Button pushed function: rotateCCW, rotateCW
        function rotateImage(app,~,event)
            switch event.Source.Tag
                case '+1'
                    app.ROTATION = mod(app.ROTATION+1,4);
                    rotateFlag = 1;
                case '-1'
                    app.ROTATION = mod(app.ROTATION-1,4);
                    rotateFlag = 2;
            end
            bin.updateImage(app,rotateFlag)
        end

        % Button pushed function: ResetROIButton
        function resetROI(app,~,~)
            bin.updateImage(app,-1)
        end

        % Menu selected function: NewMenu
        function newMenuCallback(app,~,~)
            if app.osmClassic.Visible
                bin.loadFileFolder(app)
            elseif app.osmClassic2D.Visible
                bin.loadFileFolder(app)
            elseif app.osmLive.Visible
                
            elseif app.osmLive2D.Visible
                
            end
        end

        % Button pushed function: LowerLimitButton, UpperLimitButton
        function setIntensityLimit(app,~,event)
            app.imageContainer.Visible = 'off';
            if app.toolboxes.imagePro
                tmp = drawcrosshair(app.intensityViewer);
            else
                axes(app.intensityViewer)
                hold on
                tmp.Position = ginput(1);
            end
            newBound = tmp.Position(2)/size(app.PROIMAGE,1);
            if app.toolboxes.imagePro
                delete(tmp);
            end
            switch event.Source.Tag
                case 'Upper'
                    if newBound > app.IBounds(1)
                        if newBound > 1
                            app.IBounds(2) = 1;
                        else
                            app.IBounds(2) = newBound;
                        end
                    end
                case 'Lower'
                    if newBound < app.IBounds(2)
                        if newBound < 0
                            app.IBounds(1) = 0;
                        else
                            app.IBounds(1) = newBound;
                        end
                    end
            end
            bin.updateIBounds(app);
            app.imageContainer.Visible = 'on';
        end

        % Button pushed function: ResetLimitsButton
        function resetIntensityLimit(app,~,~)
            app.IBounds = [0,1];
            bin.updateIBounds(app);
        end

        % Button pushed function: LeftButton, RightButton
        function setLRGuesses(app,~,event)
            if app.toolboxes.imagePro
                tmp = drawcrosshair(app.intensityViewer);
            else
                axes(app.intensityViewer)
                hold on
                tmp.Position = ginput(1);
            end
            newGuess = tmp.Position(1);
            if app.toolboxes.imagePro
                delete(tmp);
            end
            switch event.Source.Tag
                case 'Left'
                    if newGuess < app.RBound.Value
                        if newGuess < 1
                            app.LBound.Value = 1;
                        else
                            app.LBound.Value = newGuess;
                        end
                    end
                case 'Right'
                    if newGuess > app.LBound.Value
                        if newGuess > size(app.PROIMAGE,2)
                            app.RBound.Value = size(app.PROIMAGE,2);
                        else
                            app.RBound.Value = newGuess;
                        end
                    end
            end
        end

        % Button pushed function: AutoButton
        function autoLRGuesses(app,~,~)
            app.LBound.Value = ...
                find(app.INTENSITY.YData>0.9*max(app.INTENSITY.YData),1,'first');
            app.RBound.Value = ...
                find(app.INTENSITY.YData>0.9*max(app.INTENSITY.YData),1,'last');
        end

        % Button pushed function: STARTButton
        function classicStart(app,~,~)
            app.imageManipulation.Visible = 'off';
            app.STARTButton.Visible = 'off';
            Classic.processImages(app);
            app.imageManipulation.Visible = 'on';
            app.STARTButton.Visible = 'on';
            app.imageIdx = 0;
            bin.readNextImage(app);
            bin.updateImage(app,-2);
            app.FitLine.XData = [1 2];
            app.FitLine.YData = [0 0];
            app.SaveMenu.Enable = 'on';
        end
        
        % Button pushed function: TopRoiButton, BottomRoi Button,
        % LeftRoiButton, RightRoiButton
        function setROI(app,~,event)
            app.intensityContainer.Visible = 'off';
            axes(app.imageViewer)
            hold on
            newROI = round(ginput(1));
            switch event.Source.Tag
                case 'Top'
                    if newROI(2) < app.BROI.Value
                        if newROI(2) < 1
                            app.TROI.Value = 1;
                        else
                            app.TROI.Value = newROI(2);
                        end
                    end
                case 'Bottom'
                    if newROI(2) > app.TROI.Value
                        if newROI(2) > size(app.PROIMAGE,1)
                            app.BROI.Value = size(app.PROIMAGE,1);
                        else
                            app.BROI.Value = newROI(2);
                        end
                    end
                case 'Left'
                    if newROI(1) < app.RROI.Value
                        if newROI(1) < 1
                            app.LROI.Value = 1;
                        else
                            app.LROI.Value = newROI(1);
                        end
                    end
                case 'Right'
                    if newROI(1) > app.LROI.Value
                        if newROI(1) > size(app.PROIMAGE,2)
                            app.RROI.Value = size(app.PROIMAGE,2);
                        else
                            app.RROI.Value = newROI(1);
                        end
                    end
            end
            bin.updateIBounds(app);
            app.intensityContainer.Visible = 'on';
        end
        
        % Menu selected function: SaveMenu
        function saveMenuCallback(app,~,~)
            [file, path, filetype] = uiputfile(...
            {'*.dat','Dat File (*.dat)';...
            '*.csv','csv File (*.csv)';...
            '*.*','All Files (*.*)'},...
            'Select File to Write Data',...
            fullfile(getenv('userprofile'),'Documents',['OSMData_',datestr(clock,30),'.dat']));
        if file
            [~, file, ext] = fileparts(file);
            if filetype==1 || strcmpi(ext,'.dat') % dat
                copyfile(fullfile(getenv('temp'),"OSM-APP","tmp.dat"),...
                    fullfile(path,[file,'.dat']),'f')
            elseif filetype==2 || strcmpi(ext,'.csv') % dat
                copyfile(fullfile(getenv('temp'),"OSM-APP","tmp.dat"),...
                    fullfile(path,[file,'.csv']),'f')
            else
                copyfile(fullfile(getenv('temp'),"OSM-APP","tmp.dat"),...
                    fullfile(path,[file,ext]),'f')
            end
        end
        end
    end
    %% Constructor/Destructor
    methods
        function app = OSMAPP()
            h = findall(0,'tag','OSMAPP-V1');
            if isempty(h)
                addpath('res\');
                                
                % Check to see if user has Toolboxes installed
                bin.checkDependencies(app);
                
                % Create Figure and components
                createCommonComponents(app)
                createMainMenuComponents(app)
                createClassicComponents(app)
                createClassicLiveComponents(app)
                create2DComponents(app)
                create2DLiveComponents(app)
                createConverterComponents(app)
                createRecorderComponents(app)

                uistack([app.imageContainer,app.imageManipulation,app.intensityContainer],'top')

                app.Figure.Visible = 'on';
                % Execute the startup function
                startupFcn(app)
                if nargout == 0
                    clear app
                end
            else
                figure(h);
                clear app
            end
        end
        
        % Code that executes before app deletion
        function delete(app)
            % Delete Figure when app is deleted
            delete(app.Figure)
        end
    end
    %% Initialization
    methods (Access = private)
        function createCommonComponents(app)
            % Create UIFigure and hide until all components are created
            app.Figure = figure(...
                'Visible', 'off',...
                'MenuBar','none',...
                'Position',[100 100 1260 720],...
                'Name','OSM-Application',...
                'NumberTitle','off',...
                'Resize',1,...
                'CloseRequestFcn',@app.UIFigureCloseRequest,...
                'Tag','OSMAPP-V1');

            % Create FileMenu
            app.FileMenu = uimenu(app.Figure,...
                'Text','File');

            % Create NewMenu
            app.NewMenu = uimenu(app.FileMenu,...
                'MenuSelectedFcn',@app.newMenuCallback,...
                'Enable','off',...
                'Accelerator','n',...
                'Text','New');

            % Create OpenMenu
            app.OpenMenu = uimenu(app.FileMenu,...
                'Visible','off',...
                'Accelerator','o',...
                'Text','Open...');

            % Create SaveMenu
            app.SaveMenu = uimenu(app.FileMenu,...
                'MenuSelectedFcn',@app.saveMenuCallback,...
                'Enable','off',...
            	'Accelerator','s',...
            	'Text','Save');

            % Create SaveAsMenu
            app.SaveAsMenu = uimenu(app.FileMenu,...
            	'Enable','off',...
            	'Text','Save As...');

            % Create CloseMenu
            app.CloseMenu = uimenu(app.FileMenu,...
            	'MenuSelectedFcn',@app.openMainMenu,...
            	'Text','Close');

            % Create ExitMenu
            app.ExitMenu = uimenu(app.FileMenu,...
            	'MenuSelectedFcn',@app.UIFigureCloseRequest,...
            	'Separator','on',...
            	'Text','Exit');

            % Create EditMenu
            app.EditMenu = uimenu(app.Figure,...
            	'Text','Edit');

            % Create HelpMenu
            app.HelpMenu = uimenu(app.Figure,...
            	'Text','Help');

            % Create AboutMenu
            app.AboutMenu = uimenu(app.HelpMenu,...
            	'Text','About');

            % Create imageContainer
            app.imageContainer = uipanel(app.Figure,...
            	'Units','Pixels',...
                'AutoResizeChildren','off',...
            	'Position',[11 361 610 350]);

            % Create imageViewer
            app.imageViewer = axes(app.imageContainer,...
            	'Units','normalized',...
            	'FontName','Consolas',...
            	'XTick',[],...
            	'YTick',[],...
            	'YTickLabel','',...
            	'ZTick',[],...
            	'FontSize',1,...
            	'Position',[0 0 1 1]);
            app.imageViewer.Toolbar.Visible = 'off';
            
            % Create intensityContainer
            app.intensityContainer = uipanel(app.Figure,...
                'Units','Pixels',...
                'AutoResizeChildren','off',...
                'Position',[11 11 610 350]);

            % Create intensityViewer
            app.intensityViewer = axes(app.intensityContainer,...
            	'Units','normalized',...
            	'FontName','Consolas',...
            	'XTick',[],...
            	'YTick',[],...
            	'YTickLabel','',...
            	'ZTick',[],...
            	'FontSize',1,...
            	'Position',[0 0 1 1]);
            app.intensityViewer.Toolbar.Visible = 'off';

            % Create imageManipulation
            app.imageManipulation = uipanel(app.Figure,...
                'Units','Pixels',...
                'AutoResizeChildren','off',...
                'TitlePosition','centertop',...
                'Title','OSM-Image Options',...
                'FontName','Consolas',...
                'FontSize',20,...
                'Position',[641 171 610 540]);

            grid = bin.GridLayout([5,8],0.025);
            
            % Create invertColor
            app.invertColor = uicontrol(app.imageManipulation,...
                'Style','checkbox',...
                'Callback',@app.invertImage,...
                'String','Invert Image',...
                'FontName','Consolas',...
                'FontSize',16,...
                'Units','normalize',...
                'Position',grid.getPosition(4:5,7:8));

            % Create rotateCCW
            app.rotateCCW = uicontrol(app.imageManipulation,...
                'Style', 'pushbutton',...
                'Callback',@app.rotateImage,...
                'Tag','+1',...
                'FontName','Consolas',...
                'FontSize',16,...
                'Units','normalize',...
                'Position',grid.getPosition(4,5:6),...
                'String','Rotate -');

            % Create rotateCW
            app.rotateCW = uicontrol(app.imageManipulation,...
                'Style', 'pushbutton',...
                'Callback',@app.rotateImage,...
                'Tag','-1',...
                'FontName','Consolas',...
                'FontSize',16,...
                'Units','normalize',...
                'Position',grid.getPosition(5,5:6),...
                'String','Rotate +');

            % Create ResetROIButton
            app.ResetROIButton = uicontrol(app.imageManipulation,...
                'Style', 'pushbutton',...
                'Callback',@app.resetROI,...
                'FontName','Consolas',...
                'FontSize',16,...
                'Units','normalize',...
                'Position',grid.getPosition(3,5:8),...
                'String','<html>Reset<br /> ROI</html>');

            % Create UpperLimitButton
            app.UpperLimitButton = uicontrol(app.imageManipulation,...
                'Style', 'pushbutton',...
                'Callback',@app.setIntensityLimit,...
                'Tag','Upper',...
                'FontName','Consolas',...
                'FontSize',16,...
                'Units','normalize',...
                'Position',grid.getPosition(1:2,4),...
                'String','Upper Limit');

            % Create LowerLimitButton
            app.LowerLimitButton = uicontrol(app.imageManipulation,...
                'Style', 'pushbutton',...
                'Callback',@app.setIntensityLimit,...
                'Tag','Lower',...
                'FontName','Consolas',...
                'FontSize',16,...
                'Units','normalize',...
                'Position',grid.getPosition(1:2,3),...
                'String','Lower Limit');

            % Create ResetLimitsButton
            app.ResetLimitsButton = uicontrol(app.imageManipulation,...
                'Style', 'pushbutton',...
                'Callback',@app.resetIntensityLimit,...
                'FontName','Consolas',...
                'FontSize',16,...
                'Units','normalize',...
                'Position',grid.getPosition(3,3:4),...
                'String','<html>Reset<br />Limits</html>');

            % Create LeftButton
            app.LeftButton = uicontrol(app.imageManipulation,...
                'Style', 'pushbutton',...
            	'Callback',@app.setLRGuesses,...
            	'Tag','Left',...
                'FontName','Consolas',...
                'FontSize',16,...
                'Units','normalize',...
            	'Position',grid.getPosition(1,1:2),...
            	'String',{'<html>Left<br />Guess</html>'});

            % Create AutoButton
            app.AutoButton = uicontrol(app.imageManipulation,...
                'Style', 'pushbutton',...
                'Callback',@app.autoLRGuesses,...
                'FontName','Consolas',...
                'FontSize',16,...
                'Units','normalize',...
                'Position',grid.getPosition(3,1:2),...
                'String',{'Auto'});

            % Create RightButton
            app.RightButton = uicontrol(app.imageManipulation,...
                'Style', 'pushbutton',...
                'Callback',@app.setLRGuesses,...
                'Tag','Right',...
                'FontName','Consolas',...
                'FontSize',16,...
                'Units','normalize',...
                'Position',grid.getPosition(2,1:2),...
                'String',{'<html>Right<br />Guess</html>'});
            
            %Create TopRoiButton
            app.TopRoiButton = uicontrol(app.imageManipulation,...
                'Style', 'pushbutton',...
                'Callback',@app.setROI,...
                'Tag','Top',...
                'FontName','Consolas',...
                'FontSize',16,...
                'Units','normalize',...
                'Position',grid.getPosition(1:2,8),...
                'String',{'Top ROI'});
            
            %Create BottomRoiButton
            app.BottomRoiButton = uicontrol(app.imageManipulation,...
                'Style', 'pushbutton',...
                'Callback',@app.setROI,...
                'Tag','Bottom',...
                'FontName','Consolas',...
                'FontSize',16,...
                'Units','normalize',...
                'Position',grid.getPosition(1:2,7),...
                'String',{'Bottom ROI'});
            
            %Create LeftRoiButton
            app.LeftRoiButton = uicontrol(app.imageManipulation,...
                'Style', 'pushbutton',...
                'Callback',@app.setROI,...
                'Tag','Left',...
                'FontName','Consolas',...
                'FontSize',16,...
                'Units','normalize',...
                'Position',grid.getPosition(1,5:6),...
                'String',{'<html>Left<br />ROI</html>'});
            
            %Create RightRoiButton
            app.RightRoiButton = uicontrol(app.imageManipulation,...
                'Style', 'pushbutton',...
                'Callback',@app.setROI,...
                'Tag','Right',...
                'FontName','Consolas',...
                'FontSize',16,...
                'Units','normalize',...
                'Position',grid.getPosition(2,5:6),...
                'String',{'<html>Right<br />ROI</html>'});
            
            if  app.toolboxes.imagePro
                app.TopRoiButton.Enable = 'off';
                app.BottomRoiButton.Enable = 'off';
                app.LeftRoiButton.Enable = 'off';
                app.RightRoiButton.Enable = 'off';
            end
        end
        function createMainMenuComponents(app)
            % Create MainMenu
            app.MainMenu = uipanel(app.Figure,...
            	'Units','normalized',...
            	'TitlePosition','centertop',...
            	'Position',[0 0 1 1]);
            
            % Create OSMSOFTWARESUITELabel
            app.OSMSOFTWARESUITELabel = uicontrol(app.MainMenu,'Style','text');
            app.OSMSOFTWARESUITELabel.String = 'OSM SOFTWARE SUITE';
            app.OSMSOFTWARESUITELabel.HorizontalAlignment = 'center';
            app.OSMSOFTWARESUITELabel.FontName = 'Consolas';
            app.OSMSOFTWARESUITELabel.FontSize = 40;
            app.OSMSOFTWARESUITELabel.FontWeight = 'bold';
            app.OSMSOFTWARESUITELabel.Units = 'normalized';
            app.OSMSOFTWARESUITELabel.Position = [0,0.9,1,0.1];

            % Create ByDanielRAldrichLabel
            app.SOFTWAREAUTHORLabel = uicontrol(app.MainMenu,'Style','text');
            app.SOFTWAREAUTHORLabel.String = 'By: Daniel R. Aldrich';
            app.SOFTWAREAUTHORLabel.HorizontalAlignment = 'center';
            app.SOFTWAREAUTHORLabel.FontName = 'Consolas';
            app.SOFTWAREAUTHORLabel.FontSize = 20;
            app.SOFTWAREAUTHORLabel.Units = 'normalized';
            app.SOFTWAREAUTHORLabel.Position = [0,0.85,1,0.05];
            
            % Create VideoProgramsPanel
            app.VideoProgramsPanel = uipanel(app.MainMenu);
            app.VideoProgramsPanel.Units = 'normalized';
            app.VideoProgramsPanel.BorderType = 'none';
            app.VideoProgramsPanel.TitlePosition = 'centertop';
            app.VideoProgramsPanel.Title = 'Video Programs';
            app.VideoProgramsPanel.Position = [0 0 0.33 0.8];
            app.VideoProgramsPanel.FontName = 'Consolas';
            app.VideoProgramsPanel.FontWeight = 'bold';
            app.VideoProgramsPanel.FontSize = 24;
            
            % Create VideoConverterButton
            app.VideoConverterButton = uicontrol(app.VideoProgramsPanel,'Style', 'pushbutton');
            app.VideoConverterButton.CData = imread('res/cutVideo.png');
            app.VideoConverterButton.FontName = 'Consolas';
            app.VideoConverterButton.FontSize = 18;
            app.VideoConverterButton.FontWeight = 'bold';
            app.VideoConverterButton.ForegroundColor = [0 0.7 0];
            app.VideoConverterButton.Enable = 'off';
            app.VideoConverterButton.Units = 'normalized';
            app.VideoConverterButton.Position = [0.05 0.525 0.9 0.4];
            app.VideoConverterButton.String = 'Video Converter';

            % Create VideoRecorderButton
            app.VideoRecorderButton = uicontrol(app.VideoProgramsPanel,'Style', 'pushbutton');
            app.VideoRecorderButton.CData = imread('res/recVideo.png');
            app.VideoRecorderButton.FontName = 'Consolas';
            app.VideoRecorderButton.FontSize = 18;
            app.VideoRecorderButton.FontWeight = 'bold';
            app.VideoRecorderButton.ForegroundColor = [0 0.7 0];
            app.VideoRecorderButton.Enable = 'off';
            app.VideoRecorderButton.Units = 'normalized';
            app.VideoRecorderButton.Position = [0.05 0.05 0.9 0.4];
            app.VideoRecorderButton.String = 'Video Recorder';

            % Create VideoExtensometryPanel
            app.VideoExtensometryPanel = uipanel(app.MainMenu);
            app.VideoExtensometryPanel.Units = 'normalized';
            app.VideoExtensometryPanel.BorderType = 'none';
            app.VideoExtensometryPanel.TitlePosition = 'centertop';
            app.VideoExtensometryPanel.Title = 'Video Extensometry';
            app.VideoExtensometryPanel.Position = [0.33 0 0.33 0.8];
            app.VideoExtensometryPanel.FontName = 'Consolas';
            app.VideoExtensometryPanel.FontWeight = 'bold';
            app.VideoExtensometryPanel.FontSize = 24;

            % Create OSMClassic1DButton
            app.OSMClassic1DButton = uicontrol(app.VideoExtensometryPanel,...
                'Style', 'pushbutton');
            app.OSMClassic1DButton.Callback = @app.tmpTestFunc;
            app.OSMClassic1DButton.CData = imread('res/imageLines.png');
            app.OSMClassic1DButton.FontName = 'Consolas';
            app.OSMClassic1DButton.FontSize = 18;
            app.OSMClassic1DButton.FontWeight = 'bold';
            app.OSMClassic1DButton.ForegroundColor = [0 0.7 0];
            app.OSMClassic1DButton.Units = 'normalized';
            app.OSMClassic1DButton.Position = [0.05 0.525 0.9 0.4];
            app.OSMClassic1DButton.String = 'OSM-Classic (1D)';

            % Create OSMClassic2DButton
            app.OSMClassic2DButton = uicontrol(app.VideoExtensometryPanel,...
                'Style', 'pushbutton');
            app.OSMClassic2DButton.CData = imread('res/imageDots.png');
            app.OSMClassic2DButton.FontName = 'Consolas';
            app.OSMClassic2DButton.FontSize = 18;
            app.OSMClassic2DButton.FontWeight = 'bold';
            app.OSMClassic2DButton.ForegroundColor = [0 0.7 0];
            app.OSMClassic2DButton.Enable = 'off';
            app.OSMClassic2DButton.Units = 'normalized';
            app.OSMClassic2DButton.Position = [0.05 0.05 0.9 0.4];
            app.OSMClassic2DButton.String = 'OSM-Classic (2D)';

            % Create LiveExtensometryPanel
            app.LiveExtensometryPanel = uipanel(app.MainMenu);
            app.LiveExtensometryPanel.Units = 'normalized';
            app.LiveExtensometryPanel.BorderType = 'none';
            app.LiveExtensometryPanel.TitlePosition = 'centertop';
            app.LiveExtensometryPanel.Title = 'Live Extensometry';
            app.LiveExtensometryPanel.Position = [0.66 0 0.33 0.8];
            app.LiveExtensometryPanel.FontName = 'Consolas';
            app.LiveExtensometryPanel.FontWeight = 'bold';
            app.LiveExtensometryPanel.FontSize = 24;

            % Create OSMLive1DButton
            app.OSMLive1DButton = uicontrol(app.LiveExtensometryPanel,'Style', 'pushbutton');
            app.OSMLive1DButton.CData = imread('res/imageLinesLive.png');
            app.OSMLive1DButton.FontName = 'Consolas';
            app.OSMLive1DButton.FontSize = 18;
            app.OSMLive1DButton.FontWeight = 'bold';
            app.OSMLive1DButton.ForegroundColor = [0 0.7 0];
            app.OSMLive1DButton.Enable = 'off';
            app.OSMLive1DButton.Units = 'normalized';
            app.OSMLive1DButton.Position = [0.05 0.525 0.9 0.4];
            app.OSMLive1DButton.String = 'OSM-Live (1D)';

            % Create OSMLive2DButton
            app.OSMLive2DButton = uicontrol(app.LiveExtensometryPanel,'Style', 'pushbutton');
            app.OSMLive2DButton.CData = imread('res/imageDotsLive.png');
            app.OSMLive2DButton.FontName = 'Consolas';
            app.OSMLive2DButton.FontSize = 18;
            app.OSMLive2DButton.FontWeight = 'bold';
            app.OSMLive2DButton.ForegroundColor = [0 0.7 0];
            app.OSMLive2DButton.Enable = 'off';
            app.OSMLive2DButton.Units = 'normalized';
            app.OSMLive2DButton.Position = [0.05 0.05 0.90 0.4];
            app.OSMLive2DButton.String = 'OSM-Live (2D)';
        end
        function createClassicComponents(app)
            % Create osmClassic
            app.osmClassic = uipanel(app.Figure);
            app.osmClassic.Units = 'normalized';
            app.osmClassic.TitlePosition = 'centertop';
            app.osmClassic.Position = [0 0 1 1];
            
            % Create STARTButton
            app.STARTButton = uicontrol(app.osmClassic,...
                'Style','pushbutton');
            app.STARTButton.Callback = @app.classicStart;
            app.STARTButton.FontName = 'Consolas';
            app.STARTButton.FontSize = 16;
            app.STARTButton.Position = [845 10 200 150];
            app.STARTButton.String = 'START';
        end
        function createClassicLiveComponents(app)
            % Create osmLive
            app.osmLive = uipanel(app.Figure);
            app.osmLive.Units = 'normalized';
            app.osmLive.TitlePosition = 'centertop';
            app.osmLive.Position = [0 0 1 1];
        end
        function create2DComponents(app)
            % Create osmClassic2D
            app.osmClassic2D = uipanel(app.Figure);
            app.osmClassic2D.Units = 'normalized';
            app.osmClassic2D.TitlePosition = 'centertop';
            app.osmClassic2D.Position = [0 0 1 1];
        end
        function create2DLiveComponents(app)
            % Create osmLive2D
            app.osmLive2D = uipanel(app.Figure);
            app.osmLive2D.Units = 'normalized';
            app.osmLive2D.TitlePosition = 'centertop';
            app.osmLive2D.Position = [0 0 1 1];
        end
        function createConverterComponents(app)
            % Create VideoConverter
            app.VideoConverter = uipanel(app.Figure);
            app.VideoConverter.Units = 'normalized';
            app.VideoConverter.TitlePosition = 'centertop';
            app.VideoConverter.Position = [0 0 1 1];
        end   
        function createRecorderComponents(app)
            % Create VideoRecorder
            app.VideoRecorder = uipanel(app.Figure);
            app.VideoRecorder.Units = 'normalized';
            app.VideoRecorder.TitlePosition = 'centertop';
            app.VideoRecorder.Position = [0 0 1 1];
        end
        function createTelemetryComponents(app)
            app.imageTelemetry = uipanel(app.Figure,...
                'Units','Pixels',...
                'AutoResizeChildren','off',...
                'TitlePosition','centertop',...
                'Title','OSM-Image Telemetry',...
                'FontName','Consolas',...
                'FontSize',20,...
                'Position',[641 361 610 350]);
        end
    end
end
