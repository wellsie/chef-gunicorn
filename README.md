Description
===========

Installs and configures the latest version of Gunicorn (via pip), aka `Green Unicorn`, a Python WSGI HTTP Server for UNIX. It's a pre-fork worker model ported from Ruby's Unicorn project.  Includes an LWRP for managing Gunicorn config files.  By default Gunicorn is installed system-wide but you can target a particular `virtualenv` by overriding the `node["gunicorn"]["virtualenv"]` attribute.

Requirements
============

Platform
--------

* Debian, Ubuntu
* Amazon, CentOS, Red Hat, Fedora

Cookbooks
---------

* python

Attributes
==========

* `node["gunicorn"]["virtualenv"]` - the virtualenv you want to target Gunicorn installation into.  The virtualenv will be created if it doesn't exist.

Recipes
=======

default
-------

Installs Gunicorn using pip.

Resource/Provider
=================

This cookbook includes a LWRP for managing gunicorn config files.

`gunicorn_config`
-----------------

Creates a Gunicorn configuration file at the path specified. In depth information about Gunicorn's configuration values can be [found in the Gunicorn documentation](http://gunicorn.org/settings.html).

**This fork supports attributes with the same name and the Gunicorn settings, to improve readability and reduce confusion.**

# Actions

- :create: create a Gunicorn configuration file.
- :delete: delete an existing Gunicorn configuration file.

# Attribute Parameters

All Gunicorn v19 settings are supported with the exception of:

- user
- group
- raw_env

Note that there are only two attributes with default values:

- bind: default = '127.0.0.1:8000'
- workers: default is [number of cpu cores] * 2 + 1 or 8 which ever is smaller

Visit [Gunicorn settings documentation](http://gunicorn.org/settings.html) for details on all settings.

# Example

    # create a config with the default values
    gunicorn_config "/etc/gunicorn/myapp.py" do
      action :create
    end

    # provide some attribute values
    gunicorn_config "/etc/gunicorn/myapp.py" do
      bind 'unix:/srv/apps/flaskapp/run/flaskapp.sock'
      worker_processes 3
      worker_class :gevent
      backlog 4096
      proc_name 'gunicorn_myapp'
      debug true
      secure_scheme_headers(
        :X-FORWARDED-PROTOCOL => 'ssl', 
        :X-FORWARDED-PROTO => 'https',
        :X-FORWARDED-SSL => 'on'
      )
      action :create
    end

    # use the 'pre_fork' server hook to
    # sleep for a second before forking
    gunicorn_config "/etc/gunicorn/myapp.py" do
      bind '0.0.0.0:8888'
      server_hooks({:pre_fork => 'import time;time.sleep(1)'})
      action :create
    end


License and Authors
===================

Author:: Jono Wells(<7@oj.io>)
Author:: Seth Chisamore (<schisamo@opscode.com>)

Copyright:: 2014, Jono Wells
Copyright:: 2011, Opscode, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
