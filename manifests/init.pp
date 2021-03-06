class meetbot {
  # NOTE(pabelanger): Until we full remove puppetlabs-apache from
  # system-config, we need to do this hack to avoid a circular dependency.
  if ! defined(Class['::apache']) {
    include ::httpd
  } else {
    include ::apache
  }

  vcsrepo { '/opt/meetbot':
    ensure   => latest,
    provider => git,
    source   => 'https://git.openstack.org/openstack-infra/meetbot',
  }

  vcsrepo { '/opt/ubuntu_supybot_plugins':
    ensure   => present,
    provider => bzr,
    require  => [
      Package['bzr'],
    ],
    source   => 'lp:ubuntu-bots'
  }

  user { 'meetbot':
    gid     => 'meetbot',
    home    => '/var/lib/meetbot',
    shell   => '/sbin/nologin',
    system  => true,
    require => Group['meetbot'],
  }

  group { 'meetbot':
    ensure => present,
  }

  # We use limnoria instead of supybot
  $packages = [
    'bzr',
    'python-launchpadlib',
    'python-soappy',
    'python-twisted'
  ]

  package { $packages:
    ensure => present,
  }

  package { 'irclog2html':
    ensure   => 'present',
    provider => pip,
  }

  file { '/var/lib/meetbot':
    ensure  => directory,
    owner   => 'meetbot',
    require => User['meetbot'],
  }

  file { '/usr/share/pyshared/supybot/plugins/MeetBot':
    ensure  => directory,
    recurse => true,
    require => [
      Vcsrepo['/opt/meetbot']
    ],
    source  => '/opt/meetbot/MeetBot',
  }

  file { '/usr/share/pyshared/supybot/plugins/Bugtracker':
    ensure  => directory,
    recurse => true,
    require => [
      Vcsrepo['/opt/ubuntu_supybot_plugins']
    ],
    source  => '/opt/ubuntu_supybot_plugins/Bugtracker',
  }
}

# vim:sw=2:ts=2:expandtab:textwidth=79
