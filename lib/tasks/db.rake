namespace :db do
  task recreate: ["delayed_job:stop", :drop, :create, :migrate, :seed, "illustrations:remove_all", "stories:reindex","illustrations:reindex"]
end
