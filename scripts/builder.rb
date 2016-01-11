class Builder
  def Builder.configure(config, settings)
    # Set The VM Provider
    ENV['VAGRANT_DEFAULT_PROVIDER'] = "virtualbox"

    # Configure Local Variable To Access Scripts From Remote Location
    scriptDir = File.dirname(__FILE__)

    # Prevent TTY Errors
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

    # Configure The Box From ytake/gardening https://atlas.hashicorp.com/ytake/boxes/gardening
    config.vm.box = settings["box"] ||= "ytake/gardening"
    config.vm.box_version = settings["version"] ||= ">= 0.1"
    config.vm.hostname = settings["hostname"] ||= "gardening"

    # Configure A Private Network IP
    config.vm.network :private_network, ip: settings["ip"] ||= "192.168.10.10"

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
        9200 => 19200
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
          mount_opts = folder["mount_opts"] ? folder["mount_opts"] : ['actimeo=1']
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

    # choose web server
    web_server = settings["web_server"] ||= "nginx"

    settings["sites"].each do |site|

      type = site["type"] ||= "php"

      if (site.has_key?("hhvm") && site["hhvm"])
        type = "hhvm"
      end

      config.vm.provision "shell" do |s|
        s.path = scriptDir + "/#{web_server}-server-#{type}.sh"
        s.args = [site["map"], site["to"], site["port"] ||= "80", site["ssl"] ||= "443"]
      end
    end

    # Configure All Of The Configured Databases
    if settings.has_key?("databases")
      settings["databases"].each do |db|
        config.vm.provision "shell" do |s|
          s.path = scriptDir + "/create-mysql.sh"
          s.args = [db]
        end

        config.vm.provision "shell" do |s|
          s.path = scriptDir + "/create-postgres.sh"
          s.args = [db]
        end
      end
    end

    # for optional services
    # Configure Elasticsearch
    if (settings.has_key?("elasticsearch") && settings["elasticsearch"])
        config.vm.provision "shell" do |s|
          s.inline = "/bin/systemctl enable elasticsearch && /bin/systemctl daemon-reload && /bin/systemctl restart elasticsearch"
        end
    else
      # disable elasticsearch
      config.vm.provision "shell" do |s|
        s.inline = "/bin/systemctl disable elasticsearch && /bin/systemctl stop elasticsearch"
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

    # couchbase-server service register
    config.vm.provision "shell" do |s|
      s.path = scriptDir + "/couchbase-server-register.sh"
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
          s.inline = "echo \"\nenv[$1] = '$2'\" >> /etc/php-fpm.d/www.conf"
          s.args = [var["key"], var["value"]]
        end

        config.vm.provision "shell" do |s|
          s.inline = "echo \"\n# Set Gardening Environment Variable\nexport $1=$2\" >> /home/vagrant/.profile"
          s.args = [var["key"], var["value"]]
        end
      end
      config.vm.provision "shell" do |s|
        s.inline = "/bin/systemctl restart php-fpm"
      end
    end

    # Update Composer On Every Provision
    config.vm.provision "shell" do |s|
      s.inline = "/usr/local/bin/composer self-update"
    end

  end
end
