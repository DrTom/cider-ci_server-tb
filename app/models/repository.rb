#  Copyright (C) 2013, 2014 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#  Licensed under the terms of the GNU Affero General Public License v3.
#  See the LICENSE.txt file provided with this software.

class Repository < ActiveRecord::Base

  self.primary_key = 'id'
  has_many :branches, dependent: :destroy

  before_validation on: :create do
    raise "either name or id is required" if self.id.blank? and self.name.blank? 
    self.id ||= SecureRandom.uuid
    self.name ||= self.id
  end

  after_destroy do
    `rm -rf #{dir}`
  end

  ######################## Scopes and methods returning AR ####################
  
  default_scope { order(name: :asc).reorder(importance: :desc) }

  scope :ready, lambda { where("1=1")}

  ######################## Other stuff ########################################

  def to_s
    name
  end

  ######################## GIT ################################################

  def dir 
    [ServerSettings.find.repositories_path,self.id].join("/")
  end

  def self.initialize_git repository_id
    Repository.find(repository_id).initialize_git
  end

  def get_file_content_for(commit,file_path)
    raise unless commit.is_a? Commit
    cmd = "cd #{dir}; git show #{commit.id}:#{file_path}"
    System.execute_cmd! cmd
  end

  def initialize_git
    Rails.logger.info "Updating git for #{self}"
    System.execute_cmd! "rm -rf #{dir}"
    begin 
      if not origin_uri.blank?
        System.execute_cmd! "git clone --bare #{origin_uri} #{dir}"
        System.execute_cmd! "cd #{dir}; git update-server-info"
        update_branches
      else
        `mkdir #{dir}`
        `cd #{dir}; git init --bare`
      end
    rescue Exception => e 
      Rails.logger.error e
      raise e
    end
  end

  def update_git
    Rails.logger.info "Updating git for #{self}"
    ExceptionHelper.with_log_and_reraise do
      Repository.transaction do
        System.execute_cmd! "cd #{dir}; git fetch origin -p '+refs/heads/*:refs/heads/*'"
        System.execute_cmd! "cd #{dir}; git update-server-info"
        update_branches
        self
      end
    end
  end

  def update_branches
    Rails.logger.info "Updating branches for #{self}"
    ExceptionHelper.with_log_and_reraise do
      Repository.transaction do
        System.execute_cmd! "cd #{dir}; git update-server-info"
        branch_arrays = (`cd #{dir}; git branch -v --abbrev=1000;`).split(/\n/) \
          .map{|l| l[1..l.length]} \
          .map{|l| l.split(/\s/) .reject{|i| i =~ /\s/ || i.blank? }}.map{|l| l.take 2}
        branches.where("name not in (?)", branch_arrays.map{|ba| ba[0]}).destroy_all
        branch_arrays.each do |ba| 
          current_commit = Commit.find_by(id: ba[1]) || Commit.import_with_parents(ba[1],self.id)
          branch= branches.find_or_create_by name: ba[0],repository: self, current_commit: current_commit
          ActiveRecord::Base.connection.execute(
            %[ SELECT update_branches_commits('#{branch.id}', '#{current_commit.id}', 'NULL') ])
        end
        self
      end
    end
  end

  def git_url options = {}
    path = Rails.application.routes.url_helpers.git_root_executors_api_v1_repository_path self
    url = Rails.application.routes.url_helpers.git_root_executors_api_v1_repository_url self,
      { host: ServerSettings.find.server_host,
        port: ServerSettings.find.server_port,
        user: nil,
        password: nil,
        protocol: (ServerSettings.find.server_ssl ? "https" : "http") }.merge(options)
    Formatter.include_realative_url_root url,path
  end

end

