##   d8b       d8b          d8,                                                                    
##   ?88       88P         `8P              d8P                                               d8P  
##    88b     d88                        d888888P                                          d888888P
##    888888b 888   d8888b  88b  88bd88b   ?88'   d8888b  88bd88b?88,.d88b,  88bd88b d8888b  ?88'  
##    88P `?8b?88  d8b_,dP  88P  88P' ?8b  88P   d8b_,dP  88P'  ``?88'  ?88  88P'  `d8b_,dP  88P   
##   d88,  d88 88b 88b     d88  d88   88P  88b   88b     d88       88b  d8P d88     88b      88b   
##  d88'`?88P'  88b`?888P'd88' d88'   88b  `?8b  `?888P'd88'       888888P'd88'     `?888P'  `?8b  
##                                                                 88P'                            
##                                                                d88                              
##                                                               ?8P 


# -------------------Metadata----------------------
# Creator: Nathanael ESNAULT

# nathanael.esnault@gmail.com
# or
# nesn277@aucklanduni.ac.nz

# Creation date 21/06/2017
# Version	0.1

# Github: 
# BitBucket: 

# TODO list: 
# 


# -------------------VERY important notes----------------------
# To be used with the shell  script "bleSHELL"

# -------------------Import modules----------------------------

import sys
import os
import datetime

# -------------------Defines----------------------------
## Correct conversion with user-defined unit --> input: int output: float
def ConvertAcc(inputNumber):
    with open("/home/pi/Desktop/output4.txt", "a") as myfile:
        myfile.write("Time: " + str((datetime.datetime.now() - epoch).total_seconds() * 1000.0) + " ms " + "Acceleration: " + str(float(inputNumber)/10) + " g" + "\n")

def ConvertGyr(inputNumber):
    with open("/home/pi/Desktop/output4.txt", "a") as myfile:
        myfile.write("Time: " + str((datetime.datetime.now() - epoch).total_seconds() * 1000.0) + " ms " + "Gyroscope: " + str(float(inputNumber)/10) + " rad/s" + "\n")

def ConvertPressure(inputNumber):
    with open("/home/pi/Desktop/output4.txt", "a") as myfile:
        myfile.write("Time: " + str((datetime.datetime.now() - epoch).total_seconds() * 1000.0) + " ms " + "Pressure: " + str(float(inputNumber)) + " Pa" + "\n")

def ConvertTemp(inputNumber):
    with open("/home/pi/Desktop/output4.txt", "a") as myfile:
        myfile.write("Time: " + str((datetime.datetime.now() - epoch).total_seconds() * 1000.0) + " ms " + "Temperature: " + str(float(inputNumber)/10) + " degrees C" + "\n")

def ConvertLight(inputNumber):
    with open("/home/pi/Desktop/output4.txt", "a") as myfile:
        myfile.write("Time: " + str((datetime.datetime.now() - epoch).total_seconds() * 1000.0) + " ms " + "Light: " + str(float(inputNumber)/10) + " guess" + "\n")



# Map the inputs to the function blocks ##read the dec convertion of the handles

options = {11 : ConvertAcc,
           14 : ConvertGyr,
           17 : ConvertPressure,
           20 : ConvertTemp,
           23 : ConvertLight,
}
 

if __name__ == "__main__":
    for line in sys.stdin:
##        sys.stderr.write("DEBUG: got line: " + line)
        index1 = line.find("Notification")
        index2 = line.find("handle =")
        index3 = line.find("value:")

        if (index1 >= 0) and (index2 >= 0)  and (index3 >= 0): # Then "Notification", "handle", and "value" have been found in the input message
            line = line.rstrip()
            inputValue = line[index3+1+len("value:"):]
            inputValue =  inputValue.replace(" ","") # Delete spaces
            inputValue = int(inputValue, 16) # Conversion from hex to dec
            
##            sys.stderr.write("Translation: " + str(options[0](inputValue)))

            # Define new epoch to avoid: "OverflowError: mktime argument out of range"
            epoch = datetime.datetime(2017, 1, 1)

            if not os.path.isfile("/home/pi/Desktop/output4.txt"):
                f = open("/home/pi/Desktop/output4.txt","w+")
                f.close()

            # Detection of the data type
            options[int(line[index2+1+len("handle ="):index2+1+len("handle =")+6],16)](inputValue)    


## end of the python file
