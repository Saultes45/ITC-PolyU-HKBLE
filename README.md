# ITC-PolyU-HKBLE
Read ble devices w/ Rpi 3 rev B (BlueZ) (built-in bluetooth)

Matlab is the client and RPi is the server.
RPi handles the communication with the BLE sensor tags.
Matlab handles the HMI and exchange data with the RPi with TCP/IP connection.
The computer running Matlab can connect to the RPi either by ethernet cable or by WiFi.
If the connection is made by WiFi, the RPi is the AP and its name is raspi-BLE


TO DO:
in client
Before aquisition and after discovery ask if all sensors are ok
reload the parameters at each loop

in server
round the data properly
when sensors time out for more than 5 times, just stop it
Disconnect properly from sensors
