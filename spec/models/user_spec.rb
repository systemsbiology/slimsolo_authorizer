require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "User" do

  it "should provide a hash of summary attributes" do
    user = User.new(
      :login => "jsmith",
      :updated_at => DateTime.now
    )

    user.summary_hash.should == {
      :id => user.id,
      :login => "jsmith",
      :updated_at => user.updated_at,
      :uri => "http://example.com/users/#{user.id}"
    }
  end

  it "should provide a hash of detailed attributes" do
    lab_group_1 = mock_model(LabGroup)
    lab_group_2 = mock_model(LabGroup)

    user = User.new(
      :login => "jsmith",
      :email => "jsmith@example.com",
      :firstname => "Joe",
      :lastname => "Smith",
      :updated_at => DateTime.now
    )
    user.stub!(:lab_groups).and_return([lab_group_1, lab_group_2])

    lab_group_1.stub!(:users).and_return([user])
    lab_group_2.stub!(:users).and_return([user])

    lab_membership_1 = LabMembership.new(:lab_group_id => lab_group_1.id, :user_id => user.id)
    lab_membership_2 = LabMembership.new(:lab_group_id => lab_group_2.id, :user_id => user.id)

    profile = mock("Profile", :detail_hash => {:a => "b", :c => "d"})
    user.should_receive(:user_profile).and_return(profile)

    user.detail_hash.should == {
      :id => user.id,
      :login => "jsmith",
      :email => "jsmith@example.com",
      :firstname => "Joe",
      :lastname => "Smith",
      :updated_at => user.updated_at,
      :lab_group_uris => ["http://example.com/lab_groups/#{lab_group_1.id}",
                          "http://example.com/lab_groups/#{lab_group_2.id}"],
      :a => "b",
      :c => "d"
    }
  end

  it "should provide a Hash of users keyed by user id" do
    user_1 = mock_model(User)
    user_2 = mock_model(User)

    User.should_receive(:find).with(:all).and_return( [user_1,user_2] ) 

    User.all_by_id.should == {
      user_1.id => user_1,
      user_2.id => user_2
    }
  end
end
