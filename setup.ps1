$setting = $args[0]

$location = $(Invoke-Command {Get-Location}).ToString()
$drive = $($location)[0..1] -join ''
$user = $env:USERPROFILE
$username = $env:USERNAME

cd "$($drive)\Program Files\Oracle\VirtualBox"

if($setting -ne "vm" -And $setting -ne "os" -And $setting -ne "intnet" -And $setting -ne "Vuln" -And $setting -ne "natnet"){
    Write-Host "
./setup.ps1

    [lab number] : number of your lab
    [Name] : name of your VM
    [Path] : FULL PATH to the file download of your VM (e.g: C:/Users/path/to/your/<VM file>)
    [OS type] : for more information, run ./setup.ps1 os
    [CPU] : number of core (default: 2)
    [RAM] : amount of memory in MB (default : 1024)
    [VRAM] : Amount of video memory in MB (default: 12) 
    [size] : Size of your disk in MB (default: 30720)
    
    vm : setup VM
    vuln : add Vulnerable VM to your environment
    intnet: setup internal network
    natnet: attach VM to NAT
    "
}elseif($setting -eq "os"){
    Invoke-Command{.\VBoxManage list ostypes} | ForEach-Object -Process {Write-Host $_}
}elseif($setting -eq "vm"){
    $jsonBase = @{}
    $list = New-Object System.Collections.ArrayList
    $vm = New-Object System.Collections.ArrayList
    $vuln = New-Object System.Collections.ArrayList
    $lab_number = Read-Host "Lab number"
    $machine = @{"VM"=$vm;"Vuln"=$vuln}
    $jsonBase.Add("$($lab_num)",$machine)
    $Json = Get-Content -Raw "$($location)\lab.json" | ConvertFrom-Json

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
    if($Name -eq $null -Or $MediaPath -eq $null -Or $OSType -eq $null){
        Write-Host "There are some problem associated with the value of VM Name, Path, or OS"
    
    }else{
        # $jsonBase.Add("$($lab_number)", $list)
        $VMNum = $(Invoke-Command {.\VBoxManage list vms}).Length
        try{
            Invoke-Command {.\VBoxManage createvm --name $Name --ostype $OSType --register}
            Invoke-Command {.\VBoxManage modifyvm $Name --cpus $CPU --memory $RAM --vram $VRAM} 
            Invoke-Command {.\VBoxManage modifyvm $Name --graphicscontroller vmsvga}
            Invoke-Command {.\VBoxManage createhd --filename "$($env:USERPROFILE)\VirtualBox VMs\$($Name)\$($Name).vdi" --size $Size --variant Standard}
            Invoke-Command {.\VBoxManage storagectl $Name --name "SATA Controller $($VMNum)" --add sata --bootable on}
            Invoke-Command {.\VBoxManage storageattach $Name --storagectl "SATA Controller $($VMNum)" --port 0 --device 0 --type hdd --medium "$($env:USERPROFILE)\VirtualBox VMs\$($Name)\$($Name).vdi"} 
            Invoke-Command {.\VBoxManage storagectl $Name --name "IDE Controller $($VMNum)" --add ide}
            Invoke-Command {.\VBoxManage storageattach $Name --storagectl "IDE Controller $($VMNum)" --port 0 --device 0 --type dvddrive --medium $MediaPath}
            Invoke-Command {.\VBoxManage modifyvm $Name --nic1 intnet}
            Invoke-Command {.\VBoxManage modifyvm $Name --intnet1 "IsolatedNetwork$($lab_number)"}
        }catch{
            Write-Host $_
        }
        if($Json.$lab_number -eq $null){
            $jsonBase | ConvertTo-Json -Depth 10 | Out-File "$($location)\lab.json"
            $Json.$lab_number.VM += "$($Name)"
        }else{
            $Json.$lab_number.VM += "$($Name)"
            $Json | ConvertTo-Json -Depth 10 | Out-File "$($location)\lab.json"
        }
        Write-Host "Successfully Created virtual machine named $($Name)"
    }

}elseif($setting -eq "intnet"){
    $lab_number = Read-Host "Lab number"
    $NetworkName = "IsolatedNetwork$($lab_number)"
    Invoke-Command {.\VBoxManage dhcpserver add --network=$NetworkName --server-ip=10.38.1.1 --lower-ip=10.38.1.10 --upper-ip=10.38.1.140 --netmask=255.255.255.0 --enable}
}elseif($setting -eq "natnet"){
    $Name = Read-Host "VM"
    Invoke-Command {.\VBoxManage modifyvm $Name --nic1 nat}
}elseif($setting -eq "Vuln"){
    $jsonBase = @{}
    $list = New-Object System.Collections.ArrayList
    $vm = New-Object System.Collections.ArrayList
    $vuln = New-Object System.Collections.ArrayList
    $lab_number = Read-Host "Lab number"
    $machine = @{"VM"=$vm;"Vuln"=$vuln}
    $jsonBase.Add("$($lab_number)",$machine)
    $Json = Get-Content -Raw "$($location)\lab.json" | ConvertFrom-Json

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
            Invoke-Command {.\VBoxManage modifyvm $Name --cpus $CPU --memory $RAM --vram $VRAM} 
            Invoke-Command {.\VBoxManage modifyvm $Name --graphicscontroller vmsvga}
            Invoke-Command {.\VBoxManage createhd --filename "$($env:USERPROFILE)\VirtualBox VMs\$($Name)\$($Name).vdi" --size $Size --variant Standard}
            Invoke-Command {.\VBoxManage storagectl $Name --name "SATA Controller $($VMNum)" --add sata --bootable on}
            Invoke-Command {.\VBoxManage storageattach $Name --storagectl "SATA Controller $($VMNum)" --port 0 --device 0 --type hdd --medium "$($env:USERPROFILE)\VirtualBox VMs\$($Name)\$($Name).vdi"} 
            Invoke-Command {.\VBoxManage storagectl $Name --name "IDE Controller $($VMNum)" --add ide}
            Invoke-Command {.\VBoxManage storageattach $Name --storagectl "IDE Controller $($VMNum)" --port 0 --device 0 --type dvddrive --medium $MediaPath}
            Invoke-Command {.\VBoxManage modifyvm $Name --nic1 intnet}
            Invoke-Command {.\VBoxManage modifyvm $Name --intnet1 "IsolatedNetwork$($lab_number)"}
        }catch{
            Write-Host $_
        }
        if($Json.$lab_number -eq $null){
            $jsonBase | ConvertTo-Json -Depth 10 | Out-File "$($location)\lab.json"
            $Json.$lab_number.VM += "$($Name)"
        }else{
            $Json.$lab_number.VM += "$($Name)"
            $Json | ConvertTo-Json -Depth 10 | Out-File "$($location)\lab.json"
        }
        Write-Host "Successfully Created vuln machine named $($Name)"
    }
}

cd "$($location)"