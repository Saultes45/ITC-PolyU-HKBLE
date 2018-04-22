%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Main
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Metadata
% Written by    : Nathanaël Esnault
% Verified by   : N/A
% Creation date : 2018-04-18
% Version       : 0.1 (finished on ...)
% Modifications :
% Known bugs    :

%% Functions associated with this code :
% PokeRPi
% GetParameters
% RTAquisition
% Message

%% Possible Improvements
% add an intem in menu: ping the RPi

%% Find the date and use it as a cl
close all;
clc
clear;
%this test ID
formatOut = 'yyyy-mm-dd--HH-MM-SS-FFF';
RunID = datestr(now,formatOut);


%% Cleaning
FolderPath = ':\Thesis\MATLAB\';
FolderNumber = 7;
NumberOfDigits = 2;

startletter = 'C';
i = double(startletter);
while i < double('Z') && FolderPath(1) == ':'
    if exist([i FolderPath], 'dir') == 7 % 7=> name is a folder
        % Now we have the MATLAB folder containing all the code folders
        %Find the subfolder containing the correct number
        MyFolderInfo = dir([i FolderPath]);
        %iteration
        cnt_subdir = 1;
        while isempty(strfind(char(MyFolderInfo(cnt_subdir).name), num2str(FolderNumber,['%0' num2str(NumberOfDigits) 'i']))) && cnt_subdir < length(MyFolderInfo) %#ok<STREMP>
            cnt_subdir = cnt_subdir + 1;
        end
        FolderPath = [i FolderPath char(MyFolderInfo(cnt_subdir).name)]; %#ok<AGROW>
    end
    i = i + 1;
end

if FolderPath(1) ~= ':' %-> if we have found the folder
    cd(FolderPath);
end
clear startletter i MyFolderInfo cnt_subdir

MSGID = 'instrument:fread:unsuccessfulRead';
warning('off', MSGID); % disable Warning:
% Unsuccessful read:  The specified amount of data was not returned within the Timeout period. 

disp('You are currently: '); eval('dos(''whoami'');');

%% initialisations DO NOT MODIFY !!!!!
StopMenu          = 0;
%will be used in a different version to give the
%user the possibility to stop the aquisition
cpt_iteration     = 1;
DataShiftRequired = 0;
occured_error     = 0;
NumberOfInconsitentMessages = 0;
NumberOfEmptyMessages = 0;


%% Parameters
GetParameters;

if occured_error == 0
%     SensorIDList = {'EA:AA:AA:BB:BB:SS', 'AA:AA:AA:BB:BB:BB'};
    
    if HandleWifiAutomatically
        [status,cmdout] = dos('NETSH WLAN SHOW INTERFACE | findstr /r "^....SSID"'); %#ok<ASGLU>
        CurrentWiFiName = strtrim(cmdout(strfind(cmdout, ':') + 1 : end-1));
        disp(['Your current wifi connection is: ' CurrentWiFiName]);
        
        [status,cmdout] = dos('netsh wlan show profile');
        
        % Connect to the RPi by joining its wifi network (RPi is the AP)
        try
            [status,cmdout] = dos('netsh wlan connect name="raspi-BLE"');
            % Wait 05s for the computer network card to connect
            pause(0.5);
        catch
            disp('Cannot connect to RPi WiFi');
            disp('Error: You either never connectected the 1st time with the raspberry pi or it is not in range (maybe you forgot to turn it on)');
            occured_error = 1;
        end
    end
    
    t = tcpip(RPIDafaultIP, Port, 'NetworkRole', 'client', 'inputbuffersize', 12048);
    t.Timeout = 0.5;
    
    %% Menu
    Answer = menu ('Choose what to do','Is RPi alive?', 'Discover BLE sensors', 'Start acquisition', 'Ping RPi','Cancel');
    while Answer ~= 0 && occured_error == 0 && Answer ~= 5
        switch Answer
            case 1
                PokeRPi;
            case 2
                DiscoverBLE;
            case 3
                close all;
                % just to clear the possible remaing figures
                RTAquisition;
            case 4
                [status,cmdout] = dos(['ping ' RPIDafaultIP]);
                if isempty(length(strfind(cmdout, 'Lost = 0')))
                    disp('Ping failed, this computer is NOT connected to the RPi');
                    uiwait(msgbox('Ping failed, this computer is NOT connected to the RPi', 'Fail','error'));
                else
                    uiwait(msgbox('Ping sucess, this computer is connected to the RPi', 'Success'));
                    disp('Ping sucess, this computer is connected to the RPi');
                end
            case 5 %% Cancel
            otherwise
                disp('Problem reading the order')
        end% end for the switch on data aquisition method
        Answer = menu ('Choose what to do','Is RPi alive?', 'Discover sensors', 'Start acquisition','Ping RPi','Cancel');
    end
end

if HandleWifiAutomatically
    % try to connect back to the previous wifi
    try
        if ~strcmp(CurrentWiFiName, 'raspi-BLE') %connect back only if we were NOT connected to a RPi AP
            [status,cmdout] = dos(['netsh wlan connect name="' CurrentWiFiName '"']);
        end
    catch error
        disp('Cannot connect back to the first wifi');
    end
end


disp('End of Matlab');
