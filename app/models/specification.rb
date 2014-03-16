#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Specification < ActiveRecord::Base
  self.primary_key = :id

  before_create do |instance|
    instance.id = Specification.id_hash(instance.data)
  end
  serialize :data, YamlSerializer
  
  validate :id_matches_data, on: :update

  validate :data_poperties

  default_scope{order(:id)}

  def self.id_hash data
    YamlSerializer.uuid_hash data
  end

  ###########

  def id_matches_data 
    unless id == Specification.id_hash(self.data)
      errors.add(:data, "is immutable")
    end
  end

  def data_poperties 

#    unified_data =  data.deep_symbolize_keys
#
#    unless unified_data[:contexts].is_a? Array
#      errors.add(:data, "requires a contexts array")
#    end
#
#    unified_data[:contexts].map(&:deep_symbolize_keys).each do |context|
#
#      unless context[:tasks] or context[:tasks_file]
#        errors.add(:data, "A context must contain either a 'tasks_file' or 'tasks' key")
#      end
#
#      if context[:tasks] and not context[:tasks].is_a? Array
#        errors.add(:data, "The value of the 'tasks' key must be an array.")
#      end
#
#      if context[:file] and not context[:file].is_a? String
#        errors.add(:data, "The value of the 'file' key must be a string.")
#      end
#
#    end
#
#    unless unified_data[:traits].is_a? Array
#      errors.add(:data, "requires an traits array")
#    end

  end

  ##########
  
  def self.find_or_create_by_data! data
    find_by(id: id_hash(data)) || create!(data: data)
  end


end
