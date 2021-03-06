class Recipes::Api < Rails::AppBuilder
  def ask
    api_support = answer(:api) { Ask.confirm("Do you want to enable API support?") }
    set(:api_support, api_support)
  end

  def create
    add_api if get(:api_support)
  end

  def install
    add_api
  end

  def installed?
    gem_exists?(/versionist/)
  end

  private

  def add_api
    gather_gem 'versionist'
    gather_gem 'responders'
    gather_gem 'active_model_serializers', '~> 0.9.3'
    gather_gem 'simple_token_authentication', '~> 1.0'

    after(:gem_install) do
      line = "Rails.application.routes.draw do\n"
      insert_into_file "config/routes.rb", after: line do
        <<-HERE.gsub(/^ {8}/, '')
          scope path: '/api' do
            api_version(module: "Api::V1", path: { value: "v1" }, defaults: { format: 'json' }) do
            end
          end
        HERE
      end

      api_error_concern_path = 'app/controllers/concerns/api_error_concern.rb'

      copy_file '../assets/api/base_controller.rb', 'app/controllers/api/v1/base_controller.rb'
      copy_file '../assets/api/api_error_concern.rb', api_error_concern_path
      copy_file '../assets/api/responder.rb', 'app/responders/api_responder.rb'

      if selected?(:report_error)
        previous_line = 'logger.error exception.backtrace.join("\n")'
        new_line = "\n      Raven.capture_exception(exception)"
        insert_into_file api_error_concern_path, new_line, after: previous_line
      end
    end
  end
end
