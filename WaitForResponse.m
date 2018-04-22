% wait until we get something in the input buffer
tic;
EllapsedTime = toc;
while t.BytesAvailable < 1 && (EllapsedTime < ServerConnectionTimeOut - t.Timeout)
    pause(0.001)
    EllapsedTime = toc;
end

ServerResponse = NaN; %NaN = no response, ACK = ok, NAK = not ok (case sensitive)

if (EllapsedTime < ServerConnectionTimeOut - t.Timeout) % then a timeout arrived before the server sent anything
    tic;
    EllapsedTime = toc;
    while (EllapsedTime < ServerConnectionTimeOut - t.Timeout) && sum(double(isnan(ServerResponse)))
        % get 1 char
        extractedChar = char(fread(t, 1, 'char')); %#ok<FREAD>
        % parse char by char
        %     if strcmp(extractedChar, '*') || strcmp(extractedChar, '\n')
        if strcmp(extractedChar, '*') % this is a start of a message from the server
            %             %read the next byte that says the length (in number of bytes) of the message (max FF(h) 255(dec))
            %             messageLength = fread(t, 1, 'uint8');

            extractedChar2 = repmat(char(0),1,4); % 3 letters and an EOM char ('\n')
            for cnt = 1 : length(extractedChar2) % the length of the message is coded on 3 ascii char forming a 3 digit number (int)
                extractedChar2(cnt) = char(fread(t, 1, 'char')); %#ok<FREAD>
            end

            if strcmp(extractedChar2(end), char(10)) %char(10) = newline(> 2015) = \n 
                ServerResponse = extractedChar2(1:end-1);
                disp(['The server responded: ' ServerResponse]);
            end
        elseif strcmp(extractedChar, '$') % this is a 'connection alive' test char from the server
                % do nothing, just go on
        end
        EllapsedTime = toc;
    end
else
    disp('Server didn''t respond to last command')
end