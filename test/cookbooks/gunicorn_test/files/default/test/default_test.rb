# Create one recipe-name_test.rb file for each recipe to be tested.
require File.expand_path('helpers', File.dirname(__FILE__))

# For your own cookbooks, describe mycookbookname::default
describe 'gunicorn::default' do

  # Helpers::MinitestHandler library is defined at
  # #{cookbook_root}/files/default/tests/minitest/support/helpers.rb
  # For each cookbook, rename library to Helpers::MyCookbookName in
  # this file and in helpers.rb
  include Helpers::GunicornTest

  gunicorn = Mixlib::ShellOut.new('gunicorn -v')
  gunicorn.run_command
  gunicorn.error!
end
