require 'clockwork'
require_relative 'boot'
require_relative 'environment'

module Clockwork
  every(1.day, 'api:daily_reset', at: '00:00', tz: 'UTC') do
    system('bundle exec rake api:daily_reset')
  end

  every(1.week, 'api:weekly_reset', at: 'Sunday 00:00', tz: 'UTC') do
    system('bundle exec rake api:weekly_reset')
  end
end
