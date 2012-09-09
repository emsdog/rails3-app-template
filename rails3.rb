#encoding: utf-8
#####################################################################
#前置条件：执行 rails new myapp -m https://raw.github.com/RailsApps/rails-composer/master/composer.rb -T 初始化基于devise cancan bootstrap 的基础程序
#程序功能：为上述程序增加一些定制化的功能，践行DRY的ruby哲学。
# 1，增加一些定制化的gem [acts_as_tenant attr_encrypted acts_as_spider]
# 2，增加一套rake任务[dev:build]
# 3，增加一套saas任务[saas:apply User]，这个命令包含以下逻辑:
#     1）向User模型中增加act_as_tenant
#     2) 调用bootstrap:themed Users -f 强制更新前台使用的主题样式
#
#####################################################################
# remove files
run "rm README"
run "rm public/index.html"
run "rm public/images/rails.png"
run "cp config/database.yml config/database.yml.example"

# install gems
run "rm Gemfile"
file 'Gemfile', File.read("#{File.dirname(rails_template)}/Gemfile")

# bundle install
run "bundle install"

# generate rspec
generate "rspec:install"

# copy files
file 'script/watchr.rb', File.read("#{File.dirname(rails_template)}/watchr.rb")
file 'lib/tasks/dev.rake', File.read("#{File.dirname(rails_template)}/dev.rake")

# remove active_resource and test_unit
gsub_file 'config/application.rb', /require 'rails\/all'/, <<-CODE
  require 'rails'
  require 'active_record/railtie'
  require 'action_controller/railtie'
  require 'action_mailer/railtie'
CODE

# install jquery
run "curl -L http://code.jquery.com/jquery.min.js > public/javascripts/jquery.js"
run "curl -L http://github.com/rails/jquery-ujs/raw/master/src/rails.js > public/javascripts/rails.js"

gsub_file 'config/application.rb', /(config.action_view.javascript_expansions.*)/, 
                                   "config.action_view.javascript_expansions[:defaults] = %w(jquery rails)"

# add time format
environment 'Time::DATE_FORMATS.merge!(:default => "%Y/%m/%d %I:%M %p", :ymd => "%Y/%m/%d")'

# .gitignore
append_file '.gitignore', <<-CODE
config/database.yml
Thumbs.db
.DS_Store
tmp/*
coverage/*
CODE

# keep tmp and log
run "touch tmp/.gitkeep"
run "touch log/.gitkeep"

# git commit
git :init
git :add => '.'
git :add => 'tmp/.gitkeep -f'
git :add => 'log/.gitkeep -f'
git :commit => "-a -m 'initial commit'"