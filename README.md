# EzLab v1.0
This project is designed to help create virtual machine and hacking lab on Virtual Box on Windows faster and more convenient
## Installation 
Use [git]("https://git-scm.com/") to install:
```bash
git clone https://github.com/mdphuc/ezlab.git
```
## Usage
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
```powershell
./setup.ps1 vm & ./setup.ps1 vuln
```
<img width="550" alt="commandvm" src="https://github.com/mdphuc/hacklab/assets/41264640/5cf68ab6-c555-4c98-811d-9a31e207b4f0">

## Recommended System Requirement
- Windows 10+
- Virtual Box 7+ 

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you think should be changed.

## Constraints
This works fine on Powershell 5+ and Virtual Box 7.
For Virtual Box 6., please replace line 197:
```
$machine = $machine.SubString(5,$machine.Length - 5 - 15 - $lab_number.Length -2 -19 -2)
```
to this 
```
$machine = $machine.SubString(5,$machine.Length - 5 - 15 - $lab_number.Length -2)
```
and also replace line 194:
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
