# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'json'
require 'yaml'

Encoding.default_external = 'UTF-8'

VAGRANTFILE_API_VERSION = "2"

confDir = $confDir ||= File.expand_path("vendor/ytake/gardening", File.dirname(__FILE__))

GardeningYamlPath = "./vagrant.yaml"
GardeningJsonPath = "./vagrant.json"
appendScriptPath = "./append.sh"
aliasesPath = "./aliases"

require File.expand_path(confDir + '/scripts/builder.rb')

Vagrant.configure(2) do |config|

  if File.exists? aliasesPath then
    config.vm.provision "file", source: aliasesPath, destination: "~/.bash_aliases"
  end

  if File.exists? GardeningYamlPath then
    Builder.configure(config, YAML::load(File.read(GardeningYamlPath)))
  elsif File.exists? GardeningJsonPath then
    Builder.configure(config, JSON.parse(File.read(GardeningJsonPath)))
  end

  if File.exists? appendScriptPath then
    config.vm.provision "shell", path: appendScriptPath
  end
end
