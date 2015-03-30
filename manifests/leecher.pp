class roles::leecher (
) {

  include '::git'
  include '::nginx'
  include '::sabnzbd'

  class { 'profiles::atrpms':
    atrpms_include => 'unrar*',
  }

  package { 'rtorrent':
    ensure => installed,
  }

  package { 'php':
    ensure => installed,
  }

  package { 'unrar':
    ensure => installed,
  }

  vcsrepo { '/opt/rutorrent':
    ensure   => present,
    provider => 'git',
    user     => 'james',
    source   => 'https://github.com/Novik/ruTorrent',
  } ->
  nginx::resource::vhost { 'rutorrent':
    www_root            => '/opt/rutorrent',
    location_cfg_append => {
      'include'   => 'scgi_params',
      'scgi_pass' => 'localhost:5000',
    },
  }

  package { 'nfs-utils':
    ensure => installed,
  } ->
  file { '/mnt/nasa':
    ensure => directory,
  } ->
  mount { '/mnt/nasa':
    ensure  => 'mounted',
    device  => 'nasa.je.home:/data',
    fstype  => 'nfs4',
    options => 'defaults',
    atboot  => true,
  } ->
  file { '/mnt/nasa/rtorrent':
    ensure => directory,
    owner  => 'james',
    group  => 'james',
    mode   => '0700',
  } ->
  file { '/mnt/nasa/rtorrent/drop':
    ensure => directory,
    owner  => 'james',
    group  => 'james',
    mode   => '0700',
  } ->
  file { '/mnt/nasa/rtorrent/downloads':
    ensure => directory,
    owner  => 'james',
    group  => 'james',
    mode   => '0700',
  }

  file { '/mnt/nasb':
    ensure => directory,
  } ->
  mount { '/mnt/nasb':
    ensure  => 'mounted',
    device  => 'nasb.je.home:/data',
    fstype  => 'nfs4',
    options => 'defaults',
    atboot  => true,
  }

}
