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
    end
    %% Properties
    properties (Access = public)
        ROI             % Region of Interest
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
        
        function moveAllPanels(~)
            % Moves all the panels to the 
%             tmpPosition = app.Figure.Position;
%             app.MainMenu.Position = [1,1,tmpPosition(3:4)];
%             app.VideoConverter.Position = [1,1,tmpPosition(3:4)];
%             app.VideoRecorder.Position = [1,1,tmpPosition(3:4)];
%             app.osmClassic.Position = [1,1,tmpPosition(3:4)];
%             app.osmClassic2D.Position = [1,1,tmpPosition(3:4)];
%             app.osmLive.Position = [1,1,tmpPosition(3:4)];
%             app.osmLive2D.Position = [1,1,tmpPosition(3:4)];
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
            app.FitLine.XData = [0 0];
        end
    end
    %% Callbacks
    methods (Access = private)
        % Code that executes after component creation
        function startupFcn(app)
            
            if ispc
                % Windows is not case-sensitive
                onPath = contains(lower(path),lower(app.RESDIR));
            else
                onPath = contains(path,app.RESDIR);
            end
            
            if ~onPath
                addpath("res\")
                delete(app);
                OSMAPP;
                return;
            end
            
            app.moveAllPanels;
            
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
        % Size changed function: Figure, intensityContainer
        function UIFigureSizeChanged(app,~,~)
            app.moveAllPanels;            
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
            tmp = drawcrosshair(app.intensityViewer);
            newBound = tmp.Position(2)/size(app.PROIMAGE,1);
            delete(tmp);
            switch event.Source.Tag
                case "Upper"
                    if newBound > app.IBounds(1)
                        app.IBounds(2) = newBound;
                    end
                case "Lower"
                    if newBound < app.IBounds(2)
                        app.IBounds(1) = newBound;
                    end
            end
            bin.updateIBounds(app);
        end

        % Button pushed function: ResetLimitsButton
        function resetIntensityLimit(app,~,~)
            app.IBounds = [0,1];
            bin.updateIBounds(app);
        end

        % Button pushed function: LeftButton, RightButton
        function setLRGuesses(app,~,event)
            tmp = drawcrosshair(app.intensityViewer);
            newGuess = tmp.Position(1);
            delete(tmp);
            switch event.Source.Tag
                case "Left"
                    if newGuess < app.RBound.Value
                        app.LBound.Value = newGuess;
                    end
                case "Right"
                    if newGuess > app.LBound.Value
                        app.RBound.Value= newGuess;
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
            Classic.processImages(app);
        end
    end
    %% Constructor/Destructor
    methods
        function app = OSMAPP()
            h = findall(0,'tag','OSMAPP-V1');
            if isempty(h)
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
            app.Figure = figure('Visible', 'off');
            app.Figure.MenuBar = 'none';
            app.Figure.AutoResizeChildren = 'off';
            app.Figure.Position = [100 100 1260 720];
            app.Figure.Name = 'MATLAB App';
            app.Figure.Resize = 0;
            app.Figure.CloseRequestFcn = @app.UIFigureCloseRequest;
            app.Figure.Tag = 'OSMAPP-V1';

            % Create FileMenu
            app.FileMenu = uimenu(app.Figure);
            app.FileMenu.Text = 'File';

            % Create NewMenu
            app.NewMenu = uimenu(app.FileMenu);
            app.NewMenu.MenuSelectedFcn = @app.newMenuCallback;
            app.NewMenu.Enable = 'off';
            app.NewMenu.Accelerator = 'n';
            app.NewMenu.Text = 'New';

            % Create OpenMenu
            app.OpenMenu = uimenu(app.FileMenu);
            app.OpenMenu.Visible = 'off';
            app.OpenMenu.Accelerator = 'o';
            app.OpenMenu.Text = 'Open...';

            % Create SaveMenu
            app.SaveMenu = uimenu(app.FileMenu);
            app.SaveMenu.Enable = 'off';
            app.SaveMenu.Accelerator = 's';
            app.SaveMenu.Text = 'Save';

            % Create SaveAsMenu
            app.SaveAsMenu = uimenu(app.FileMenu);
            app.SaveAsMenu.Enable = 'off';
            app.SaveAsMenu.Text = 'Save As...';

            % Create CloseMenu
            app.CloseMenu = uimenu(app.FileMenu);
            app.CloseMenu.MenuSelectedFcn = @app.openMainMenu;
            app.CloseMenu.Text = 'Close';

            % Create ExitMenu
            app.ExitMenu = uimenu(app.FileMenu);
            app.ExitMenu.MenuSelectedFcn = @app.UIFigureCloseRequest;
            app.ExitMenu.Separator = 'on';
            app.ExitMenu.Text = 'Exit';

            % Create EditMenu
            app.EditMenu = uimenu(app.Figure);
            app.EditMenu.Text = 'Edit';

            % Create HelpMenu
            app.HelpMenu = uimenu(app.Figure);
            app.HelpMenu.Text = 'Help';

            % Create AboutMenu
            app.AboutMenu = uimenu(app.HelpMenu);
            app.AboutMenu.Text = 'About';

            % Create imageContainer
            app.imageContainer = uipanel(app.Figure);
            app.imageContainer.Units = 'Pixels';
            app.imageContainer.AutoResizeChildren = 'off';
            app.imageContainer.Position = [11 361 610 350];

            % Create imageViewer
            app.imageViewer = axes(app.imageContainer);
            app.imageViewer.Toolbar.Visible = 'off';
            app.imageViewer.Units = 'normalized';
            app.imageViewer.FontName = 'Consolas';
            app.imageViewer.XTick = [];
            app.imageViewer.YTick = [];
            app.imageViewer.YTickLabel = '';
            app.imageViewer.ZTick = [];
            app.imageViewer.FontSize = 1;
            app.imageViewer.Position = [0 0 1 1];

            % Create intensityContainer
            app.intensityContainer = uipanel(app.Figure);
            app.intensityContainer.Units = 'Pixels';
            app.intensityContainer.AutoResizeChildren = 'off';
            app.intensityContainer.SizeChangedFcn = @app.UIFigureSizeChanged;
            app.intensityContainer.Position = [11 11 610 350];

            % Create intensityViewer
            app.intensityViewer = axes(app.intensityContainer);
            app.intensityViewer.Toolbar.Visible = 'off';
            app.intensityViewer.Units = 'normalized';
            app.intensityViewer.FontName = 'Consolas';
            app.intensityViewer.XTick = [];
            app.intensityViewer.YTick = [];
            app.intensityViewer.YTickLabel = '';
            app.intensityViewer.ZTick = [];
            app.intensityViewer.FontSize = 1;
            app.intensityViewer.Position = [0 0 1 1];

            % Create imageManipulation
            app.imageManipulation = uipanel(app.Figure);
            app.imageManipulation.Units = 'Pixels';
            app.imageManipulation.AutoResizeChildren = 'off';
            app.imageManipulation.TitlePosition = 'centertop';
            app.imageManipulation.Title = 'OSM-Image Options';
            app.imageManipulation.FontName = 'Consolas';
            app.imageManipulation.FontSize = 20;
            app.imageManipulation.Position = [641 361 610 350];

            % Create invertColor
            app.invertColor = uicontrol(app.imageManipulation,'Style','checkbox');
            app.invertColor.Callback = @app.invertImage;
            app.invertColor.String = {'Invert Image'};
            app.invertColor.FontName = 'Consolas';
            app.invertColor.FontSize = 16;
            app.invertColor.Units = 'normalize';
            app.invertColor.Position = [0.025 0.8375 0.95 0.1375];

            % Create rotateCCW
            app.rotateCCW = uicontrol(app.imageManipulation,'Style', 'pushbutton');
            app.rotateCCW.Callback = @app.rotateImage;
            app.rotateCCW.Tag = '+1';
            app.rotateCCW.FontName = 'Consolas';
            app.rotateCCW.FontSize = 16;
            app.rotateCCW.Units = 'normalize';
            app.rotateCCW.Position = [0.025 0.675 0.4625 0.1375];
            app.rotateCCW.String = 'Rotate -';

            % Create rotateCW
            app.rotateCW = uicontrol(app.imageManipulation,'Style', 'pushbutton');
            app.rotateCW.Callback = @app.rotateImage;
            app.rotateCW.Tag = '-1';
            app.rotateCW.FontName = 'Consolas';
            app.rotateCW.FontSize = 16;
            app.rotateCW.Units = 'normalize';
            app.rotateCW.Position = [0.5125 0.675 0.4625 0.1375];
            app.rotateCW.String = 'Rotate +';

            % Create ResetROIButton
            app.ResetROIButton = uicontrol(app.imageManipulation,'Style', 'pushbutton');
            app.ResetROIButton.Callback = @app.resetROI;
            app.ResetROIButton.FontName = 'Consolas';
            app.ResetROIButton.FontSize = 16;
            app.ResetROIButton.Units = 'normalize';
            app.ResetROIButton.Position = [0.025 0.5125 0.95 0.1375];
            app.ResetROIButton.String = 'Reset ROI';

            % Create UpperLimitButton
            app.UpperLimitButton = uicontrol(app.imageManipulation,'Style', 'pushbutton');
            app.UpperLimitButton.Callback = @app.setIntensityLimit;
            app.UpperLimitButton.Tag = 'Upper';
            app.UpperLimitButton.FontName = 'Consolas';
            app.UpperLimitButton.FontSize = 16;
            app.UpperLimitButton.Units = 'normalize';
            app.UpperLimitButton.Position = [0.025 0.35 0.625 0.1375];
            app.UpperLimitButton.String = 'Upper Limit';

            % Create LowerLimitButton
            app.LowerLimitButton = uicontrol(app.imageManipulation,'Style', 'pushbutton');
            app.LowerLimitButton.Callback = @app.setIntensityLimit;
            app.LowerLimitButton.Tag = 'Lower';
            app.LowerLimitButton.FontName = 'Consolas';
            app.LowerLimitButton.FontSize = 16;
            app.LowerLimitButton.Units = 'normalize';
            app.LowerLimitButton.Position = [0.025 0.1875 0.625 0.1375];
            app.LowerLimitButton.String = 'Lower Limit';

            % Create ResetLimitsButton
            app.ResetLimitsButton = uicontrol(app.imageManipulation,'Style', 'pushbutton');
            app.ResetLimitsButton.Callback = @app.resetIntensityLimit;
            app.ResetLimitsButton.FontName = 'Consolas';
            app.ResetLimitsButton.FontSize = 16;
            app.ResetLimitsButton.Units = 'normalize';
            app.ResetLimitsButton.Position = [0.675 0.1875 0.3 0.3];
            app.ResetLimitsButton.String = {'Reset'; 'Limits'};

            % Create LeftButton
            app.LeftButton = uicontrol(app.imageManipulation,'Style', 'pushbutton');
            app.LeftButton.Callback = @app.setLRGuesses;
            app.LeftButton.Tag = 'Left';
            app.LeftButton.FontName = 'Consolas';
            app.LeftButton.FontSize = 16;
            app.LeftButton.Units = 'normalize';
            app.LeftButton.Position = [0.025 0.025 0.3 0.1375];
            app.LeftButton.String = {'Left'};

            % Create AutoButton
            app.AutoButton = uicontrol(app.imageManipulation,'Style', 'pushbutton');
            app.AutoButton.Callback = @app.autoLRGuesses;
            app.AutoButton.FontName = 'Consolas';
            app.AutoButton.FontSize = 16;
            app.AutoButton.Units = 'normalize';
            app.AutoButton.Position = [0.35 0.025 0.3 0.1375];
            app.AutoButton.String = {'Auto'};

            % Create RightButton
            app.RightButton = uicontrol(app.imageManipulation,'Style', 'pushbutton');
            app.RightButton.Callback = @app.setLRGuesses;
            app.RightButton.Tag = 'Right';
            app.RightButton.FontName = 'Consolas';
            app.RightButton.FontSize = 16;
            app.RightButton.Units = 'normalize';
            app.RightButton.Position = [0.675 0.025 0.3 0.1375];
            app.RightButton.String = {'Right'};

        end
        function createMainMenuComponents(app)
            % Create MainMenu
            app.MainMenu = uipanel(app.Figure);
            app.MainMenu.Units = 'Pixels';
            app.MainMenu.AutoResizeChildren = 'off';
            app.MainMenu.TitlePosition = 'centertop';
            app.MainMenu.Position = [1 1 1260 720];
            
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
            app.VideoProgramsPanel.AutoResizeChildren = 'off';
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
            app.VideoExtensometryPanel.AutoResizeChildren = 'off';
            app.VideoExtensometryPanel.BorderType = 'none';
            app.VideoExtensometryPanel.TitlePosition = 'centertop';
            app.VideoExtensometryPanel.Title = 'Video Extensometry';
            app.VideoExtensometryPanel.Position = [0.33 0 0.33 0.8];
            app.VideoExtensometryPanel.FontName = 'Consolas';
            app.VideoExtensometryPanel.FontWeight = 'bold';
            app.VideoExtensometryPanel.FontSize = 24;

            % Create OSMClassic1DButton
            app.OSMClassic1DButton = uicontrol(app.VideoExtensometryPanel,'Style', 'pushbutton');
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
            app.OSMClassic2DButton = uicontrol(app.VideoExtensometryPanel,'Style', 'pushbutton');
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
            app.LiveExtensometryPanel.AutoResizeChildren = 'off';
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
            app.osmClassic.Units = 'Pixels';
            app.osmClassic.AutoResizeChildren = 'off';
            app.osmClassic.TitlePosition = 'centertop';
            app.osmClassic.Position = [1 1 1260 720];
            
            % Create STARTButton
            app.STARTButton = uicontrol(app.osmClassic,'Style','pushbutton');
            app.STARTButton.Callback = @app.classicStart;
            app.STARTButton.FontName = 'Consolas';
            app.STARTButton.FontSize = 16;
            app.STARTButton.Position = [901 97 65 42];
            app.STARTButton.String = 'START';
        end
        function createClassicLiveComponents(app)
            % Create osmLive
            app.osmLive = uipanel(app.Figure);
            app.osmLive.Units = 'Pixels';
            app.osmLive.AutoResizeChildren = 'off';
            app.osmLive.TitlePosition = 'centertop';
            app.osmLive.Position = [1 1 1260 720];
        end
        function create2DComponents(app)
            % Create osmClassic2D
            app.osmClassic2D = uipanel(app.Figure);
            app.osmClassic2D.Units = 'Pixels';
            app.osmClassic2D.AutoResizeChildren = 'off';
            app.osmClassic2D.TitlePosition = 'centertop';
            app.osmClassic2D.Position = [1 1 1260 720];
        end
        function create2DLiveComponents(app)
            % Create osmLive2D
            app.osmLive2D = uipanel(app.Figure);
            app.osmLive2D.Units = 'Pixels';
            app.osmLive2D.AutoResizeChildren = 'off';
            app.osmLive2D.TitlePosition = 'centertop';
            app.osmLive2D.Position = [1 1 1260 720];
        end
        function createConverterComponents(app)
            % Create VideoConverter
            app.VideoConverter = uipanel(app.Figure);
            app.VideoConverter.Units = 'Pixels';
            app.VideoConverter.AutoResizeChildren = 'off';
            app.VideoConverter.TitlePosition = 'centertop';
            app.VideoConverter.Position = [1 1 1260 720];
        end
        function createRecorderComponents(app)
            % Create VideoRecorder
            app.VideoRecorder = uipanel(app.Figure);
            app.VideoRecorder.Units = 'Pixels';
            app.VideoRecorder.AutoResizeChildren = 'off';
            app.VideoRecorder.TitlePosition = 'centertop';
            app.VideoRecorder.Position = [1 1 1260 720];
        end
    end
end
