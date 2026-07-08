# config/clockwork.rb
# Scheduled tasks for Flight API

require 'clockwork'
require_relative 'boot'
require_relative 'environment'

module Clockwork
  handler do |job|
    puts "[Clockwork] Running scheduled job: #{job}"
  end

  # Daily flight status reset at midnight UTC
  every(1.day, 'api:daily_reset', at: '00:00', tz: 'UTC') do
    puts "[#{Time.now.utc}] Starting daily flight status reset..."

    begin
      Rake::Task['api:daily_reset'].reenable
      Rake::Task['api:daily_reset'].invoke
      puts "[#{Time.now.utc}] ✅ Daily reset completed successfully"
    rescue => e
      puts "[#{Time.now.utc}] ❌ ERROR in daily reset: #{e.message}"
      Rails.logger.error "Daily reset failed: #{e.message}\n#{e.backtrace.join("\n")}"
    end
  end

  # Weekly seat and pricing reset at Sunday midnight UTC
  every(1.week, 'api:weekly_reset', at: 'Sunday 00:00', tz: 'UTC') do
    puts "[#{Time.now.utc}] Starting weekly seat and pricing reset..."

    begin
      Rake::Task['api:weekly_reset'].reenable
      Rake::Task['api:weekly_reset'].invoke
      puts "[#{Time.now.utc}] ✅ Weekly reset completed successfully"
    rescue => e
      puts "[#{Time.now.utc}] ❌ ERROR in weekly reset: #{e.message}"
      Rails.logger.error "Weekly reset failed: #{e.message}\n#{e.backtrace.join("\n")}"
    end
  end

  # Daily weather regeneration at 1:00 AM UTC (after flight reset)
  every(1.day, 'api:weather_refresh', at: '01:00', tz: 'UTC') do
    puts "[#{Time.now.utc}] Starting daily weather refresh..."

    begin
      # Delete old weather (more than 7 days old)
      deleted = WeatherCondition.where('forecast_date < ?', Date.current).delete_all
      puts "[#{Time.now.utc}] Deleted #{deleted} old weather records"

      # Generate new weather for next 7 days
      WeatherCondition.generate_forecasts(7)
      puts "[#{Time.now.utc}] Generated 7-day forecasts for all airports"

      puts "[#{Time.now.utc}] ✅ Weather refresh completed successfully"
    rescue => e
      puts "[#{Time.now.utc}] ❌ ERROR in weather refresh: #{e.message}"
      Rails.logger.error "Weather refresh failed: #{e.message}\n#{e.backtrace.join("\n")}"
    end
  end
end
