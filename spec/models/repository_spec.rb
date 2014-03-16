require 'spec_helper'

describe Repository do

  before :each do
    ServerSettings.find.update_attributes! repositories_path: Rails.root.join("repositories").to_s
  end

  it "can be created" do
    expect{@repository = FactoryGirl.create :repository}.not_to raise_error
  end

  after :each do
    # clean up
    @repository.destroy
  end

  context "without an origin," do

    before :each do
      @repository = FactoryGirl.create :repository
    end

    it "has and empty origin_uri" do
      expect(@repository.origin_uri).to be nil
    end

    describe "Initializing the git_repository" do

      it "doesn't throw an error" do
        expect{@repository.initialize_git}.not_to raise_error
      end

      it "creates and git repository in the `dir` directory" do
        @repository.initialize_git
        expect(File.exists?("#{@repository.dir}/HEAD")).to be true
      end

    end

  end

  context "with test_repo as the origin," do

    def test_repo_path
      Rails.root.join "tmp", "test_repo"
    end
  
    before :all do
      `rm -rf #{test_repo_path}`
      System.execute_cmd! %Q[tar xf #{Rails.root.join "spec", "data", "test_repo.tar.gz"} -C #{Rails.root.join "tmp"}]
    end

    before :each do
      @repository = FactoryGirl.create :repository, origin_uri: test_repo_path.to_s
    end

    after :each do
      @repository.destroy
    end

    describe "Initializing the git_repository" do

      it "doesn't throw an error" do
        expect{@repository.initialize_git}.not_to raise_error
      end

      it "clones the origin in the `dir` directory" do
        @repository.initialize_git
        expect(`cd #{@repository.dir}; git log 3c1bdc8 --oneline`).to match /Initial/
      end

    end

    describe "update_branches" do

      before :each do
        @repository.initialize_git
        @repository.update_branches
      end

      it "doesn't raise an error and creates branches, and the commit-tree" do
        expect{@repository.update_branches}.not_to raise_error
        expect(@repository.branches.count).to be == 2
        expect(@repository.branches.find_by(name: 'master').current_commit.id).to be == "416a312495a4eac45bd7629fa7df1dfb01a1117b"
      end

    end

    context "a initialized git repo" do

      before :each do
        @repository.initialize_git
      end

      describe "get_file_content_for" do

        before :each do
          @commit = Commit.find "6712b320e6998988f023ea2a6265e2d781f6e959"
        end

        it "get's the content of a file for a particular commit" do
          expect{@file_content = @repository.get_file_content_for(@commit,"README.mdk") }.not_to raise_error
          expect(@file_content).to match /This is a git repository for testing purpose\./
        end

      end

    end

  end

end
