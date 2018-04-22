%% Handling sockets

try
    SensorIDList = {};
    fopen(t);
    flushinput(t);
    pause(1);
    fwrite(t,'DISC');
    
    WaitForResponse;
    
    if strcmp(ServerResponse, 'ACK')
        %         SensorIDList = {'EA:AA:AA:BB:BB:SS', 'AA:AA:AA:BB:BB:BB'};
        EOMReceived = 0;
        
        tic;
        
        h = waitbar(0,['Remaining time: ' ...
            num2str(ServerConnectionTimeOut - t.Timeout + BLEDiscoveryTime - toc) 's'],...
            'Name',['Connecting to RPi @ ' RPIDafaultIP]);
        
        EllapsedTime = toc;
        while (EllapsedTime < ServerConnectionTimeOut - t.Timeout + BLEDiscoveryTime) && ~EOMReceived
             waitbar((ServerConnectionTimeOut - t.Timeout + BLEDiscoveryTime  - toc)...
                 /(ServerConnectionTimeOut - t.Timeout + BLEDiscoveryTime ), h,...
                 ['Remaining time: '...
                 num2str(ServerConnectionTimeOut - t.Timeout + BLEDiscoveryTime - toc) 's'])
            % get 1 char
            extractedChar = char(fread(t, 1, 'char')); %#ok<FREAD>
            % parse char by char
            %     if strcmp(extractedChar, '*') || strcmp(extractedChar, '\n')
            if strcmp(extractedChar, '*') % this is a start of a message from the server
                %read the next byte that says the number of detected BLE sensors (max 9(dec))
                
                extractedChar2 = repmat(char(0),1,1);
                for cnt = 1 : length(extractedChar2) % the length of the message is coded on 1 ascii char forming a 1 digit number (uint)
                    extractedChar2(cnt) = char(fread(t, 1, 'char')); %#ok<FREAD>
                end
                
                messageLength = str2double(extractedChar2);
                
                %pre allocate
                CharMess = repmat(char(0),1,messageLength*18+1); %because of the EOM character
                for cnt_charInMessage = 1 : length(CharMess)
                    %read the message until the EOM character
                    CharMess(cnt_charInMessage) = char(fread(t, 1, 'char'));
                end
                %             Check that we have the EOM char
                %                 if strcmp(CharMess(end), newline)
                if strcmp(CharMess(end), char(10)) %char(10) = newline(> 2015) = \n
                    disp(['A complete message of length ' num2str(length(CharMess)-1) ' has been retrieved']);
                    if messageLength == 0
                        EOMReceived = 1;
                    end
                    %parsing data
                    Separator = strfind(CharMess,',');
                    if length(Separator) == messageLength
                        SensorIDList = cell(1, messageLength);
                        for cnt_sensors = 1 : messageLength
                            if cnt_sensors == messageLength
                                EOMReceived = 1;
                                try
                                    SensorIDList{cnt_sensors} = (CharMess(Separator(cnt_sensors)+1 : end-1));
                                catch
                                    disp('Error while retriving the address of the sensor')
                                end
                            else
                                try
                                    SensorIDList{cnt_sensors} = (CharMess(Separator(cnt_sensors)+1 : Separator(cnt_sensors+1)-1));
                                catch
                                    disp('Error while retriving the address of the sensor')
                                end
                            end
                        end
                    end
                end
            end
            EllapsedTime = toc;
        end
        uiwait(msgbox([{['Server discovered ' num2str(length(SensorIDList)) ' BLE sensors']}, SensorIDList],'Success'));
    elseif strcmp(ServerResponse, 'NAK')
        uiwait(msgbox('Server sent a ''NAK''','Fail'));
    else
        uiwait(msgbox('Server didn''t respond to last command','Fail'));
    end
    close(h);
    flushinput(t)
catch err
    disp(err)
    uiwait(msgbox('Server appears down, maybe not turned ON or bad IP (just saying...)','Fail'));
end
fclose(t);