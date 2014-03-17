node /^varnish(\d)*\..*/ {

    $varnish_use = $memorysize_mb * 0.9

    class { 'varnish':
        varnish_listen_port => 80,
        varnish_storage_size => "${varnish_use}M",
    }

    class { 'varnish::vcl':
        template => 'drupal/drupal.vcl.erb',
        min_cache_time    => '60s',
        static_cache_time => '5m',
        wafexceptions => [],

        backends => {
            'web1'=> { host => '192.168.77.2', port => '80' },
        },
        directors => {
            'cluster1' => { backends => [ 'web1' ] },
        },
        selectors => {
            'cluster1' => { condition => 'true' },
        }
    }

    file { "/etc/varnish/includes":
        ensure => directory,
    }

    # Note: acls and waf are not currently imported into the VCL
    $includefiles = ["probes", "backends", "directors", "backendselection", "acls", "waf"]
    varnish::vcl::includefile { $includefiles: }

    class { 'drupal::fw': }

    firewall { '100 allow http':
        port   => 80,
        proto  => 'tcp',
        action => 'accept',
    }
}