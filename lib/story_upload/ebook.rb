require 'epub/parser'
require 'uri'
require 'time'
require 'zip/zip'
require 'css_parser'

class StoryUpload::Ebook
  FONT_SIZE={"560px" =>  "largest", "480px" => "large", "360px" => "normal", "320px" => "medium", "280px" => "small","240px" => "smallest"}
  def initialize(book_path,align)
    @css=nil
    @timestamp= Time.now.to_i.to_s
    @book_path=book_path
    @book = EPUB::Parser.parse(book_path)
    unzip
    @text_align=get_text_align(align)
    @page_data = process_page_data
  end

  def get_text_align(align)
    return "left" if align.nil? || align.empty?
    if ["left","right","center"].include? align.downcase
      return align.downcase
    else
      return "left"
    end
  end

  def get_page_data
    @page_data
  end

  def get_cover_page
    return @cover_image
  end

  def get_file_path(file_name)
    add_path(File.basename(file_name))
  end

  def self.simplify_para(para)
    if(para.is_a?String)
      html  = Nokogiri::HTML para
      para  = html.css("body p")
    end
    prev_node=nil
    para.children.each do |span|
      if !prev_node.nil?
        if(span.attribute("class").to_s==prev_node.attribute("class").to_s)
          prev_node.inner_html += span.inner_html
          span.remove
        else
          prev_node=span
        end
      else
        prev_node=span
      end
    end
    para
  end

  def self.simplify_paras(page)
    html  = Nokogiri::HTML page.content
    paras = html.css("body p")
    paras.each do |para|
      simplify_para(para)
    end
    paras
  end

  def destroy
    FileUtils.remove_dir(tmp_path)
  end

  private
  def process_cover_page(page)
    @cover_image=""
      doc= page.content_document.nokogiri
      images = doc.css("img")
      images.each do |m|
        image_uri=URI.decode(m.attr("src"))
        if image_uri.downcase.include?("cover")
          @cover_image = image_uri
          break
        end
      end
      if @cover_image == "" &&  images.count > 0
        @cover_image=URI.decode(images[0].attr("src"))
      end
  end

  def parse_css
    css_string=""
    @book.resources.each do |r|
      if r.media_type == "text/css"
        css_string= r.read
        break
      end
    end
    return if css_string==""
    @css = CssParser::Parser.new
    @css.add_block!(css_string)
  end

  def page_count
    count = 0
    @book.each_page_on_spine do |page|
      count+=1
    end
    return count
  end

  def process_page_data
    parse_css
    page_data=[]
    index=0
    count = page_count
    @book.each_page_on_spine do |page|
      if index==0
        process_cover_page page
      end
      index+=1
      next if (index < 2 || index > count -2)
      data={}
      doc= page.content_document.nokogiri
      images = doc.css("img")
      if images.count > 1
        raise "ebook has more than one image in page : #{index}"
      end
      images.each do |m|
        data["image"]=URI.decode(m.attr("src"))
        break
      end
      contents = doc.css("div.Basic-Text-Frame")
      data["content"]=""
        contents.each do |c|
          para = c.css("p")
          para.each do |p|
            _content = ""
            _content += "<p class='wysiwyg-text-align-#{@text_align}'>"
            if p.children.count == 0
             _content +=  p.inner_text.to_s
            else
              p.children.each do |s|
                if s["class"] !=nil
                  _content += generate_formated_text(s)
                else
                 _content += "<#{s.name}>" + s.inner_text.to_s + "</#{s.name}>"
                end
              end
            end
            _content += "</p> "
            data["content"] += StoryUpload::Ebook.simplify_para(_content).to_s
          end
        end
      page_data<<data
    end
    page_data
  end

  def generate_formated_text(element)
    data = element.inner_text.to_s
    data = data.strip.blank? ? '&nbsp;' : data
    css_text =""
    @css.find_by_selector(element.name+"."+element["class"]).each do |_css_text|
      css_text += _css_text.to_s
    end
    _hash = css_strip_to_hash(css_text)
    if _hash["font-weight"] != nil && _hash["font-weight"] != "normal"
      data =  "<b>#{data}</b>"
    end
    if _hash["font-style"] != nil && _hash["font-style"]=="italic"
      data =   "<i>#{data}</i>"
    end
    if _hash["text-decoration"] != nil && _hash["text-decoration"]=="underline"
      data =   "<u>#{data}</u>"
    end
    font_size=get_font_size(_hash)
    if data == element.inner_text.to_s
      return "<#{element.name} class='text-font-#{font_size}'>" + element.inner_text.to_s + "</#{element.name}>"
    else
      return "<span class='text-font-#{font_size}'>" + data + "</span}>"
    end
  end

  def get_font_size(css)
    size=""
    if (css["font-size"] != nil)
      size = FONT_SIZE[css["font-size"].strip]
    end
    return (size.nil? || size.empty?) ? "normal" : size
  end

  def tmp_path
    File.join('tmp','stories',File.basename(@book_path)+@timestamp)
  end

  def make_tmp_path
    FileUtils.mkdir_p tmp_path
  end

  def add_path(filename)
    File.join(tmp_path,filename)
  end

  def css_strip_to_hash(str)
    begin
      return str.split("; ").each_with_object({}) do |s, h|
        k,v = s.split(":")
        h[k.downcase] = v.strip.gsub(/;/,'')
      end
    rescue
      return {}
    end
  end

  def unzip
    make_tmp_path
    Zip::ZipFile.open(@book_path).each do |single_file|
      if isFileType(single_file,/.png/) || isFileType(single_file, /.jpg/) || isFileType(single_file,/jpeg/)
        single_file.extract(add_path(File.basename(single_file.name)))
      end
    end
  end

  def isFileType(file,regex)
    file.name.downcase =~ regex
  end
end
