#File config/initializers/swagger_docs.rb
Swagger::Docs::Config.register_apis({
  "1.0" =>  {
    :api_file_path => "public",
    :base_path => ENV['rootUrl'] ? ENV['rootUrl'] : "http://localhost:3000",
    :clean_directory => true,
  }
})
