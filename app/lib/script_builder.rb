#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

module ScriptBuilder
  class << self

    def non_blank_or_nil v
      case v
      when String
        v.blank? ? nil : v
      else
        v
      end
    end

    # builds the scripts for a given task out of the specification; 
    # the task data must be given as the last element of the hierarchy array; 
    def build_scripts hierarchy 
        script_names(hierarchy) \
          .map{|name| Hash[name, build_script(name, hierarchy)]} \
          .reduce(&:merge)
    end

    def script_names hierarchy
      hierarchy.map do |space| 
        space.deep_symbolize_keys.try(:[],:scripts).try(:map){|name,script| name}
      end.flatten.uniq.reject(&:nil?).reject{|name| name =~ /^_.*/}
    end

    def build_script name, hierarchy
      { body: ['_common',name].map{|name| spec_attribute_concat_string(:body,name, hierarchy)}.join("\n"),
        order: spec_attribute_last_value(:order, name, hierarchy) || Script::DEFAULT_ORDER,
        timeout: spec_attribute_last_value(:timeout, name, hierarchy) || Script::DEFAULT_TIMEOUT,
        interpreter: spec_attribute_last_value(:interpreter, name, hierarchy) || nil,
        type:  spec_attribute_last_value(:type, name, hierarchy) || "main" }
    end

    def spec_attribute_concat_string  att_name, script_name, hierarchy
      collect_attribute_data(att_name, script_name, hierarchy) \
        .join("\n").nil_or_non_blank_value
    end

    def spec_attribute_last_value att_name, script_name, hierarchy
      collect_attribute_data(att_name, script_name, hierarchy) \
        .reject(&:nil?).last
    end

    def collect_attribute_data  att_name, script_name, hierarchy
      hierarchy.map{|space| space.deep_symbolize_keys \
        .try(:[],:scripts).try(:[],script_name.to_sym).try(:[],att_name.to_sym)} \
        .reject(&:nil?).map{|v| non_blank_or_nil v}.reject(&:nil?)
    end

  end
end
