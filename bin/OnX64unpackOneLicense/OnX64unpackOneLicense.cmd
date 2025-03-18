@echo off
if "%1"=="runas" (
  cd %~dp0
  echo Adminstrator mode
  if exist "C:\Program Files (x86)\TSplus\UserDesktop\files\OneLicenseBak.dll" (
  echo File seems already unpacked
  goto :end
  )

  if exist "C:\Program Files (x86)\TSplus\UserDesktop\files\OneLicense_notamper.dll" del "C:\Program Files (x86)\TSplus\UserDesktop\files\OneLicense_notamper.dll"

  if exist "C:\Program Files (x86)\TSplus\UserDesktop\files\OneLicense.dll" (
  ConfuseExDAntitamper.exe "C:\Program Files (x86)\TSplus\UserDesktop\files\OneLicense.dll"
  if exist "C:\Program Files (x86)\TSplus\UserDesktop\files\OneLicense_notamper.dll" (
  echo Anti-tamper succesfully removed
  ) else (
  copy "C:\Program Files (x86)\TSplus\UserDesktop\files\OneLicense.dll" "C:\Program Files (x86)\TSplus\UserDesktop\files\OneLicense_notamper.dll"
  )

  if exist "C:\Program Files (x86)\TSplus\UserDesktop\files\OneLicense_notamper.dll" (
  ConfuserEx-Unpacker.exe -d "C:\Program Files (x86)\TSplus\UserDesktop\files\OneLicense_notamper.dll"
    if exist "C:\Program Files (x86)\TSplus\UserDesktop\files\OneLicense_notampercleaned.dll" (
    echo File succesfully unpacked
    if exist "C:\Program Files (x86)\TSplus\UserDesktop\files\OneLicenseBak.dll" del "C:\Program Files (x86)\TSplus\UserDesktop\files\OneLicenseBak.dll"
    ren "C:\Program Files (x86)\TSplus\UserDesktop\files\OneLicense.dll" OneLicenseBak.dll
    ren "C:\Program Files (x86)\TSplus\UserDesktop\files\OneLicense_notampercleaned.dll" OneLicense.dll
    )
  )
  )



) else (
  powershell Start -File "cmd '/K %~f0 runas'" -Verb RunAs
)

  :end
