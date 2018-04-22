DiscoverBLE;
% SensorIDList = {'EA:AA:AA:BB:BB:SS','CC:CC:CC:CC:CC:CC','EE:CC:CC:CC:CC:CC'};
% A=fread(obj1,get(obj1,'BytesAvailable'))
% [a, MSGID] = lastwarn();
if ~isempty(SensorIDList)
    try
        fopen(t);
        flushinput(t);
        pause(5);
        fwrite(t,'START');
        
        WaitForResponse;
        if strcmp(ServerResponse, 'ACK')
            
            GenerateBlankFigures;
            
            %% Preallocation
            %each element of these vector will in fact be a mean of FrameMeanSize
            %elements (this parameter is adjustabe in the .ini file)
            %Time
            X1 = ones(MaxSensors,DisplayedDataMaxLength)*NaN;
            %Temperature
            Y1 = ones(MaxSensors,DisplayedDataMaxLength)*NaN;
            %     Pressure
            Y2 = ones(MaxSensors,DisplayedDataMaxLength)*NaN;
            
            DataShiftRequired = 0;
            
            % wait until we get something in the input buffer
            while t.BytesAvailable < 1 && ishandle(Handle_fig100)
                pause(0.001);
                %             flushinput(t);
                drawnow;
            end
            
            % inf loop
            while ishandle(Handle_fig100)
                CharMess = fgets(t);
                % % % % %             % get 1 char
                % % % % %             extractedChar = char(fread(t, 1, 'char')); %#ok<FREAD>
                % % % % %             % parse char by char
                % % % % %             %     if strcmp(extractedChar, '*') || strcmp(extractedChar, '\n')
                % % % % %             if strcmp(extractedChar, '*') % this is a start of a message from the server
                % % % % %                 %             %read the next byte that says the length (in number of bytes) of the message (max FF(h) 255(dec))
                % % % % %                 %             messageLength = fread(t, 1, 'uint8');
                % % % % %
                % % % % % % % % % %                 extractedChar2 = repmat(char(0),1,3);
                % % % % % % % % % %                 for cnt = 1 : 3 % the length of the message is coded on 3 ascii char forming a 3 digit number (int)
                % % % % % % % % % %                     extractedChar2(cnt) = char(fread(t, 1, 'char')); %#ok<FREAD>
                % % % % % % % % % %                 end
                % % % % %                 extractedChar2 = char(fread(t, 3, 'char'));
                % % % % %
                % % % % %                 messageLength = str2double(extractedChar2);
                % % % % %
                % % % % % % % % % %                 %pre allocate
                % % % % % % % % % %                 CharMess = repmat(char(0),1,messageLength);
                % % % % % % % % % %                 for cnt_charInMessage = 1 : messageLength + 1 %because of the EOM character
                % % % % % % % % % %                     %read the message until the EOM character
                % % % % % % % % % %                     CharMess(cnt_charInMessage) = char(fread(t, 1, 'char'));
                % % % % % % % % % %                 end
                % % % % %                 CharMess = strjoin(string(char(fread(t, messageLength, 'char'))));
                % % % % %
                % % % % %                 %             Check that we have the EOM char
                
                if strcmp(CharMess(end), char(10)) %char(10) = newline(> 2015) = \n
                    %                     disp(['A complete message of length ' num2str(length(CharMess)-1) ' has been retrieved']);
                    %parsing data
                    
                    
                    Separator = strfind(CharMess,',');
                    if length(Separator) == 4
                        j=1;
                        Trame.SensorID =    (CharMess(Separator(j)+1 : Separator(j+1)-1));  % unit : N/A
                        j = j + 1;
                        Trame.time =          str2double(CharMess(Separator(j)+1 : Separator(j+1)-1));   % unit : ms
                        j = j + 1;
                        Trame.valueType =   str2double(CharMess(Separator(j)+1 : Separator(j+1)-1));   % unit : N/A (1:Temp, 2:Press)
                        j = j + 1;
                        Trame.value =       str2double(CharMess(Separator(j)+1 : end));   % unit : (1:°C, 2:Pa)
                    end
                    clear CharMess
                    
                    %                     Find the number of the sensor with its UUID
                    SensorIDNumber = find(strcmp(SensorIDList, Trame.SensorID));
                    
                    if ~DataShiftRequired && ~isempty(find(isnan(X1(SensorIDNumber, :)),1,'first'))
                        % If X1 has already be completelly filled then we act
                        % like a FIFO  : we discard 1st element of the vector--> X1(2:end)
                        % and we put the new value at the end of the vector-->Trame.time+X1(end)
                        % we need to do that for all data vector (X1 is a bit special
                        % because of integration)
                        Index2fill = find(isnan(X1(SensorIDNumber, :)),1,'first');
                        X1(SensorIDNumber, Index2fill) = Trame.time;
                        switch  Trame.valueType
                            case 1
                                Y1(SensorIDNumber,Index2fill) = Trame.value;
                                if Index2fill > 1
                                    Y2(SensorIDNumber,Index2fill) = Y2(SensorIDNumber,Index2fill-1);
                                end
                            case 2
                                Y2(SensorIDNumber,Index2fill) = Trame.value;
                                if Index2fill > 1
                                    Y1(SensorIDNumber,Index2fill) = Y1(SensorIDNumber,Index2fill-1);
                                end
                        end
                    else
                        DataShiftRequired = 1; % once its equal to 1 there is no going back
                        X1(SensorIDNumber,:) = get(lHandle1(SensorIDNumber), 'XData');
                        X1(SensorIDNumber,:) = [X1(SensorIDNumber,2:end) Trame.time];
                        
                        switch  Trame.valueType
                            case 1
                                Y1(SensorIDNumber,:) = get(lHandle1(SensorIDNumber), 'YData');
                                Y1(SensorIDNumber,:) = [Y1(SensorIDNumber,2:end) Trame.value];
                                Y2(SensorIDNumber,:) = get(lHandle2(SensorIDNumber), 'YData');
                                Y2(SensorIDNumber,:) = [Y2(SensorIDNumber,2:end) Y2(SensorIDNumber,end-1)];
                            case 2
                                Y2(SensorIDNumber,:) = get(lHandle2(SensorIDNumber), 'YData');
                                Y2(SensorIDNumber,:) = [Y2(SensorIDNumber,2:end) Trame.value];
                                Y1(SensorIDNumber,:) = get(lHandle1(SensorIDNumber), 'YData');
                                Y1(SensorIDNumber,:) = [Y1(SensorIDNumber,2:end) Y1(SensorIDNumber,end-1)];
                        end
                        
                    end
                    
                    %Now we take care of the graphs
                    set(lHandle1(SensorIDNumber), 'XData', X1(SensorIDNumber,:), 'YData', Y1(SensorIDNumber,:));
                    set(lHandle2(SensorIDNumber), 'XData', X1(SensorIDNumber,:), 'YData', Y2(SensorIDNumber,:));
                    
                end
                % wait until we get something in the input buffer
                while t.BytesAvailable < 1 && ishandle(Handle_fig100)
                    pause(0.001);
                    drawnow;
                end
                %             end
                %     end
                fwrite(t,'@'); % the 'I am alive' (KeepAlive) message to the server
                % It can be anything except "STOP"
            end
            
            %send the command to the server to stop recording
            try
                fwrite(t,'STOP');
                %             WaitForResponse;
            catch
                disp('Problem while asking the server to stop')
            end
            fclose(t);
            SaveMATData = questdlg('Would you like to save the data', ...
                'Saving options', ...
                'Yes','No','Yes');
            
            %% Data Saving
            if strcmp(SaveMATData, 'Yes')
                try
                    formatOut = 'yyyy-mm-dd--HH-MM-SS-FFF';
                    
                    
                    %              for cnt_sensors = 1 : MaxSensors
                    %                  %avoiding all the NaN (To be improved) --> .* ~isnan(Y11) .* ~isnan(Y12)
                    %                 NoNNaNIndex = find(~isnan(X1(cnt_sensors,:)) | ~isnan(Y1(cnt_sensors,:)) ...
                    %                     | ~isnan(Y2(cnt_sensors,:))>0);
                    %
                    %                 if ~isempty(NoNNaNIndex)
                    %                     X1(cnt_sensors, :) = X1(cnt_sensors,NoNNaNIndex);
                    %                     Y1(cnt_sensors, :) = Y1(cnt_sensors,NoNNaNIndex);
                    %                     Y2(cnt_sensors, :) = Y2(cnt_sensors,NoNNaNIndex);
                    %                 end
                    %              end
                    
                    
                    if AutochoseSavePath == 0
                        [matFile.name,matFile.path] = uiputfile('*.mat','Save Data As');
                        if isequal(matFile.name,0) || isequal(matFile.path,0)
                            disp('User selected Cancel')
                        else
                            disp(['User selected ',fullfile(matFile.path,matFile.name)])
                        end
                        SaveSensorDataFileName =[matFile.path matFile.name];
                        clear matFile
                    else
                        if exist([cd '\Data'],'dir')
                            SaveSensorDataFileName = [cd '\Data\' RunID '-SensorData.mat'];
                        else
                            SaveSensorDataFileName = [cd '\' RunID '-SensorData.mat'];
                        end
                    end
                    
                    save(SaveSensorDataFileName, 'X1', 'Y1', 'Y2', 'SensorIDList');
                    
                catch error
                    disp(error);
                    occured_error = 1;
                    disp('Data couldn''t be saved');
                end
            end
        end
    catch
        uiwait(msgbox('Server appears down, maybe not turned ON or bad IP (just saying...)','Fail'));
    end
    fclose(t);
else
    uiwait(msgbox('No BLE sensor detected by server','Fail'));
end