%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Figures for Temp and Press only
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Temp
Handle_fig1 = figure();
set(Handle_fig1,'Position',[1 6 704 699]);
legendTitle1 = cell(1,8);
cmap = lines(8);
for cntSensor = 1 : 8
    lHandle1(cntSensor) = line(nan,nan); %#ok<*SAGROW> % Generate a blank line and return the line handle
    hold on;
    legendTitle1{cntSensor} = ['Sensor ' num2str(cntSensor)];
    lHandle1(cntSensor).Color = cmap(cntSensor, :);
    lHandle1(cntSensor).Marker = '+';
    lHandle1(cntSensor).Marker = '+';
end
grid on;
xlabel('Time');
ylabel('Temperature [°C]');
legend(legendTitle1);

%% Press
Handle_fig2 = figure();
set(Handle_fig2,'Position',[574 6 704 699]);
for cntSensor = 1 : 8
    lHandle2(cntSensor) = line(nan,nan); % Generate a blank line and return the line handle
    hold on;
    lHandle2(cntSensor).Color = cmap(cntSensor, :);
    lHandle2(cntSensor).Marker = '+';
end
grid on;
xlabel('Time');
ylabel('Pressure (Pa)');
legend(legendTitle1);

%% Generate a figure to be able to stop aquisition
Handle_fig100 = figure();
set(Handle_fig100,'Position',[504 451 343 163]);
drawnow;

drawnow;
