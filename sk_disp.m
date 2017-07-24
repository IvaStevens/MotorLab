function sk_disp(text)
% sk_disp(text)
%
% Displays the date and time with the text
%
% Parameters
% ----------
% text : string
%     The text to be displayed.
%
% sdk29@pitt.edu 2016-12
    
    nowtime = datestr(now, 31);
    disp(['[' nowtime '] ' text]);
