class roles::leecher (
) {

  include '::git'
  include '::nginx'

  package { 'rtorrent':
    ensure => installed,
  }

  package { 'php':
    ensure => installed,
  }

  vcsrepo { '/opt/rutorrent':
    ensure   => present,
    provider => 'git',
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
