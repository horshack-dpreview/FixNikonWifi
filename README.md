# FixNikonWifi

Nikon Z cameras have built-in WiFi that can upload images and videos to a Windows PC. On the PC side, Nikon installs a Windows Service that listens for WiFi broadcasts from the camera - when detected, the service launches an executable that begins a transfer session with the camera. From there you can either manually select images on the camera to transfer and/or optionally configure the camera to automatically transfer images in real-time as they're taken.

Unfortunately there's a long-standing bug that causes the Nikon Service to stop responding to future broadcasts from Z cameras after a  transfer session ends. This most frequently occurs if you end the session by turning off the camera rather than ending it via the camera menu option. When this occurs the camera is stuck with a "Connecting to computer" message in the menu:

![Screenshot of Connect to PC waiting for computer to respond](https://raw.githubusercontent.com/horshack-dpreview/FixNikonWifi/main/Screenshot_Nikon_Connect_To_PC_Wait.png)

The fix implemented in this script is to periodically poll when a Nikon transfer session has started, then wait for that session to end, then restart the Nikon Windows Service to return the service back into a state that will respond to future camera broadcasts and session requests.

This script must run in an Administrator command window because stopping and starting a Windows service requires Administrator privileges.

## Installing

Download the batch file by right-clicking on [this link](https://raw.githubusercontent.com/horshack-dpreview/FixNikonWifi/main/FixNikonWifi.cmd) and clicking "Save link as...". To make it easier to launch the batch file you'll want to create a shortcut, that way you can configure it to run with the necessary Administrator privileges and minimized. Here's how to create the shortcut:

1. Right-click on the downloaded batch file and click "Create shortcut"
2. Move the shortcut to where you want to run it from, for example the desktop
3. Right-click shortcut and choose "Properties"
4. Change "Run" in the drop-down from "Normal window" to "Minimized"
5. Click the "Shortcut" tab and then the "Advanced..." button. Check "Run as administrator"

## Running
Double-click the batch file / shortcut to the batch file to execute the script. The script will run indefinitely. 
