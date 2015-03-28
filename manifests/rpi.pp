class roles::rpi (
) {

  include '::profiles::base'

  include '::keepalived'
  keepalived::vrrp::instance { 'VI_DNS':
    interface         => 'eth0',
    state             => 'BACKUP',
    virtual_router_id => '50',
    priority          => '100',
    auth_type         => 'PASS',
    auth_pass         => 'secret',
    virtual_ipaddress => [ '192.168.1.2/24' ],
  }

}
