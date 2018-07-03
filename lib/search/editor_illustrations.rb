module Search

  class EditorIllustrations
    attr_reader :results
    def self.search params={}
      self.new params
    end

    def initialize params
      @story = Story.find(params[:story_id]) unless params[:story_id].nil?
      @page = Page.find(params[:page_id]) unless params[:page_id].nil?
      currTitle = @story.title
      search_filters = filters(params)
      if(@story.pages_with_illustrations.length == 0)
        currTitle += " dummyField"
        q = Illustration.search(currTitle, operator: "or", where: search_filters, execute: false, load: false, page: params[:page], per_page: params[:per_page])
        @results = q.execute
      else
        illustrationsAll = @story.illustrations
        illustrationNames = []
        categories = []
        tags  = []
        styles   = []
        illustrators = []
        illustrationsAll.each do |il|
          if (il != nil)
            illustrators << il.illustrators.collect(&:name).join(" ")
            illustrationNames.push(il.name)
            il.categories.each do |cat|
              categories.push(cat.name)
            end
            il.tags.each do |tag|
              tags.push(tag.name)
            end
            il.styles.each do |style|
              styles.push(style.name)
            end
          end
        end
        ilString = illustrators.join(" ")
        qString = illustrationNames.join(" ")
        categString = categories.join(" ")
        tagsString = tags.join(" ")
        styString = styles.join(" ")
        q = Illustration.search(
          body:{
            query:{
              bool:{
                must:{
                  dis_max:{
                    queries:[
                      prepare_searchkick_search("name.analyzed", qString, 5, false),
                      prepare_searchkick_search("name.analyzed", qString, 5, true),
                      prepare_searchkick_search("illustrators.analyzed", (qString + " " + ilString), 5, false),
                      prepare_searchkick_search("illustrators.analyzed", (qString + " " + ilString), 5, true),
                      prepare_searchkick_search("tags_name.analyzed", (tagsString + " " + qString), 5, false),
                      prepare_searchkick_search("tags_name.analyzed", (tagsString + " " + qString), 5, true),
                      prepare_searchkick_search("styles.analyzed", styString, 5, false),
                      prepare_searchkick_search("styles.analyzed", styString, 5, true),
                      prepare_searchkick_search("categories.analyzed", categString, 5, false),
                      prepare_searchkick_search("categories.analyzed", categString, 5, true),
                      prepare_searchkick_search("dummy.analyzed", "dummyField", 1, false),
                      prepare_searchkick_search("dummy.analyzed", "dummyField", 1, true)
                    ]
                  }
                },
                must_not: {
                  dis_max:{
                    queries:[
                      {
                        match: {
                          "favorites.analyzed"=> @story.id
                        }
                      }
                    ]
                  }
                }
              }
            },
            from:(params[:page].to_i - 1)*params[:per_page].to_i,
            size:params[:per_page].to_i
          },
          where: search_filters,
          execute: false,
          page: params[:page],
          per_page: params[:per_page],
          load: false
        )
        @results = q.execute
      end
    end

    def filters(params)
      search_filters = {}
      unless params[:is_organization_cm]
        search_filters[:image_mode] = false
      end
      search_filters[:is_pulled_down] = false
      return search_filters
    end

    def prepare_searchkick_search(name, query, boost, fuzzy_prefix_max)
      prepare_matches(name, query, boost, "searchkick_search", fuzzy_prefix_max)
      prepare_matches(name, query, boost, "searchkick_search2", fuzzy_prefix_max)
    end

    def prepare_matches(name, query, boost, analyzer, fuzzy_prefix_max)
      q={
        match: {
          name => searchkick_search_query(query, boost,analyzer, fuzzy_prefix_max)
        }
      }
      return q
    end

    def searchkick_search_query(query, boost, analyzer, fuzzy_prefix_max)
      query = {
        query:query,
        boost:boost,
        operator:"or",
        analyzer:analyzer
      }
      cut_off = {cutoff_frequency:0.001}
      fuzzy = {
        fuzziness:1,
        prefix_length:0,
        max_expansions:3,
        fuzzy_transpositions:true
      }
      fuzzy_prefix_max == true ? query.merge!(fuzzy) : query.merge(cut_off)
    end

  end
end