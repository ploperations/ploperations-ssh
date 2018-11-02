# Class: ssh::chroot
#
# Prepares the chroot environment for SSH
#
class ssh::chroot {

  file { '/var/chroot':
    ensure => directory;
  }
}
