$setting = $args[0]

$location = $(Invoke-Command {Get-Location}).ToString()
$drive = $($location)[0..1] -join ''
$user = $env:USERPROFILE
$username = $env:USERNAME

cd "$($drive)\Program Files\Oracle\VirtualBox"

if($setting -ne "vm" -And $setting -ne "os" -And $setting -ne "intnet" -And $setting -ne "Vuln" -And $setting -ne "natnet" -And $setting -ne "remove_machine" -And $setting -ne "remove_lab" -And $setting -ne "clone" -And $setting -ne "upgrade" -And $setting -ne "ova" -And $setting -ne "lab" -And $setting -ne "network_remove" -And $setting -ne "dhcp" -And $setting -ne "graph"){
    Write-Host "
./setup.ps1

    [lab number] : number of your lab
    [Name] : name of your VM
    [Path] : FULL PATH to the file download of your VM (e.g: C:/Users/path/to/your/<VM file>) (iso file)
    [OS type] : for more information, run ./setup.ps1 os
    [CPU] : number of core (default: 2)
    [RAM] : amount of memory in MB (default : 1024)
    [VRAM] : Amount of video memory in MB (default: 12) 
    [size] : Size of your disk in MB (default: 30720)
    
    vm: setup VM
    vuln: add Vulnerable VM to your environment
    ova: import ova file
        VM: create virtual machine
        Vuln: create vulnerable machine
    dhcp: dhcpserver
        create: create dhcp server
        list: list dhcp server
        remove: remove dhcp server
    intnet: list internal network
    remove_machine: remove a machine
    remove_lab: remove a lab
    clone: clone a machine
    lab: move machine to a different lab
    graph: graph of all machine in a lab 
    "
}elseif($setting -eq "os"){
    Invoke-Command{.\VBoxManage.exe list ostypes} | ForEach-Object -Process {Write-Host $_}
}elseif($setting -eq "vm"){
    $lab_number = Read-Host "Lab number"
    $Name = Read-Host "Name"
    
    $MediaPath = Read-Host "Path"
    $username = Read-Host "Username"
    $password = Read-Host "Password"
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
        $VMNum = $(Invoke-Command {.\VBoxManage.exe list vms}).Length
        try{
            Invoke-Command {.\VBoxManage.exe createvm --name $Name --ostype $OSType --register}
            Invoke-Command {.\VBoxManage.exe modifyvm $Name --groups "/Lab$($lab_number)/VM"}
            Invoke-Command {.\VBoxManage.exe modifyvm $Name --cpus $CPU --memory $RAM --vram $VRAM} 
            Invoke-Command {.\VBoxManage.exe modifyvm $Name --graphicscontroller vmsvga}
            Invoke-Command {.\VBoxManage.exe createhd --filename "$($env:USERPROFILE)\VirtualBox VMs\Lab$($lab_number)VM\$($Name)\$($Name).vdi" --size $Size --variant Standard}
            Invoke-Command {.\VBoxManage.exe storagectl $Name --name "SATA Controller $($VMNum)" --add sata --bootable on}
            Invoke-Command {.\VBoxManage.exe storageattach $Name --storagectl "SATA Controller $($VMNum)" --port 0 --device 0 --type hdd --medium "$($env:USERPROFILE)\VirtualBox VMs\Lab$($lab_number)VM\$($Name)\$($Name).vdi"} 
            Invoke-Command {.\VBoxManage.exe storagectl $Name --name "IDE Controller $($VMNum)" --add ide}
            # Invoke-Command {.\VBoxManage.exe storageattach $Name --storagectl "IDE Controller $($VMNum)" --port 0 --device 0 --type dvddrive --medium $MediaPath}
            Invoke-Command {.\VBoxManage.exe unattended install $Name --iso=$MediaPath --user=$username --password=$password}
            try{
                $NetworkName = "IsolatedNetwork$($lab_number)"
                Invoke-Command {.\VBoxManage.exe dhcpserver add --network=$NetworkName --server-ip="10.38.$($lab_number).1" --lower-ip="10.38.$($lab_number).10" --upper-ip="10.38.$($lab_number).140" --netmask=255.255.255.0 --enable}
            }catch{
                $ErrorActionPreference = "Continue"
            }
            Invoke-Command {.\VBoxManage.exe modifyvm $Name --nic1 intnet}
            Invoke-Command {.\VBoxManage.exe modifyvm $Name --intnet1 "IsolatedNetwork$($lab_number)"}
            Invoke-Command {.\VBoxManage.exe modifyvm $Name --nic2 nat}
            Write-Host "Successfully create virtual machine named $($Name)"
        }catch{
            Write-Host $_
        }
        
    }

}elseif($setting -eq "intnet"){
    Invoke-Command {.\VBoxManage.exe list intnets}
}elseif($setting -eq "dhcp"){
    $option = Read-Host "Option (create, list, remove)"
    if($option -eq "create" -And $option -ne "list" -And $option -ne "remove"){
        $NetworkName = Read-Host "Network Name"
        $ServerIP = Read-Host "Server IP"
        $LowerIP = Read-Host "Lower IP"
        $UpperIP = Read-Host "Upper IP"
        $SubnetMask = Read-Host "Subnet Mask"
        $ServerIP_examine = $ServerIP.Split(".")
        $ServerIP_examine = $ServerIP_examine[0] + "." + $ServerIP_examine[1] + "." + $ServerIP_examine[2]

        $serverip_check = Invoke-Command {.\VBoxManage.exe list -l dhcpservers | Select-String "$($ServerIP_examine)" -Context 1,0 -CaseSensitive}
        if($serverip_check -ne $null){
            Write-Host "A dhcpserver has that IP address. Run 'dhcp list' for more information"

        }else{
            try{
                Invoke-Command {.\VBoxManage.exe dhcpserver add --network=$NetworkName --server-ip=$ServerIP --lower-ip=$LowerIP --upper-ip=$UpperIP --netmask=$SubnetMask --enable}
                Write-Host "Successfully create network name $($NetworkName))"
            }catch{
                Write-Host $_
            }
        }
    }elseif($option -eq "list"){
        Invoke-Command {.\VBoxManage.exe list dhcpservers}
    }elseif($option -eq "remove"){
        $NetworkName = Read-Host "Network Name"
        Invoke-Command {.\VBoxManage.exe dhcpserver remove --network $NetworkName}
        Write-Host "Successfully delete network name $($(NetworkName))"
    }else{
        Write-Host "Invalid Option"
    }
}elseif($setting -eq "Vuln"){
    $lab_number = Read-Host "Lab number"
    $Name = Read-Host "Name"
    
    $MediaPath = Read-Host "Path"
    
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
        $VMNum = $(Invoke-Command {.\VBoxManage.exe list vms}).Length
        try{
            Invoke-Command {.\VBoxManage.exe createvm --name $Name --ostype $OSType --register}
            Invoke-Command {.\VBoxManage.exe modifyvm $Name --groups "/Lab$($lab_number)/Vuln"}
            Invoke-Command {.\VBoxManage.exe modifyvm $Name --cpus $CPU --memory $RAM --vram $VRAM} 
            Invoke-Command {.\VBoxManage.exe modifyvm $Name --graphicscontroller vmsvga}
            Invoke-Command {.\VBoxManage.exe createhd --filename "$($env:USERPROFILE)\VirtualBox VMs\Lab$($lab_number)Vuln\$($Name)\$($Name).vdi" --size $Size --variant Standard}
            Invoke-Command {.\VBoxManage.exe storagectl $Name --name "SATA Controller $($VMNum)" --add sata --bootable on}
            Invoke-Command {.\VBoxManage.exe storageattach $Name --storagectl "SATA Controller $($VMNum)" --port 0 --device 0 --type hdd --medium "$($env:USERPROFILE)\VirtualBox VMs\Lab$($lab_number)Vuln\$($Name)\$($Name).vdi"} 
            Invoke-Command {.\VBoxManage.exe storagectl $Name --name "IDE Controller $($VMNum)" --add ide}
            Invoke-Command {.\VBoxManage.exe storageattach $Name --storagectl "IDE Controller $($VMNum)" --port 0 --device 0 --type dvddrive --medium $MediaPath}
            try{
                $NetworkName = "IsolatedNetwork$($lab_number)"
                Invoke-Command {.\VBoxManage.exe dhcpserver add --network=$NetworkName --server-ip="10.38.$($lab_number).1" --lower-ip="10.38.$($lab_number).10" --upper-ip="10.38.$($lab_number).140" --netmask=255.255.255.0 --enable}
            }catch{
                $ErrorActionPreference = "Continue"
            }
            Invoke-Command {.\VBoxManage.exe modifyvm $Name --nic1 intnet}
            Invoke-Command {.\VBoxManage.exe modifyvm $Name --intnet1 "IsolatedNetwork$($lab_number)"}
            Write-Host "Successfully create vuln machine named $($Name)"
        }catch{
            Write-Host $_
        }
       
    }
}elseif($setting -eq "remove_machine"){
    $lab_number = Read-Host "Lab number"
    $Name = Read-Host "Name"
    try{
        Invoke-Command {.\VBoxManage.exe modifyvm $machine --groups ""}
        Invoke-Command {.\VBoxManage.exe unregistervm $Name --delete}
        Invoke-Command {.\VBoxManage.exe dhcpserver remove --network "IsolatedNetwork$($lab_number)"}
        Write-Host "Successfully delete machine named $($Name)"
    }catch{
        Write-Host $_
    }
}elseif($setting -eq "remove_lab"){
    $lab_number = Read-Host "Lab number"
    $vmsl = Invoke-Command {.\VBoxManage.exe list -l vms | Select-String "/Lab$($lab_number)/VM" -Context 2,0 -CaseSensitive}
    ForEach($machine in $vmsl){
        $machine = $machine -replace " ",""
        $machine = $machine.SubString(5,$machine.Length - 5 - 15 - $lab_number.Length -2 -19 -2)
        Write-Host $machine
        try{
            Invoke-Command {.\VBoxManage.exe modifyvm $machine --groups ""}
            Invoke-Command {.\VBoxManage.exe unregistervm $machine --delete}
            Invoke-Command {.\VBoxManage.exe dhcpserver remove --network "IsolatedNetwork$($lab_number)"}
            Write-Host "Successfully delete lab named Lab$($lab_number)"
        }catch{
            Write-Host $_
        }
    }
}elseif($setting -eq "clone"){
    $Name = Read-Host "Name of the machine you want to clone"
    $Type = Read-Host "Type (VM, Vuln, Router)"
    if ($Type -ne "VM" -AND $Type -ne "Vuln" -AND $Type -ne "Router"){
        Write-Host "Invalid Type"
    }else{
        $Name_clone = Read-Host "Name of new machine"
        $lab_number = Read-Host "Lab number" 
        try{
            Invoke-Command {.\VBoxManage.exe clonevm $Name --name $Name_clone --register --mode=all}
            Invoke-Command {.\VBoxManage.exe modifyvm $Name_clone --groups "/Lab$($lab_number)/$($Type)"}
            Invoke-Command {.\VBoxManage.exe dhcpserver add --network=$NetworkName --server-ip="10.38.$($lab_number).1" --lower-ip="10.38.$($lab_number).10" --upper-ip="10.38.$($lab_number).140" --netmask=255.255.255.0 --enable}

            Invoke-Command {.\VBoxManage.exe modifyvm $Name_clone --intnet1 "IsolatedNetwork$($lab_number)"}
            Write-Host "Successfully clone $($Name)"
        }catch{
            Write-Host $_
        }
    }
}elseif($setting -eq "lab"){
    $Name = Read-Host "Name of the machine you want to move:"
    $lab_number = Read-Host "Lab Destination"
    try{
        Invoke-Comamnd {.\VBoxManage.exe modifyvm $Name --groups "Lab$($lab_number)/VM"}
        Invoke-Command {.\VBoxManage.exe modifyvm $Name --intnet1 "IsolatedNetwork$($lab_number)"}
        Write-Host "Successfully move machine named $($Name) to Lab Lab$($lab_number)"
    }catch{
        Write-Host $_
    }
}elseif($setting -eq "ova"){
    $lab_number = Read-Host "Lab number"
    $Name = Read-Host "Name"
    $Type = Read-Host "Type (VM, Vuln)"
    if($Type -eq "VM" -Or $Type -eq "Vuln"){
        $MediaPath = Read-Host "Path"
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
            $VMNum = $(Invoke-Command {.\VBoxManage.exe list vms}).Length
            try{
                Invoke-Command {.\VBoxManage.exe import $MediaPath --vsys 0 --vmname $Name --cpus $CPU --memory $RAM}
                Invoke-Command {.\VBoxManage.exe modifyvm $Name --groups "/Lab$($lab_number)/$($Type)"}
                try{
                    $NetworkName = "IsolatedNetwork$($lab_number)"
                    Invoke-Command {.\VBoxManage.exe dhcpserver add --network=$NetworkName --server-ip="10.38.$($lab_number).1" --lower-ip=10.38.$(lab_number).10 --upper-ip=10.38.$(lab_number).140 --netmask=255.255.255.0 --enable}
                }catch{
                    $ErrorActionPreference = "Continue"
                }
                if($Type -eq "VM" -And $Type -ne "Vuln"){
                    Invoke-Command {.\VBoxManage.exe modifyvm $Name --nic1 intnet}
                    Invoke-Command {.\VBoxManage.exe modifyvm $Name --intnet1 "IsolatedNetwork$($lab_number)"}
                    Write-Host "Successfully create virtual machine named $($Name)"
                }elseif($Type -eq "Vuln"){
                    Invoke-Command {.\VBoxManage.exe modifyvm $Name --nic1 intnet}
                    Invoke-Command {.\VBoxManage.exe modifyvm $Name --intnet1 "IsolatedNetwork$($lab_number)"}
                    Invoke-Command {.\VBoxManage.exe modifyvm $Name --nic2 nat}
                    Write-Host "Successfully create vuln machine named $($Name)"
                }
            }catch{
                Write-Host $_
            }
        
        }
    }else{
        Write-Host "Invalid Type"
    }
}elseif($setting -eq "graph"){
    $option = Read-Host "Option (help, show)"
    if($option -ne "help" -AND $option -ne "show"){
        Write-Host "Invalid option"
    }elseif($option -eq "help"){
        Write-Host "
Blue Rectangle: virtual machine
Red Rectangle: bulnerable machine
Ping Triangle: server
Green Circle: router, switch, etc
White Circle: unknown
        "
    }elseif($option -eq "show"){
        $lab_number = Read-Host "Lab number"
        $vmsl = Invoke-Command {.\VBoxManage.exe list -l vms | Select-String "/Lab$($lab_number)/VM" -Context 2,0 -CaseSensitive}
        $machine_graph = @()
        ForEach($machine in $vmsl){
            $machine = $machine -replace " ",""
            $machine_name = $machine.SubString(5,$machine.Length - 5 - 15 - $lab_number.Length -2 -19 -2)
            $machine_type = $machine.SubString($machine.Length-2,2)
            $machine_combine = $machine_name + "-" + $machine_type
            $machine_graph += @($machine_combine)
        }


        cd "$($env:USERPROFILE)\AppData\Local\Programs\Python\Python39"
        Invoke-Command {.\python.exe "$($location)/graph.py" $($machine_graph)}
        cd "$($drive)\Program Files\Oracle\VirtualBox"
    }
}


cd "$($location)"