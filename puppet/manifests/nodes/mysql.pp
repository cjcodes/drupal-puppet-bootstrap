# Additional configuration steps:
# 1. From mysql master, run:
#    SHOW MASTER STATUS;
#
# 2. From mysqlN, run:
#    CHANGE MASTER TO
#       MASTER_HOST='<<< MASTER IP >>>',
#       MASTER_USER='slave',
#       MASTER_PASSWORD='drupalslave',
#       MASTER_LOG_FILE='<<< FROM ABOVE >>>',
#       MASTER_LOG_POS=<<< FROM ABOVE >>>;
#    START SLAVE;
#    SHOW SLAVE STATUS\G

node /^mysql\..*/ inherits mysql {
    $users = merge($mysql::users, {
        'slave@%' => {
            ensure => 'present',
            password_hash => '*A2033F60E2D4B9BA7F64CF3AF83D69D990AAE728', #'drupalslave'
        },
    })

    $grants = merge($mysql::grants, {
        'slave@%/*.*' => {
            ensure     => 'present',
            options    => ['GRANT'],
            privileges => ['REPLICATION SLAVE'],
            table      => '*.*',
            user       => 'slave@%',
        },
        'drupal@%/drupal.*' => {
            ensure     => 'present',
            options    => ['GRANT'],
            privileges => ['ALL PRIVILEGES'],
            table      => 'drupal.*',
            user       => 'drupal@%',
        }
    })

    class { '::mysql::server':
        databases => $databases,
        users => $users,
        grants => $grants,
        root_password => 'defaultroot',
        override_options => {
            'mysqld' => {
                'bind-address' => '0.0.0.0',
                'replicate-do-db' => ['drupal'],
                'server-id' => 999,
                'log_bin' => '/var/log/mysql/mysql-bin.log',
            }
        }
    }
}

node /^mysql(\d)+\..*/ inherits mysql {
    $grants = merge($mysql::grants, {
        'drupal@%/drupal.*' => {
            ensure     => 'present',
            options    => ['GRANT'],
            privileges => ['SELECT'],
            table      => 'drupal.*',
            user       => 'drupal@%',
        }
    })

    class { '::mysql::server':
        databases => $databases,
        users => $users,
        grants => $grants,
        root_password => 'defaultroot',
        override_options => {
            'mysqld' => {
                'bind-address' => '0.0.0.0',
                'replicate-do-db' => ['drupal'],
                'server-id' => $1,
                'log_bin' => '/var/log/mysql/mysql-bin.log',
                'relay-log' => '/var/log/mysql/mysql-relay-bin.log',
            }
        }
    }
}

node 'mysql' {
    $databases =  {
        'drupal' => {
            ensure => 'present',
            charset => 'utf8',
            collate => 'utf8_swedish_ci',
        },
    }

    $users = {
        'drupal@%' => {
            ensure => 'present',
            password_hash => '*7C3A61A270DF7F61AA1C25F9FA846B81967FFCBF', #'drupaldefault'
        },
    }

    $grants = {}

    file { '/var/log/mysql/':
        ensure => 'directory',
        owner => 'mysql',
        group => 'mysql',
        require => Package['mysql-server'],
        notify => Service['mysqld'],
    }

    file { '/var/log/mysql/mysql-bin.index':
        ensure => 'present',
        require => File['/var/log/mysql/'],
        owner => 'mysql',
        group => 'mysql',
    }

    class { 'drupal::fw': }

    firewall { '100 allow mysqld':
        port   => 3306,
        proto  => 'tcp',
        action => 'accept',
    }
}