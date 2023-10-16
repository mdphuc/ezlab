def dhcpserver_get_detail(dhcpserver_detail, dhcp_name):
    dhcps = []
    for i in range(len(dhcp_name)):
        dhcps.append((dhcpserver_detail[i],dhcp_name[i]))

    return dhcps
        
    
    
