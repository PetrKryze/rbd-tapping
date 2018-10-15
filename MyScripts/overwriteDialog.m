function choice = overwriteDialog(filename)
d = dialog('Position',[300 300 220 80],'Name','Overwrite Confirm');
txt = uicontrol('Parent',d,...
    'Style','text',...
    'Position',[20 30 200 40],...
    'String',sprintf('%s already exists. Do you want to overwrite it?',filename));

btn_ok = uicontrol('Parent',d,...
    'Position',[20 10 70 25],...
    'String','Ok',...
    'Callback',@ok_callback);

btn_no = uicontrol('Parent',d,...
    'Position',[130 10 70 25],...
    'String','Nope',...
    'Callback',@no_callback);

choice = 0;
% Wait for d to close before running to completion
uiwait(d);

    function ok_callback(h,event)
        choice = 1;
        delete(gcf)
    end

    function no_callback(h,event)
        choice = 0;
        delete(gcf)
    end
end