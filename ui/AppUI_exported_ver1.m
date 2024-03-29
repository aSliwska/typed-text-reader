classdef AppUI_exported_ver1 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        FileMenu                        matlab.ui.container.Menu
        SaveTextToFileMenu              matlab.ui.container.Menu
        SaveParametersToFileMenu        matlab.ui.container.Menu
        LoadParametersFromFileMenu      matlab.ui.container.Menu
        MainGridLayout                  matlab.ui.container.GridLayout
        RightPanelGridLayout            matlab.ui.container.GridLayout
        OptionsGridLayout               matlab.ui.container.GridLayout
        DenoiseLevelSlider              matlab.ui.control.Slider
        DenoiseLevelLabel               matlab.ui.control.Label
        AdditionalSegmentationLabel     matlab.ui.control.Label
        AdditionalSegmentationCheckBox  matlab.ui.control.CheckBox
        Slider4                         matlab.ui.control.Slider
        Slider4Label                    matlab.ui.control.Label
        SegmentationLevelSlider         matlab.ui.control.Slider
        SegmentationLevelLabel          matlab.ui.control.Label
        LetterMergeLevelSlider          matlab.ui.control.Slider
        LetterMergeLevelLabel           matlab.ui.control.Label
        ButtonGridLayout                matlab.ui.container.GridLayout
        GenerateButton                  matlab.ui.control.Button
        PreviewButton                   matlab.ui.control.Button
        ChooseFileButton                matlab.ui.control.Button
        TabGroup                        matlab.ui.container.TabGroup
        OriginalImageTab                matlab.ui.container.Tab
        OriginalImageHolder             matlab.ui.container.GridLayout
        OriginalImage                   matlab.ui.control.UIAxes
        SegmentationResultTab           matlab.ui.container.Tab
        SegmentationResultHolder        matlab.ui.container.GridLayout
        SegmentationResultImage         matlab.ui.control.UIAxes
        BiggestParagraphTab             matlab.ui.container.Tab
        BiggestParagraphHolder          matlab.ui.container.GridLayout
        BiggestParagraphImage           matlab.ui.control.UIAxes
        FoundTextLinesTab               matlab.ui.container.Tab
        FoundTextLinesHolder            matlab.ui.container.GridLayout
        FoundTextLinesImage             matlab.ui.control.UIAxes
        TextTab                         matlab.ui.container.Tab
        TextHolder                      matlab.ui.container.GridLayout
        TextArea                        matlab.ui.control.TextArea

        separatorFields;
        recognizerFields;

        separator = TextSeparator;
        recognizer = TextRecognizer;
    end

    % Callbacks that handle component events
    methods (Access = private)

        function segmentationPreview(app, event)

            set(app.PreviewButton,'Backgroundcolor','#EDB120');
            drawnow();

            % if no image has been set by user
            try
                imhandles(app.OriginalImage).CData;
            catch
                set(app.PreviewButton,'Backgroundcolor','default');
                return;
            end


            %%%%%%%%%%%%%%%% separator %%%%%%%%%%%%%%%%

            % get values for separator
            separatorValues = {zeros(length(app.separatorFields))};

            for i = 1:length(app.separatorFields)
                separatorValues{i} = app.separatorFields(i).Value;
            end

            % run separator
            segmentationResult = app.separator.preview(imhandles(app.OriginalImage).CData, separatorValues);

            % show separator result
            showImage(app, app.SegmentationResultImage, segmentationResult);

            flashGreenButton(app, app.PreviewButton);
        end

        % Button pushed function: GenerateButton
        function generateText(app, event)

            set(app.GenerateButton,'Backgroundcolor','#EDB120');
            drawnow();

            % if no image has been set by user
            try
                imhandles(app.OriginalImage).CData;
            catch
                set(app.GenerateButton,'Backgroundcolor','default');
                return;
            end

            %%%%%%%%%%%%%%%% separator %%%%%%%%%%%%%%%%

            % get values for separator
            separatorValues = {zeros(length(app.separatorFields))};

            for i = 1:length(app.separatorFields)
                separatorValues{i} = app.separatorFields(i).Value;
            end

            % run separator
            [segmentationResult, compositedLetters, foundTextLines, paragraphs] = app.separator.separate(imhandles(app.OriginalImage).CData, separatorValues);

            % show separator result
            showImage(app, app.SegmentationResultImage, segmentationResult);

            showImage(app, app.BiggestParagraphImage, compositedLetters);

            showImage(app, app.FoundTextLinesImage, foundTextLines);


            %%%%%%%%%%%%%%%% recognizer %%%%%%%%%%%%%%%%

            % get values for recognizer
            recognizerValues = {zeros(length(app.recognizerFields))};

            for i = 1:length(app.recognizerFields)
                recognizerValues{i} = app.recognizerFields(i).Value;
            end

            % run recognizer
            resultText = app.recognizer.recognize(paragraphs, recognizerValues);

            % show separator result
            app.TextArea.Value = resultText;

            flashGreenButton(app, app.GenerateButton);
        end

        

        function flashGreenButton(app, button)
            set(button,'Backgroundcolor','#77AC30');
            pause(0.5);
            set(button,'Backgroundcolor','default');
        end

        % Button pushed function: ChooseFileButton
        function loadImageFile(app, event)
            % load file
            loadfilepath = loadFileFromUser(app, {'*.*'});

            if loadfilepath == 0
                % file wasn't returned
                return;
            end
            
            try
                im = imread(loadfilepath);
                rgb2gray(im);
                if ndims(im) == 3
                    showImage(app, app.OriginalImage, im);
                else
                    throw E;
                end
            catch E
                uialert(app.UIFigure,"Plik musi być 3 wymiarowym obrazem.","Niepoprawny plik");
            end
        end


        function showImage(app, axes, image)
            imshow(image, 'Parent', axes);
            axes.XLim = [-inf inf];
            axes.YLim = [-inf inf];
        end


        % Menu selected function: SaveTextToFileMenu
        function saveTextToFile(app, event)
            % get file path
            savefilepath = askForSaveFilePath(app);
            
            if savefilepath == ""
                % user clicked cancel
                return;
            end

            % save text to file
            text = app.TextArea.Value;
            file = fopen(savefilepath,'w');

            for row = 1:length(text)
                fprintf(file, '%s\n', text{row,:});
            end

            fclose(file);
        end


        % Menu selected function: SaveParametersToFileMenu
        function saveParametersToFile(app, event)
            % get file path
            savefilepath = askForSaveFilePath(app);

            if savefilepath == ""
                % user clicked cancel
                return;
            end

            % save parameters to file
            file = fopen(savefilepath,'w');
            fields = cat(2, app.separatorFields, app.recognizerFields);

            for i = 1:length(fields)
                fprintf(file, '%s=%s\n', fields(i).Tag, getFieldStringValue(app, fields(i)));
            end

            fclose(file);
        end


        % Menu selected function: LoadParametersFromFileMenu
        function loadParametersFromFile(app, event)
            % load file
            loadfilepath = loadFileFromUser(app, {'*.txt'});

            if loadfilepath == 0
                % file wasn't returned
                return;
            end

            % read file and set parameters
            file = fopen(loadfilepath,'r');
            
            line = fgetl(file);
            while ischar(line)
                tagAndValue = strsplit(line, '=');
                setParameter(app, tagAndValue{1}, tagAndValue{2});

                line = fgetl(file);
            end

            fclose(file);
        end

        function setParameter(app, tag, stringValue)
            fields = cat(2, app.separatorFields, app.recognizerFields);
            
            for i = 1:length(fields)
                if strcmp(tag, fields(i).Tag)
                    switch class(fields(i))
                        case 'matlab.ui.control.Slider'
                            fields(i).Value = str2double(stringValue);

                        case 'matlab.ui.control.CheckBox'
                            if stringValue == "true"
                                fields(i).Value = 1;
                            else
                                fields(i).Value = 0;
                            end
                    end

                    return;
                end
            end
        end


        function loadfilepath = loadFileFromUser(app, allowedExtensions)
            % get file from user
            [filename, folder] = uigetfile(allowedExtensions);

            if filename == 0
                % user clicked cancel
                loadfilepath = 0;
                return;
            end

            % get loaded file extension
            temp = strsplit(filename, '.'); % chaining parenthesis is not supported...
            extension = append('*.', temp{2});

            % if extension is allowed return file
            if any(strcmp(allowedExtensions, extension)) || any(strcmp(allowedExtensions, '*.*'))
                loadfilepath = append(folder, filename);
            else
                loadfilepath = 0;
                uialert(app.UIFigure,"File type not supported.","Invalid file type");
            end
        end


        function stringValue = getFieldStringValue(app, field)
            switch class(field)
                case 'matlab.ui.control.Slider'
                    stringValue = sprintf('%.4f', field.Value);

                case 'matlab.ui.control.CheckBox'
                    stringValue = string(field.Value);
            end
        end


        function savefilepath = askForSaveFilePath(app)
            % define start folder
            startingFolder = fullfile(userpath, "..");
            defaultFilename = fullfile(startingFolder, '*.*');

            % get file name and path from user
            [filename, folder] = uiputfile(defaultFilename, 'Specify savefile name and path');
            
            if filename == 0
                % user clicked cancel
                savefilepath = "";
            else
                savefilepath = append(fullfile(folder, filename), ".txt");
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToThisFolder = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1000 600];
            app.UIFigure.Name = 'AO Projekt - J. Kawka, D. Kokot, K. Duda, A. Śliwska';

            % Create FileMenu
            app.FileMenu = uimenu(app.UIFigure);
            app.FileMenu.Text = 'Plik';

            % Create SaveTextToFileMenu
            app.SaveTextToFileMenu = uimenu(app.FileMenu);
            app.SaveTextToFileMenu.MenuSelectedFcn = createCallbackFcn(app, @saveTextToFile, true);
            app.SaveTextToFileMenu.Text = 'Zapisz tekst do pliku';

            % Create SaveParametersToFileMenu
            app.SaveParametersToFileMenu = uimenu(app.FileMenu);
            app.SaveParametersToFileMenu.MenuSelectedFcn = createCallbackFcn(app, @saveParametersToFile, true);
            app.SaveParametersToFileMenu.Text = 'Zapisz parametry';

            % Create LoadParametersFromFileMenu
            app.LoadParametersFromFileMenu = uimenu(app.FileMenu);
            app.LoadParametersFromFileMenu.MenuSelectedFcn = createCallbackFcn(app, @loadParametersFromFile, true);
            app.LoadParametersFromFileMenu.Text = 'Wczytaj parametry';

            % Create MainGridLayout
            app.MainGridLayout = uigridlayout(app.UIFigure);
            app.MainGridLayout.ColumnWidth = {'2x', '1x'};
            app.MainGridLayout.RowHeight = {'1x'};


            % Create TabGroup
            app.TabGroup = uitabgroup(app.MainGridLayout);
            app.TabGroup.Layout.Row = 1;
            app.TabGroup.Layout.Column = 1;

            % Create OriginalImageTab
            app.OriginalImageTab = uitab(app.TabGroup);
            app.OriginalImageTab.Title = 'Oryginalne zdjęcie';
            app.OriginalImageTab.Scrollable = 'on';

            % Create OriginalImageHolder
            app.OriginalImageHolder = uigridlayout(app.OriginalImageTab);
            app.OriginalImageHolder.ColumnWidth = {'1x'};
            app.OriginalImageHolder.RowHeight = {'1x'};
            app.OriginalImageHolder.Padding = [0 0 0 0];
            app.OriginalImageHolder.Scrollable = 'on';

            % Create OriginalImage
            app.OriginalImage = uiaxes(app.OriginalImageHolder);
            app.OriginalImage.Toolbar.Visible = 'off';
            title(app.OriginalImage, []);
            xlabel(app.OriginalImage, []);
            ylabel(app.OriginalImage, []);
            app.OriginalImage.XAxis.TickLabels = {};
            app.OriginalImage.YAxis.TickLabels = {};
            app.OriginalImage.Layout.Row = 1;
            app.OriginalImage.Layout.Column = 1;
            pan(app.OriginalImage, 'on');
            zoom(app.OriginalImage, 'on');
            app.OriginalImage.Visible = "off";


            % Create SegmentationResultTab
            app.SegmentationResultTab = uitab(app.TabGroup);
            app.SegmentationResultTab.Title = 'Wynik segmentacji';

            % Create SegmentationResultHolder
            app.SegmentationResultHolder = uigridlayout(app.SegmentationResultTab);
            app.SegmentationResultHolder.ColumnWidth = {'1x'};
            app.SegmentationResultHolder.RowHeight = {'1x'};
            app.SegmentationResultHolder.Padding = [0 0 0 0];
            app.SegmentationResultHolder.Scrollable = 'on';

            % Create SegmentationResultImage
            app.SegmentationResultImage = uiaxes(app.SegmentationResultHolder);
            app.SegmentationResultImage.Toolbar.Visible = 'off';
            title(app.SegmentationResultImage, []);
            xlabel(app.SegmentationResultImage, []);
            ylabel(app.SegmentationResultImage, []);
            app.SegmentationResultImage.XAxis.TickLabels = {};
            app.SegmentationResultImage.YAxis.TickLabels = {};
            app.SegmentationResultImage.Layout.Row = 1;
            app.SegmentationResultImage.Layout.Column = 1;
            pan(app.SegmentationResultImage, 'on');
            zoom(app.SegmentationResultImage, 'on');
            app.SegmentationResultImage.Visible = "off";


            % Create BiggestParagraphTab
            app.BiggestParagraphTab = uitab(app.TabGroup);
            app.BiggestParagraphTab.Title = 'Największy znaleziony akapit';

            % Create BiggestParagraphHolder
            app.BiggestParagraphHolder = uigridlayout(app.BiggestParagraphTab);
            app.BiggestParagraphHolder.ColumnWidth = {'1x'};
            app.BiggestParagraphHolder.RowHeight = {'1x'};
            app.BiggestParagraphHolder.Padding = [0 0 0 0];
            app.BiggestParagraphHolder.Scrollable = 'on';

            % Create BiggestParagraphImage
            app.BiggestParagraphImage = uiaxes(app.BiggestParagraphHolder);
            app.BiggestParagraphImage.Toolbar.Visible = 'off';
            title(app.BiggestParagraphImage, []);
            xlabel(app.BiggestParagraphImage, []);
            ylabel(app.BiggestParagraphImage, []);
            app.BiggestParagraphImage.XAxis.TickLabels = {};
            app.BiggestParagraphImage.YAxis.TickLabels = {};
            app.BiggestParagraphImage.Layout.Row = 1;
            app.BiggestParagraphImage.Layout.Column = 1;
            pan(app.BiggestParagraphImage, 'on');
            zoom(app.BiggestParagraphImage, 'on');
            app.BiggestParagraphImage.Visible = "off";


            % Create FoundTextLinesTab
            app.FoundTextLinesTab = uitab(app.TabGroup);
            app.FoundTextLinesTab.Title = 'Odszukane linie tekstu';

            % Create FoundTextLinesHolder
            app.FoundTextLinesHolder = uigridlayout(app.FoundTextLinesTab);
            app.FoundTextLinesHolder.ColumnWidth = {'1x'};
            app.FoundTextLinesHolder.RowHeight = {'1x'};
            app.FoundTextLinesHolder.Padding = [0 0 0 0];
            app.FoundTextLinesHolder.Scrollable = 'on';

            % Create FoundTextLinesImage
            app.FoundTextLinesImage = uiaxes(app.FoundTextLinesHolder);
            app.FoundTextLinesImage.Toolbar.Visible = 'off';
            title(app.FoundTextLinesImage, []);
            xlabel(app.FoundTextLinesImage, []);
            ylabel(app.FoundTextLinesImage, []);
            app.FoundTextLinesImage.XAxis.TickLabels = {};
            app.FoundTextLinesImage.YAxis.TickLabels = {};
            app.FoundTextLinesImage.Layout.Row = 1;
            app.FoundTextLinesImage.Layout.Column = 1;
            pan(app.FoundTextLinesImage, 'on');
            zoom(app.FoundTextLinesImage, 'on');
            app.FoundTextLinesImage.Visible = "off";


            % Create TextTab
            app.TextTab = uitab(app.TabGroup);
            app.TextTab.Title = 'Tekst';

            % Create TextHolder
            app.TextHolder = uigridlayout(app.TextTab);
            app.TextHolder.ColumnWidth = {'1x'};
            app.TextHolder.RowHeight = {'1x'};
            app.TextHolder.Padding = [0 0 0 0];

            % Create TextArea
            app.TextArea = uitextarea(app.TextHolder);
            app.TextArea.Layout.Row = 1;
            app.TextArea.Layout.Column = 1;


            % Create RightPanelGridLayout
            app.RightPanelGridLayout = uigridlayout(app.MainGridLayout);
            app.RightPanelGridLayout.ColumnWidth = {'1x'};
            app.RightPanelGridLayout.RowHeight = {'8x', '2x'};
            app.RightPanelGridLayout.RowSpacing = 0;
            app.RightPanelGridLayout.Padding = [0 0 0 0];
            app.RightPanelGridLayout.Layout.Row = 1;
            app.RightPanelGridLayout.Layout.Column = 2;

            % Create ButtonGridLayout
            app.ButtonGridLayout = uigridlayout(app.RightPanelGridLayout);
            app.ButtonGridLayout.RowHeight = {'1x'};
            app.ButtonGridLayout.Layout.Row = 2;
            app.ButtonGridLayout.Layout.Column = 1;

            % Create ChooseFileButton
            app.ChooseFileButton = uibutton(app.ButtonGridLayout, 'push');
            app.ChooseFileButton.ButtonPushedFcn = createCallbackFcn(app, @loadImageFile, true);
            app.ChooseFileButton.Layout.Row = 1;
            app.ChooseFileButton.Layout.Column = 1;
            app.ChooseFileButton.Text = 'Wybierz plik';

            % Create GenerateButton
            app.GenerateButton = uibutton(app.ButtonGridLayout, 'push');
            app.GenerateButton.ButtonPushedFcn = createCallbackFcn(app, @generateText, true);
            app.GenerateButton.Layout.Row = 2;
            app.GenerateButton.Layout.Column = 2;
            app.GenerateButton.Text = 'Generuj';

            % Create PreviewButton
            app.PreviewButton = uibutton(app.ButtonGridLayout, 'push');
            app.PreviewButton.ButtonPushedFcn = createCallbackFcn(app, @segmentationPreview, true);
            app.PreviewButton.Layout.Row = 2;
            app.PreviewButton.Layout.Column = 1;
            app.PreviewButton.Text = 'Podgląd segmentacji';

            % Create OptionsGridLayout
            app.OptionsGridLayout = uigridlayout(app.RightPanelGridLayout);
            app.OptionsGridLayout.ColumnWidth = {'3x', '3x'};
            app.OptionsGridLayout.RowHeight = {35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35};
            app.OptionsGridLayout.Padding = [0 0 0 0];
            app.OptionsGridLayout.Layout.Row = 1;
            app.OptionsGridLayout.Layout.Column = 1;
            app.OptionsGridLayout.Scrollable = 'on';


            % Create DenoiseLevelLabel
            app.DenoiseLevelLabel = uilabel(app.OptionsGridLayout);
            app.DenoiseLevelLabel.HorizontalAlignment = 'center';
            app.DenoiseLevelLabel.Layout.Row = 1;
            app.DenoiseLevelLabel.Layout.Column = 1;
            app.DenoiseLevelLabel.Text = 'Poziom odszumiania';

            % Create DenoiseLevelSlider
            app.DenoiseLevelSlider = uislider(app.OptionsGridLayout);
            app.DenoiseLevelSlider.MinorTicks = [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100];
            app.DenoiseLevelSlider.Layout.Row = 1;
            app.DenoiseLevelSlider.Layout.Column = 2;
            app.DenoiseLevelSlider.Value = 5;
            app.DenoiseLevelSlider.Tag = 'tagDenoiseLevelSlider';

            % Create LetterMergeLevelLabel
            app.LetterMergeLevelLabel = uilabel(app.OptionsGridLayout);
            app.LetterMergeLevelLabel.HorizontalAlignment = 'center';
            app.LetterMergeLevelLabel.Layout.Row = 2;
            app.LetterMergeLevelLabel.Layout.Column = 1;
            app.LetterMergeLevelLabel.Text = 'Czułość łączenia liter';

            % Create LetterMergeLevel
            app.LetterMergeLevelSlider = uislider(app.OptionsGridLayout);
            app.LetterMergeLevelSlider.MinorTicks = [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100];
            app.LetterMergeLevelSlider.Layout.Row = 2;
            app.LetterMergeLevelSlider.Layout.Column = 2;
            app.LetterMergeLevelSlider.Value = 5;
            app.LetterMergeLevelSlider.Tag = 'tagLetterMergeLevelSlider';

            % Create SegmentationLevelLabel
            app.SegmentationLevelLabel = uilabel(app.OptionsGridLayout);
            app.SegmentationLevelLabel.HorizontalAlignment = 'center';
            app.SegmentationLevelLabel.Layout.Row = 3;
            app.SegmentationLevelLabel.Layout.Column = 1;
            app.SegmentationLevelLabel.Text = 'Czułość segmentacji słów';

            % Create SegmentationLevelSlider
            app.SegmentationLevelSlider = uislider(app.OptionsGridLayout);
            app.SegmentationLevelSlider.MinorTicks = [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100];
            app.SegmentationLevelSlider.Layout.Row = 3;
            app.SegmentationLevelSlider.Value = 60;
            app.SegmentationLevelSlider.Layout.Column = 2;
            app.SegmentationLevelSlider.Tag = 'tagSegmentationLevelSlider';

            % Create Slider4Label
            app.Slider4Label = uilabel(app.OptionsGridLayout);
            app.Slider4Label.HorizontalAlignment = 'center';
            app.Slider4Label.Layout.Row = 4;
            app.Slider4Label.Layout.Column = 1;
            app.Slider4Label.Text = 'Czułość adaptacyjnej binaryzacji';

            % Create Slider4
            app.Slider4 = uislider(app.OptionsGridLayout);
            app.Slider4.MinorTicks = [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100];
            app.Slider4.Layout.Row = 4;
            app.Slider4.Value = 25;
            app.Slider4.Layout.Column = 2;
            app.Slider4.Tag = 'tagSlider4';

            % Create AdditionalSegmentationLabel
            app.AdditionalSegmentationLabel = uilabel(app.OptionsGridLayout);
            app.AdditionalSegmentationLabel.HorizontalAlignment = 'center';
            app.AdditionalSegmentationLabel.Layout.Row = 5;
            app.AdditionalSegmentationLabel.Layout.Column = 1;
            app.AdditionalSegmentationLabel.Text = 'Dodatkowa segmentacja';

            % Create AdditionalSegmentationCheckBox
            app.AdditionalSegmentationCheckBox = uicheckbox(app.OptionsGridLayout);
            app.AdditionalSegmentationCheckBox.Text = '';
            app.AdditionalSegmentationCheckBox.Layout.Row = 5;
            app.AdditionalSegmentationCheckBox.Layout.Column = 2;
            app.AdditionalSegmentationCheckBox.Tag = 'tagAdditionalSegmentationCheckBox';


            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';

            % choose which field values will be given to methods
            app.separatorFields = [app.DenoiseLevelSlider app.LetterMergeLevelSlider app.SegmentationLevelSlider app.Slider4 app.AdditionalSegmentationCheckBox];
            app.recognizerFields = [];
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = AppUI_exported_ver1

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end