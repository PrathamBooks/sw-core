FactoryGirl.define do
	factory :back_inner_cover_page_template do
		sequence(:name) { |n| " Back Inner Cover Page Template #{n}" }
		orientation "landscape"
		content_dimension 30.0
	end
end
