#Check to see if this is from the bootstrap of the VM or if this is an individual run list
nodename = node['set_hostname']
if nodename == nil
    nodename = node['hostname']
end

db = data_bag_item(node['chef_ipaddress']['databag'], nodename)
interfaces = db['interfaces']

if platform_family?('debian')
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
        notifies :restart, "service[networking]"
    end
end

if platform_family?('rhel')
    service 'network' do
        provider Chef::Provider::Service::Systemd
        action :nothing
    end

    interfaces.each do |inter|
        template "/etc/sysconfig/network-scripts/ifcfg-#{inter}" do
            source 'ifcfg-interface.erb'
            owner 'root'
            group 'root'
            mode '0644'
            action :create
            variables :interfaces => interfaces
            notifies :restart, 'service[network]'
        end
    end
end
