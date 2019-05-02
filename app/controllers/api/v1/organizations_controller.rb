class Api::V1::OrganizationsController < Api::V1::ApplicationController

  respond_to :json
def autocomplete
    organizations = Organization.search(params[:query], {
                                             fields: ["organization_name^5"],
                                             match: :word_start,
                                             limit: 10,
                                             load: false,
                                             misspellings: {below: 5}
                                           })
     results = {}
     organizations.each do |org|
       results[:id] = org.id
       results[:name] = org.organization_name
       results[:country] = org.country
       results[:city] = org.city
       results[:children] = org.children_impacted
       results[:classrooms] = org.number_of_classrooms
     end 
     
    render json: {"ok" => true, :data => [results]} 
  end
end
