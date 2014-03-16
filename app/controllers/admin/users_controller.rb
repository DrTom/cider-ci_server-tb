#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Admin::UsersController < AdminController

  helper_method :is_admin_filter, :user_text_search_filter

  def create
    begin
      @user = User.create! params.require(:user).permit!
      redirect_to admin_user_path(@user)
    rescue Exception => e 
      redirect_to new_admin_user_path(user: params[:user].merge(password: nil)), flash: {error: [e.to_s]}
    end
  end

  def destroy
    begin 
      User.find(params[:id]).destroy
      redirect_to admin_users_path, flash: {success: "The user has been destroyed"}
    rescue Exception => e
      redirect_to admin_user_path(@user), flash: {error: [e.to_s]}
    end
  end


  def index
    @users= User.page()
    @users= @users.where(is_admin: true) if is_admin_filter
    if search_term = user_text_search_filter
      # NOTE we include the email addresses; however, the pg parser recognizes
      # emails and does not break them apart: foo@bar.baz  will only be found
      # when the full email address is search for and not by "foo", or "bar", or baz! 
      # http://www.postgresql.org/docs/current/static/textsearch-parsers.html
      search_options= { \
        users: {login: search_term,last_name: search_term,first_name: search_term}, \
        email_addresses: {email_address: search_term, searchable: search_term} }
      @users= @users.joins(:email_addresses).basic_search(search_options,false).reorder(:last_name,:first_name).uniq 
    end
  end

  def new
    @user = User.new params.permit![:user]
  end


  def show
    @user = User.find params[:id]
  end

  def update
    with_rescue_flash do
      @user= User.find(params[:id])
      @user.update_attributes! params.require(:user).permit!
      {success: "The user has been updated."}
    end
  end

  def add_email_address
    with_rescue_flash do
      EmailAddress.create! user_id: @user.id, email_address: params[:email_address]
      {success: "The new email-address has been added. "}
    end
  end

  def delete_email_address
    with_rescue_flash do
      EmailAddress.find_by(user_id: params[:id],email_address: params[:email_address]).destroy
      {success: "The email address has been removed."}
    end
  end

  def as_primary_email_address
    with_rescue_flash do
      EmailAddress.where(user_id: params[:id]).update_all primary: false
      EmailAddress.find_by(user_id: params[:id],email_address: params[:email_address]).update_attributes! primary: true
      {success: "A new primary email has been set."}
    end
  end



  def user_text_search_filter
    params.try('[]',"user").try('[]',:text).try(:nil_or_non_blank_value)
  end


  def is_admin_filter
    (params["is_admin"] and true) or false
  end


  private

  def with_rescue_flash
    flash= begin 
             @user= User.find(params[:id])
             yield
           rescue Exception => e
             {error: e.to_s}
           end
    redirect_to admin_user_path(@user), flash: flash
  end


end

