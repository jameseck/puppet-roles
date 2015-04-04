class roles::foreman (
) {

  sysctl { 'net.ipv4.ip_nonlocal_bind':
    ensure    => 'present',
    permanent => 'yes',
    value     => '1',
  }

  sudo::conf { 'foreman-proxy-puppetcert':
    priority => 10,
    content  => 'foreman-proxy ALL = NOPASSWD: /usr/bin/puppet cert *',
  }
  sudo::conf { 'foreman-proxy-norequiretty':
    priority => 11,
    content  => 'Defaults:foreman-proxy !requiretty',
  }

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
