# == Schema Information
#
# Table name: blog_posts
#
#  id                           :integer          not null, primary key
#  title                        :string(255)
#  body                         :text
#  status                       :integer
#  scheduled                    :datetime
#  comments_count               :integer          default(0)
#  user_id                      :integer
#  created_at                   :datetime
#  updated_at                   :datetime
#  published_at                 :datetime
#  reads                        :integer          default(0)
#  blog_post_image_file_name    :string(255)
#  blog_post_image_content_type :string(255)
#  blog_post_image_file_size    :integer
#  blog_post_image_updated_at   :datetime
#

FactoryGirl.define do
	factory :blog_post do
		sequence(:title) { |n| "BlogPost#{n}" }
		sequence(:body) { |n| "Description for BlogPost#{n}" }
		status 1
		user
		blog_post_image  Rack::Test::UploadedFile.new('spec/photos/forest.jpg', 'image/jpg')
    end
end
