from pyvis.network import Network
from IPython.core.display import display, HTML
import sys
from graph import machine, dhcpserver

net = Network(height="1500px",width="100%",bgcolor="#222222", font_color="white", directed=True)

sys.argv.remove(sys.argv[0])

# vm and vuln machine detail
machine_detail = sys.argv[0].split("|")
machine_detail.remove(machine_detail[0])
machine_infos = machine.machine_get_detail(machine_detail)

#dhcpserver detail
dhcpserver_detail = sys.argv[1].split("/")

#add node to graph
for machine_info in machine_infos:
  try:
    net.add_node(machine_info[0], label=machine_info[0], shape=machine_info[1], color=machine_info[2], title=machine_info[3])
    dhcpserver_infos = dhcpserver.dhcpserver_get_detail(dhcpserver_detail, machine_info[4])
  except:
    pass
  try:
    for dhcp in dhcpserver_infos:
      net.add_node(dhcp[1][1], label=dhcp[1][1], shape="triangle",color="green", title=f"{dhcp[1][1]}"+"\n"+f"{dhcp[0]}"+"\n"+f"{dhcp[1][3]}" )
      net.add_edge(machine_info[0], dhcp[1][1])
  except:
    pass
#prepare html file and display
net.repulsion()
net.show("nodes1.html", notebook=False)
display(HTML("nodes1.html"))
