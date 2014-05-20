#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Trial < ActiveRecord::Base
  self.primary_key= 'id'
  before_create{self.id ||= SecureRandom.uuid}
  belongs_to :task
  belongs_to :executor

  has_many :attachments, lambda{reorder(:path)}, dependent: :destroy

  validates :state, inclusion: {in: Constants.TRIAL_STATES}

  after_create do
    task.reload.update_state! 
    create_scripts
  end

  after_commit do
    if destroyed? \
      or previous_changes.keys.include?('state')  \
      or previous_changes.keys.include?('created_at') # resource is newly created

      # TODO use messaging for the following:
      task.check_and_retry!
      task.update_state!
    end
  end

  delegate :script, to: :task

  default_scope{ reorder(created_at: :desc, id: :asc)}

  scope(:finished, lambda do
    where(state: ['success','failed']).reorder(updated_at: :desc)
  end)

  scope :not_finished, lambda{
    where("state NOT IN ('success','failed')").reorder(updated_at: :desc)} 
  
  scope :to_be_dispatched, lambda{
    where(state: 'pending').joins(task: :execution) \
    .reorder("executions.priority DESC", "executions.created_at DESC", "tasks.priority DESC", "tasks.created_at DESC")}

  scope :in_execution, lambda{
    where("trials.state IN ('dispatched','executing')")}

  scope :in_not_finished_timeout, lambda{
    not_finished.where(%[ trials.created_at <
      (now() - interval '#{TimeoutSettings.find.trial_end_state_timeout_minutes} Minutes')])}
  
  scope :in_dispatch_timeout, lambda{
    to_be_dispatched.reorder("").where(%[ trials.created_at <
      (now() - interval '#{TimeoutSettings.find.trial_dispatch_timeout_minutes} Minutes')])}

  scope :in_execution_timeout, lambda{
    in_execution().where(%[ trials.updated_at <
      (now() - interval '#{TimeoutSettings.find.trial_execution_timeout_minutes} Minutes')])}

  scope :with_scripts_to_clean, lambda{
    where("json_array_length(scripts) > 0")
    .where(%[ trials.created_at <
      (now() - interval '#{TimeoutSettings.find.trial_scripts_retention_time_days} Days')])}

  def update_state!
    update_attributes! state: evaluate_state
  end

  def evaluate_state
    script_states= scripts.pluck(:state)
    case
    when script_states.any?{|state| state == 'failed'}
      'failed'
    when script_states.all?{|state| state == 'success'}
      'success'
    when script_states.any?{|state| ['dispatched','executing'].include? state }
      'executing'
    else # leave it
      state
    end
  end

  def create_scripts
    self.scripts= task.data.deep_symbolize_keys.try(:[],:scripts).map { |name,script|
      script.merge({name: name, id: SecureRandom.uuid})
    }.sort { |s1,s2| s1[:order] <=> s2[:order] }
    self.save
  end

end
