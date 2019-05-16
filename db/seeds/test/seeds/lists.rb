def create_list(story_count: 10, category: get_list_category, reads: 0, likes: 0, list_title: nil)
   list = List.new
   title = list_title != nil ? list_title : "Automation List"
   list.title= title
   list.description = "List for testing purpose"
   list.categories = [category]
   list.user = User.find_by_email("admin@example.com")
   list.stories << Story.published[0..story_count-1]
   list.status = :published
   list.save!
   user = User.find_by_email("admin@example.com")
   likes.to_i.times { |count| ListLike.new(user_id: user.id, list_id: list.id).save! }
   reads.to_i.times { |count| ListView.new(user_id: user.id, list_id: list.id).save! }
   list.reindex
end

def get_list_category
   list_category_id = rand(ListCategory.count)+1
   rand_record = ListCategory.find_by_id(list_category_id)
   return rand_record
end