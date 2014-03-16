#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Execution < ActiveRecord::Base

  if defined? TorqueBox
    always_background :create_tasks_and_trials_for
  end

  has_one :execution_stat
  has_one :execution_cache_signature

  before_create{self.id ||= SecureRandom.uuid}

  belongs_to :specification

  has_and_belongs_to_many :tags 

  has_many :commits, primary_key: 'tree_id', foreign_key: 'tree_id'  #through: :tree
  has_many :branches, ->{reorder("branches.name ASC").uniq} ,through: :commits
  has_many :repositories, ->{reorder("").uniq}, through: :branches

  has_many :tasks #, foreign_key: [:specification_id,:tree_id]

  default_scope { order(created_at: :desc,tree_id: :asc,specification_id: :asc) }

  serialize :substituted_specification_data

  def repository
    Repository.joins(branches: :commits).where("commits.tree_id  = ?",self.tree_id) \
      .reorder("branches.updated_at").first
  end

  ### deeper associations
  #def branches
  #  Branch.joins(commits: :tree).where("trees.id = ?",self.tree_id) \
  #    .reorder(name: :desc).select("DISTINCT branches.*")
  #end
  #def respositories
  #  Repository.joins(branches:  {commits: :tree}).where("trees.id = ?",self.tree_id) \
  #   .reorder(name: :asc,created_at: :desc).select("DISTINCT repositories.*")
  #end
  def trials
    Trial.joins(task: :execution) \
      .where("executions.tree_id = ?",tree_id) \
      .where("executions.specification_id = ?", specification_id) \
  end
  ######################

  # a commit, rather arbitrary the most recent 
  # but git doesn't care as long it is referenced by a head 
  def commit 
    commits.reorder(updated_at: :desc).first
  end


  def accumulated_time
    trials.where.not(started_at: nil).where.not(finished_at: nil) \
      .select("date_part('epoch', SUM(finished_at - started_at)) as acc_time") \
      .reorder("").group("executions.tree_id").first[:acc_time]
  end

  def duration
    trials.reorder("") \
      .select("date_part('epoch', MAX(finished_at) - MIN(started_at)) duration") \
      .group("executions.tree_id").first[:duration]
  end

  def collect_from_specification hierarchy, keyword
    hierarchy.map{|x| x[keyword]}.reject(&:nil?).reduce(&:merge)
  end

  def self.create_tasks_and_trials_for id
    begin 
      Execution.find(id).create_tasks_and_trials
    rescue Exception => e
      Execution.find(id).update_attributes \
        state: 'failed', error: Formatter.exception_to_log_s(e)
    end
  end

  def create_tasks_and_trials
    begin
      update_attributes! substituted_specification_data:  substitute_specification_data.deep_stringify_keys
      if substituted_specification_data["error"] 
        self.update_attributes! state: "failed"
      else
        spec = substituted_specification_data.deep_symbolize_keys
        spec[:contexts].map(&:deep_symbolize_keys).each do |context|
          context[:tasks].map(&:deep_symbolize_keys).each do |task_data| 
            environment_variables = [spec,context,task_data].map{|x| x[:environment_variables]}.reject(&:nil?).reduce(&:merge)
            begin
              @task = Task.create! execution: self
              @task.update_attributes!  traits: (spec[:traits] || []),
                priority: task_data[:priority] || context[:priority] || @task.priority,
                name: [spec[:name],context[:name],task_data[:name]].reject(&:blank?).join(" - "),
                data: task_data.merge({scripts: ScriptBuilder.build_scripts([spec,context,task_data]),
                                      ports: collect_from_specification([spec,context,task_data],:ports), 
                                      environment_variables: collect_from_specification([spec,context,task_data],:environment_variables), 
                                      attachments: collect_from_specification([spec,context,task_data],:attachments)}) 
              @task.create_trial
            rescue Exception => e
              @task.update_attributes(state: 'failed', error: Formatter.exception_to_log_s(e)) if @task
            end
          end
        end
      end
    rescue Exception => e
      update_attributes state: 'failed', error: Formatter.exception_to_log_s(e)
      self
    end
    self
  end

  def substitute_specification_data

    begin 

      path_getter = lambda{|path|
        repository.get_file_content_for(commit,path).instance_eval do|file_content|
          case path
          when /\.yml/
            Psych.load file_content
          when /\.json/
            JSON.parse file_content
          else
            file_content
          end
        end
      }

      k_v_substitutor= lambda{|k,v|
        substitution_match = /^(\w+)_substitute_with_path:?$/
        if k =~ substitution_match and v.is_a?(String)
          [k.match(substitution_match).captures.first, path_getter.call(v) ]
        else
          [k,v]
        end
      }

      node_substitutor = lambda{|x|
        substitution_macher = /^substitute_with_path:?\s*(.*)$/
        if x.is_a? String and x =~ substitution_macher
          path_getter.call x.match(substitution_macher).captures.first
        else
          x
        end
      }
      DFS.new(node_substitutor,k_v_substitutor).traverse(specification.data)

    rescue Exception => e
      Rails.logger.error Formatter.exception_to_log_s(e)
      {error: "Subsitution failed with #{e.to_s}. See the trace details.",
        trace: Formatter.exception_to_log_s(e) }
    end
  end

  def update_state!
    update_attributes! state: _state
  end

  def _state
    task_states = tasks.pluck(:state)
    case
    when task_states.all?{|state| state == 'success'}
      'success'
    when task_states.any?{|state| state == 'executing'}
      'executing'
    when task_states.any?{|state| state == 'pending'}
      'pending'
    when task_states.any?{|state| state == 'failed'}
      'failed'
    else
      'pending'
    end
  end

  def sha1
    Digest::SHA1.hexdigest(id.to_s)
  end

  def to_s
    sha1
  end

end
