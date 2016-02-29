require "spec_helper"
require "rubocop"

RSpec.describe "A new project" do
  before(:all) do
    drop_dummy_database
    remove_project_directory
    create_dummy_project
  end

  it "is correctly bundled" do
    expect { on_project { `bundle exec rails -v` } }.to_not output.to_stderr
  end

  it "is a valid rubocop project" do
    on_project do
      options, paths = RuboCop::Options.new.parse(["."])
      runner = RuboCop::Runner.new(options, RuboCop::ConfigStore.new)
      expect(runner.run(paths)).to eq(true)
    end
  end
end
