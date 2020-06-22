skip_devise = yes?('Do you skip devise? [yes or ELSE]')
commentout = ->(c) { '# ' if c }

# git
append_file ".gitignore", <<-CODE

.DS_Store
/coverage/
/spec/reports/
/spec/examples.txt
/vendor/bundle
CODE

# gem
append_file "Gemfile", <<-CODE

# group :development, :test do
#   gem "factory_bot_rails"
#   gem "faker"
# end

# group :test do
#   gem "rspec-rails"
#   gem "screenshot_opener"
#   gem "simplecov", require: false
#   gem "capybara"
#   gem "webdrivers"
# end

group :development do
  gem "pry-byebug"
  gem "pry-doc"
  gem "pry-rails"
  gem "pry-stack_explorer"

  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false

  #{commentout[skip_devise]}gem "letter_opener"
  #{commentout[skip_devise]}gem "letter_opener_web"
end

gem "rails-i18n"
gem "meta-tags"

#{commentout[skip_devise]}gem "devise"
#{commentout[skip_devise]}gem "devise-bootstrap-views", "~> 1.0"
#{commentout[skip_devise]}gem "devise-i18n"
CODE

# editorconfig
get "https://raw.githubusercontent.com/youdeee/dotfiles/master/rails/.editorconfig", ".editorconfig"

# rubocop
get "https://raw.githubusercontent.com/youdeee/dotfiles/master/rails/.rubocop.yml", ".rubocop.yml"

# application.rb
application do
<<-CODE
config.generators do |g|
  g.assets  false
  g.helper false
  g.stylesheets false
  # g.test_framework :rspec, fixture: true
  # g.fixture_replacement :factory_bot, dir: "spec/factories"
  # g.view_specs false
  # g.controller_specs false
  # g.routing_specs false
  # g.helper_specs false
  # g.request_specs true
end

config.time_zone = "Tokyo"
config.i18n.default_locale = :ja
config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}").to_s]

CODE
end

unless skip_devise
  environment(nil, env: "development") do
    <<-CODE
config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
config.action_mailer.delivery_method = :letter_opener_web

CODE
  end

  environment(nil, env: "production") do
    <<-CODE
config.action_mailer.default_url_options = { host: "DEFAULT_HOST", protocol: "https" }
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  :user_name => ENV["SENDGRID_USERNAME"],
  :password => ENV["SENDGRID_PASSWORD"],
  :domain => "herokuapp.com",
  :address => "smtp.sendgrid.net",
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}

CODE
  end
end

# locales
run "rm config/locales/en.yml"

file "config/locales/common/ja.yml", <<-CODE
ja:
  common:
    site: DEFAULT_APP_NAME
    login: ログイン
    logout: ログアウト
    signup: アカウント作成
    delete_action: 削除する
CODE

file "config/locales/home/ja.yml", <<-CODE
ja:
  home:
    index:
      description: DEFAULT_APP_NAMEなら、効率的なタスク管理で人生の時間を節約できます。
      subdescription: DEFAULT_APP_NAMEで日々のタスクを管理すると、タスクを楽しく柔軟に効率よく整理して優先順位をつけることができます。
      create_account: アカウントを作成 - 無料です！
CODE

# meta tag
insert_into_file("app/helpers/application_helper.rb", <<-'CODE', after: "module ApplicationHelper")

  def show_meta_tags
    if display_meta_tags.blank?
      key = "#{controller_path.tr('/', '.')}.#{action_name}.title"
      if I18n.exists? key
        assign_meta_tags(title: t(key))
      else
        assign_meta_tags
      end
    end
    display_meta_tags
  end

  def assign_meta_tags(options = {})
    defaults = {
      title:     t("common.site"),
      site:      t("common.site"),
      separator: ":",
      reverse:   true,
      canonical: request.original_url
    }
    options.reverse_merge!(defaults)
    set_meta_tags(options)
  end
CODE

# layouts
require "Date"

file("app/views/layouts/application.html.erb", <<-CODE, force: true)
<!DOCTYPE html>
<html>
  <head>
    <%= render "layouts/head" %>
  </head>
  <body>
    <%= yield %>
  </body>
</html>
CODE

unless skip_devise
  file("app/views/layouts/devise.html.erb", <<-CODE, force: true)
<!DOCTYPE html>
<html>
  <head>
    <%= render "layouts/head" %>
  </head>
  <body>
    <nav class="site-header sticky-top py-1">
      <div class="container d-flex justify-content-between">
        <%= link_to t("common.site"), root_path, class: "py-2" %>
      </div>
    </nav>
    <main class="container mt-2">
      <% if notice %>
        <p class="notice"><%= notice %></p>
      <% end %>
      <% if alert  %>
        <p class="alert"><%= alert %></p>
      <% end %>
      <%= yield %>
    </main>
    <%= render "layouts/footer" %>
  </body>
</html>
CODE

  file("app/controllers/application_controller.rb", <<-CODE, force: true)
class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def after_sign_in_path_for(_resource)
    # YOUR_LOGIN_RESOURCES_path
  end
end
CODE
end

file("app/views/layouts/home.html.erb", <<-CODE, force: true)
<!DOCTYPE html>
<html>
  <head>
    <%= render "layouts/head" %>
  </head>
  <body>
    <nav class="site-header sticky-top py-1">
      <div class="container d-flex justify-content-between">
        <%= link_to t("common.site"), root_path, class: "py-2" %>
        <div class="py-2">
          <%#{'#' if skip_devise}= link_to t("common.login"), new_user_session_path %>
          <%#{'#' if skip_devise}= link_to t("common.signup"), new_user_registration_path, class: "pl-2" %>
        </div>
      </div>
    </nav>
    <%= yield %>
    <%= render "layouts/footer" %>
  </body>
</html>
CODE

file "app/views/layouts/_head.html.erb", <<-CODE
<meta http-equiv="Content-type" content="text/html; charset=UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="format-detection" content="telephone=no">
<%= show_meta_tags %>
<%= csrf_meta_tags %>
<%= csp_meta_tag %>
<%= javascript_pack_tag "application" %>
<%= stylesheet_pack_tag "application", media: "all" %>
CODE

file "app/views/layouts/_footer.html.erb", <<-CODE
<footer class="container py-5">
  <div class="row">
    <div class="col-12 col-md">
      <small class="mb-3"><%= t("common.site") %></small>
      <small class="mb-3 text-muted">© #{Date.today.year}</small>
    </div>
    <% if false %>
      <div class="col-6 col-md">
        <h5>About</h5>
        <ul class="list-unstyled text-small">
          <li><a class="text-muted" href="#">Team</a></li>
          <li><a class="text-muted" href="#">Locations</a></li>
          <li><a class="text-muted" href="#">Privacy</a></li>
          <li><a class="text-muted" href="#">Terms</a></li>
        </ul>
      </div>
    <% end %>
  </div>
</footer>
CODE

# static error pages
file("public/404.html", <<-CODE, force: true)
<!DOCTYPE html>
<html>
  <head>
    <title>Page not found (404)</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
  </head>
  <body>
    <h1>Page not found (404)</h1>
  </body>
</html>
CODE

file("public/422.html", <<-CODE, force: true)
<!DOCTYPE html>
<html>
  <head>
    <title>Change was rejected (422)</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
  </head>
  <body>
    <h1>Change was rejected (422)</h1>
  </body>
</html>
CODE

file("public/500.html", <<-CODE, force: true)
<!DOCTYPE html>
<html>
  <head>
    <title>Internal server error (500)</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
  </head>
  <body>
    <h1>Internal server error (500)</h1>
  </body>
</html>
CODE

# LP
route "root to: \"home#index\""

file "app/controllers/home_controller.rb", <<-CODE
class HomeController < ActionController::Base
end
CODE

file "app/views/home/index.html.erb", <<-CODE
<div class="position-relative overflow-hidden p-3 p-md-5 m-md-3 text-center bg-light">
  <div class="col-md-5 p-lg-5 mx-auto my-5">
    <h1 class="font-weight-normal"><%= t(".description") %></h1>
    <p class="lead font-weight-normal"><%= t(".subdescription") %></p>
    <%#{'#' if skip_devise}= link_to t(".create_account"), new_user_registration_path, class: "btn btn-outline-secondary" %>
  </div>
  <div class="product-device shadow-sm d-none d-md-block"></div>
  <div class="product-device product-device-2 shadow-sm d-none d-md-block"></div>
</div>
<style>
  .product-device {
    position: absolute;
    right: 10%;
    bottom: -30%;
    width: 300px;
    height: 540px;
    background-color: #333;
    border-radius: 21px;
    -webkit-transform: rotate(30deg);
    transform: rotate(30deg);
  }

  .product-device::before {
    position: absolute;
    top: 10%;
    right: 10px;
    bottom: 10%;
    left: 10px;
    content: "";
    background-color: rgba(255, 255, 255, .1);
    border-radius: 5px;
  }

  .product-device-2 {
    top: -25%;
    right: auto;
    bottom: 0;
    left: 5%;
    background-color: #e5e5e5;
  }

  .overflow-hidden { overflow: hidden; }
</style>
CODE

# db
rails_command("db:create")

after_bundle do
  # js
  run "yarn add bootstrap jquery popper.js moment @fortawesome/fontawesome-free"

  append_file "app/javascript/packs/application.js", <<-CODE

import $ from 'jquery'
global.$ = $
global.jQuery = $
import 'bootstrap'

import moment from 'moment'
moment.locale('ja')
global.moment = moment

import '@fortawesome/fontawesome-free/js/all'

import '../stylesheets/application'
CODE

  file "app/javascript/stylesheets/application.scss", <<-CODE
@import '~bootstrap/scss/bootstrap';
@import '~@fortawesome/fontawesome-free/scss/fontawesome';

.site-header {
  background-color: rgba(0, 0, 0, .85);
  -webkit-backdrop-filter: saturate(180%) blur(20px);
  backdrop-filter: saturate(180%) blur(20px);
}
.site-header a {
  color: #999;
  transition: ease-in-out color .15s;
}
.site-header a:hover {
  color: #fff;
  text-decoration: none;
}
CODE

  insert_into_file("config/webpack/environment.js", <<-CODE, before: "module.exports = environment")
const webpack = require('webpack')
environment.plugins.prepend('Provide',
                            new webpack.ProvidePlugin({
                              $: 'jquery/src/jquery',
                              jQuery: 'jquery/src/jquery',
                              Popper: ['popper.js', 'default']
                            })
                           )

CODE

  # devise
  unless skip_devise
    route <<-CODE
if Rails.env.development?
  mount LetterOpenerWeb::Engine, at: "/letter_opener"
end
CODE

    run "bin/spring stop"
    run "bundle exec rails generate devise:install"
    run "rm config/locales/devise.en.yml"

    gsub_file "config/initializers/devise.rb", "# config.lock_strategy = :failed_attempts", "config.lock_strategy = :failed_attempts"
    gsub_file "config/initializers/devise.rb", "# config.unlock_keys = [:email]", "config.unlock_keys = [:email]"
    gsub_file "config/initializers/devise.rb", "# config.unlock_strategy = :both", "config.unlock_strategy = :both"
    gsub_file "config/initializers/devise.rb", "# config.maximum_attempts = 20", "config.maximum_attempts = 10"
    gsub_file "config/initializers/devise.rb", "# config.unlock_in = 1.hour", "config.unlock_in = 0.5.hour"
    gsub_file "config/initializers/devise.rb", "# config.last_attempt_warning = true", "config.last_attempt_warning = true"

    run "bundle exec rails generate devise user"

    file("app/models/user.rb", <<-CODE, force: true)
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable
end
CODE

    gsub_file Dir.glob("db/migrate/*")[0], "# t.integer  :sign_in_count, default: 0, null: false", "t.integer  :sign_in_count, default: 0, null: false"
    gsub_file Dir.glob("db/migrate/*")[0], "# t.datetime :current_sign_in_at", "t.datetime :current_sign_in_at"
    gsub_file Dir.glob("db/migrate/*")[0], "# t.datetime :last_sign_in_at", "t.datetime :last_sign_in_at"
    gsub_file Dir.glob("db/migrate/*")[0], "# t.string   :current_sign_in_ip", "t.string   :current_sign_in_ip"
    gsub_file Dir.glob("db/migrate/*")[0], "# t.string   :last_sign_in_ip", "t.string   :last_sign_in_ip"
    gsub_file Dir.glob("db/migrate/*")[0], "# t.string   :confirmation_token", "t.string   :confirmation_token"
    gsub_file Dir.glob("db/migrate/*")[0], "# t.datetime :confirmed_at", "t.datetime :confirmed_at"
    gsub_file Dir.glob("db/migrate/*")[0], "# t.datetime :confirmation_sent_at", "t.datetime :confirmation_sent_at"
    gsub_file Dir.glob("db/migrate/*")[0], "# t.string   :unconfirmed_email", "t.string   :unconfirmed_email"
    gsub_file Dir.glob("db/migrate/*")[0], "# t.integer  :failed_attempts, default: 0, null: false", "t.integer  :failed_attempts, default: 0, null: false"
    gsub_file Dir.glob("db/migrate/*")[0], "# t.string   :unlock_token", "t.string   :unlock_token"
    gsub_file Dir.glob("db/migrate/*")[0], "# t.datetime :locked_at", "t.datetime :locked_at"
    gsub_file Dir.glob("db/migrate/*")[0], "# add_index :users, :confirmation_token,   unique: true", "add_index :users, :confirmation_token,   unique: true"
    gsub_file Dir.glob("db/migrate/*")[0], "# add_index :users, :unlock_token,         unique: true", "add_index :users, :unlock_token,         unique: true"

    rails_command("db:migrate")
  end

  # run rubocop
  run "bundle exec rubocop --auto-correct"

  # git commit
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
