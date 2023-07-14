::
:: Batch script to fix Nikon's PC transfer service not responding
::
:: Nikon Z cameras have built-in WiFi that can upload images and videos to
:: a Windows PC. On the PC side, Nikon installs a Windows Service that
:: listens for WiFi broadcasts from the camera - when detected, the service
:: launches an executable that begins a transfer session with the camera.
:: From there you can either manually select images on the camera to transfer
:: and/or optionally configure the camera to automatically transfer images
:: in real-time as they're taken.
::
:: Unfortunately there's a long-standing bug that causes the Nikon Service
:: to stop responding to future broadcasts from Z cameras after a 
:: transfer session ends. This most frequently occurs if you end the session
:: by turning off the camera rather than ending it via the camera menu option.
::
:: The fix implemented in this script is to periodically poll when a Nikon
:: transfer session has started, then wait for that session to end, then
:: restart the Nikon Windows Service to return the service back into a state
:: that will respond to future camera broadcasts and session requests.
::
:: This script must run in an Administrator command window because stopping
:: and starting a Windows service requires Administrator privileges.
::

@echo off
setlocal enabledelayedexpansion

::
:: Variables controlling how often the script polls to check for a transfer
:: session with the camera starting and stopping. If you set the interval too
:: short it will consume more CPU time. If you set the interval too long it
:: may miss a session and fail to restart the Nikon service to fix the bug
:: of the service getting hung up after a session ends
:: 

set /A PollIntervalSecsForConnectionActive=5
set /A PollIntervalSecsForConnectionEnded=5

::
:: Restart the Nikon service preemptively when we first start, in case it's
:: already hung up from a transfer session started/ended before we
:: were launched
::

echo FixNikonWifi script launched...restarting NkPtpEnumWT3 service
net stop NkPtpEnumWT3 > nul
net start NkPtpEnumWT3 > nul

::
:: Poll waiting for a Nikon PTP session to become active. When
:: NkPtpEnumWT3 detects a camera broadcast, it launches NkPtpipStorage.exe
:: to handle the PTP session. We run netstat to see if there are any
:: TCP entries belonging to NkPtpipStorage.exe - we know there's an active
:: session when we find one
::

:startWaitForNikonPtpConnectionActive
echo Waiting for next active Nikon PTP Connection...
:continueWaitForNikonPtpConnectionActive
timeout /t %PollIntervalSecsForConnectionActive% > nul
netstat -anb -p tcp | findstr  "NkPtpipStorage.exe" > nul
if !errorlevel! == 1 (goto continueWaitForNikonPtpConnectionActive)

::
:: PTP session detected. Poll waiting for the session to end by running
:: netstat to detect the absence of a NkPtpipStorage.exe entry
::

echo Nikon PTP Connection detected - waiting for it to end
:continueWaitForNikonPtpConnectionNotActive
timeout /t %PollIntervalSecsForConnectionEnded% > nul
netstat -anb -p tcp | findstr  "NkPtpipStorage.exe" > nul
if !errorlevel! == 0 (goto continueWaitForNikonPtpConnectionNotActive)

::
:: PTP session has ended. Restart the Nikon broadcast listener service
:: to fix the bug where it fails to respond to future broadcasts after
:: a session has ended
::

echo Nikon PTP Connection ended - restarting NkPtpEnumWT3 service...
net stop NkPtpEnumWT3 > nul
net start NkPtpEnumWT3 > nul

::
:: Poll for next PTP session
::

goto startWaitForNikonPtpConnectionActive
