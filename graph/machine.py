def machine_get_detail(machine_detail):
  machine = []
  for detail in machine_detail:
    detail = detail.split("/")
    nics = []
    title = ""
    for i in range(4,4 + int(detail[0])):
      nic = detail[i].split(":")
      nic_name = nic[0].split("+")
      network = nic[1].split(";")
      ip = network[0].split(",")
      netmask = network[1].split(",")
      nics.append((nic_name[0],nic_name[1],f"IP: {ip[1]}",f"Netmask: {netmask[1]}"))
    for n in nics:
      for i in range(len(n)):
        title += n[i] + "\n"
      title += "\n"

    if(detail[2] == "VM"):
      machine.append([detail[1],"square","blue",title,nics])
    elif(detail[2] == "Vuln"):
      machine.append([detail[1],"square","red",title,nics])

  return machine
