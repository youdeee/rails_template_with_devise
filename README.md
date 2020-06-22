# rails_template_with_devise
## How to start Rails
- mkdir your_project_root && cd $_
- bundle init
- edit Gemfile (delete commentout at gem "rails")
- bundle install
- bundle exec rails new . -d mysql --skip-action-text --skip-action-mailbox -T --skip-turbolinks -m https://raw.githubusercontent.com/youdeee/rails_template_with_devise/master/template.rb
- rails s (and bin/webpack-dev-server)

## What you should do after start
### Replace placeholder
- DEFAULT_APP_NAME : your app name show at views.
- DEFAULT_HOST : mailer settings.
- YOUR_LOGIN_RESOURCES : root resources during logged in.

## TODO
- Add rspec settings.
