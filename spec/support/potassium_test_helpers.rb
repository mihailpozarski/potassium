module PotassiumTestHelpers
  APP_NAME = "dummy_app"

  def remove_project_directory
    FileUtils.rm_rf(project_path)
  end

  def create_tmp_directory
    FileUtils.mkdir_p(tmp_path)
  end

  def create_dummy_project
    Dir.chdir(tmp_path) do
      Bundler.with_clean_env do
        run_command("#{potassium_bin} create #{APP_NAME} #{bin_arguments}")
      end
    end
  end

  def drop_dummy_database
    return unless File.exist?(project_path)
    on_project { run_command("bundle exec rake db:drop") }
  end

  def project_path
    @project_path ||= Pathname.new("#{tmp_path}/#{APP_NAME}")
  end

  def on_project(&block)
    Dir.chdir(project_path) do
      Bundler.with_clean_env do
        block.call
      end
    end
  end

  private

  def tmp_path
    @tmp_path ||= Pathname.new("#{root_path}/tmp")
  end

  def potassium_bin
    File.join(root_path, "bin", "potassium")
  end

  def bin_arguments
    [
      "--db=mysql",
      "--lang=es",
      "--no-devise",
      "--no-admin",
      "--no-pundit",
      "--no-paperclip",
      "--no-api",
      "--no-heroku",
      "--no-delayed-job"
    ].join(" ")
  end

  def root_path
    File.expand_path("../../../", __FILE__)
  end

  def run_command(command)
    system(command)
  end
end
