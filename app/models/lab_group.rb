class LabGroup < ActiveRecord::Base
  has_one :lab_group_profile, :dependent => :destroy
  has_many :lab_memberships, :dependent => :destroy
  has_many :users, :through => :lab_memberships
  has_many :projects, :dependent => :destroy
  has_many :charge_sets, :dependent => :destroy

  validates_uniqueness_of :name

  def lab_group_profile
    LabGroupProfile.find_or_create_by_lab_group_id(self.id)
  end

  def destroy_warning
    charge_sets = ChargeSet.find(:all, :conditions => ["lab_group_id = ?", id])
    
    return "Destroying this lab group will also destroy:\n" + 
           charge_sets.size.to_s + " charge set(s)\n" +
           projects.size.to_s + " project(s)\n" +
           "Are you sure you want to destroy it?"
  end

  def summary_hash
    return {
      :id => id,
      :name => name,
      :updated_at => updated_at,
      :uri => "#{SiteConfig.site_url}/lab_groups/#{id}"
    }
  end

  def detail_hash
    return {
      :id => id,
      :name => name,
      :updated_at => updated_at,
      :user_uris => user_ids.sort.
        collect {|x| "#{SiteConfig.site_url}/users/#{x}" },
    }.merge(lab_group_profile.detail_hash)
  end

private

  def user_ids
    LabMembership.find(:all, :conditions => {:lab_group_id => self.id}).
      collect {|x| x.user_id}
  end
end
