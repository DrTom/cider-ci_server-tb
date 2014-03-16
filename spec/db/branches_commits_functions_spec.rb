require 'spec_helper'


describe "Functions for managing branches_commits"  do


  before :each do
    # 1 <- 2 <- 3
    # 1 <- 4 <- 3
    #      4 <- 5

    @commit1 = FactoryGirl.create :commit, id: '0000000000000000000000000000000000000001' 
    @commit2 = FactoryGirl.create :commit, id: '0000000000000000000000000000000000000002' 
    @commit2.parents << @commit1
    @commit3 = FactoryGirl.create :commit, id: '0000000000000000000000000000000000000003' 
    @commit3.parents << @commit2
    @commit4 = FactoryGirl.create :commit, id: '0000000000000000000000000000000000000004' 
    @commit3.parents << @commit4
    @commit4.parents << @commit1
    @commit5 = FactoryGirl.create :commit, id: '0000000000000000000000000000000000000005' 
    @commit5.parents << @commit4

    @repository = FactoryGirl.create :repository
    @branch = FactoryGirl.create :branch, repository: @repository, current_commit: @commit2
    ActiveRecord::Base.connection.execute "DELETE FROM branches_commits"

  end

  describe "descendant functions" do

    describe "with_descendants for @commit2" do

      before :each do 
        @res = ActiveRecord::Base.connection.exec_query(
          %[SELECT with_descendants('#{@commit2.id}')]).rows
      end

      it "includes itself" do
        expect(@res).to include [@commit2.id]
      end

      it "includes the descendante commit3" do
        expect(@res).to include [@commit3.id]
      end

      it "does not include the ancestor commit1" do
        expect(@res).not_to include [@commit1.id]
      end


    end


    describe  "is_descendant " do

      it "returns true if the second argument is a descendant of the first" do
        @res = ActiveRecord::Base.connection.exec_query(
          %[SELECT is_descendant('#{@commit2.id}', '#{@commit3.id}')]).rows
        expect(@res[0][0]).to be== "t"
      end

      it "returns false if the second argument is the same as the first" do
        @res = ActiveRecord::Base.connection.exec_query(
          %[SELECT is_descendant('#{@commit2.id}', '#{@commit2.id}')]).rows
        expect(@res[0][0]).to be== "f"
      end

      it "returns false if the second argument is not a descendant of the first, and they are not equal" do
        @res = ActiveRecord::Base.connection.exec_query(
          %[SELECT is_descendant('#{@commit2.id}', '#{@commit1.id}')]).rows
        expect(@res[0][0]).to be== "f"
      end

    end

  end


  describe "ancestor functions" do

    describe "with_ancestors for @commit2" do

      before :each do 
        @res = ActiveRecord::Base.connection.exec_query(
          %[SELECT with_ancestors('#{@commit2.id}')]).rows
      end

      it "includes itself" do
        expect(@res).to include [@commit2.id]
      end

      it "includes the ancestor commit1" do
        expect(@res).to include [@commit1.id]
      end

      it "does not include the ancestor commit3" do
        expect(@res).not_to include [@commit3.id]
      end

    end


    describe  "is_ancestor " do

      it "returns true if the second argument is a ancestor of the first" do
        @res = ActiveRecord::Base.connection.exec_query(
          %[SELECT is_ancestor('#{@commit2.id}', '#{@commit1.id}')]).rows
        expect(@res[0][0]).to be== "t"
      end

      it "returns false if the second argument is the same as the first" do
        @res = ActiveRecord::Base.connection.exec_query(
          %[SELECT is_ancestor('#{@commit2.id}', '#{@commit2.id}')]).rows
        expect(@res[0][0]).to be== "f"
      end

      it "returns false if the second argument is not a ancestor of the first, and they are not equal" do
        @res = ActiveRecord::Base.connection.exec_query(
          %[SELECT is_ancestor('#{@commit2.id}', '#{@commit3.id}')]).rows
        expect(@res[0][0]).to be== "f"
      end

    end

  end


  describe "add_fast_forward_ancestors_to_branches_commits" do

    describe "precondition branches_commits" do
      it "is empty" do
        @res = ActiveRecord::Base.connection.exec_query(
          %[SELECT * from branches_commits]).rows
        expect(@res).to be_empty
      end
    end

    describe "add_fast_forward_ancestors_to_branches_commits for commit2" do

      before :each do
        ActiveRecord::Base.connection.execute %[ SELECT add_fast_forward_ancestors_to_branches_commits('#{@branch.id}','#{@commit2.id}') ]
        @res = ActiveRecord::Base.connection.exec_query( %[SELECT * from branches_commits]).rows
      end

      it "adds the row with commit2 to branches_commits" do
        expect(@res).to include [@branch.id,@commit2.id]
      end

      it "adds the row with commit1 to branches_commits" do
        expect(@res).to include [@branch.id,@commit1.id]
      end

      it "does not add the row with commit3 to branches_commits" do
        expect(@res).not_to include [@branch.id,@commit3.id]
      end

    end

  end

  describe "update_branches_commits function" do

    describe "resetting (old_commit_id = NULL) from 5 to commit 3 " do

      before :each do
        ActiveRecord::Base.connection.execute(
          %[ SELECT update_branches_commits('#{@branch.id}', '#{@commit5.id}', NULL) ])
        ActiveRecord::Base.connection.execute(
          %[ SELECT update_branches_commits('#{@branch.id}', '#{@commit3.id}', NULL) ])
        @res = ActiveRecord::Base.connection.exec_query(
          %[SELECT * from branches_commits]).rows
      end

      it "adds the row with commit3 to branches_commits" do
        expect(@res).to include [@branch.id,@commit3.id]
      end
      it "adds the row with commit2 to branches_commits" do
        expect(@res).to include [@branch.id,@commit2.id]
      end
      it "adds the row with commit1 to branches_commits" do
        expect(@res).to include [@branch.id,@commit1.id]
      end
      it "adds the row with commit4 to branches_commits" do
        expect(@res).to include [@branch.id,@commit4.id]
      end
      it "does not add the row with commit5 to branches_commits" do
        expect(@res).not_to include [@branch.id,@commit5.id]
      end

    end

    describe "setting 1 (and then fast forward to 3) " do

      before :each do
        ActiveRecord::Base.connection.execute(
          %[ SELECT update_branches_commits('#{@branch.id}', '#{@commit1.id}', NULL) ])
        @res = ActiveRecord::Base.connection.exec_query(
          %[SELECT * from branches_commits]).rows
      end

      it "adds the row with commit1 to branches_commits" do
        expect(@res).to include [@branch.id,@commit1.id]
      end

      it "adds nothing else" do
        expect(@res.size).to be== 1 
      end

      describe "fast forward from 1 to 3" do

        before :each do
          ActiveRecord::Base.connection.execute(
            %[ SELECT update_branches_commits('#{@branch.id}', '#{@commit3.id}', '#{@commit1.id}') ])
          @res = ActiveRecord::Base.connection.exec_query(
            %[SELECT * from branches_commits]).rows
        end
        it "adds the row with commit3 to branches_commits" do
          expect(@res).to include [@branch.id,@commit3.id]
        end
        it "adds the row with commit2 to branches_commits" do
          expect(@res).to include [@branch.id,@commit2.id]
        end
        it "keeps the row with commit1 to branches_commits" do
          expect(@res).to include [@branch.id,@commit1.id]
        end
        it "adds the row with commit4 to branches_commits" do
          expect(@res).to include [@branch.id,@commit4.id]
        end
        it "does not add the row with commit5 to branches_commits" do
          expect(@res).not_to include [@branch.id,@commit5.id]
        end
      end

    end

    describe "setting to commit5 from none (and then non fast forward to 3) " do

      before :each do
        ActiveRecord::Base.connection.execute(
          %[ SELECT update_branches_commits('#{@branch.id}', '#{@commit5.id}', NULL) ])
        @res = ActiveRecord::Base.connection.exec_query(
          %[SELECT * from branches_commits]).rows
      end

      it "adds the row with commit5 to branches_commits" do
        expect(@res).to include [@branch.id,@commit5.id]
      end
      it "adds the row with commit4 to branches_commits" do
        expect(@res).to include [@branch.id,@commit4.id]
      end
      it "adds the row with commit1 to branches_commits" do
        expect(@res).to include [@branch.id,@commit1.id]
      end
      it "does not add the row with commit3 to branches_commits" do
        expect(@res).not_to include [@branch.id,@commit3.id]
      end
      it "does not add the row with commit2 to branches_commits" do
        expect(@res).not_to include [@branch.id,@commit2.id]
      end

      describe "non fast forward from 5 to 3" do
        before :each do
          ActiveRecord::Base.connection.execute(
            %[ SELECT update_branches_commits('#{@branch.id}', '#{@commit3.id}', '#{@commit5.id}') ])
          @res = ActiveRecord::Base.connection.exec_query(
            %[SELECT * from branches_commits]).rows
        end
        it "adds the row with commit3 to branches_commits" do
          expect(@res).to include [@branch.id,@commit3.id]
        end
        it "adds the row with commit2 to branches_commits" do
          expect(@res).to include [@branch.id,@commit2.id]
        end
        it "keeps the row with commit1 to branches_commits" do
          expect(@res).to include [@branch.id,@commit1.id]
        end
        it "adds the row with commit4 to branches_commits" do
          expect(@res).to include [@branch.id,@commit4.id]
        end
        it "reoves the the row with commit5 from branches_commits" do
          expect(@res).not_to include [@branch.id,@commit5.id]
        end
      end

    end


  end

end
