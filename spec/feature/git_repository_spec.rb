require 'spec_helper'
require 'spec_capybara_conf'
require 'spec_helper_no_tx'

describe "GitRepositoryServer", type: :feature, js: true do

  before :all do
    ServerSettings.find.update_attributes! repositories_path: Rails.root.join("repositories").to_s
    System.execute_cmd! %Q[tar xf #{Rails.root.join "spec", "data", "test_repo.tar.gz"} -C #{Rails.root.join "tmp"}]
    @repository = Repository.create origin_uri: Rails.root.join("tmp","test_repo").to_s, name: "test_repo"
    @repository.initialize_git
  end

  def test_repo_path
    Rails.root.join("tmp","test_repo_cloned").to_s
  end

  after :all do
    @repository.destroy
    `rm -rf #{test_repo_path}`
  end

  it " cloning it" do
    server = Capybara.current_session.server
    expect(Dir.exists? test_repo_path).not_to be true
    expect do 
      repository_url = @repository.git_url host: server.host, port: server.port
      System.execute_cmd! "git clone #{repository_url} #{test_repo_path}"
    end.not_to raise_error
    expect(File.exists? "#{test_repo_path}/README.mkd").to be true
  end

end
