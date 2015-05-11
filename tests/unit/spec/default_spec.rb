require 'chefspec'
ChefSpec::Coverage.start!

describe 'chef-ipaddress::default' do
  before do
    stub_data_bag_item('servers', 'Fauxhai').and_return(ifaces)
  end

  centos_tmpl = '/etc/sysconfig/network-scripts/ifcfg'
  let(:ubuntu_tmpl) { chef_run.template('/etc/network/interfaces') }
  let(:ifaces) {
    {
      id: 'Fauxhai',
      interfaces: {
        eth0: {
        },
        eth1: {
        }
      }
    }
  }

  context 'centos' do
    let (:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '7.0',
        cookbook_path: '../')
    end

    it 'should run the default recipe' do
      chef_run.converge(described_recipe)
      expect(chef_run).to include_recipe('chef-ipaddress::default')
    end

    it 'should create centos network template' do
      chef_run.converge(described_recipe)
      ifaces[:interfaces].each do |k, v|
        expect(chef_run).to create_template("#{centos_tmpl}-#{k}")
          .with(owner: 'root', group: 'root', mode: '0644')
      end
    end

    it 'should notify the service' do
      chef_run.node.set['chef-ipaddress']['restart_networking'] = true
      chef_run.converge(described_recipe)

      ifaces[:interfaces].each do |k, v|
        expect(chef_run.template("#{centos_tmpl}-#{k}"))
          .to notify('service[network]').to(:restart)
      end
    end

    it 'should not notify the service' do
      chef_run.node.set['chef-ipaddress']['restart_networking'] = false
      chef_run.converge(described_recipe)

      ifaces[:interfaces].each do |k, v|
        expect(chef_run.template("#{centos_tmpl}-#{k}"))
          .to_not notify('service[network]').to(:restart)
        expect(chef_run.template("#{centos_tmpl}-#{k}"))
          .to notify('service[network]').to(:nothing)
      end
    end

    it 'should restart network service' do
      chef_run.node.set['chef-ipaddress']['restart_networking'] = true
      chef_run.converge(described_recipe)

      expect(chef_run).to restart_service('network')
    end

    it 'should not restart network service' do
      chef_run.node.set['chef-ipaddress']['restart_networking'] = false
      chef_run.converge(described_recipe)

      expect(chef_run).to_not restart_service('network')
    end
  end

  context 'ubuntu' do
    let (:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '12.04',
        cookbook_path: '../')
    end

    it 'should run the default recipe' do
      chef_run.converge(described_recipe)
      expect(chef_run).to include_recipe('chef-ipaddress::default')
    end

    it 'should create ubuntu network template' do
      chef_run.converge(described_recipe)
      expect(chef_run).to create_template('/etc/network/interfaces')
        .with(owner: 'root', group: 'root', mode: '0644')
    end

    it 'should notify the service' do
      chef_run.node.set['chef-ipaddress']['restart_networking'] = true
      chef_run.converge(described_recipe)

      expect(ubuntu_tmpl).to notify('service[networking]').to(:restart)
    end

    it 'should not notify the service' do
      chef_run.node.set['chef-ipaddress']['restart_networking'] = false
      chef_run.converge(described_recipe)

      expect(ubuntu_tmpl).to_not notify('service[networking]').to(:restart)
      expect(ubuntu_tmpl).to notify('service[networking]').to(:nothing)
    end

    it 'should restart networking service' do
      chef_run.node.set['chef-ipaddress']['restart_networking'] = true
      chef_run.converge(described_recipe)

      expect(chef_run).to restart_service('networking')
    end

    it 'should not restart networking service' do
      chef_run.node.set['chef-ipaddress']['restart_networking'] = false
      chef_run.converge(described_recipe)

      expect(chef_run).to_not restart_service('networking')
    end
  end
end
