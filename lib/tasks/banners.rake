namespace :banners do
  desc "Initilaize the banners which are already present"
  task initialize_banners: :environment do
  	initial_banners = {
  		'Banner_1_small_new.jpg' => 'http://blog.prathambooks.org/2017/09/pratham-books-storyweaver-receives_5.html',
  		'Banner_1_small.jpg' => 'https://storyweaver.org.in/blog_posts/176-say-hello-to-our-new-story-creation-tool', 
  		'Banner_3_small.jpg' => 'https://storyweaver.org.in/search', 
  		'Banner_4_small.jpg' => 'https://storyweaver.org.in/start', 
  		'Banner_5_small.jpg' => 'https://storyweaver.org.in/translate'
  	}
  	banners_list_order = ['Banner_1_small_new.jpg','Banner_1_small.jpg', 'Banner_3_small.jpg', 'Banner_4_small.jpg','Banner_5_small.jpg']
  	banners_list_order.each_with_index do |fname, pos|
  		b = Banner.new
  		b.name = "Banner#{pos+1}"
  		b.link_path = initial_banners[fname]
  		f = File.open(Rails.root.join('app', 'assets', 'images', fname))
        b.banner_image = f
        b.position = pos+1
        b.is_active = true
        b.save!
  	end
  end
end
