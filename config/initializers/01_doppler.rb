# Initialize a top-level configuration value populated from secrets drawn from
# Doppler. This assumes that the `DOPPLER_TOKEN` environment variable is
# present, which is necessary to authenticate API calls to the Doppler endpoint.

Rails.application.config.before_configuration do
  Rails.application.config.doppler =
    JSON.parse(`doppler secrets --json`).map do |key, val|
      [key.downcase.to_sym, val['computed']]
    end.to_h
end
