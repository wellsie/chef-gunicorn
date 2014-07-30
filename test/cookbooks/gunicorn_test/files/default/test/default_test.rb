# Create one recipe-name_test.rb file for each recipe to be tested.
require File.expand_path('helpers', File.dirname(__FILE__))

# For your own cookbooks, describe mycookbookname::default
describe 'gunicorn::default' do

  include Helpers::GunicornTest

  gunicorn = Mixlib::ShellOut.new('gunicorn -v')
  gunicorn.run_command
  gunicorn.error!
end
