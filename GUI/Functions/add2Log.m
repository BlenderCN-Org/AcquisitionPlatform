function add2Log(string)
%add2Log This functions add the given string in to the experiment log
%   Detailed explanation goes here
    
    global logHandle
    
    currentText= cellstr(get(logHandle,'String'));
    currentHour= clock;
    string= [num2str(currentHour(4),'%.2d'), ':', num2str(currentHour(5),'%.2d'), ':', num2str(round(currentHour(6)),'%.2d'), ': ', string];
    text= [{string};currentText];
    set(logHandle,'String',text);

    currentDay= date;
    logfile= ['../Logs' currentDay '.txt'];
    if(exist(logfile,'file')==2)
        
    end

    
    
end

