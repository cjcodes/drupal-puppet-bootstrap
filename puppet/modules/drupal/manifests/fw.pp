class drupal::fw {
    resources { 'firewall':
        purge => true
    }

    Firewall {
        before  => Class['drupal::fw::post'],
        require => Class['drupal::fw::pre'],
    }

    class { ['drupal::fw::pre', 'drupal::fw::post']: }

    class { 'firewall': }

    firewall { '100 allow ssh':
        port   => 22,
        proto  => 'tcp',
        action => 'accept',
    }
}