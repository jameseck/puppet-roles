class roles::elbuild (
) {

  include '::java'

  exec { 'yum groupinstall Development Tools':
    unless   => "/usr/bin/yum grouplist \"Development Tools\" | /bin/grep \"^Installed [Gg]roups\"",
    command  => "/usr/bin/yum -y groupinstall \"Development Tools\"",
    provider => 'shell',
  }

  package { 'maven':
    ensure => installed,
  }
  package { 'fakeroot':
    ensure => installed,
  }
  package { 'rpmlint':
    ensure => installed,
  }
  package { 'rpmdevtools':
    ensure => installed,
  }

}
