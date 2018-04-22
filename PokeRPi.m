tic;

% h = waitbar(1, 'Name',['Connecting to RPi @ ' RPIDafaultIP],['Remaining time: ' num2str(ServerConnectionTimeOut - toc) 's']);
h = waitbar(0,['Remaining time: ' num2str(ServerConnectionTimeOut - toc) 's'],'Name',['Connecting to RPi @ ' RPIDafaultIP],...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
setappdata(h,'canceling',0);


% try to open until it works or timeout
EllapsedTime = toc;
while strcmp(t.Status, 'closed') && (EllapsedTime < ServerConnectionTimeOut - t.Timeout) && ~getappdata(h,'canceling')
%     waitbar(x,h,'updated message')
    waitbar((ServerConnectionTimeOut - toc)/ServerConnectionTimeOut, h, ['Remaining time: ' num2str(ServerConnectionTimeOut - toc) 's'])
    try
        fopen(t);
    catch
        disp(['Server unreachable, trying again for ' num2str(ServerConnectionTimeOut - toc) ' seconds']);
        pause(0.5)
        EllapsedTime = toc;
    end
end
if strcmp(t.Status, 'closed')
    delete(h)       % DELETE the waitbar; don't try to CLOSE it.
    disp('Server is down, maybe not turned ON (just saying...)');
    uiwait(msgbox('Server appears down, maybe not turned ON or bad IP (just saying...)','Fail'));
else
    delete(h)       % DELETE the waitbar; don't try to CLOSE it.
    fclose(t);
    disp('Server is up and running, awaiting your command');
    uiwait(msgbox('Server is up and running, awaiting your command','Success'));
end