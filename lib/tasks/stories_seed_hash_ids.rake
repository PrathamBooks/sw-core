require 'digest/md5'

namespace :stories do
  desc "Seed hash ids to existing stories"
  task seed_hash_ids: :environment do
    Story.where(:status => Story.statuses[:published]).each do |s|
      s.update_attribute(:hash_id, Digest::MD5.hexdigest(s.id.to_s))
    end
  end
end
