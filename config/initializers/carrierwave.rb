CarrierWave.configure do |config|
  config.asset_host = Rails.application.secrets[:host]
end
