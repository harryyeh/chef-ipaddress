# Check to see if this is from the bootstrap of the VM,
# or if this is an individual run list
nodename = node['set_hostname'].nil? ? node['hostname'] : node['set_hostname']

db = data_bag_item(node['chef_ipaddress']['databag'], nodename)
interfaces = db['interfaces']

if platform_family?('debian')
  service 'networking' do
    provider Chef::Provider::Service::Upstart
    action :nothing
  end

  template '/etc/network/interfaces' do
    source 'interfaces.erb'
    owner 'root'
    group 'root'
    mode '0644'
    action :create
    variables interfaces: interfaces
    notifies :restart, 'service[networking]'
  end
end

if platform_family?('rhel')
  service 'network' do
    provider Chef::Provider::Service::Systemd
    action :nothing
  end

  # Centos has a file per interface.
  interfaces.each do |inter|
    template "/etc/sysconfig/network-scripts/ifcfg-#{inter.first}" do
      source 'ifcfg-interface.erb'
      owner 'root'
      group 'root'
      mode '0644'
      action :create
      variables interfaces: interfaces
      notifies :restart, 'service[network]'
    end
  end
end
