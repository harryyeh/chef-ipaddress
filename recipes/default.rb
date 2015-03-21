#Check to see if this is from the bootstrap of the VM or if this is an individual run list
nodename = node[:set_hostname]
if nodename == nil
	nodename = node[:hostname]
end

db = data_bag_item(node['chef_ipaddress']['databag'], nodename)
interfaces = db['interfaces']

service "networking" do
  provider Chef::Provider::Service::Upstart
	service_name "networking"
  action :nothing
end

template "/etc/network/interfaces" do
	source "interfaces.erb"
	owner "root"	
	group "root"
  mode "0644"
  action :create
	variables :interfaces => interfaces
	#if network interface is reconfigured while 
	#bootstrapping a node, the bootstrapping process fails.
	#notifies :restart, "service[networking]"
end
