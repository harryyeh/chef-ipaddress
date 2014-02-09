#Check to see if this is from the bootstrap of the VM or if this is an individual run list
nodename = node[:set_hostname]
if nodename == nil
	nodename = node[:hostname]
end

db = data_bag_item(node['chef_ipaddress']['databag'], nodename)
interfaces = db['interfaces']


service "networking" do
	service_name "networking"
  action :restart
end

template "/etc/network/interfaces" do
	source "interfaces.erb"
	owner "root"	
	group "root"
  mode "0644"
  action :create
	variables :interfaces => interfaces
	#notifies :start, "service[networking]", :immediately
end
