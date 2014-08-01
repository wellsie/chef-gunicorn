#
# Author:: Jono Wells (<7@oj.io>)
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

require File.expand_path('helpers', File.dirname(__FILE__))

describe 'gunicorn_test::lwrps' do
  include Helpers::GunicornTest

  it 'creates flaskapp.py gunicorn settings file' do
    file('/etc/gunicorn/flaskapp.py').must_exist
  end

  it 'creates an entry for bind' do
    bind = 'bind'
    file('/etc/gunicorn/flaskapp.py').must_match(/#{bind}/)
  end
end