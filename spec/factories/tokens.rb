# == Schema Information
#
# Table name: tokens
#
#  id                 :integer          not null, primary key
#  access_token       :string(255)      not null
#  story_count        :integer          default(0)
#  illustration_count :integer          default(0)
#  organization_id    :integer          not null
#  expires_at         :datetime
#  created_at         :datetime
#  updated_at         :datetime
#

FactoryGirl.define do
  
  factory :token do
    access_token        "sQ67yTuIrKeOp09"
    story_count         100
    illustration_count  500
    organization_id     3
    expires_at          Time.now + 1.days
  end

  factory :expired_token, class: Token do
    access_token        "jQyuRttb1N8J77f"
    story_count         100
    illustration_count  500
    organization_id     3
    expires_at          Time.now - 1.days    
  end

end