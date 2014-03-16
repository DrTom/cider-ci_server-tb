#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Definition < ActiveRecord::Base
  self.primary_key = :id

  belongs_to :specification
  has_many :branch_update_triggers

  before_create do 
    self.id ||= SecureRandom.uuid
  end

  default_scope{order(:name,:id)}

  validates :name, uniqueness: true, allow_blank: false
  validates :name, length: {minimum: 1}, allow_nil: false


  def to_s
    name
  end
end
