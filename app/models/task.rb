#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Task < ActiveRecord::Base
  AUTO_TRIALS= 3
  EAGER_TRIALS= 1
  self.primary_key= 'id'
  before_create{self.id ||= SecureRandom.uuid}
  belongs_to :execution
  has_many :trials

  #validate :data_poperties

  after_save{execution.update_state! if state_changed?}

  default_scope{order(created_at: :desc,id: :asc)}

  scope :with_failed_trials, lambda{
    where("EXISTS (SELECT 1 FROM trials WHERE trials.task_id = tasks.id AND trials.state = 'failed')")
  }

  #validates :state, inclusion: {in: %w(pending executing failed success)}

  def suitable_executors
    ExecutorWithLoad.from('executors_with_load, tasks').where("tasks.id = ?", id) \
      .where('tasks.traits <@ executors_with_load.traits')
  end

  def data_poperties 
    unless data.deep_symbolize_keys[:name]
      errors.add :data, "must have a name attribute" 
    end
  end

  def auto_trials
     Integer(data['auto_trials']) rescue AUTO_TRIALS 
  end

  def eager_trials
     Integer(data['eager_trials']) rescue EAGER_TRIALS 
  end


  def check_and_retry!
    while trials.where(state: 'success').count == 0 \
      and trials.count < auto_trials \
      and trials.count - trials.where(state: 'failed').count < eager_trials
      create_trial
    end
  end

  def update_state!
    update_attributes! state: evaluate_state
  end

  def evaluate_state 
    trial_states = trials.pluck(:state)
    case
    when trial_states.any?{|state| state == 'success'}
      'success'
    when trial_states.any?{|state| state == 'dispatching' || state == 'executing'}
      'executing'
    when trial_states.all?{|state| state == 'failed'}
      'failed'
    else
      'pending'
    end
  end

  def create_trial
    trials.create! 
  end

  def to_s
    name
  end
end
