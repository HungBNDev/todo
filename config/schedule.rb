# config/schedule.rb
set :environment, ENV.fetch("RAILS_ENV", "production")
set :output, "/rails/log/cron.log"
set :job_template, "bash -l -c 'source /rails/.env.cron && :job'"
#
# every 15.minutes do
#   rake "gold:notify"
# end
