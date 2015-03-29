class roles::leecher (
) {

  include '::git'
  include '::nginx'

  package { 'rtorrent':
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

}
