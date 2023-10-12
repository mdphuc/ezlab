from pyvis.network import Network
from IPython.core.display import display, HTML
import sys

sys.argv.remove(sys.argv[0])

net = Network(height="1500px",width="100%",bgcolor="#222222", font_color="white", directed=True)
# nodes = ["a","b","c","d"]
# labels = ["A","B","C","D"]
# net.add_nodes(nodes, label=labels)
# net.add_edge("a","b")


for items in sys.argv:
    item = items.split("-")
    print(item)
    if(item[1] == "VM"):
      net.add_node(item[0], label=item[0], shape="square", color="blue")
    elif(item[1] == "Vuln"):
      net.add_node(item[0], label=item[0], shape="square", color="red")
    else:
      net.add_node(item[0], label=item[0], shape="circle", color="green") 

net.repulsion()
net.show("nodes1.html", notebook=False)
display(HTML("nodes1.html"))
