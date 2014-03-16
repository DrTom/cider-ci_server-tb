#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class PublicController < ApplicationController
  def show
    @executions = Execution.reorder(created_at: :desc).limit(7).select("DISTINCT executions.*")
    @commits = Commit.joins(:head_of_branches).joins(tree: :executions).limit(7).select("DISTINCT commits.*")

    if partial= request.headers['PARTIAL']
      render partial: partial, layout: false, locals: {executions: @executions,commits: @commits}
    else
      render
    end
  end

  def find_user_by_login login
    begin
      User.find_by(login_downcased: login) || EmailAddress.find_by!(email_address: login).user
    rescue
      raise "Neither login nor email found!"
    end
  end

  def sign_in
    begin
      user = find_user_by_login params.require(:sign_in)[:login].downcase
      if user.authenticate(params.require(:sign_in)[:password])
        session.reset! rescue nil # this seems to fail, but why?
        session[:user_id]=user.id
      else
        raise "Password authentication failed!"
      end
      redirect_to public_path, flash: {success: "You have been signed in!"}
    rescue Exception => e
      redirect_to public_path, flash: {error: e.to_s}
    end
  end

  def sign_out
    reset_session
    redirect_to public_path, flash: {success: "You have been signed out!"}
  end

end

