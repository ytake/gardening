class Builder
  def Builder.configure(config, settings)
    # Set The VM Provider
    ENV['VAGRANT_DEFAULT_PROVIDER'] = "virtualbox"

    # Configure Local Variable To Access Scripts From Remote Location
    scriptDir = File.dirname(__FILE__)

    config.ssh.forward_agent = true

    # Prevent TTY Errors
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

    # Configure The Box From ytake/gardening https://atlas.hashicorp.com/ytake/boxes/gardening
    config.vm.box = settings["box"] ||= "ytake/gardening"
    config.vm.box_version = settings["version"] ||= ">= 1.1.0"
    config.vm.hostname = settings["hostname"] ||= "gardening"

    # Configure A Private Network IP
    if settings["ip"] != "autonetwork"
      config.vm.network :private_network, ip: settings["ip"] ||= "192.168.10.10"
    else
      config.vm.network :private_network, :ip => "0.0.0.0", :auto_network => true
    end

    # Configure Additional Networks
    if settings.has_key?("networks")
      settings["networks"].each do |network|
        config.vm.network network["type"], ip: network["ip"], bridge: network["bridge"] ||= nil
      end
    end

    # Configure A Few VirtualBox Settings
    config.vm.provider "virtualbox" do |vb|
      vb.name = settings["name"] ||= "gardening"
      vb.customize ["modifyvm", :id, "--memory", settings["memory"] ||= "2048"]
      vb.customize ["modifyvm", :id, "--cpus", settings["cpus"] ||= "1"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    end

    # Standardize Ports Naming Schema
    if (settings.has_key?("ports"))
      settings["ports"].each do |port|
        port["guest"] ||= port["to"]
        port["host"] ||= port["send"]
        port["protocol"] ||= "tcp"
      end
    else
      settings["ports"] = []
    end

    # Default Port Forwarding
    default_ports = {
        80   => 8000,
        443  => 44300,
        3306 => 33060,
        5432 => 54320,
        27017 => 47017,
        9200 => 19200,
        5601 => 56010,
        9024 => 19024,
        9092 => 19092,
    }

    # Use Default Port Forwarding Unless Overridden
    default_ports.each do |guest, host|
      unless settings["ports"].any? { |mapping| mapping["guest"] == guest }
        config.vm.network "forwarded_port", guest: guest, host: host, auto_correct: true
      end
    end

    # Add Custom Ports From Configuration
    if settings.has_key?("ports")
      settings["ports"].each do |port|
        config.vm.network "forwarded_port", guest: port["guest"], host: port["host"], protocol: port["protocol"], auto_correct: true
      end
    end

    # Configure The Public Key For SSH Access
    if settings.include? 'authorize'
      config.vm.provision "shell" do |s|
        s.inline = "echo $1 | grep -xq \"$1\" /home/vagrant/.ssh/authorized_keys || echo $1 | tee -a /home/vagrant/.ssh/authorized_keys"
        s.args = [File.read(File.expand_path(settings["authorize"]))]
      end
    end

    # Copy The SSH Private Keys To The Box
    if settings.include? 'keys'
      settings["keys"].each do |key|
        config.vm.provision "shell" do |s|
          s.privileged = false
          s.inline = "echo \"$1\" > /home/vagrant/.ssh/$2 && chmod 600 /home/vagrant/.ssh/$2"
          s.args = [File.read(File.expand_path(key)), key.split('/').last]
        end
      end
    end

    # Register All Of The Configured Shared Folders
    if settings.include? 'folders'
      settings["folders"].each do |folder|
        mount_opts = []

        if (folder["type"] == "nfs")
          mount_opts = folder["mount_options"] ? folder["mount_options"] : ['actimeo=1', 'nolock']
        elsif (folder["type"] == "smb")
            mount_opts = folder["mount_options"] ? folder["mount_options"] : ['vers=3.02', 'mfsymlinks']
        end

        # For b/w compatibility keep separate 'mount_opts', but merge with options
        options = (folder["options"] || {}).merge({ mount_opts: mount_opts })

        # Double-splat (**) operator only works with symbol keys, so convert
        options.keys.each{|k| options[k.to_sym] = options.delete(k) }

        config.vm.synced_folder folder["map"], folder["to"], type: folder["type"] ||= nil, **options
      end
    end

    # Install All The Configured Nginx Sites
    config.vm.provision "shell" do |s|
      s.path = scriptDir + "/clear-nginx.sh"
    end

    # timezone
    timezone = settings["timezone"] ||= "Asia/Tokyo"
    config.vm.provision "shell" do |s|
      s.name = "timezone specified: " + timezone
      s.path = scriptDir + "/setup-timezone.sh"
      s.args = [timezone]
    end

    # choose PHP Version (update-alternatives: for cli, build, compile etc...)
    php_alternatives = settings["php-alternatives"] ||= "7.2"
    config.vm.provision "shell" do |s|
      s.name = "default php version: " + php_alternatives
      s.path = scriptDir + "/setup-php-alternatives.sh"
      s.args = [php_alternatives]
    end

    # choose web server
    web_server = settings["web_server"] ||= "nginx"

    settings["sites"].each do |site|
      ## choose php(default: Laravel/Zend Framework3/Zend Expressive etc..), symfony(2.0~3.0), symfony4
      type = site["type"] ||= "php"

      config.vm.provision "shell" do |s|
        s.path = scriptDir + "/setup-#{web_server}-certificate.sh"
        s.args = [site["map"],]
      end

      config.vm.provision "shell" do |s|
        s.path = scriptDir + "/#{web_server}-server-#{type}.sh"
        s.args = [site["map"], site["to"], site["port"] ||= "80", site["ssl"] ||= "443", site["php"] ||= "7.2"]
      end
    end

    # Configure All Of The Configured Databases
    if settings.has_key?("databases")
      settings["databases"].each do |db|
        config.vm.provision "shell" do |s|
          s.name = "creating database[MySQL]: " + db
          s.path = scriptDir + "/create-mysql.sh"
          s.args = [db]
        end

        config.vm.provision "shell" do |s|
          s.name = "creating database[PostgreSQL]: " + db
          s.path = scriptDir + "/create-postgres.sh"
          s.args = [db]
        end
      end
    end

    # for optional services
    # Configure Elasticsearch
    if (settings.has_key?("elasticsearch") && settings["elasticsearch"])
        config.vm.provision "shell" do |s|
          s.name = "enabled Elasticsearch"
          s.path = scriptDir + "/setup-elasticsearch.sh"
        end
    else
      # disable elasticsearch
      config.vm.provision "shell" do |s|
        s.name = "disabled Elasticsearch"
        s.inline = "/bin/systemctl disable elasticsearch && /bin/systemctl stop elasticsearch"
      end
    end

    # Configure kibana
    if (settings.has_key?("kibana") && settings["kibana"])
        config.vm.provision "shell" do |s|
          s.name = "enabled Kibana"
          s.inline = "/bin/systemctl enable kibana && /bin/systemctl daemon-reload && /bin/systemctl restart kibana"
        end
    else
      # disable kibana
      config.vm.provision "shell" do |s|
        s.name = "disabled Kibana"
        s.inline = "/bin/systemctl disable kibana && /bin/systemctl stop kibana"
      end
    end

    # Configure fluentd
    if (settings.has_key?("fluentd") && settings["fluentd"])
      # enable fluentd
      config.vm.provision "shell" do |s|
        s.inline = "/bin/systemctl enable td-agent && /bin/systemctl start td-agent"
      end
    else
      # disable fluentd
      config.vm.provision "shell" do |s|
        s.inline = "/bin/systemctl disable td-agent && /bin/systemctl stop td-agent"
      end
    end

    # Configure Confluent Platform
    if (settings.has_key?("confluent") && settings["confluent"])
      # confluent platform start
      config.vm.provision "shell" do |s|
        s.path = scriptDir + "/setup-confluent.sh"
      end
    else
      # confluent platform stop
      config.vm.provision "shell" do |s|
        s.inline = "sudo confluent stop"
      end
    end

    # Configure Apache Cassandra
    if (settings.has_key?("cassandra") && settings["cassandra"])
      # cassandra start
      config.vm.provision "shell" do |s|
        s.path = scriptDir + "/setup-cassandra.sh"
      end
    else
      # confluent platform stop
      config.vm.provision "shell" do |s|
        s.inline = "/bin/systemctl disable cassandra && /bin/systemctl stop cassandra"
      end
    end

    # Configure mongodb
    if (settings.has_key?("mongodb") && settings["mongodb"])
      # disable mongodb
      config.vm.provision "shell" do |s|
        s.inline = "/bin/systemctl enable mongod && /bin/systemctl restart mongod"
      end
    else
      # disable mongodb
      config.vm.provision "shell" do |s|
        s.inline = "/bin/systemctl disable mongod && /bin/systemctl stop mongod"
      end
    end

    # Configure RabbitMQ
    if (settings.has_key?("rabbitmq") && settings["rabbitmq"])
      # disable mongodb
      config.vm.provision "shell" do |s|
        s.path = scriptDir + "/setup-rabbitmq.sh"
      end
    else
      # disable mongodb
      config.vm.provision "shell" do |s|
        s.inline = "/bin/systemctl disable rabbitmq-server && /bin/systemctl stop rabbitmq-server"
      end
    end

    # Configure couchbase-server
    if (settings.has_key?("couchbase") && settings["couchbase"])
      # enable couchbase-server
      config.vm.provision "shell" do |s|
        s.inline = "/bin/systemctl enable couchbase-server && /bin/systemctl restart couchbase-server"
      end
    else
      # disable couchbase-server
      config.vm.provision "shell" do |s|
        s.inline = "/bin/systemctl disable couchbase-server && /bin/systemctl stop couchbase-server"
      end
    end

    # disable for disable_server
    config.vm.provision "shell", run: "always" do |s|
      s.path = scriptDir + "/server-switcher.sh"
      s.args = [web_server]
    end

    # Configure All Of The Server Environment Variables
    config.vm.provision "shell" do |s|
      s.path = scriptDir + "/clear-variables.sh"
    end

    if settings.has_key?("variables")
      settings["variables"].each do |var|
        config.vm.provision "shell" do |s|
          s.inline = "echo \"\nenv[$1] = '$2'\" >> /etc/opt/remi/php70/php-fpm.d/www.conf"
          s.args = [var["key"], var["value"]]
        end

        config.vm.provision "shell" do |s|
          s.inline = "echo \"\nenv[$1] = '$2'\" >> /etc/opt/remi/php71/php-fpm.d/www.conf"
          s.args = [var["key"], var["value"]]
        end

        config.vm.provision "shell" do |s|
          s.inline = "echo \"\nenv[$1] = '$2'\" >> /etc/opt/remi/php72/php-fpm.d/www.conf"
          s.args = [var["key"], var["value"]]
        end

        config.vm.provision "shell" do |s|
          s.inline = "echo \"\n# Set Gardening Environment Variable\nexport $1=$2\" >> /home/vagrant/.profile"
          s.args = [var["key"], var["value"]]
        end
      end
    end

    config.vm.provision "shell" do |s|
      s.inline = "/bin/systemctl restart php70-php-fpm && /bin/systemctl restart php71-php-fpm && /bin/systemctl restart php72-php-fpm"
    end

    # Update Composer On Every Provision
    config.vm.provision "shell" do |s|
      s.inline = "/usr/local/bin/composer self-update"
    end

    config.vm.provision "shell" do |s|
      s.path = scriptDir + "/network-restart.sh"
    end
  end
end
