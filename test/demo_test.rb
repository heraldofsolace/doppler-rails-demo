require "test_helper"

class DemoTest < ActiveSupport::TestCase
    test "Correct credential is loaded" do
        assert Rails.application.credentials.dig(:api_key) == "d1d3153d-a3c5-44ee-99d6-19f90fcd4f7c"
    end
end