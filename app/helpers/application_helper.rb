#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

module ApplicationHelper

  def bootstrap_color_for_state state
    case state
    when 'success'
      'success'
    when 'failed'
      'danger'
    when 'executing'
      'warning'
    else
      ''
    end
  end

  def button_class_for_state state
    case state
    when "failed"
      "btn-error"
    else
      ''
    end
  end

  def icon_class_for_state state
    case state
    when 'executing', 'dispatching'
      "icon-executing"
    when 'failed'
      "icon-failed"
    when 'pending'
      "icon-pending"
    when 'success'
      "icon-success"
    else
      Rails.logger.warn "no icon defined for #{state}"
    end
  end


  def icon_class_for_priority priority
    case 
    when priority >= 7
      "icon-star"
    when priority >= 4
      "icon-star-half-full"
    else
      "icon-star-empty"
    end
  end

  def label_for_state state
    render "label_for_state", state: state
  end


  def link_to_commit commit
    render partial: "link_to_commit", locals: {commit: commit}
  end

  def form_group label, opts ={}, &block
    control_id=(opts[:control_id] || SecureRandom.uuid)
    render "form_group",label: label,
           control_id: control_id,
           cols_label: (opts[:cols_label] || 3),
           label_class: (opts[:label_class] || ""),
           cols_control: (opts[:cols_control] || 5),
           block_output: capture(opts.merge({control_id: control_id}),&block)
  end

  def markdown(source)
    Kramdown::Document.new(source).to_html.html_safe
  end

  def render_executor_row executor, &block
    render "executor_row",executor: executor, block_output: capture(&block)
  end

  def render_execution_label execution, &block
    render "execution_label", execution: execution, block_output: capture(&block)
  end


  def label_class_for_state state
    case state
    when 'failed'
      'label-failed'
    when 'success'
      'label-success'
    when 'pending'
      'label-pending'
    when 'executing','dispatched'
      'label-executing'
    else
      'label-default' 
    end
  end

end
