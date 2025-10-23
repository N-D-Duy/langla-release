@echo off
setlocal enabledelayedexpansion

echo ========================================
echo    Mesa3D Tu Dong: Tai - Cai Dat
echo ========================================
echo.

REM Thiet lap cac bien
set "DOWNLOAD_URL=https://github.com/N-D-Duy/langla-release/releases/download/support-v1/mesa3d-25.2.4.7z"
set "FILENAME=mesa3d-25.2.4.7z"
set "EXTRACT_DIR=mesa3d"
set "CURRENT_DIR=%CD%"
set "INSTALL_SUCCESS=0"

REM ==================== PHAN 1: TAI XUONG ====================

REM Kiem tra folder mesa3d da ton tai chua
if exist "mesa3d\" (
    echo [INFO] Folder mesa3d da ton tai!
    echo.
    echo Ban co muon:
    echo 1. Tai lai va giai nen moi (xoa folder cu^)
    echo 2. Bo qua tai xuong va su dung folder hien tai
    echo 3. Thoat
    echo.
    set /p folder_choice="Chon (1/2/3): "
    
    if "!folder_choice!"=="1" (
        echo Dang xoa folder cu...
        rmdir /s /q "mesa3d"
        echo [OK] Da xoa folder cu
        echo.
    ) else if "!folder_choice!"=="2" (
        echo [OK] Su dung folder hien tai
        echo.
        goto :install
    ) else if "!folder_choice!"=="3" (
        echo Thoat chuong trinh.
        pause
        exit /b 0
    ) else (
        echo Lua chon khong hop le. Thoat chuong trinh.
        pause
        exit /b 1
    )
)

echo Dang kiem tra cong cu giai nen...

REM Kiem tra 7-Zip
where 7z >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Tim thay 7-Zip
    set "EXTRACT_TOOL=7z"
    set "EXTRACT_CMD=7z x"
    goto :download
)

REM Kiem tra WinRAR
where winrar >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Tim thay WinRAR
    set "EXTRACT_TOOL=winrar"
    set "EXTRACT_CMD=winrar x"
    goto :download
)

REM Kiem tra WinRAR trong thu muc Program Files
if exist "%ProgramFiles%\WinRAR\WinRAR.exe" (
    echo [OK] Tim thay WinRAR trong Program Files
    set "EXTRACT_TOOL=winrar"
    set "WINRAR_PATH=%ProgramFiles%\WinRAR\WinRAR.exe"
    goto :download
)

REM Kiem tra WinRAR trong thu muc Program Files (x86)
if exist "%ProgramFiles(x86)%\WinRAR\WinRAR.exe" (
    echo [OK] Tim thay WinRAR trong Program Files (x86)
    set "EXTRACT_TOOL=winrar"
    set "WINRAR_PATH=%ProgramFiles(x86)%\WinRAR\WinRAR.exe"
    goto :download
)

echo [ERROR] Khong tim thay cong cu giai nen!
echo Vui long cai dat 7-Zip hoac WinRAR
pause
exit /b 1

:download
echo.
echo Dang tai Mesa3D tu: %DOWNLOAD_URL%
echo.

REM Thu curl truoc (neu co)
where curl >nul 2>&1
if %errorlevel% equ 0 (
    echo Su dung curl de tai file...
    curl -L -o "%FILENAME%" "%DOWNLOAD_URL%"
    if %errorlevel% equ 0 (
        if exist "%FILENAME%" (
            echo [OK] Tai file thanh cong voi curl!
            goto :extract_file
        )
    )
    echo [WARNING] Curl that bai, chuyen sang PowerShell...
)

REM Tao script PowerShell voi ho tro TLS 1.2 (cho Windows Server 2012)
echo Creating PowerShell download script with TLS 1.2 support...

REM Tao file PowerShell
echo [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 > download_script.ps1
echo try { >> download_script.ps1
echo     $webClient = New-Object System.Net.WebClient >> download_script.ps1
echo     $webClient.DownloadFile('%DOWNLOAD_URL%', '%FILENAME%') >> download_script.ps1
echo     Write-Host "[OK] Tai file thanh cong!" >> download_script.ps1
echo     exit 0 >> download_script.ps1
echo } catch { >> download_script.ps1
echo     Write-Host "[ERROR] Loi: $_" >> download_script.ps1
echo     exit 1 >> download_script.ps1
echo } >> download_script.ps1

REM Chay PowerShell script
echo Dang tai file voi PowerShell (bat TLS 1.2)...
powershell -ExecutionPolicy Bypass -File "%CURRENT_DIR%\download_script.ps1"

REM Xoa script tam
if exist "download_script.ps1" del "download_script.ps1"

REM Kiem tra file da tai
if not exist "%FILENAME%" (
    echo.
    echo [ERROR] Khong the tai file tu dong!
    echo.
    echo ========================================
    echo    TAI FILE THU CONG
    echo ========================================
    echo.
    echo Vui long tai file thu cong:
    echo.
    echo 1. Mo trinh duyet va truy cap:
    echo    %DOWNLOAD_URL%
    echo.
    echo 2. Luu file vao thu muc hien tai:
    echo    %CURRENT_DIR%
    echo.
    echo 3. Dam bao ten file la: %FILENAME%
    echo.
    echo 4. Sau khi tai xong, nhan phim bat ky de tiep tuc...
    echo.
    pause
    
    REM Kiem tra lai sau khi user tai thu cong
    if not exist "%FILENAME%" (
        echo [ERROR] Van khong tim thay file %FILENAME%
        echo Thoat chuong trinh.
        pause
        exit /b 1
    )
    echo [OK] Tim thay file da tai!
)

:extract_file
echo [OK] Tai file thanh cong!
echo.

echo Dang giai nen file...
echo.

REM Tao thu muc giai nen
if not exist "%EXTRACT_DIR%" mkdir "%EXTRACT_DIR%"

REM Giai nen file
if "%EXTRACT_TOOL%"=="7z" (
    %EXTRACT_CMD% "%FILENAME%" -o"%EXTRACT_DIR%" -y
) else if "%EXTRACT_TOOL%"=="winrar" (
    if defined WINRAR_PATH (
        "%WINRAR_PATH%" x "%FILENAME%" "%EXTRACT_DIR%\" -y
    ) else (
        %EXTRACT_CMD% "%FILENAME%" "%EXTRACT_DIR%\" -y
    )
)

if %errorlevel% neq 0 (
    echo [ERROR] Loi khi giai nen file
    goto :error
)

echo [OK] Giai nen thanh cong!
echo.

REM ==================== PHAN 2: CAI DAT ====================

:install
echo.
echo ========================================
echo    Bat dau cai dat System Wide
echo ========================================
echo.

REM Kiem tra quyen admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Script can quyen Administrator!
    echo Vui long chay lai voi quyen Administrator.
    echo.
    pause
    exit /b 1
)

echo [OK] Da co quyen Administrator
echo.

REM Kiem tra file systemwidedeploy.cmd
if not exist "mesa3d\systemwidedeploy.cmd" (
    echo [ERROR] Khong tim thay file systemwidedeploy.cmd
    echo.
    goto :manual_fallback
)

echo [OK] Tim thay file systemwidedeploy.cmd
echo.

REM Tao file VBS de tu dong gui phim
echo Tao script tu dong gui phim...
(
    echo Set WshShell = WScript.CreateObject^("WScript.Shell"^)
    echo WScript.Sleep 1000
    echo.
    echo ' Gui Enter dau tien
    echo WshShell.SendKeys "{ENTER}"
    echo WScript.Sleep 1000
    echo.
    echo ' Gui so 1
    echo WshShell.SendKeys "1"
    echo WScript.Sleep 500
    echo WshShell.SendKeys "{ENTER}"
    echo WScript.Sleep 500
    echo.
    echo ' Doi them 2 giay de qua trinh xu ly hoan thanh
    echo WScript.Sleep 500
    echo.
    echo ' Gui Enter lan 2
    echo WshShell.SendKeys "{ENTER}"
    echo WScript.Sleep 500
    echo.
    echo ' Gui so 9
    echo WshShell.SendKeys "9"
    echo WScript.Sleep 500
    echo WshShell.SendKeys "{ENTER}"
    echo WScript.Sleep 500
    echo.
    echo ' Gui Enter lan 3
    echo WshShell.SendKeys "{ENTER}"
    echo WScript.Sleep 500
) > autokeys.vbs

REM Chuyen den thu muc mesa3d
cd mesa3d

REM Chay VBS script de gui phim tu dong (chay background)
start /min wscript.exe "..\autokeys.vbs"

REM Chay systemwidedeploy.cmd
echo ===== BAT DAU CHAY SYSTEMWIDEDEPLOY.CMD =====
echo.
call systemwidedeploy.cmd

REM Kiem tra ket qua
if %errorlevel% equ 0 (
    set "INSTALL_SUCCESS=1"
    echo.
    echo [OK] Cai dat thanh cong!
) else (
    echo.
    echo [WARNING] Cai dat co the that bai
)

REM Doi 2 giay de xem ket qua
timeout /t 2 /nobreak

REM Quay lai thu muc goc
cd /d "%CURRENT_DIR%"

REM Xoa file tam
if exist "autokeys.vbs" del "autokeys.vbs"

REM Neu that bai, chuyen sang che do thu cong
if "%INSTALL_SUCCESS%"=="0" (
    goto :manual_fallback
)

goto :cleanup

REM ==================== PHAN 3: FALLBACK THU CONG ====================

:manual_fallback
echo.
echo ========================================
echo    Cai dat thu cong
echo ========================================
echo.
echo Cai dat tu dong that bai hoac khong kha dung.
echo.
echo Huong dan cai dat thu cong:
echo 1. Mo thu muc: mesa3d
echo 2. Chay file: systemwidedeploy.cmd (voi quyen Administrator)
echo 3. Chon cac tuy chon theo huong dan
echo.
echo Ban co muon mo thu muc mesa3d bay gio? (y/n)
set /p open_folder=
if /i "!open_folder!"=="y" (
    if exist "mesa3d\" (
        explorer "mesa3d"
        echo [OK] Da mo thu muc mesa3d
    ) else (
        echo [ERROR] Khong tim thay thu muc mesa3d
    )
)
goto :cleanup

REM ==================== PHAN 4: DON DEP ====================

:cleanup
echo.
echo ========================================
echo    Don dep
echo ========================================
echo.

REM Xoa file tai xuong
set "FULLPATH_FILENAME=%CURRENT_DIR%\%FILENAME%"
if exist "%FULLPATH_FILENAME%" (
    echo Tim thay file tai xuong: %FILENAME%
    echo Ban co muon xoa file nay? (y/n)
    set /p delete_choice=
    if /i "!delete_choice!"=="y" (
        del "%FULLPATH_FILENAME%"
        if exist "%FULLPATH_FILENAME%" (
            echo [WARNING] Khong the xoa file %FILENAME%
        ) else (
            echo [OK] Da xoa file tai xuong
        )
    ) else (
        echo [OK] Giu lai file tai xuong
    )
)

echo.
echo ========================================
echo    Hoan thanh!
echo ========================================
if "%INSTALL_SUCCESS%"=="1" (
    echo Mesa3D da duoc cai dat thanh cong!
) else (
    echo Vui long kiem tra huong dan cai dat thu cong o tren.
)
echo.
pause
exit /b 0

REM ==================== XU LY LOI ====================

:error
echo.
echo ========================================
echo    Co loi xay ra!
echo ========================================
echo Vui long kiem tra lai:
echo 1. Ket noi mang
echo 2. Cong cu giai nen
echo 3. Quyen ghi file
echo.
pause
exit /b 1