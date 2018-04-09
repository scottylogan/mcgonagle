#
# Primary node configuration
#

#
# Homebrew setup and basic package installation
#
include stdlib

class { 'homebrew': }

file { "/etc/sudoers.d/${homebrew::user}":
  ensure  => file,
  owner   => 0,
  group   => 0,
  mode    => '0440',
  content => "Defaults:${homebrew::user} timestamp_timeout=60,!tty_tickets

             ${homebrew::user} ALL=(ALL) NOPASSWD : ALL
             ",
  before  => Class['homebrew'],
}

$local_folders = [
  '/usr/local/Caskroom',
  '/usr/local/Cellar',
  '/usr/local/Frameworks',
  '/usr/local/Homebrew',
  '/usr/local/bin',
  '/usr/local/etc',
  '/usr/local/include',
  '/usr/local/lib',
  '/usr/local/opt',
  '/usr/local/share',
  '/usr/local/var',
]

$local_folders.each | String $local_folder | {
  if !defined(File[$local_folder]) {
    file { $local_folder:
      ensure => directory,
      owner  => $homebrew::user,
      group  => $homebrew::group,
      mode   => '0775',
      before => Package[$taps],
    }
  }
}

Package { provider => brew }

# install taps before everything else
Package <| provider == tap |> -> Package <| provider == brew |>
Package <| provider == tap |> -> Package <| provider == brewcask |>
Package <| provider == tap |> -> Package <| provider == homebrew |>

# install casks before brews
#Package <| provider == brewcask |> -> Package <| provider == brew |>

$taps  = lookup('taps', Array[String], 'deep')
$brews = lookup('brews', Array[String], 'deep')
$casks = lookup('casks', Array[String], 'deep')


package { $taps:
  ensure   => present,
  provider => tap,
}

package { $brews:
  ensure => present,
}

package { $casks:
  ensure   => present,
  provider => brewcask,
}

#
# Default node
#
node default { }

#
# Customized nodes
#

# node mymac { include someclass }
