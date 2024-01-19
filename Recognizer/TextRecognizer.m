classdef TextRecognizer
    methods
        function resultText = recognize(obj, someInput, recognizerValues)

            % for now you don't get any values in recognizerValues, tell me
            % if you need any

            % idk what input you'll get from the separator, sorry 
            someInput;


            textArray = {'this is ' '   some text' '' 'mind the lack of commas in matlab arrays 😒'};
            
            % define return value
            resultText = textArray;
        end
    end
end