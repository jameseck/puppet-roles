class roles::rpi (
) {

  include '::keepalived'
  keepalived::vrrp::instance { 'VI_DNS':
    interface         => 'eth0',
    state             => 'MASTER',
    virtual_router_id => '50',
    priority          => '101',
    auth_type         => 'PASS',
    auth_pass         => 'secret',
    virtual_ipaddress => [ '192.168.1.2/24' ],
  }

}
