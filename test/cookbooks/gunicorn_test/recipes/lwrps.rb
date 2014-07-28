#
# Author:: Jono Wells (<schisamo@opscode.com>)
# Cookbook Name:: gunicorn_test
# Recipe:: lwrps
#
# Copyright 2014, Jono Wells
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

include_recipe 'gunicorn'

gunicorn_config '/etc/gunicorn/flaskapp.py' do
  action :create
  bind 'unix:/tmp/jfd.sock'
  # workers 1
  worker_class :gevent
  keep_alive 7
  debug true
  secure_scheme_headers(
    'X-FORWARDED-PROTOCOL' => 'ssl',
    'X-FORWARDED-PROTO' => 'https',
    'X-FORWARDED-SSL' => 'on'
   )

  server_hooks(
    :on_starting => 'print(server)',
    :on_reload => 'print(server)',
    :when_ready => 'print(server)',
    :pre_fork => 'print(server, worker)',
    :post_fork => 'print(server, worker)',
    :pre_exec => 'print(server)',
    :pre_request => 'print(worker, req)',
    :post_request => 'print(worker, req)',
    :worker_exit => 'print(server, worker)'
  )
end
