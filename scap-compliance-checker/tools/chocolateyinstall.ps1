$sccVersion            = '5.4'
$sccZipCheckSum        = 'FEB4FE6A6253FEDB96B69724CC3C03D406DD55AAE6E1652D9F69A8D10ACB7818'
$sccZipCheckSumType    = 'sha256'

$ErrorActionPreference = 'Stop'
$sccUnzipDir           = Join-Path -Path $env:TEMP -ChildPath 'NIWCASCC'
$sccInstallerZipPath   = Join-Path -Path $sccUnzipDir -ChildPath 'scc.zip'
$sccInstallerDir       = Join-Path -Path $sccUnzipDir -ChildPath "SCC_$($sccVersion)_Windows"
$sccInstallExe         = Join-Path -Path $sccInstallerDir -ChildPath "SCC_$($sccVersion)_Windows_Setup.exe"
$sccSilentFilePath     = Join-Path -Path $sccInstallerDir -ChildPath 'SCC.inf'

$sccSilentFilecontent  = @"
[Setup]
Lang=english
Dir=C:\Program Files\SCAP Compliance Checker $sccVersion
Group=SCAP Compliance Checker $sccVersion
NoIcons=0
SetupType=custom
Components=core,Content\NIST_USGCB_SCAP_Content,Content\DISA_STIG_SCAP_Content 
Task=
"@
$url                   = "https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/scc-$($sccVersion)_Windows_bundle.zip"

# Get the zip
$GetWebFileParams      = @{
  Url                  = $url
  FileName             = $sccInstallerZipPath
}
Get-WebFile              @GetWebFileParams

# Test checksum of zip
$GetChecksvParams      = @{
  File                 = $sccInstallerZipPath
  Checksum             = $sccZipCheckSum
  ChecksumType         = $sccZipCheckSumType
  OriginalUrl          = $url
}
Get-ChecksumValid @GetChecksvParams

# Expand the zip to a temporary filder
$GetChocoUnzipParams   = @{
  FileFullPath         = $sccInstallerZipPath
  Destination          = $sccUnzipDir
}
Get-ChocolateyUnzip      @GetChocoUnzipParams

# Create the options file
$sccSilentFilecontent | 
Out-File -FilePath $sccSilentFilePath -Encoding ASCII -Force

# Run the installer
$packageArgs           = @{
  packageName          = $env:ChocolateyPackageName
  file                 = $sccInstallExe
  softwareName         = "SCAP Compliance Checker $sccVersion"
  silentArgs           = "/LOADINF=""$sccSilentFilePath"" /VERYSILENT /SUPPRESSMSGBOXES"
  validExitCodes       = @(0, 3010, 1641)
}
Install-ChocolateyInstallPackage @packageArgs

# Remove the temporary downloaded content
Remove-Item -Path $sccUnzipDir -Force -Recurse -ErrorAction Ignore










    








