class roles::elbuild (
) {

  include '::profiles::base'

  package { 'Development Tools':
    ensure => installed,
  }

}
