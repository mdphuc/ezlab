# EzLab v1.0
<img src=https://github.com/mdphuc/ezlab/assets/41264640/f062bde3-ba74-48c8-bff1-5be0387aee90 style="width:250px;height:auto">

This project is designed to help create, view, maintain virtual machine and hacking lab on Virtual Box on Windows faster and more convenient
## Installation 
Use ```[git]("https://git-scm.com/")``` to install:
```bash
git clone https://github.com/mdphuc/ezlab.git
```
## Usage
run ```pip install -r requirement.txt```
```powershell
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
        help: help
        show: build graph
```

## Recommended System Requirement
- Windows 10+
- Virtual Box 6+
- Function ```graph``` can only work on Virtual Box version 7+ - which support ```guest addition```
- ```unintended install``` when calling ```vm``` or ```vuln``` can work on Virtual Box 6.x, but there's no gurantee it will give a complete unexpected install process like in version 7.x of Virtual Box

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you think should be changed.

## Constraints
This works fine on Powershell 5+ and Virtual Box 7.x
For Virtual Box 6.x, please replace line 202:
```
$machine = $machine.SubString(5,$machine.Length - 5 - 15 - $lab_number.Length -2 -19 -2)
```
to this 
```
$machine = $machine.SubString(5,$machine.Length - 5 - 15 - $lab_number.Length -2)
```
and also replace line 199:
```
$vmsl = Invoke-Command {.\VBoxManage.exe list -l vms | Select-String "/Lab$($lab_number)/VM" -Context 2,0 -CaseSensitive}
```
to this
```
$vmsl = Invoke-Command {.\VBoxManage.exe list -l vms | Select-String "/Lab$($lab_number)/VM" -Context 1,0 -CaseSensitive}
```
The number of labs is below 255

## License
[MIT](https://choosealicense.com/licenses/mit/)
