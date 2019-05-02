namespace :story do
  desc "Generate the text for all pages of the story"
  task :text, [:outdir, :id] => :environment do |t, args|
    split_file_name = args[:outdir] + "/" + args[:id] + ".txt"
    s = Story.find(args[:id])
    File.open(split_file_name, "w") do |f|
      s.story_pages.each do |p|
        content = p.content
        doc = Nokogiri::HTML::DocumentFragment.parse(content)
        doc.traverse do |node| 
          if node.text?
            node.content.split(" ").each do |c|
              c.split("\u00A0").each do |w|
                f.puts w
                f.puts
              end
            end
          end
        end
      end
    end
    html_file_name = args[:outdir] + "/" + args[:id] + ".html"
    File.open(html_file_name, "w") do |f|
      cue = 1
      s.story_pages.each do |p|
        content = p.content
        doc = Nokogiri::HTML::DocumentFragment.parse(content)
        doc.traverse do |node| 
          if node.text?
            node.content.split(" ").each do |c|
              c.split("\u00A0").each do |w|
                f.puts "<span data-cue=\"#{cue}\">" + w + "</span>"
                cue += 1
              end
            end
          end
        end
      end
    end
  end
end
