node /^memcache(\d)+\..*/ {
    class { 'memcached':
        manage_firewall => true
    }
}