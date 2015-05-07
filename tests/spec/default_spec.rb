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
          .converge(described_recipe)
    end

    it 'should run the default recipe' do
      expect(chef_run).to include_recipe('chef-ipaddress::default')
    end

    it 'should create centos network template' do
      ifaces[:interfaces].each do |inter|
        expect(chef_run).to create_template("#{centos_tmpl}-#{inter.first}")
          .with(
            owner: 'root',
            group: 'root',
            mode:  '0644'
        )

      expect(chef_run.template("#{centos_tmpl}-#{inter.first}"))
        .to notify('service[network]').to(:restart)
      end
    end
  end

  context 'ubuntu' do
    let (:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '12.04',
        cookbook_path: '../')
          .converge(described_recipe)
    end

    it 'should run the default recipe' do
      expect(chef_run).to include_recipe('chef-ipaddress::default')
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
