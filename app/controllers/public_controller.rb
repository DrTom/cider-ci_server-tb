#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class PublicController < ApplicationController
  def show
    @radiator_rows= WelcomePageSettings.find
      .radiator_config.try(:[],"rows").map do |row|
        {name: row.try(:[],"name"),
         items: build_items(row) }
      end
  end

  def build_items row
    row.try(:[],"items").map do |item|
      build_item item
    end
  end

  def build_item item
    repository= Repository.find_by(name: item["repository_name"]) rescue nil
    branch= repository.branches.find_by(name: item["branch_name"]) rescue nil
    execution= Execution.joins(commits: :branches) \
      .where("branches.id = ?",branch.id) \
      .where(definition_name: item["definition_name"]).first rescue nil

    item.merge( {repository: repository,
                 branch: branch,
                 execution:execution})
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

