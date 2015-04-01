class roles::leecher (
) {

  include '::git'
  include '::nginx'
  include '::profiles::nux_desktop'

  class { 'sabnzbd':
    user     => 'james',
    group    => 'james',
    home_dir => '/home/james/.sabnzbd',
  }

  class { 'profiles::atrpms':
    atrpms_include => 'unrar*',
  }

  package { 'rtorrent':
    ensure => installed,
  }

  $php_packages = [ 'php-xml', 'php-common', 'php', 'php-cli', 'php-fpm', 'php-process', 'php-pecl-apcu', 'php-pear', ]

  package { $php_packages:
    ensure => installed,
  }

  package { 'unrar':
    ensure => installed,
  }

  package { 'ffmpeg':
    ensure => installed,
  }

  package { 'mediainfo':
    ensure => installed,
  }

  vcsrepo { '/opt/rutorrent':
    ensure   => present,
    provider => 'git',
    user     => 'james',
    source   => 'https://github.com/Novik/ruTorrent',
  }

  nginx::resource::vhost { 'rutorrent':
    ensure               => present,
    server_name          => [ $::fqdn ],
    www_root             => '/opt/rutorrent',
    ssl                  => true,
    listen_port          => '443',
    ssl_cert             => '/etc/nginx/rutorrent.crt',
    ssl_key              => '/etc/nginx/rutorrent.key',
    #listen_port          => '80',
    use_default_location => false,
    vhost_cfg_append     => {
      'try_files' => '$uri $uri/ =404',
    },
  }
#  nginx::resource::location { 'rutorrent_auth':
#    ensure         => present,
#    location       => '^~ /rutorrent',
#    vhost          => 'rutorrent',
#    location_alias => '/opt/rutorrent',
#  }
  nginx::resource::location { 'rutorrent_php':
    ensure              => present,
    location            => '~ \.php$',
    vhost               => 'rutorrent',
    ssl                 => true,
    ssl_only            => true,
    www_root            => '/opt/rutorrent',
    location_cfg_append => {
      'fastcgi_split_path_info' => '^(.+\.php)(/.+)$',
      'fastcgi_pass'            => '127.0.0.1:9000',
      'fastcgi_param'           => 'SCRIPT_FILENAME $document_root$fastcgi_script_name',
      'fastcgi_index'           => 'index.php',
      'include'                 => 'fastcgi_params',
    }
  }
  nginx::resource::location { 'rutorrent_RPC2':
    ensure              => present,
    location            => '/RPC2',
    vhost               => 'rutorrent',
    ssl                 => true,
    ssl_only            => true,
    www_root            => '/opt/rutorrent',
    location_cfg_append => {
      'include'   => 'scgi_params',
      'scgi_pass' => 'localhost:5000',
    }
  }

  file { '/var/lib/php/session':
    ensure => directory,
    owner  => 'nginx',
    group  => 'root',
    mode   => '0770',
  }

  file { '/etc/php-fpm.d/www.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/roles/leecher/php-fpm.d_www.conf',
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
  } ->
  file { '/mnt/nasa/rtorrent/downloads/complete':
    ensure => directory,
    owner  => 'james',
    group  => 'james',
    mode   => '0700',
  }
  file { '/mnt/nasa/rtorrent/downloads/incomplete':
    ensure => directory,
    owner  => 'james',
    group  => 'james',
    mode   => '0700',
  }

  file { '/home/james/.rtorrent-rc':
    ensure => file,
    owner  => 'james',
    group  => 'james',
    mode   => '0644',
    source => 'puppet:///modules/roles/leecher/rtorrent-rc',
  }

  file { '/etc/systemd/system/rtorrent.service':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/roles/leecher/_etc_systemd_system_rtorrent.service',
  } ->
  service { 'rtorrent':
    ensure => running,
    enable => true,
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
