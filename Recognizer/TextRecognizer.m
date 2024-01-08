classdef TextRecognizer
    methods
        function resultText = recognize(obj, someInput, recognizerValues)

            % if something goes wrong you'll get zeros
            % in the recognizerValues cell array (but it shouldn't lol)

            % for now it'll be easier for you to edit what you get if you
            % get a whole cell array, but once you tell me exactly what fields
            % you'd like to have, then you won't have to map like this:

            slider3_value = recognizerValues{1};
            slider4_value = recognizerValues{2};
            editfield_value = recognizerValues{3};
            doubleslider_value_min = recognizerValues{4}(1);
            doubleslider_value_max = recognizerValues{4}(2);

            % idk what input you'll get from the separator, sorry 
            someInput;


            textArray = {'this is ' '   some text' '' 'mind the lack of commas in matlab arrays 😒'};
            
            % define return value
            resultText = textArray;
        end
    end
end