@REM Make sure this script is run as an administrator

@REM install chocolatey
@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

@REM Disable global confirmation to avoid having to confirm the installation of individual programs
choco feature enable -n allowGlobalConfirmation

@REM Use choco to install the required dependencies
choco install cmake --installargs 'ADD_CMAKE_TO_PATH=System'
choco install ninja gperf python311 git dtc-msys2 wget 7zip

@REM Create a new virtual environment
cd %HOMEPATH%
python -m venv zephyrproject\.venv
zephyrproject\.venv\Scripts\activate.bat

@REM Install west
pip install west

@REM Get the Zephyr source code
west init .
west update

@REM Export a Zephyr CMake package
west zephyr-export

@REM install python dependencies
west packages pip --install

@REM Install the Zephyr SDK
cd zephyr
west sdk install

@REM install the segger jlink software
cd ..
curl -o JLink_Windows_V812_x86_64.exe https://www.segger.com/downloads/jlink/JLink_Windows_V812_x86_64.exe
start /wait JLink_Windows_V812_x86_64.exe /silent
del JLink_Windows_V812_x86_64.exe

@REM add segger jlink to the path
setx PATH "%PATH%;C:\Program Files (x86)\SEGGER\JLink"
