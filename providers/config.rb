#
# Author:: Jono Wells (<7@oj.io>)
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Cookbook Name:: gunicorn
# Provider:: config
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
# Based on https://github.com/opscode-cookbooks/gunicorn v1.1.7
#

action :create do

  log("Creating #{@new_resource} at #{@new_resource.path}") unless exists?

  template_variables = {}
  # %w{proc_name bind backlog threads}.each do |a|
  %w{ bind backlog workers worker_class threads worker_connections max_requests 
      timeout graceful_timeout keep_alive limit_request_line limit_request_fields
      limit_request_field_size debug reload spew preload_app chdir daemon pidfile
      worker_tmp_dir umask tmp_upload_dir secure_scheme_headers forward_allowed_ips
      accesslog pythonpath proxy_protocol proxy_allow_ips access_log_format errorlog 
      loglevel logger_class logconfig syslog_addr syslog syslog_prefix syslog_facility 
      enable_stdio_inheritance stats_host proc_name keyfile certfile ssl_version cert_reqs 
      ca_certs suppress_ragged_eofs do_handshake_on_connect ciphers
      }.each do |a|
    item = new_resource.send(a)
    template_variables[a.to_sym] = item unless item.nil?
  end

  #Chef::Log.debug("Using variables #{template_variables} to configure #{@new_resource}")

  config_dir = ::File.dirname(new_resource.path)

  d = directory config_dir do
    recursive true
    action :create
  end

  t = template new_resource.path do
    source new_resource.template
    cookbook new_resource.cookbook
    mode "0644"
    owner new_resource.owner if new_resource.owner
    group new_resource.group if new_resource.group
    variables(
      :path => new_resource.path,
      :options => template_variables, 
      :server_hooks => new_resource.send(:server_hooks),
      :valid_server_hooks_and_params => new_resource.send(:valid_server_hooks_and_params),
    )

  end

  new_resource.updated_by_last_action(d.updated_by_last_action? || t.updated_by_last_action?)
end

action :delete do
  if exists?
    if ::File.writable?(@new_resource.path)
      log("Deleting #{@new_resource} at #{@new_resource.path}")
      ::File.delete(@new_resource.path)
      new_resource.updated_by_last_action(true)
    else
      raise "Cannot delete #{@new_resource} at #{@new_resource.path}!"
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::GunicornConfig.new(@new_resource.name)
  @current_resource.path(@new_resource.path)
  @current_resource
end

private
  def exists?
    ::File.exist?(@current_resource.path)
  end
