# config/deploy.rb 全域設定
sh "ssh-add"
# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

# set :application, "my_app_name"
# set :repo_url, "git@example.com:me/my_repo.git"

# 設定專案名稱
set :application, "rails-recipes"
# 讓機器知道要到哪裡找我們的程式碼
set :repo_url, "git@github.com:edmondsun/rails-recipes.git" 

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"
set :deploy_to, "/home/ed/rails-recipes"

# Default value for :format is :airbrussh.
# set :format, :airbrussh
set :format, :pretty

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"
# 放在 shared 中，那些不在版本控制中的檔案
append :linked_files, "config/database.yml", ".env"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"
# 放在 shared 中，不同 release 之間共享的目錄
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system" 
set :passenger_restart_with_touch, true

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5
set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

set :passenger_restart_with_touch, true
