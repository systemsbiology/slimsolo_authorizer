require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "LabGroup" do
  fixtures :lab_groups, :samples, :charge_sets, :projects

  it "should provide an accurate destroy warning" do   
    expected_warning = "Destroying this lab group will also destroy:\n" + 
                       "3 charge set(s)\n" +
                       "2 project(s)\n" +
                       "Are you sure you want to destroy it?"

    group = LabGroup.find( lab_groups(:gorilla_group).id )   

    # mock charge sets and projects since these aren't part of the engine
    ChargeSet.should_receive(:find).and_return(
      [ mock("ChargeSet"), mock("ChargeSet"), mock("ChargeSet") ]
    )
    group.should_receive(:projects).and_return(
      [ mock("Project"), mock("Project") ]
    )

    group.destroy_warning.should == expected_warning
  end

  it "should provide a hash of summary attributes" do
    lab_group = LabGroup.new(
      :name => "Fungus Group",
      :updated_at => DateTime.now
    )

    lab_group.summary_hash.should == {
      :id => lab_group.id,
      :name => "Fungus Group",
      :updated_at => lab_group.updated_at,
      :uri => "http://example.com/lab_groups/#{lab_group.id}"
    }
  end

  it "should provide a hash of detailed attributes" do
    lab_group = LabGroup.new(
      :name => "Fungus Group",
      :updated_at => DateTime.now
    )
    user_1 = mock_model(User, :lab_groups => [lab_group])
    user_2 = mock_model(User, :lab_groups => [lab_group])

    lab_membership_1 = LabMembership.new(:lab_group_id => lab_group.id, :user_id => user_1.id)
    lab_membership_2 = LabMembership.new(:lab_group_id => lab_group.id, :user_id => user_2.id)

    LabMembership.should_receive(:find).
      with(:all, :conditions => {:lab_group_id => lab_group.id}).
      and_return([lab_membership_1, lab_membership_2])

    profile = mock("Profile", :detail_hash => {:a => "b", :c => "d"})
    lab_group.should_receive(:lab_group_profile).and_return(profile)

    lab_group.detail_hash.should == {
      :id => lab_group.id,
      :name => "Fungus Group",
      :updated_at => lab_group.updated_at,
      :user_uris => ["http://example.com/users/#{user_1.id}",
                     "http://example.com/users/#{user_2.id}"],
      :a => "b",
      :c => "d"
    }
  end
end
