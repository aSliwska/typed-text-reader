classdef TextSeparator
    methods
        function resultImage = separate(obj, originalImage, separatorValues)
            
            % if something goes wrong you'll get zeros 
            % in the separatorValues cell array (but it shouldn't lol)

            % for now it'll be easier for you to edit what you get if you
            % get a whole cell array, but once you tell me exactly what fields
            % you'd like to have, then you won't have to map like this:

            slider1_value = separatorValues{1};
            slider2_value = separatorValues{2};
            dropdown_value = separatorValues{3};
            checkbox_value = separatorValues{4};


            im = imread(originalImage);
            
            % define return value (should probably return this and a 2d array 
            % of letter images?)
            resultImage = im;
        end
    end
end