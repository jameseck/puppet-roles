class roles::kvm (
) {

  include '::nfs::server'

  sysctl { 'net.ipv4.ip_nonlocal_bind':
    ensure    => 'present',
    permanent => 'yes',
    value     => '1',
  }

  nfs::server::export { '/export':
    clients => ['192.168.1.0/24' ],
    options => 'rw,no_root_squash,fsid=0',
  }
  nfs::server::export { '/export/nasa_data':
    clients => [ '192.168.1.0/24' ],
    options => 'rw,no_root_squash,fsid=1',
  }
  nfs::server::export { '/export/nasb_data':
    clients => [ '192.168.1.0/24' ],
    options => 'rw,no_root_squash,fsid=2',
  }
  nfs::server::export { '/export/nasa_backup':
    clients => [ '192.168.1.0/24' ],
    options => 'rw,no_root_squash,fsid=3',
  }

  class { '::samba::server':
    workgroup                => 'JEHOME',
    server_string            => 'nasa.je.home',
    #netbios_name             => 'nasa',
    interfaces               => [ 'lo', 'br0' ],
    hosts_allow              => [ '127.', '192.168.1.' ],
    local_master             => 'yes',
    map_to_guest             => 'Bad User',
    os_level                 => '50',
    preferred_master         => 'yes',
    selinux_enable_home_dirs => true,
    extra_global_options     => [
      'printing = BSD',
      'printcap name = /dev/null',
      'disable netbios = yes',
      'smb ports = 445',
    ],
    shares                   => {
      'homes'  => [
        'comment = Home Directories',
        'browseable = no',
        'writable = yes',
      ],
      'data'   => [
        'comment = nasa_data',
        'path = /export/nasa_data',
        'browseable = yes',
        'writable = yes',
        'guest ok = no',
        'available = yes',
        'valid users = james',
      ],
      'nasb'   => [
        'comment = nasb_data',
        'path = /export/nasb_data',
        'browseable = yes',
        'writable = yes',
        'guest ok = no',
        'available = yes',
        'valid users = james',
      ],
      'backup' => [
        'comment = nasa_backup',
        'path = /export/nasa_backup',
        'browseable = yes',
        'writable = yes',
        'guest ok = no',
        'available = yes',
        'valid users = james',
      ],
    },
  }


  selboolean { 'samba_share_nfs':
    persistent => true,
    value      => 'on',
  }
  selboolean { 'allow_smbd_anon_write':
    persistent => true,
    value      => 'on',
  }

  file { '/export':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    seltype => 'public_content_rw_t',
  }
  selinux_fcontext { '/export(/.*)':
    ensure  => 'present',
    seltype => 'public_content_rw_t',
  }

  file { '/export/nasa_data':
    ensure  => directory,
  } ->
  mount { '/export/nasa_data':
    ensure  => 'mounted',
    device  => '/dev/mapper/vg_nasadata-lv_data',
    fstype  => 'ext4',
    options => 'defaults',
  } ->
  selinux_fcontext { '/export/nasa_data(/.*)':
    ensure  => 'present',
    seltype => 'public_content_rw_t',
    notify  => Exec['restorecon nasa_data'],
  }
  exec { 'restorecon nasa_data':
    command     => 'restorecon -R /export/nasa_data',
    refreshonly => true,
  }

  file { '/export/nasb_data':
    ensure  => directory,
  } ->
  mount { '/export/nasb_data':
    ensure  => 'mounted',
    device  => '/dev/mapper/vg_nasb-lv_data',
    fstype  => 'ext4',
    options => 'defaults',
  } ->
  selinux_fcontext { '/export/nasb_data(/.*)':
    ensure  => 'present',
    seltype => 'public_content_rw_t',
    notify  => Exec['restorecon nasb_data'],
  }
  exec { 'restorecon nasb_data':
    command     => 'restorecon -R /export/nasb_data',
    refreshonly => true,
  }

  file { '/export/nasa_backup':
    ensure  => directory,
  } ->
  mount { '/export/nasa_backup':
    ensure  => 'mounted',
    device  => 'UUID="a9dbc7a2-9f6f-4f1c-b60a-c9d95f753674"',
    fstype  => 'ext4',
    options => 'defaults',
  } ->
  selinux_fcontext { '/export/nasa_backup(/.*)':
    ensure  => 'present',
    seltype => 'public_content_rw_t',
    notify  => Exec['restorecon nasa_backup'],
  }
  exec { 'restorecon nasa_backup':
    command     => 'restorecon -R /export/nasa_backup',
    refreshonly => true,
  }

}
