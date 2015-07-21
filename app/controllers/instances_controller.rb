class InstancesController < ApplicationController
require 'chef'
  def index
  	Chef::Config.from_file("/home/ubuntu/chef-repo/.chef/knife.rb")
  	query = Chef::Search::Query.new
  	@nodes = query.search('node', '*:*').first rescue []
  end
end
