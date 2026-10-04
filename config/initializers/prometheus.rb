if Rails.env.production? || ENV["ENABLE_PROMETHEUS"].present?
  require "prometheus_exporter/middleware"
  Rails.application.config.middleware.insert_after 0, PrometheusExporter::Middleware
end
