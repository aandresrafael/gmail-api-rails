class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def cache_expire
    Rails.configuration.settings['cache_expiry'].minutes
  end

  def race_condition_ttl
    Rails.configuration.settings['cache_race_ttl'].minutes
  end
end
