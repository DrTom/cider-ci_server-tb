#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Executor < ActiveRecord::Base
  ONLINE_SQL_CONDITION = "last_ping_at > (now() - interval '3 Minutes')"

  has_many :trials
  has_one :executor_with_load, primary_key: 'id', foreign_key: 'id'

  self.primary_key= 'id'

  before_create{self.id ||= SecureRandom.uuid}

  default_scope{order(:name)}
  scope :enabled, lambda{where(enabled: true)}
  scope :online, lambda{where(ONLINE_SQL_CONDITION)}

  def ping
    begin
      RestClient.post("#{url}/ping", {time: Time.zone.now.iso8601}.to_json, 
                      content_type: :json, accept: :json, timeout: 3, open_timeout: 3)
      update_attributes! last_ping_at: Time.zone.now
    rescue  RestClient::Exception, Errno::ECONNREFUSED => e
      Rails.logger.warn Formatter.exception_to_log_s(e)
      nil 
    end
    self
  end

  def online?
    !! Executor.where(id: self.id).where(ONLINE_SQL_CONDITION).take
  end

  def protocol
    ssl ? "https" : "http" 
  end

  def url
    "#{protocol}://#{host}:#{port}"
  end
end
