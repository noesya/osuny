source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.0"

gem "activestorage-scaleway-service"#, path: "../activestorage-scaleway-service"
gem "active_storage_validations", "~> 1"
gem "add_to_calendar"
gem "angularjs-rails"
gem "aws-sdk-s3"
gem "bootstrap"
gem "bootsnap", "~> 1", require: false
gem "bootstrap5-kaminari-views"
gem "breadcrumbs_on_rails"
gem "bugsnag"
# Lock précis parce que @sebouchu a identifié un problème
# (les authorize through des modèles qui faisaient des faux négatifs sur les rôles intermédiaires)
gem "cancancan", "~> 3.3.0"
gem "caxlsx_rails", "~> 0"
gem "citeproc", "~> 1"
gem "citeproc-ruby", "~> 2"
gem "cocoon", "~> 1"
gem "country_select"
gem "csl-styles", "~> 2"
gem "curation"#, path: "../../arnaudlevy/curation"
gem "delayed_job_active_record"
gem "delayed_job_prevent_duplicate"#, path: "../delayed_job_prevent_duplicate"
gem "delayed_job_web"
gem "devise"
gem "devise-i18n"
gem "enum_help"
# gem "faceted_search"#, path: "../../noesya/faceted_search"
gem "faceted_search"
gem "faraday"
gem "font-awesome-sass"
gem "front_matter_parser"
gem "geocoder", "~> 1"
gem "geo_point"
gem "gitlab"
gem "hal_openscience", "~> 0"
# gem "hal_openscience", path: "../hal_openscience"
gem "has_scope", "~> 0"
gem "hash_dot"
gem "i18n_data", "~> 0"
gem "i18n_date_range"
# gem "i18n_date_range", path: "../../noesya/i18n_date_range"
gem "image_processing"
gem "jbuilder"
gem "jquery-rails"
gem "jquery-ui-rails", git: "https://github.com/jquery-ui-rails/jquery-ui-rails.git", tag: "v7.0.0"
gem "kamifusen"#, path: "../kamifusen"
gem "kaminari"
gem "leaflet-rails"
gem "libretranslate"#, path: "../libretranslate"
gem "mini_magick"
gem "octokit"
gem "omniauth-rails_csrf_protection", "~> 1"
gem "omniauth-saml", "~> 2"
gem "orthotypo"#, path: '../../noesya/orthotypo'
gem "pexels", "~> 0"
gem "pg", "~> 1"
gem "puma"
gem "rails", "~> 7.1.0"
gem "rails-autocomplete", "~> 2"
gem "rails-i18n"
gem "roo", "~> 2"
gem "sanitize"
gem "sassc-rails"
gem "scout_apm", "~> 5"
gem "sib-api-v3-sdk"
gem "simple-navigation"
gem "simple_form"
gem "simple_form_bs5_file_input"#, path: "../simple_form_bs5_file_input"
gem "simple_form_password_with_hints"#, path: "../simple_form_password_with_hints"
gem "sprockets-rails", "~> 3"
gem "summernote-rails", git: "https://github.com/noesya/summernote-rails.git"
# gem "summernote-rails", path: "../summernote-rails"
gem "two_factor_authentication", git: "https://github.com/noesya/two_factor_authentication.git"
# gem "two_factor_authentication", path: "../two_factor_authentication"
gem "unsplash"

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "figaro"
  gem "vcr"
  gem "webmock"
end

group :development do
  gem "annotate"
  gem "listen", "~> 3.3"
  gem "rack-mini-profiler", "~> 2.0"
  gem "spring"
  gem "web-console", ">= 4.1.0"
end

group :test do
  gem "capybara", ">= 3.26"
  gem "selenium-webdriver"
  gem "webdrivers"
  gem "simplecov", require: false
end

gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
