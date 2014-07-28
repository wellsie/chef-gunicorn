#
# Author:: Jono Wells (<7@oj.io>)
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Cookbook Name:: gunicorn
# Resource:: config
#
# Copyright:: 2014, Jono Wells <7@oj.io>
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

attribute :owner, :regex => Chef::Config[:user_valid_regex]
attribute :group, :regex => Chef::Config[:group_valid_regex]

# gunicorn settings v.19
# see http://docs.gunicorn.org for details

# server socket
#
attribute :bind, :kind_of => String, :default => '127.0.0.1:8000'
attribute :backlog, :kind_of => [Integer, NilClass], :default => nil

# worker processes
#
attribute :workers, :kind_of => Integer, :default => (node['cpu'] && node['cpu']['total']) && [node['cpu']['total'].to_i * 2 + 1, 8].min || 8
attribute :worker_class, :kind_of => [String, Symbol], :default => :sync
attribute :threads, :kind_of => [Integer, NilClass], :default => nil
attribute :worker_connections, :kind_of => [Integer, NilClass], :default => nil
attribute :max_requests, :kind_of => [Integer, NilClass], :default => nil
attribute :timeout, :kind_of => [Integer, NilClass], :default => nil
attribute :graceful_timeout, :kind_of => [Integer, NilClass], :default => nil
attribute :keep_alive, :kind_of => [Integer, NilClass], :default => nil

# security
#
attribute :limit_request_line, :kind_of => [Integer, NilClass], :default => nil
attribute :limit_request_fields, :kind_of => [Integer, NilClass], :default => nil
attribute :limit_request_field_size, :kind_of => [Integer, NilClass], :default => nil

# debugging
#
attribute :debug, :kind_of => [TrueClass, FalseClass, NilClass], :default => nil
attribute :reload, :kind_of => [TrueClass, FalseClass, NilClass], :default => nil
attribute :spew, :kind_of => [TrueClass, FalseClass, NilClass], :default => nil

# server mechanics
#
attribute :preload_app, :kind_of => [TrueClass, FalseClass, NilClass], :default => nil
attribute :chdir, :kind_of => [String, NilClass], :default => nil
attribute :daemon, :kind_of => [TrueClass, FalseClass, NilClass], :default => nil
# attribute :raw_env, :kind_of => [Hash, NilClass], :default => nil
attribute :pidfile, :kind_of => [String, NilClass], :default => nil
attribute :worker_tmp_dir, :kind_of => [String, NilClass], :default => nil
# attribute :user, :kind_of => [Integer, NilClass], :default => nil
# attribute :group, :kind_of => [Integer, NilClass], :default => nil
attribute :umask, :kind_of => [Integer, NilClass], :default => nil
attribute :tmp_upload_dir, :kind_of => [String, NilClass], :default => nil
attribute :secure_scheme_headers, :kind_of => [Hash, NilClass], :default => nil
attribute :forward_allowed_ips, :kind_of => [String, NilClass], :default => nil
attribute :pythonpath, :kind_of => [String, NilClass], :default => nil
attribute :proxy_protocol, :kind_of => [TrueClass, FalseClass, NilClass], :default => nil
attribute :proxy_allow_ips, :kind_of => [String, NilClass], :default => nil

# logging
#
attribute :accesslog, :kind_of => [String, NilClass], :default => nil
attribute :access_log_format, :kind_of => [String, NilClass], :default => nil
attribute :errorlog, :kind_of => [String, NilClass], :default => nil
attribute :loglevel, :kind_of => [String, Symbol, NilClass], :default => nil
attribute :logger_class, :kind_of => [String, NilClass], :default => nil
attribute :logconfig, :kind_of => [String, NilClass], :default => nil
attribute :syslog_addr, :kind_of => [String, NilClass], :default => nil
attribute :syslog, :kind_of => [TrueClass, FalseClass, NilClass], :default => nil
attribute :syslog_prefix, :kind_of => [String, NilClass], :default => nil
attribute :syslog_facility, :kind_of => [String, NilClass], :default => nil
attribute :enable_stdio_inheritance, :kind_of => [TrueClass, FalseClass, NilClass], :default => nil
attribute :stats_host, :kind_of => [String, NilClass], :default => nil

# process naming
#
attribute :proc_name, :kind_of => [String, NilClass], :default => nil

# ssl
#
attribute :keyfile, :kind_of => [String, NilClass], :default => nil
attribute :certfile, :kind_of => [String, NilClass], :default => nil
attribute :ssl_version, :kind_of => [Integer, NilClass], :default => nil
attribute :cert_reqs, :kind_of => [Integer, NilClass], :default => nil
attribute :ca_certs, :kind_of => [String, NilClass], :default => nil
attribute :suppress_ragged_eofs, :kind_of => [TrueClass, FalseClass, NilClass], :default => nil
attribute :do_handshake_on_connect, :kind_of => [TrueClass, FalseClass, NilClass], :default => nil
attribute :ciphers, :kind_of => [String, NilClass], :default => nil

# server hooks
#
attribute :server_hooks,
          :kind_of => Hash,
          :default => {},
          :callbacks => {
            'should contain a valid gunicorn server hook name' => ->(hooks) { Chef::Resource::GunicornConfig.validate_server_hook_hash_keys(hooks) }
          }

VALID_SERVER_HOOKS_AND_PARAMS = {
  :on_starting => 'server',
  :on_reload => 'server',
  :when_ready => 'server',
  :pre_fork => 'server, worker',
  :post_fork => 'server, worker',
  :post_worker_init => 'worker',
  :worker_init => 'worker',
  :worker_abort => 'worker',
  :pre_exec => 'server',
  :pre_request => 'worker, req',
  :post_request => 'worker, req, environ, resp',
  :worker_exit => 'server, worker',
  :nworkers_changed => 'server, new_value, old_value',
  :on_exit => 'server'
}

attribute :valid_server_hooks_and_params, :kind_of => Hash, :default => VALID_SERVER_HOOKS_AND_PARAMS

def initialize(*args)
  super
  @action = :create
end

private

def self.validate_server_hook_hash_keys(server_hooks)
  server_hooks.keys.reject { |key| VALID_SERVER_HOOKS_AND_PARAMS.keys.include?(key.to_sym) }.empty?
end
