# HackLab v1.0
The project is designed to help create virtual machine and hacking lab on Virtual Box faster on Windows
## Installation 
Use [git]("https://git-scm.com/") to install:
```bash
git clone https://github.com/mdphuc/hacklab.git
```
## Usage
```powershell
./setup.ps1 <command>

    [lab number] : number of your lab
    [media path] : FULL PATH to the file download of your VM (e.g: C:/Users/path/to/your/<VM file>)
    [pfsense path] : FULL PATH to the file download of pfsense (e.g: C:/Users/path/to/the/<pfsense file>)
    [OS type] : for more information, run ./setup.ps1 os
    [CPU] : number of core (default: 2)
    [RAM] : amount of memory in MB (default : 1024)
    [VRAM] : Amount of video memory in MB (default: 12) 
    [size] : Size of your disk in MB (default: 30720)

    vm : setup VM
    vuln : add Vulnerable VM to your environment
    intnet: setup internal network
    natnet: attach VM to NAT
```
##### Should use setup.ps1 and lab.json in the same directory
```powershell
./setup.ps1 vm & ./setup.ps1 vuln
```
<img width="550" alt="commandvm" src="https://github.com/mdphuc/hacklab/assets/41264640/5cf68ab6-c555-4c98-811d-9a31e207b4f0">

## Recommended System Requirement
- Windows 10+
- 16GB+ of RAM

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you think should be changed.

## License
[MIT](https://choosealicense.com/licenses/mit/)
