require 'chefspec'
require_relative 'spec_helper'

describe 'gunicorn::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'includes the python::default recipe' do
    expect(chef_run).to include_recipe('python')
  end
end
