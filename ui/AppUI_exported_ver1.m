classdef AppUI_exported_ver1 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        FileMenu                  matlab.ui.container.Menu
        SaveTextToFileMenu        matlab.ui.container.Menu
        SaveParametersToFileMenu  matlab.ui.container.Menu
        LoadParametersFromFileMenu  matlab.ui.container.Menu
        MainGridLayout            matlab.ui.container.GridLayout
        RightPanelGridLayout      matlab.ui.container.GridLayout
        OptionsGridLayout         matlab.ui.container.GridLayout
        Slider11                  matlab.ui.control.Slider
        Slider11Label             matlab.ui.control.Label
        Slider10                  matlab.ui.control.Slider
        Slider10Label             matlab.ui.control.Label
        Slider9                   matlab.ui.control.Slider
        Slider9Label              matlab.ui.control.Label
        DoubleSlider              matlab.ui.control.RangeSlider
        DoubleSliderLabel         matlab.ui.control.Label
        EditField                 matlab.ui.control.NumericEditField
        EditFieldLabel            matlab.ui.control.Label
        Slider1                   matlab.ui.control.Slider
        Slider1Label              matlab.ui.control.Label
        CheckBoxLabel             matlab.ui.control.Label
        CheckBox                  matlab.ui.control.CheckBox
        DropDown                  matlab.ui.control.DropDown
        DropDownLabel             matlab.ui.control.Label
        Slider8                   matlab.ui.control.Slider
        Slider8Label              matlab.ui.control.Label
        Slider7                   matlab.ui.control.Slider
        Slider7Label              matlab.ui.control.Label
        Slider6                   matlab.ui.control.Slider
        Slider6Label              matlab.ui.control.Label
        Slider5                   matlab.ui.control.Slider
        Slider5Label              matlab.ui.control.Label
        Slider4                   matlab.ui.control.Slider
        Slider4Label              matlab.ui.control.Label
        Slider3                   matlab.ui.control.Slider
        Slider3Label              matlab.ui.control.Label
        Slider2                   matlab.ui.control.Slider
        Slider2Label              matlab.ui.control.Label
        ButtonGridLayout          matlab.ui.container.GridLayout
        GenerateButton            matlab.ui.control.Button
        ChooseFileButton          matlab.ui.control.Button
        TabGroup                  matlab.ui.container.TabGroup
        ImageTab                  matlab.ui.container.Tab
        ImageHolder               matlab.ui.container.GridLayout
        Image                     matlab.ui.control.Image
        ProcessedImageTab         matlab.ui.container.Tab
        ProcessedImageHolder      matlab.ui.container.GridLayout
        ProcessedImage            matlab.ui.control.Image
        TextTab                   matlab.ui.container.Tab
        TextHolder                matlab.ui.container.GridLayout
        TextArea                  matlab.ui.control.TextArea
        ImageWithTextTab          matlab.ui.container.Tab
        ImageWithTextHolder       matlab.ui.container.GridLayout

        separatorFields;
        recognizerFields;

        separator = TextSeparator;
        recognizer = TextRecognizer;
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: GenerateButton
        function generateText(app, event)

            %%%%%%%%%%%%%%%% separator %%%%%%%%%%%%%%%%

            % get values for separator
            separatorValues = {zeros(length(app.separatorFields))};

            for i = 1:length(app.separatorFields)
                separatorValues{i} = app.separatorFields(i).Value;
            end

            % run separator
            [processedImage, paragraphs] = app.separator.separate(app.Image.ImageSource, separatorValues);

            % show separator result
            app.ProcessedImage.ImageSource = processedImage;
            app.ProcessedImage.Visible = "on";

            % change active tab
            app.TabGroup.SelectedTab = app.ProcessedImageTab;

            %%%%%%%%%%%%%%%% recognizer %%%%%%%%%%%%%%%%

            % get values for recognizer
            recognizerValues = {zeros(length(app.recognizerFields))};

            for i = 1:length(app.recognizerFields)
                recognizerValues{i} = app.recognizerFields(i).Value;
            end

            % paragraphs{1}

            % run recognizer
            resultText = app.recognizer.recognize(paragraphs, recognizerValues);

            % show separator result
            app.TextArea.Value = resultText;

            % change active tab
            app.TabGroup.SelectedTab = app.TextTab;

        end


        % Button pushed function: ChooseFileButton
        function loadImageFile(app, event)
            % load file
            loadfilepath = loadFileFromUser(app, {'*.png';'*.jpg';'*.jpeg'});

            if loadfilepath == 0
                % file wasn't returned
                return;
            end
            
            % set image
            app.Image.ImageSource = loadfilepath;
            app.Image.Visible = 'on';
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
        
                        case 'matlab.ui.control.DropDown'
                            fields(i).Value = stringValue;
        
                        case 'matlab.ui.control.CheckBox'
                            if stringValue == "true"
                                fields(i).Value = 1;
                            else
                                fields(i).Value = 0;
                            end
        
                        case 'matlab.ui.control.NumericEditField'
                            fields(i).Value = str2double(stringValue);
        
                        case 'matlab.ui.control.RangeSlider'
                            bothValuesAsStrings = strsplit(stringValue);
                            fields(i).Value(1) = str2double(bothValuesAsStrings{1}(2:end));
                            fields(i).Value(2) = str2double(bothValuesAsStrings{2}(1:end-1));
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
            if any(strcmp(allowedExtensions, extension))
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

                case 'matlab.ui.control.DropDown'
                    stringValue = string(field.Value);

                case 'matlab.ui.control.CheckBox'
                    stringValue = string(field.Value);

                case 'matlab.ui.control.NumericEditField'
                    stringValue = sprintf('%.4f', field.Value);

                case 'matlab.ui.control.RangeSlider'
                    stringValue = sprintf('[%.1f %.1f]', field.Value(1), field.Value(2));
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
            app.UIFigure.Position = [100 100 860 520];
            app.UIFigure.Name = 'MATLAB App';

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

            % Create ImageTab
            app.ImageTab = uitab(app.TabGroup);
            app.ImageTab.Title = 'Oryginalne zdjęcie';
            app.ImageTab.Scrollable = 'on';

            % Create ImageHolder
            app.ImageHolder = uigridlayout(app.ImageTab);
            app.ImageHolder.ColumnWidth = {'1x'};
            app.ImageHolder.RowHeight = {'1x'};
            app.ImageHolder.Padding = [0 0 0 0];
            app.ImageHolder.Scrollable = 'on';

            % Create Image
            app.Image = uiimage(app.ImageHolder);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 1;
            app.Image.ImageSource = 255*ones(1,1,3);
            app.Image.Visible = 'off';

            % Create ProcessedImageTab
            app.ProcessedImageTab = uitab(app.TabGroup);
            app.ProcessedImageTab.Title = 'Podgląd operacji na zdjęciu';

            % Create ProcessedImageHolder
            app.ProcessedImageHolder = uigridlayout(app.ProcessedImageTab);
            app.ProcessedImageHolder.ColumnWidth = {'1x'};
            app.ProcessedImageHolder.RowHeight = {'1x'};
            app.ProcessedImageHolder.Padding = [0 0 0 0];
            app.ProcessedImageHolder.Scrollable = 'on';

            % Create ProcessedImage
            app.ProcessedImage = uiimage(app.ProcessedImageHolder);
            app.ProcessedImage.Layout.Row = 1;
            app.ProcessedImage.Layout.Column = 1;
            app.ProcessedImage.ImageSource = 255*ones(1,1,3);
            app.ProcessedImage.Visible = 'off';

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

            % Create ImageWithTextTab
            app.ImageWithTextTab = uitab(app.TabGroup);
            app.ImageWithTextTab.Title = 'Tekst na zdjęciu';

            % Create ImageWithTextHolder
            app.ImageWithTextHolder = uigridlayout(app.ImageWithTextTab);
            app.ImageWithTextHolder.ColumnWidth = {'1x'};
            app.ImageWithTextHolder.RowHeight = {'1x'};
            app.ImageWithTextHolder.Padding = [0 0 0 0];

            % Create RightPanelGridLayout
            app.RightPanelGridLayout = uigridlayout(app.MainGridLayout);
            app.RightPanelGridLayout.ColumnWidth = {'1x'};
            app.RightPanelGridLayout.RowHeight = {'8x', '1x'};
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
            app.GenerateButton.Layout.Row = 1;
            app.GenerateButton.Layout.Column = 2;
            app.GenerateButton.Text = 'Generuj';

            % Create OptionsGridLayout
            app.OptionsGridLayout = uigridlayout(app.RightPanelGridLayout);
            app.OptionsGridLayout.ColumnWidth = {'2x', '3x'};
            app.OptionsGridLayout.RowHeight = {35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35, 35};
            app.OptionsGridLayout.Padding = [0 0 0 0];
            app.OptionsGridLayout.Layout.Row = 1;
            app.OptionsGridLayout.Layout.Column = 1;
            app.OptionsGridLayout.Scrollable = 'on';


            % Create Slider1Label
            app.Slider1Label = uilabel(app.OptionsGridLayout);
            app.Slider1Label.HorizontalAlignment = 'center';
            app.Slider1Label.Layout.Row = 1;
            app.Slider1Label.Layout.Column = 1;
            app.Slider1Label.Text = 'Slider1';

            % Create Slider1
            app.Slider1 = uislider(app.OptionsGridLayout);
            app.Slider1.MinorTicks = [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100];
            app.Slider1.Layout.Row = 1;
            app.Slider1.Layout.Column = 2;
            app.Slider1.Tag = 'tag1';

            % Create Slider2Label
            app.Slider2Label = uilabel(app.OptionsGridLayout);
            app.Slider2Label.HorizontalAlignment = 'center';
            app.Slider2Label.Layout.Row = 2;
            app.Slider2Label.Layout.Column = 1;
            app.Slider2Label.Text = 'Slider2';

            % Create Slider2
            app.Slider2 = uislider(app.OptionsGridLayout);
            app.Slider2.MinorTicks = [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100];
            app.Slider2.Layout.Row = 2;
            app.Slider2.Layout.Column = 2;
            app.Slider2.Tag = 'tag2';

            % Create Slider3Label
            app.Slider3Label = uilabel(app.OptionsGridLayout);
            app.Slider3Label.HorizontalAlignment = 'center';
            app.Slider3Label.Layout.Row = 3;
            app.Slider3Label.Layout.Column = 1;
            app.Slider3Label.Text = 'Slider3';

            % Create Slider3
            app.Slider3 = uislider(app.OptionsGridLayout);
            app.Slider3.MinorTicks = [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100];
            app.Slider3.Layout.Row = 3;
            app.Slider3.Layout.Column = 2;
            app.Slider3.Tag = 'tag3';

            % Create Slider4Label
            app.Slider4Label = uilabel(app.OptionsGridLayout);
            app.Slider4Label.HorizontalAlignment = 'center';
            app.Slider4Label.Layout.Row = 4;
            app.Slider4Label.Layout.Column = 1;
            app.Slider4Label.Text = 'Slider4';

            % Create Slider4
            app.Slider4 = uislider(app.OptionsGridLayout);
            app.Slider4.MinorTicks = [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100];
            app.Slider4.Layout.Row = 4;
            app.Slider4.Layout.Column = 2;
            app.Slider4.Tag = 'tag4';

            % Create Slider5Label
            app.Slider5Label = uilabel(app.OptionsGridLayout);
            app.Slider5Label.HorizontalAlignment = 'center';
            app.Slider5Label.Layout.Row = 5;
            app.Slider5Label.Layout.Column = 1;
            app.Slider5Label.Text = 'Slider5';

            % Create Slider5
            app.Slider5 = uislider(app.OptionsGridLayout);
            app.Slider5.MinorTicks = [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100];
            app.Slider5.Layout.Row = 5;
            app.Slider5.Layout.Column = 2;
            app.Slider5.Tag = 'tag5';

            % Create Slider6Label
            app.Slider6Label = uilabel(app.OptionsGridLayout);
            app.Slider6Label.HorizontalAlignment = 'center';
            app.Slider6Label.Layout.Row = 6;
            app.Slider6Label.Layout.Column = 1;
            app.Slider6Label.Text = 'Slider6';

            % Create Slider6
            app.Slider6 = uislider(app.OptionsGridLayout);
            app.Slider6.MinorTicks = [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100];
            app.Slider6.Layout.Row = 6;
            app.Slider6.Layout.Column = 2;
            app.Slider6.Tag = 'tag6';

            % Create Slider7Label
            app.Slider7Label = uilabel(app.OptionsGridLayout);
            app.Slider7Label.HorizontalAlignment = 'center';
            app.Slider7Label.Layout.Row = 7;
            app.Slider7Label.Layout.Column = 1;
            app.Slider7Label.Text = 'Slider7';

            % Create Slider7
            app.Slider7 = uislider(app.OptionsGridLayout);
            app.Slider7.MinorTicks = [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100];
            app.Slider7.Layout.Row = 7;
            app.Slider7.Layout.Column = 2;
            app.Slider7.Tag = 'tag7';

            % Create Slider8Label
            app.Slider8Label = uilabel(app.OptionsGridLayout);
            app.Slider8Label.HorizontalAlignment = 'center';
            app.Slider8Label.Layout.Row = 8;
            app.Slider8Label.Layout.Column = 1;
            app.Slider8Label.Text = 'Slider8';

            % Create Slider8
            app.Slider8 = uislider(app.OptionsGridLayout);
            app.Slider8.MinorTicks = [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100];
            app.Slider8.Layout.Row = 8;
            app.Slider8.Layout.Column = 2;
            app.Slider8.Tag = 'tag8';

            % Create Slider9Label
            app.Slider9Label = uilabel(app.OptionsGridLayout);
            app.Slider9Label.HorizontalAlignment = 'center';
            app.Slider9Label.Layout.Row = 9;
            app.Slider9Label.Layout.Column = 1;
            app.Slider9Label.Text = 'Slider9';

            % Create Slider9
            app.Slider9 = uislider(app.OptionsGridLayout);
            app.Slider9.MinorTicks = [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100];
            app.Slider9.Layout.Row = 9;
            app.Slider9.Layout.Column = 2;
            app.Slider9.Tag = 'tag9';

            % Create Slider10Label
            app.Slider10Label = uilabel(app.OptionsGridLayout);
            app.Slider10Label.HorizontalAlignment = 'center';
            app.Slider10Label.Layout.Row = 10;
            app.Slider10Label.Layout.Column = 1;
            app.Slider10Label.Text = 'Slider10';

            % Create Slider10
            app.Slider10 = uislider(app.OptionsGridLayout);
            app.Slider10.MinorTicks = [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100];
            app.Slider10.Layout.Row = 10;
            app.Slider10.Layout.Column = 2;
            app.Slider10.Tag = 'tag10';

            % Create Slider11Label
            app.Slider11Label = uilabel(app.OptionsGridLayout);
            app.Slider11Label.HorizontalAlignment = 'center';
            app.Slider11Label.Layout.Row = 11;
            app.Slider11Label.Layout.Column = 1;
            app.Slider11Label.Text = 'Slider11';

            % Create Slider11
            app.Slider11 = uislider(app.OptionsGridLayout);
            app.Slider11.MinorTicks = [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100];
            app.Slider11.Layout.Row = 11;
            app.Slider11.Layout.Column = 2;
            app.Slider11.Tag = 'tag11';

            % Create DropDownLabel
            app.DropDownLabel = uilabel(app.OptionsGridLayout);
            app.DropDownLabel.HorizontalAlignment = 'center';
            app.DropDownLabel.Layout.Row = 12;
            app.DropDownLabel.Layout.Column = 1;
            app.DropDownLabel.Text = 'DropDown';

            % Create DropDown
            app.DropDown = uidropdown(app.OptionsGridLayout);
            app.DropDown.Items = ["Opcja 1" "Opcja 2" "Opcja 3" "Opcja 4"];
            app.DropDown.ItemsData = ["wartosc1" "wartosc2" "wartosc3" "wartosc4"];
            app.DropDown.Layout.Row = 12;
            app.DropDown.Layout.Column = 2;
            app.DropDown.Value = "wartosc1";
            app.DropDown.Tag = 'tagDropDown';

            % Create CheckBoxLabel
            app.CheckBoxLabel = uilabel(app.OptionsGridLayout);
            app.CheckBoxLabel.HorizontalAlignment = 'center';
            app.CheckBoxLabel.Layout.Row = 13;
            app.CheckBoxLabel.Layout.Column = 1;
            app.CheckBoxLabel.Text = 'CheckBox';

            % Create CheckBox
            app.CheckBox = uicheckbox(app.OptionsGridLayout);
            app.CheckBox.Text = '';
            app.CheckBox.Layout.Row = 13;
            app.CheckBox.Layout.Column = 2;
            app.CheckBox.Tag = 'tagCheckBox';

            % Create EditFieldLabel
            app.EditFieldLabel = uilabel(app.OptionsGridLayout);
            app.EditFieldLabel.HorizontalAlignment = 'center';
            app.EditFieldLabel.Layout.Row = 14;
            app.EditFieldLabel.Layout.Column = 1;
            app.EditFieldLabel.Text = 'EditField';

            % Create EditField
            app.EditField = uieditfield(app.OptionsGridLayout, 'numeric');
            app.EditField.Layout.Row = 14;
            app.EditField.Layout.Column = 2;
            app.EditField.Tag = 'tagEditField';
            app.EditField.ValueDisplayFormat = '%.4f';

            % Create DoubleSliderLabel
            app.DoubleSliderLabel = uilabel(app.OptionsGridLayout);
            app.DoubleSliderLabel.HorizontalAlignment = 'center';
            app.DoubleSliderLabel.Layout.Row = 15;
            app.DoubleSliderLabel.Layout.Column = 1;
            app.DoubleSliderLabel.Text = 'DoubleSlider';

            % Create DoubleSlider
            app.DoubleSlider = uislider(app.OptionsGridLayout, 'range');
            app.DoubleSlider.MinorTicks = [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100];
            app.DoubleSlider.Layout.Row = 15;
            app.DoubleSlider.Layout.Column = 2;
            app.DoubleSlider.Tag = 'tagDoubleSlider';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';

            % choose which field values will be given to methods
            app.separatorFields = [app.Slider1 app.Slider2 app.DropDown app.CheckBox];
            app.recognizerFields = [app.Slider3 app.Slider4 app.EditField app.DoubleSlider];
            % be careful not to add the same field to both arrays or you'll
            % start overriding each other
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