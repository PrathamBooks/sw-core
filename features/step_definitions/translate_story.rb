When (/^I create translation of english stories$/) do
  Story.generate_auto_translate_drafts
end

When (/^I click on Menu Button$/) do
  find(:xpath, "(.//*[@id='Editor']//button)[1]").click
end

Given "I stub auto_translate_api" do
  allow_any_instance_of(ApplicationHelper).to receive(:translateText).and_return("dummy translation")
end
