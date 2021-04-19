$sccVersion            = '5.4'
$sccZipCheckSum        = 'FEB4FE6A6253FEDB96B69724CC3C03D406DD55AAE6E1652D9F69A8D10ACB7818'

$ErrorActionPreference = 'Stop';
$sccUnzipDir           = Join-Path -Path $env:TEMP -ChildPath 'NIWCASCC'
$sccInstallerDir       = Join-Path -Path $sccUnzipDir -ChildPath "SCC_$($sccVersion)_Windows"
$sccInstallExe         = Join-Path -Path $sccInstallerDir -ChildPath "SCC_$($sccVersion)_Windows_Setup.exe"
$sccSilentFilePath     = Join-Path -Path $sccInstallerDir -ChildPath 'SCC.inf'
$url                   = "https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/scc-$($sccVersion)_Windows_bundle.zip"

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

$sccLic = @"
IN NO EVENT SHALL THE UNITED STATES NAVY (OR GOVERNMENT) OR ANY 
EMPLOYEES THEREOF BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, 
SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST 
PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND/ OR ITS 
DOCUMENTATION, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE, 
NOR SHALL THE UNITED STATES NAVY (OR GOVERNMENT) OR ANY EMPLOYEES
THEREOF ASSUME ANY LEGAL LIABILITY OR RESPONSIBILITY FOR THE 
ACCURACY, COMPLETENESS, OR USEFULNESS OF THIS SOFTWARE AND/OR ITS 
DOCUMENTATION.

THE UNITED STATES NAVY (OR GOVERNMENT) SPECIFICALLY DISCLAIMS ANY 
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE 
SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER 
IS PROVIDED "AS IS". THE UNITED STATES NAVY (OR GOVERNMENT) HAS NO
OBLIGATION HEREUNDER TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, 
ENHANCEMENTS, OR MODIFICATIONS. ANY REPRODUCTION OF THIS WORK MUST 
INCLUDED THE ABOVE NOTICES AND THE FOLLOWING NOTICE: "PORTIONS OF 
THIS SOFTWARE ARE OFFICIAL WORKS OF THE U.S. GOVERNMENT. THE U.S. 
GOVERNMENT MAY PUBLISH OR REPRODUCE THIS SOFTWARE, OR ALLOW OTHERS 
TO DO SO, FOR ANY PURPOSE WHATSOEVER."

FOR MORE INFORMATION CONTACT:
OFFICE OF INTELLECTUAL PROPERTY
NAVAL INFORMATION WARFARE CENTER PACIFIC
SAN DIEGO, CA 92152
"@

# Print the license agreement, throw if not agreed
$sccLic | Write-Warning 
$Response = Read-Host -Prompt "DO YOU ACCEPT THE ABOVE LICENSE [Y(es)/N(o)]?"
If (($Response -notmatch 'y') -and ($Response -notmatch 'yes')) {
    Throw "You must agree to the license agreement to install the software"
}

# Unzip the package
$unzipArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $sccUnzipDir
  url           = $url
  checksum      = $sccZipCheckSum
  checksumType  = 'sha256'
}
Install-ChocolateyZipPackage @unzipArgs

# Add the inf-file
$sccSilentFilecontent | Out-File -FilePath $sccSilentFilePath -Encoding ASCII -Force

# Install
$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  file          = $sccInstallExe
  softwareName  = "SCAP Compliance Checker $sccVersion"

  silentArgs    = "/LOADINF=""$sccSilentFilePath"" /VERYSILENT /SUPPRESSMSGBOXES"
  validExitCodes= @(0, 3010, 1641)
}
Install-ChocolateyInstallPackage @packageArgs