#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Cookbook Name:: gunicorn
# Resource:: config
#
# Copyright:: 2011, Opscode, Inc <legal@opscode.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

actions :create, :delete

attribute :path, :kind_of => String, :name_attribute => true
attribute :template, :kind_of => String, :default => 'gunicorn.py.erb'
attribute :cookbook, :kind_of => String, :default => 'gunicorn'

attribute :options, :kind_of => Hash, :default => { :bind => '127.0.0.1:8000' }

attribute :server_hooks, :kind_of => Hash, :default => {}, \
    :callbacks => {
      "should contain a valid gunicorn server hook name" => lambda { |hooks| Chef::Resource::GunicornConfig.validate_server_hook_hash_keys(hooks)}
    }

attribute :owner, :regex => Chef::Config[:user_valid_regex]
attribute :group, :regex => Chef::Config[:group_valid_regex]


VALID_SERVER_HOOKS_AND_PARAMS = {
  :on_starting => 'server', 
  :on_reload => 'server', 
  :when_ready => 'server', 
  :pre_fork => 'server, worker', 
  :post_fork => 'server, worker',
  :pre_exec => 'server', 
  :pre_request => 'worker, req', 
  :post_request => 'worker, req', 
  :worker_exit => 'server, worker',
}

attribute :valid_server_hooks_and_params, :kind_of => Hash, :default => VALID_SERVER_HOOKS_AND_PARAMS


def initialize(*args)
  super
  @action = :create
end


private
  def self.validate_server_hook_hash_keys(server_hooks)
    server_hooks.keys.reject{|key| VALID_SERVER_HOOKS_AND_PARAMS.keys.include?(key.to_sym)}.empty?
  end
