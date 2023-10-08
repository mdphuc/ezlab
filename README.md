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
```
```powershell
./setup.ps1 vm & ./setup.ps1 vuln
```
<img width="550" alt="commandvm" src="https://github.com/mdphuc/hacklab/assets/41264640/5cf68ab6-c555-4c98-811d-9a31e207b4f0">

## Recommended System Requirement
- Windows 10+
- 8GB is fine, 16GB+ is recommended

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you think should be changed.

## License
[MIT](https://choosealicense.com/licenses/mit/)
