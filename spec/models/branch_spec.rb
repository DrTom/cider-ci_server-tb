require 'spec_helper'

describe Branch do
  before :each do 
    ServerSettings.find.update_attributes! repositories_path: Rails.root.join("repositories").to_s
    @repository = FactoryGirl.create :repository
    @repository.initialize_git
    @repository.branches.destroy_all
    @commit = FactoryGirl.create :commit
  end

  it "can be created" do
    expect{ Branch.create! repository: @repository, name: "master", current_commit: @commit}.not_to raise_error
    expect{ FactoryGirl.create :branch, repository: @repository, current_commit: @commit}.not_to raise_error
  end


  describe "has a current_commit" do

    before :each do 
      @branch = FactoryGirl.create :branch, repository: @repository, current_commit: @commit
    end

    it "which can be set" do
      expect{@branch.update_attributes! current_commit: @commit}.not_to raise_error
    end

    context "which is set to a commit which" do
      before :each do
        @branch.update_attributes! current_commit: @commit
      end

      it "points to the branch as head" do
        expect(@commit.head_of_branches).to include @branch
      end
    end

  end

end


