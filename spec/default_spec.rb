require 'chefspec'
ChefSpec::Coverage.start!

describe 'ipaddress::default' do
  before do
    stub_data_bag_item('servers', 'Fauxhai').and_return(
      id: 'Fauxhai',
      interfaces: {
        eth0: {
          address: '10.1.1.1',
          netmask: '255.255.255.0',
          gateway: '10.1.1.255'
        }
      }
    )
  end

  let(:centos_tmpl) { chef_run.template('/etc/sysconfig/network-scripts/ifcfg-eth0') }
  let(:ubuntu_tmpl) { chef_run.template('/etc/network/interfaces') }

  context 'centos' do
    let (:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0')
        .converge('ipaddress::default')
    end

    it 'should run the default recipe' do
      expect(chef_run).to include_recipe('ipaddress::default')
    end

    it 'should create centos network template' do
      expect(chef_run).to create_template('/etc/sysconfig/network-scripts/ifcfg-eth0')
        .with(
          owner: 'root',
          group: 'root',
          mode:  '0644'
      )

      expect(centos_tmpl).to notify('service[network]').to(:restart)
    end
  end

  context 'ubuntu' do
    let (:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '12.04')
        .converge('ipaddress::default')
    end

    it 'should run the default recipe' do
      expect(chef_run).to include_recipe('ipaddress::default')
    end

    it 'should create ubuntu network template' do
      expect(chef_run).to create_template('/etc/network/interfaces').with(
        owner: 'root',
        group: 'root',
        mode:  '0644'
      )
      expect(ubuntu_tmpl).to notify('service[networking]').to(:restart)
    end
  end
end
