require 'spec_helper'
require 'spec_capybara_conf'
require 'spec_helper_no_tx'

describe "GitRepositoryServer", type: :feature, js: true do

  def test_repo_path
    Rails.root.join "tmp", "test_repo"
  end

  def test_repo_path_clone
    Rails.root.join "tmp", "test_repo_clone"
  end



  before :all do
    `rm -rf #{test_repo_path}`
    System.execute_cmd! "mkdir -p #{Rails.root.join 'tmp'}"
    System.execute_cmd! %Q[tar xf #{Rails.root.join "spec", "data", "test_repo.tar.gz"} -C #{Rails.root.join "tmp"}]
    ActiveRecord::Base.connection.tap do |connection|
      connection.tables.reject{|tn|tn=="schema_migrations"}.join(', ').tap do |tables|
        connection.execute " TRUNCATE TABLE #{tables} CASCADE; "
      end
    end
    repositories_path= Rails.root.join("tmp","repositories").to_s
    System.execute_cmd! "rm -rf #{repositories_path}"
    System.execute_cmd! "mkdir -p #{repositories_path}"
    Settings.git.repositories_path= repositories_path
    @repository = Repository.find_or_create_by name: "TestRepo", origin_uri: test_repo_path.to_s
    @repository.initialize_git
  end

  after :all do
    @repository.destroy
    `rm -rf #{test_repo_path}`
  end

  it " cloning it" do
    server = Capybara.current_session.server
    expect(Dir.exists? test_repo_path_clone).not_to be true
    expect do 
      repository_url = @repository.git_url host: server.host, port: server.port
      System.execute_cmd! "git clone #{repository_url} #{test_repo_path_clone}"
    end.not_to raise_error
    expect(File.exists? "#{test_repo_path_clone}/README.mkd").to be true
  end

end
