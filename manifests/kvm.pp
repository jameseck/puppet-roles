class roles::kvm (
) {

  include '::nfs::server'

  nfs::server::export { '/home/nasa_data':
    clients => [ '192.168.1.0/24' ],
    options => 'rw,no_root_squash',
  }
  nfs::server::export { '/home/nasa_backup':
    clients => [ '192.168.1.0/24' ],
    options => 'rw,no_root_squash',
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
      'homes' => [
        'comment = Home Directories',
        'browseable = no',
        'writable = yes',
      ],
      'data'  => [
        'comment = nasa_data',
        'path = /home/nasa_data',
        'browseable = yes',
        'writable = yes',
        'guest ok = no',
        'available = yes',
        'valid users = james',
      ],
    },
  }

  selinux_fcontext { '/home/nasa_data(/.*)':
    ensure  => 'present',
    seltype => 'public_content_rw_t',
    notify  => Exec['restorecon nasa_data'],
  }

  exec { 'restorecon nasa_data':
    command     => 'restorecon -R /home/nasa_data',
    refreshonly => true,
  }

  selboolean { 'samba_share_nfs':
    value => 'on',
  }
  selboolean { 'allow_smbd_anon_write':
    value => 'on',
  }

  file { '/home/nasa_data':
    ensure => directory,
  } ->
  mount { '/home/nasa_data':
    ensure  => 'mounted',
    device  => '/dev/mapper/vg_data-lv_data',
    fstype  => 'ext4',
    options => 'defaults',
  }


}
