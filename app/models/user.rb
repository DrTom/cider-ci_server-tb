#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class User < ActiveRecord::Base
  has_secure_password validations: false  
  has_many :email_addresses, lambda{order(email_address: :asc)}

  def to_s
    login
  end

  before_save{ self.login_downcased= self.login.downcase}

  after_save{ User.check_last_admin_not_gone! }
  after_destroy{ User.check_last_admin_not_gone! }

  validates :login, :first_name, :last_name, presence: true

  validates :login, format: { with: /\A[\w\d]+\z/, message: "Only alphanumic characters allowed" }

  default_scope lambda{order(:last_name,:first_name)}

  scope :most_recent,lambda{reorder(updated_at: :desc)}


  def self.check_last_admin_not_gone!
    raise "There must be at least one administrator!" if User.users? and not User.admins? 
  end

  def self.users? 
    User.count > 0
  end

  def self.admin_party?
    not users?
  end

  def self.admins? 
    User.where(is_admin: true).count > 0
  end

end
