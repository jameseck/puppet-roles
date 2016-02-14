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

  include '::profiles::keepalived_dns'

  postfix::hash { '/etc/postfix/sender_canonical':
    ensure  => 'present',
    content => "/^(.*)@(.*).je.home\$/     \${1}.\${2}@jehome.co.uk",
  }

  package { 'stunnel':
    ensure => installed,
  } ->
  file { '/etc/stunnel/blueyonder.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    source => 'puppet:///modules/roles/foreman/stunnel_blueyonder.conf',
  } ~>
  service { 'stunnel@blueyonder.service':
    ensure => running,
    enable => true,
  }

}
