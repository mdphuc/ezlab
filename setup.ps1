$setting = $args[0]

$location = $(Invoke-Command {Get-Location}).ToString()
$drive = $($location)[0..1] -join ''
$user = $env:USERPROFILE

cd "$($drive)\Program Files\Oracle\VirtualBox"

if($setting -ne "vm" -And $setting -ne "os" -And $setting -ne "network" -And $setting -ne "firewall" -And $setting -ne "Vuln" -And $setting -ne "firewall_setup"){
    Write-Host "
./setup.ps1

    [lab number] : number of your lab
    [media path] : FULL PATH to the file download of your VM (e.g: C:/Users/path/to/your/<VM file>)
    [pfsense path] : FULL PATH to the file download of pfsense (e.g: C:/Users/path/to/the/<pfsense file>)
    [OS type] : for more information, run ./setup.ps1 os
    [CPU] : number of core (default: 2)
    [RAM] : amount of memory in MB (default : 1024)
    [VRAM] : Amount of video memory in MB (default: 12) 
    [size] : Size of your disk in MB (default: 30720)
    VM : setup VM
    Vuln : add Vulnerable VM to your environment
    network: setup internal network
    firewall: setup firewall (pfsense)
    firewall_setup: setup firewall (pfsense)
    "
}elseif($setting -eq "os"){
    Invoke-Command{.\VBoxManage list ostypes} | ForEach-Object -Process {Write-Host $_}
}elseif($setting -eq "vm"){
    $Json = Get-Content .\lab_machine.json -Raw | ConvertFrom-Json
    $JsonBase = @{}
    # $jsonBase = @{}
    $list = New-Object System.Collections.Arraylist
    # $Name = Read-Host "VM Name: "
    $lab_number = Read-Host "Lab number"
    $Name = Read-Host "Name"
    # $MediaPath = "$(Read-Host "Path: ")"
    $MediaPath = Read-Host "Path"
    # $OSType = Read-Host "OS: "
    $OSType = Read-Host "OS type"
    $CPU = Read-Host "CPU"
    $RAM = Read-Host "RAM (in MB)"
    $VRAM = Read-Host "VRAM (in MB)"
    $Size = Read-Host "Size (in MB)"
    if($CPU -eq $null -Or $CPU -lt 1){
        $CPU = 2
    }
    if($RAM -eq $null -Or $RAM -lt 100){
        $RAM = 1024
    }
     if($VRAM -eq $null -Or $VRAM -lt 7){
        $VRAM = 12
    }
     if($Size -eq $null -Or $Size -lt 5120){
        $Size = 30720
    }
    Write-Host $CPU, $RAM, $VRAM, $Size
    Write-Host $CPU.GetType(), $RAM.GetType(), $VRAM.GetType(), $Size.GetType()
    if($Name -eq $null -Or $MediaPath -eq $null -Or $OSType -eq $null){
        Write-Host "There are some problem associated with the value of VM Name, Path, or OS"
    
    }else{
        # $jsonBase.Add("$($lab_number)", $list)
        $VMNum = $(Invoke-Command {.\VBoxManage list vms}).Length
        try{
            Invoke-Command {.\VBoxManage createvm --name $Name --ostype $OSType --register}
            Invoke-Command {Start-Sleep -Milliseconds 2000;.\VBoxManage modifyvm $Name --cpus $CPU --memory $RAM --vram $VRAM} 
            Invoke-Command {Start-Sleep -Milliseconds 2000;.\VBoxManage modifyvm $Name --graphicscontroller vmsvga}
            Invoke-Command {Start-Sleep -Milliseconds 2000;.\VBoxManage createhd --filename "$($env:USERPROFILE)\VirtualBox VMs\$($Name)\$($Name).vdi" --size $Size --variant Standard}
            Invoke-Command {Start-Sleep -Milliseconds 2000;.\VBoxManage storagectl $Name --name "SATA Controller $($VMNum)" --add sata --bootable on}
            Invoke-Command {Start-Sleep -Milliseconds 2000;.\VBoxManage storageattach $Name --storagectl "SATA Controller $($VMNum)" --port 0 --device 0 --type hdd --medium "$($env:USERPROFILE)\VirtualBox VMs\$($Name)\$($Name).vdi"} 
            Invoke-Command {Start-Sleep -Milliseconds 2000;.\VBoxManage storagectl $Name --name "IDE Controller $($VMNum)" --add ide}
            Invoke-Command {Start-Sleep -Milliseconds 2000;.\VBoxManage storageattach $Name --storagectl "IDE Controller $($VMNum)" --port 0 --device 0 --type dvddrive --medium $MediaPath}
            Invoke-Command {.\VBoxManage modifyvm $Name --nic1 intnet}
            Invoke-Command {.\VBoxManage modifyvm $Name --intnet1 "IsolatedNetwork"}
        }catch{
            Write-Host $_
        }
        if($Json.$lab_number -eq "null"){
            $list.Add("$($Name)")
            $vm = @{"VM" = $list}
            $JsonBase.Add("$($lab_number)", $vm)
            $jsonBase | ConvertTo-Json -Depth 10 | Out-File ".\lab_machine.json"
        }else{
            $Json.$lab_number.VM += "$($Name)"
        }
        # $jsonBase | ConvertTo-Json -Depth 10 | Out-File ".\lab_machine.json"

    }

}elseif($setting -eq "firewall"){
    $VMNum = $(Invoke-Command {.\VBoxManage list vms}).Length
    $PfsensePath = Read-Host "Pfsense path"
    try{
        Invoke-Command {.\VBoxManage createvm --name pfsense --ostype FreeBSD_64 --register}
        Invoke-Command {.\VBoxManage modifyvm pfsense --cpus 2 --memory 1024 --vram 12} 
        Invoke-Command {.\VBoxManage createhd --filename "$($env:USERPROFILE)\VirtualBox VMs\pfsense\pfsense.vdi" --size 10240 --variant Standard}
        Invoke-Command {.\VBoxManage storagectl pfsense --name "SATA Controller $($VMNum)" --add sata --bootable on}
        Invoke-Command {.\VBoxManage storageattach pfsense --storagectl "SATA Controller $($VMNum)" --port 0 --device 0 --type hdd --medium "$($env:USERPROFILE)\VirtualBox VMs\pfsense\pfsense.vdi"} 
        Invoke-Command {.\VBoxManage storagectl pfsense --name "IDE Controller $($VMNum)" --add ide}
        Invoke-Command {.\VBoxManage storageattach pfsense --storagectl "IDE Controller $($VMNum)" --port 0 --device 0 --type dvddrive --medium $PfsensePath}
    }catch{
        Write-Host $_
    }
}elseif($setting -eq "network"){
    Invoke-Command {.\VBoxManage dhcpserver add --network=IsolatedNetwork --server-ip=10.38.1.1 --lower-ip=10.38.1.10 --upper-ip=10.38.1.140 --netmask=255.255.255.0 --enable}
}elseif($setting -eq "Vuln"){
    $lab_number = Read-Host "Lab number"
    $Name = Read-Host "Name"
    # $MediaPath = "$(Read-Host "Path: ")"
    $MediaPath = Read-Host "Path"
    # $OSType = Read-Host "OS: "
    $OSType = Read-Host "OS type"
    $CPU = Read-Host "CPU"
    $RAM = Read-Host "RAM (in MB)"
    $VRAM = Read-Host "VRAM (in MB)"
    $Size = Read-Host "Size (in MB)"
    if($CPU -eq $null -Or $CPU -lt 1){
        $CPU = 2
    }
    if($RAM -eq $null -Or $RAM -lt 100){
        $RAM = 1024
    }
     if($VRAM -eq $null -Or $VRAM -lt 7){
        $VRAM = 12
    }
     if($Size -eq $null -Or $Size -lt 5120){
        $Size = 30720
    }
    Write-Host $CPU, $RAM, $VRAM, $Size
    Write-Host $CPU.GetType(), $RAM.GetType(), $VRAM.GetType(), $Size.GetType()
    if($Name -eq $null -Or $MediaPath -eq $null -Or $OSType -eq $null){
        Write-Host "There are some problem associated with the value of VM Name, Path, or OS"
    
    }else{
        $VMNum = $(Invoke-Command {.\VBoxManage list vms}).Length
        try{
            Invoke-Command {.\VBoxManage createvm --name $Name --ostype $OSType --register}
            Invoke-Command {Start-Sleep -Milliseconds 2000;.\VBoxManage modifyvm $Name --cpus $CPU --memory $RAM --vram $VRAM} 
            Invoke-Command {Start-Sleep -Milliseconds 2000;.\VBoxManage modifyvm $Name --graphicscontroller vmsvga}
            Invoke-Command {Start-Sleep -Milliseconds 2000;.\VBoxManage createhd --filename "$($env:USERPROFILE)\VirtualBox VMs\$($Name)\$($Name).vdi" --size $Size --variant Standard}
            Invoke-Command {Start-Sleep -Milliseconds 2000;.\VBoxManage storagectl $Name --name "SATA Controller $($VMNum)" --add sata --bootable on}
            Invoke-Command {Start-Sleep -Milliseconds 2000;.\VBoxManage storageattach $Name --storagectl "SATA Controller $($VMNum)" --port 0 --device 0 --type hdd --medium "$($env:USERPROFILE)\VirtualBox VMs\$($Name)\$($Name).vdi"} 
            Invoke-Command {Start-Sleep -Milliseconds 2000;.\VBoxManage storagectl $Name --name "IDE Controller $($VMNum)" --add ide}
            Invoke-Command {Start-Sleep -Milliseconds 2000;.\VBoxManage storageattach $Name --storagectl "IDE Controller $($VMNum)" --port 0 --device 0 --type dvddrive --medium $MediaPath}
            Invoke-Command {.\VBoxManage modifyvm $Name --nic1 intnet}
            Invoke-Command {.\VBoxManage modifyvm $Name --intnet1 "IsolatedNetwork"}
        }catch{
            Write-Host $_
        }
        if($Json.$lab_number -eq "null"){
            $list.Add("$($Name)")
            $vm = @{"Vuln" = $list}
            $JsonBase.Add("$($lab_number)", $vm)
            $jsonBase | ConvertTo-Json -Depth 10 | Out-File ".\lab_machine.json"
        }else{
            $Json.$lab_number.VM += "$($Name)"
        }
       
    }
}

cd "$($location)"