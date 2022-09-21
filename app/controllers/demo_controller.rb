class DemoController < ApplicationController
  def index
    @doppler_project = Rails.application.credentials.doppler_project
    @doppler_environment = Rails.application.credentials.doppler_environment
    @doppler_config = Rails.application.credentials.doppler_config
    @api_key = Rails.application.credentials.api_key
  end
end
