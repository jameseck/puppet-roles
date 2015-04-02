class roles::leecher (
) {

  # This will describe an Ubuntu 14 VM running nzbdrone, sabnzbd, rtorrent, etc

  include '::git'
  include '::nginx'

  package { 'dtach':
    ensure => installed,
  }

  package { 'nfs-common':
    ensure => installed,
  }

  package { 'mono-complete':
    ensure => installed,
  }

  apt::key { 'nzbdrone':
    key        => 'D9B78493',
    key_source => 'http://update.nzbdrone.com/publickey.gpg',
  } ->
  apt::source { 'nzbdrone':
    release     => 'master',
    repos       => 'main',
    location    => 'http://update.nzbdrone.com/repos/apt/debian',
    include_src => false,
  } ->
  package { 'nzbdrone':
    ensure => installed,
  } ->
  file { '/etc/init/nzbdrone.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/roles/leecher/_etc_init_nzbdrone.conf',
  } ->
  service { 'nzbdrone':
    ensure => running,
    enable => true,
  }

  apt::ppa { 'ppa:mc3man/trusty-media': } ->
  package { 'ffmpeg':
    ensure => installed,
  }

  package { 'mediainfo':
    ensure => installed,
  }

  apt::ppa { 'ppa:jcfp/ppa': } ->
  package { 'sabnzbdplus':
    ensure => installed,
  } ->
  file { '/etc/default/sabnzbdplus':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/roles/leecher/_etc_default_sabnzbdplus',
  } ->
  service { 'sabnzbdplus':
    ensure => running,
    enable => true,
  }

  package { 'rtorrent':
    ensure => installed,
  }

  $php_packages = [
    'php5',
    'php5-fpm',
    'php5-common',
    'php5-cli',
    'php5-apcu',
    'php-pear',
  ]

  package { $php_packages:
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
  }

  # reverse proxy to localhost:8989 for nzbdrone


  nginx::resource::vhost { 'leecher':
    ensure               => present,
    server_name          => [ $::fqdn ],
    listen_port          => '443',
    ssl                  => true,
    ssl_port             => '443',
    ssl_cert             => '/etc/nginx/rutorrent.crt',
    ssl_key              => '/etc/nginx/rutorrent.key',
    www_root             => '/opt/rutorrent',
    use_default_location => false,
    vhost_cfg_append     => {
      'try_files' => '$uri $uri/ =404',
    },
  }

  nginx::resource::location { 'rutorrent':
    ensure              => present,
    location            => '~ \.php$',
    vhost               => 'leecher',
    ssl                 => true,
    ssl_only            => true,
    www_root            => '/opt/rutorrent',
    location_cfg_append => {
      'fastcgi_split_path_info' => '^(.+\.php)(/.+)$',
      'fastcgi_pass'            => '127.0.0.1:9000',
      'fastcgi_param'           => 'SCRIPT_FILENAME $document_root$fastcgi_script_name',
      'fastcgi_index'           => 'index.php',
      'include'                 => 'fastcgi_params',
      'try_files'               => '$uri $uri/ =404',
    },
  }

  nginx::resource::location { 'rutorrent_RPC2':
    ensure              => present,
    location            => '/RPC2',
    vhost               => 'leecher',
    ssl                 => true,
    ssl_only            => true,
    www_root            => '/opt/rutorrent',
    location_cfg_append => {
      'include'   => 'scgi_params',
      'scgi_pass' => 'localhost:5000',
    }
  }

  file { '/var/lib/php5/session':
    ensure => directory,
    owner  => 'nginx',
    group  => 'root',
    mode   => '0770',
  }

  file { '/etc/php5/fpm/pool.d/www.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/roles/leecher/php-fpm.d_www.conf',
  }

  file { '/mnt/nasa':
    ensure => directory,
  } ->
  mount { '/mnt/nasa':
    ensure  => 'mounted',
    device  => 'kvm.je.home:/home/nasa_data',
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

  file { '/home/james/.rtorrent.rc':
    ensure => file,
    owner  => 'james',
    group  => 'james',
    mode   => '0644',
    source => 'puppet:///modules/roles/leecher/rtorrent-rc',
  } ->
  file { '/var/lib/rtorrent_session':
    ensure => directory,
    owner  => 'james',
    group  => 'nginx',
    mode   => '0770',
  } ->
  file { '/etc/init/rtorrent.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/roles/leecher/_etc_init_rtorrent.conf',
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
