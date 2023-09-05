param($h, $Name, $MediaPath, $OSType, $CPU, $RAM, $VRAM, $Size)

cd "C:\Program Files\Oracle\VirtualBox"
$drive = $($(Invoke-Command {Get-Location}).ToString())[0..1] -join ''
$user = $env:USERPROFILE

if(($h -eq $null -And $Name -eq $null -And $MediaPath -eq $null -And $OSType -eq $null -And $CPU -eq $null -And $RAM -eq $null -And $VRAM -eq $null -And $Size -eq $null) -Or $h -eq "help" -Or $h -eq " "){
    Write-Host "
./setup.ps1 [name] [media path] [OS type] [CPU] [RAM] [VRAM] [size]
    [media path] : full path to the file download of your VM (e.g: C:/Users/<your-username>/Downloads/<VM file>)
    [OS type] : for more information, run ./setup.ps1 --os
    [CPU] : number of core (default: 2)
    [RAM] : amount of memory in MB (default : 2048)
    [VRAM] : Amount of video memory in MB (default: 12) 
    [size] : Size of your disk 
    "
}elseif(( $Name -ne $null -Or $MediaPath -ne $null -Or $OSType -ne $null -Or $CPU -ne $null -Or $RAM -ne $null -Or $VRAM -ne $null -Or $Size -ne $null) -And $h -ne "help" -And $h -ne $null){
Write-Host "
./setup.ps1 [name] [media path] [OS type] [CPU] [RAM] [VRAM] [size]
    [media path] : full path to the file download of your VM (e.g: C:/Users/<your-username>/Downloads/<VM file>)
    [OS type] : for more information, run ./setup.ps1 --os
    [CPU] : number of core (default: 2)
    [RAM] : amount of memory in MB (default : 2048)
    [VRAM] : Amount of video memory in MB (default: 12) 
    [size] : Size of your disk 
    "
}else{
    Write-Host("Hurray")
}

cd "C:\Users\Mai Dinh Phuc\Downloads"