node /^web(\d)+\..*/ inherits 'drupal' {
    include epel

    #
    # Apache
    #
    class { 'apache':
        mpm_module => false,
    }

    class { 'apache::mod::prefork': }

    #
    # PHP
    #
    include apache::mod::php
    class { 'php': }

    # modules
    php::module { 'gd': }
    php::module { 'mbstring': }
    php::module { 'xml': }
    php::module { 'apc':
        module_prefix => 'php-pecl-',
    }

    # configuration
    php::augeas {
       'php-memorylimit':
            entry  => 'PHP/memory_limit',
            value  => '128M';
       'php-date_timezone':
            entry  => 'Date/date.timezone',
            value  => 'GMT';
    }

    #
    # DRUSH
    #
    php::pear::module { 'drush':
        repository  => 'pear.drush.org',
        use_package => 'no',
    }
}

node 'drupal' {
    class { 'drupal::fw': }
    firewall { '100 allow httpd':
        port   => 80,
        proto  => 'tcp',
        action => 'accept',
    }
}