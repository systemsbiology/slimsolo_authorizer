# Cache these to be consistent with SLIMcore, even though with SLIMsolo
# Authorizer they're not that slow

module SlimcoreCaching
  protected
  
    def cache_users
      @users_by_id ||= User.all_by_id
    end

    def users_by_id
      @users_by_id || cache_users
    end

    def cache_lab_groups
      @lab_groups_by_id ||= LabGroup.all_by_id
    end

    def lab_groups_by_id
      @lab_groups_by_id || cache_lab_groups
    end
end
