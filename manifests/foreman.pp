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
  file { '/etc/keepalived/notify-keepalived.sh':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('roles/foreman/notify-keepalived.sh.erb'),
  } ->
  file { '/etc/keepalived/check-keepalived.sh':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/roles/foreman/check-keepalived.sh',
  } ->
  keepalived::vrrp::instance { 'VI_DNS':
    interface         => 'eth0',
    state             => 'MASTER',
    virtual_router_id => '50',
    priority          => '101',
    auth_type         => 'PASS',
    auth_pass         => 'secret',
    virtual_ipaddress => [ '192.168.1.2/24' ],
    notify_script     => '/etc/keepalived/notify-keepalived.sh',
    track_script      => 'checkscript',
  } ->
  keepalived::vrrp::script { 'checkscript':
    script   => '/etc/keepalived/check-keepalived.sh',
    interval => 2,
    rise     => 2,
    fall     => 2,
  }

}
