class roles::media (
) {

  include '::git'

  # Describes the subsonic server

  # We'll also put the build requirements on this server,
  # since it's likely the only Ubuntu server I need

  # https://github.com/EugeneKay/subsonic



  mount { '/mnt/nasb':
    fstype => 'nfs4',
    atboot => true,
  }

  $package_list = [ 'openjdk-7-jdk', 'maven', 'lintian', 'fakeroot', ]

  package { $package_list:
    ensure => installed,
  }


  file { '/home/james/gittmp':
    ensure => directory,
    owner  => 'james',
    group  => 'james',
    mode   => '0755',
  }

  vcsrepo { '/home/james/gittmp/subsonic':
    ensure   => present,
    provider => 'git',
    source   => 'https://github.com/EugeneKay/subsonic',
  }


}
