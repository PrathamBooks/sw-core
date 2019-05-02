include ApplicationHelper

class PagesController < ApplicationController

  before_action :authenticate_user!,
    except: [:index, :story_page_template, :show, :navigate_to]
  before_action :assign_page, only: [:show, :navigate_to]
  before_action :assign_story

  before_action(:only => :show) do |controller|
    store_location_and_redirect(illustrations_path,new_user_session_path) if controller.request.format.epub? || controller.request.format.pdf?
  end

  def new
    @story_page_templates = StoryPageTemplate.all
    @page = StoryPage.new
  end


  def create
    @page = StoryPage.new(page_params)
    inserted = @story.insert_page(@page)
    illustration = Illustration.find_by_id(params[:story_page][:illustration_id])
    illustration.process_crop!(@page) unless illustration.nil?
    if(inserted && (@page.illustration_crop.present? unless illustration.nil?))
      redirect_to story_pages_path(@story)
    else
      @story_page_templates = StoryPageTemplate.all
      @page = StoryPage.new
      render :new
    end
  end

  def show
    @similar_stories = @story.similar(fields: [:language , :reading_level, :categories], where: {status: "published", language: @story.language.name, reading_level: @story.reading_level, orientation: @story.orientation}, limit: 12, order: {_score: :desc}, operator: "and", load: false).results if @story rescue []
    @story_read_id = (current_user && @story.published?) ? StoryRead.save_story_read(current_user, @story) : 'nil'
    session[:reads] ||= []
    session[:reads] << @story.id
    @additional_illustration_license_types = if @story.license_type == "Public Domain"
        @story.illustration_license_types.reject{|license| license == 'Public Domain'}
      else
        @story.illustration_license_types.reject{|license| license == 'CC BY 4.0' || license == 'CC BY 3.0'}
      end
    @disable_review_link = params[:disable_review_link] if params[:disable_review_link].present?
    respond_to do |format|
      format.html {redirect_to react_stories_show_path(@story.to_param, :story_read=>true)}
      format.epub do

        dir    = Dir.mktmpdir
        pages  = []
        images = []
        files  = []

        @additional_illustration_license_types =
          @story.illustration_license_types.reject{|license| license == 'CC BY 4.0' || license == 'CC BY 3.0'}
        
        @story.pages.each do |page|
          page_file = "#{dir}/#{page.position}"
          pages     << page_file+".xhtml"
          unless page.illustration_crop.nil?
            image_file = "#{dir}/image_#{page.position}"
            images     << image_file+".jpg"
            files      << image_file+".jpg"
            FileUtils.cp page.illustration_crop.load_image(:size7), "#{image_file}.jpg"
          end
          templates_dir = "#{Rails.root}/app/views"
          av=  ActionView::Base.new(templates_dir)
          av.assign({
            :page => page
          })
          f = File.new(page_file+".xhtml", 'w')
          page = f.puts(av.render(:template => "pages/show.epub.erb", locals: {:page => page, :@story => @story, :@additional_illustration_license_types => @additional_illustration_license_types, :form_authenticity_token => nil,  :@offline_processing => true}))
          f.close
        end
        
        #copy organization logo
        logo_type = @story.organization.present? ? @story.organization.logo_content_type : ""
        extension = ".jpg"
        if(logo_type == "image/png")
          extension = ".png"
        elsif(logo_type == "image/gif")
          extension = ".gif"
        end


        FileUtils.cp open(organization_logo_pdf(@story)), "#{dir}/publisher_logo#{extension}"
        files << "#{dir}/publisher_logo#{extension}"

        #copy level bands
        FileUtils.cp open(level_band_image_pdf(@story)), "#{dir}/level_band.png"
        files << "#{dir}/level_band.png"

        # copy other static images
        ['pb-storyweaver-logo-01.png', 'ccby.png', 'cc0.png', 'publicdomain.svg'].each do |image|
          logo_path = Rails.root.join('app', 'assets', 'images', image) 
          FileUtils.cp open(logo_path), "#{dir}/#{image}"
          files << "#{dir}/#{image}"
        end
       
        #Embedding necessary fonts
        fonts = []
        embed_fonts(@story,dir,fonts)     
        
        name = @story.title
        author = who_did_it(@story)
        organization = (@story.organization.nil? ? 'StoryWeaver Community' : @story.organization.organization_name)
        date = @story.copy_right_year
        id= @story.id
        url = url_for(@story)
        language = @story.language.locale

      # Gepub generating epub 3 files
        builder = GEPUB::Builder.new {
          language language
          unique_identifier url, "Story-#{id}", 'URL'
          title name
          id "story_#{id}"
          creator author
          date Time.new(date ? date : 1980)

          resources(:workdir => dir) {

            cover_image 'image_1.jpg'

            fonts.each do |fon|
              file fon
            end  

            files.each do |f|
              unless f.split('/')[-1].match('image_1.jpg')
                file f.split('/')[-1]
              end
            end

            ordered {
             pages.each do |pag|
               file pag.split('/')[-1]
               heading "Page #{pag.split('/')[-1].split('.')[0]}"
              end           
            }
          }
        }
 
        builder.generate_epub("#{dir}/#{@story.to_param}.epub")
        send_file "#{dir}/#{@story.to_param}.epub", :type=>"application/epub"
      end

      format.js
      format.json do
        illustration = @page.illustration_crop.try(:illustration)
        render json: {
          page: {
            content: sanitized_content
          }.as_json,
          links: [
            {
              rel: 'self',
              uri: story_page_path(@story,@page)
            },
            {
              rel: 'story',
              uri: react_stories_show_path(@story.to_param)
            },
            {
              rel: 'illustration_crop',
              uri: illustration_crop_path()
            }
          ]
        }
      end
      format.pdf do
        render pdf: @story.to_param,
          show_as_html: params[:debug],
          print_media_type: true,
          page_size: 'A4',
          orientation: @story.orientation.capitalize,
          extra: params[:high_resolution] ? '--no-pdf-compression --image-quality 100 --image-dpi 3000' : '--image-quality 60' ,
          margin:     {:top                => 3,
                       :bottom             => 3,
                       :left               => 10,
                       :right              => 3}
      end
    end
  end

  def navigate_to
    respond_to do |format|
      format.html {}
      format.js
    end
  end

  private
  def page_params
    params.require(:story_page).permit(:page_template_id, :content)
  end

  def assign_story
    if @page != nil
      @story = @page.story
    else
      @story = Story.eager_load({:pages=>[:page_template,{:illustration_crop=>{:illustration=>:illustrators}}]}).find_by_id(params[:story_id])
    end
  end

  def assign_page
    @page = Page.eager_load([:page_template,{:illustration_crop=>{:illustration=>:illustrators}}])
    .find_by_id(params[:id])
  end

  def sanitized_content
    ActionView::Base.full_sanitizer.sanitize @page.content
  end

  def embed_fonts(story, dir, fonts)

    storyFont = @story.language.language_font.font.gsub(/\s+/, "")
    Dir.mkdir("#{dir}/fonts")

    # Adding NotoSans by default
    Dir.mkdir("#{dir}/fonts/NotoSans")
    Dir.mkdir("#{dir}/fonts/NotoSans/Regular")
    Dir.mkdir("#{dir}/fonts/NotoSans/Bold")
    Dir.mkdir("#{dir}/fonts/NotoSans/Italic")
    Dir.mkdir("#{dir}/fonts/NotoSans/BoldItalic")

    ['Regular', 'Bold', 'Italic', 'BoldItalic'].each do |style|
      style_path = "#{Rails.root}/app/assets/fonts/NotoSans/#{style}/NotoSans-#{style}_gdi.woff"
      font_file = "#{dir}/fonts/NotoSans/#{style}/NotoSans-#{style}_gdi"
      fonts << "#{font_file.split('/').last(4).join('/')}.woff"
      FileUtils.cp open(style_path), "#{font_file}.woff"
    end
    
    if (['NotoNastaliqUrdu', "NotoSansMongolian", "NotoSansOlChiki"].include? storyFont)
      Dir.mkdir("#{dir}/fonts/#{storyFont}")
      regular_path = "#{Rails.root}/app/assets/fonts/#{storyFont}/#{storyFont}-Regular.woff"
      font_file_regular = "#{dir}/fonts/#{storyFont}/#{storyFont}-Regular"
      fonts << "#{font_file_regular.split('/').last(3).join('/')}.woff"
      FileUtils.cp open(regular_path), "#{font_file_regular}.woff"
    elsif storyFont != "NotoSans"
      Dir.mkdir("#{dir}/fonts/#{storyFont}")
      Dir.mkdir("#{dir}/fonts/#{storyFont}/Regular")
      Dir.mkdir("#{dir}/fonts/#{storyFont}/Bold")
      regular_path = "#{Rails.root}/app/assets/fonts/#{storyFont}/Regular/#{storyFont}-Regular.woff"
      bold_path = "#{Rails.root}/app/assets/fonts/#{storyFont}/Bold/#{storyFont}-Bold.woff"
      font_file_regular = "#{dir}/fonts/#{storyFont}/Regular/#{storyFont}-Regular"
      font_file_bold = "#{dir}/fonts/#{storyFont}/Bold/#{storyFont}-Bold"
      fonts << "#{font_file_regular.split('/').last(4).join('/')}.woff"
      fonts << "#{font_file_bold.split('/').last(4).join('/')}.woff"
      FileUtils.cp open(regular_path), "#{font_file_regular}.woff"
      FileUtils.cp open(bold_path), "#{font_file_bold}.woff"
    end
  end  

end
