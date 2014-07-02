if ENV['RACK_ENV'] == 'development'
  worker_processes 1
  listen "#{ENV['BOXEN_SOCKET_DIR']}/rails_app", backlog: 1024, tcp_nopush: false
  timeout 60
else
  worker_processes Integer(ENV["WEB_CONCURRENCY"] || 2)
  port = ENV["PORT"].to_i
  listen port, backlog: Integer(ENV['UNICORN_BACKLOG'] || 5), tcp_nopush: false
  timeout 29
end

preload_app true # for new relic

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

end

after_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
  end

  #https://devcenter.heroku.com/articles/concurrency-and-database-connections
  if defined?(ActiveRecord::Base)
    db_pool_size = if ENV["DB_POOL"]
      ENV["DB_POOL"]
    else
      ENV["WEB_CONCURRENCY"] || 2
    end

    config = Rails.application.config.database_configuration[Rails.env]
    config['reaping_frequency'] = ENV['DB_REAP_FREQ'] || 10 # seconds
    config['pool']              = db_pool_size
    ActiveRecord::Base.establish_connection(config)
    ActiveRecord::Base.connection.execute "update pg_settings set setting='off' where name = 'synchronous_commit';"
  end

end
