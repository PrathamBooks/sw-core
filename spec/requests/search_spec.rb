require "spec_helper"

describe "home" do
  let(:search_link) { {'rel' => 'search','uri' => '/search'} }
  let(:new_additions_link) { {'rel' => 'new-arrivals','uri' => '/search?search[sort][][created_at][order]=desc'} }
  let(:most_reads_link) { {'rel' => 'most-reads','uri' => '/search?search[sort][][reads][order]=desc'} }
  let(:most_liked_link) { {'rel' => 'most-liked','uri' => '/search?search[sort][][likes][order]=desc'} }
  # let(:books_by_publishers_link) { {'rel' => 'books-by-publishers','uri' => '/search?books-by-publishers=true'} }
  let(:recommended_link) { {'rel' => 'recommended','uri' => '/search?search[recommended]=true'} }
  let(:expected) do
    {
      'links' => [
        search_link
      ]
    }.to_json
  end
#  it "should return JSON" do
#    get '/', nil, {'HTTP_ACCEPT' => "application/json"}
#    expect(response).to be_ok
#    expect(response.header['Content-Type']).to include 'application/json'
#  end
#  it "should return search as a link" do
#    get '/', nil, {'HTTP_ACCEPT' => "application/json"}
#    json = JSON.parse(response.body)
#    expect(json['links']).to include(search_link)
#  end
#  it "should return new arrivals as a link" do
#    get '/', nil, {'HTTP_ACCEPT' => "application/json"}
#    json = JSON.parse(response.body)
#    expect(json['links']).to include(new_additions_link)
#  end
#  it "should return most read as a link" do
#    get '/', nil, {'HTTP_ACCEPT' => "application/json"}
#    json = JSON.parse(response.body)
#    expect(json['links']).to include(most_reads_link)
#  end
#  it "should return most liked as a link" do
#    get '/', nil, {'HTTP_ACCEPT' => "application/json"}
#    json = JSON.parse(response.body)
#    expect(json['links']).to include(most_liked_link)
#  end
#  xit "should return books by publishers as a link" do
#    get '/', nil, {'HTTP_ACCEPT' => "application/json"}
#    json = JSON.parse(response.body)
#    expect(json['links']).to include(books_by_publishers_link)
#  end
#  it "should return recommended as a link" do
#    get '/', nil, {'HTTP_ACCEPT' => "application/json"}
#    json = JSON.parse(response.body)
#    expect(json['links']).to include(recommended_link)
#  end
end

describe "search" do
  let(:front_cover_page_template) {FactoryGirl.create(:front_cover_page_template,default: true,orientation: 'landscape')}
  let(:back_inner_cover_page_template) {FactoryGirl.create(:back_inner_cover_page_template,default: true,orientation: 'landscape')}
  let(:back_cover_page_template) {FactoryGirl.create(:back_cover_page_template,default: true,orientation: 'landscape')}
  describe "search" do
    let(:stories) do
      front_cover_page_template
      back_inner_cover_page_template
      back_cover_page_template
      new_time = Time.now
      stories = []
      32.times do |i|
        story = FactoryGirl.build(
          :story,
          reads: Random.rand(1000),
          recommended_status: (Random.rand(2) == 0 ? Story.recommended_statuses[:recommended] : nil),
          publisher: (Random.rand(2) == 0 ? FactoryGirl.create(:publisher) : nil)
        )
        Random.rand(5).times {story.liked_by FactoryGirl.create(:user)}
        story.build_book
        story.save!
        story.publish
        stories << story
        Timecop.travel(new_time+i.day)
      end
      Story.reindex
      stories
    end
    let(:search_result_pg_1) do
      stories[-10..-1].map do |story|
        {
          'rel' => 'story',
          'uri' => react_stories_show_path(story.to_param)
        }
      end
    end
    let(:metadata) {
      {
          'per_page' =>  10,
          'hits'     => 32,
          'page'     =>   1,
          'total_pages'    =>  4
        }
    }
    let(:search_response) do
      {
        'search_results' => search_result_pg_1,
        'metadata'       => metadata,
        'links' => {
          'next_page' => '/search?page=2'
        }
      }
    end
#    it "should link to stories" do
#      search_response
#      get '/search', {search: {recommended: true }}, {'HTTP_ACCEPT' => "application/json"}
#      json = JSON.parse(response.body)
#      first_result = json['search_results'].first
#    end
#    it "should be show only 10 results" do
#      search_response
#      get '/search', nil, {'HTTP_ACCEPT' => "application/json"}
#      json = JSON.parse(response.body)
#      expect(json['search_results'].length).to eq search_response['search_results'].length
#    end
#    it "should provide the right metadata" do
#      search_response
#      get '/search', nil, {'HTTP_ACCEPT' => "application/json"}
#      json = JSON.parse(response.body)
#      expect(json['metadata']).to eq metadata
#    end
#    it "should show results with details" do
#      search_response
#      get '/search', nil, {'HTTP_ACCEPT' => "application/json"}
#      json = JSON.parse(response.body)
#      results = json['search_results']
#      expect(results.first.keys).to eq ["id","title", "english_title", "reading_level", "status", "language", "script", "authors", "author_slugs", "categories", "synopsis", "recommended", "image_url", "url_slug", "organization", "publisher_slug", "illustrators", "illustrator_slugs","reads","likes", "uploading", "links","story_path","can_user_like_story", "user_likes_story", "is_disabled", "content_manager", "published", "derivation_type", "recommended_status", "recommended_tag", "recommendation", "created_by_child","is_winner", "story_title", "story_url","story_category","contest_name", "reviewer_comment", "rating_value", "published_at", "story_downloads","organization_status",  "story_download_count"]
#    end
#    it "should give next/prev page if followed" do
#      search_response
#      get '/search', nil, {'HTTP_ACCEPT' => "application/json"}
#      json = JSON.parse(response.body)
#      expect(json['metadata']['page']).to eq 1
#      get json["links"]["next_page"], nil, {'HTTP_ACCEPT' => "application/json"}
#      json = JSON.parse(response.body)
#      expect(json['metadata']['page']).to eq 2
#      get json["links"]["prev_page"], nil, {'HTTP_ACCEPT' => "application/json"}
#      json = JSON.parse(response.body)
#      expect(json['metadata']['page']).to eq 1
#    end
#    it "should return the most recent books" do
#      search_response
#      get '/search?search[sort][][created_at][order]=desc', nil, {'HTTP_ACCEPT' => "application/json"}
#      expect(assigns(:results).map(&:title)).to eq(stories.sort{|a,b|b.created_at<=>a.created_at}.map(&:title)[0..9])
#    end
#    it "should return the most liked books" do
#      search_response
#      get '/search?search[sort][][likes][order]=desc', nil, {'HTTP_ACCEPT' => "application/json"}
#      expect(assigns(:results).map(&:likes)).to eq(stories.sort{|a,b|b.likes<=>a.likes}.map(&:likes)[0..9])
#    end
#    it "should return the most read books" do
#      search_response
#      get '/search?search[sort][][reads][order]=desc', nil, {'HTTP_ACCEPT' => "application/json"}
#      expect(assigns(:results).map(&:reads)).to eq(stories.sort{|a,b|b.reads<=>a.reads}.map(&:reads)[0..9])
#    end
#    #This test case should need to update with the new type of recommendation
#=begin
#    it "should return recommended books" do
#      search_response
#      get '/search?search[recommended]=true', nil, {'HTTP_ACCEPT' => "application/json"}
#      recommended_stories = stories.select{|s|s.recommended == true}
#      expect(assigns(:results).map(&:title)).to eq(recommended_stories.sort{|a,b|b.reads<=>a.reads}.map(&:title)[0..9])
#    end
#=end
#    it "should respond that user cannot like story when he is not logged in" do
#      search_response
#
#      get '/search?search[sort][][reads][order]=desc', nil, {'HTTP_ACCEPT' => "application/json"}
#      json = JSON.parse(response.body)
#      first_result = json['search_results'].first
#      expect(first_result['can_user_like_story']).to be false
#    end
  end
end

