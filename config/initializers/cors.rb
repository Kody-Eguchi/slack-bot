Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*' 
    resource '*',
      headers: :any,
      methods: [:post, :get, :options, :delete, :put, :patch]
  end
end
