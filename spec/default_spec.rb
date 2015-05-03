require 'chefspec'

describe 'ipaddress::default' do
    let (:chef_run) {
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '12.04')
        .converge('ipaddress::default')
    }

    before do
        stub_data_bag_item('servers', 'Fauxhai').and_return('Fauxhai')
    end

    it 'should run the default recipe' do
        expect(chef_run).to include_recipe('ipaddress::default')
    end

    it 'should create ubuntu network template' do
        expect(chef_run).to render_file('/etc/network/interfaces')
    end

    #it 'should create centos network template' do
    #    expect(chef_run).to render_file('/tmp/derp')
    #end
end
