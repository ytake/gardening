<?php

/**
 * Gardening Configure
 * for vagrant configuration file
 */
return [
    'ip' => "192.168.10.10",
    'memory' => 2048,
    'cpus' => 1,
    'hostname' => 'gardening',
    'name' => 'gardening',
    'authorize' => '~/.ssh/id_rsa.pub',
    'keys' => [
        '~/.ssh/id_rsa',
    ],
    'folders' => [
        [
            'map' => null,
            'to' => '/home/vagrant/Code'
        ]
    ],
    'sites' => [
        [
            'map' => 'gardening.app',
            'to' => '/home/vagrant/Code/public',
            'hhvm' => false
        ]
    ],
    // optional
    'elasticsearch' => false,
    'fluentd' => false,
    'mongodb' => false,
    'couchbase' => false
];
