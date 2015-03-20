class roles::elbuild (
) {

  include '::profiles::base'

  exec { 'yum groupinstall Development Tools':
    unless   => "/usr/bin/yum grouplist \"Development Tools\" | /bin/grep \"^Installed [Gg]roups\"",
    command  => "/usr/bin/yum -y groupinstall \"Development Tools\"",
    provider => 'shell',
  }

  package { 'Development Tools':
    ensure => installed,
  }

}
