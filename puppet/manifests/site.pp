#
# Primary node configuration
#

#
# Homebrew setup and basic package installation
#
include stdlib

class { 'homebrew': }

Package { provider => brew }

# install taps before everything else
Package <| provider == tap |> -> Package <| provider == brew |>
Package <| provider == tap |> -> Package <| provider == brewcask |>

# install brews before casks
Package <| provider == brew |> -> Package <| provider == brewcask |>

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
