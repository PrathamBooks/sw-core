module SWCONSTANTS
  ATTENTIONREQUIRED = 'Attention Required'.freeze
  CANNTREMOVEPAGE = 'You cannot remove this page'.freeze
#read_pge
  TITLEERROR = "Title can't be blank, Title can't be blank, Title can only have English Alphabet, numbers and punctuation characters".freeze
  RP_SORTBYOPTIONS = ['Relevance', 'New Arrivals', 'Most Read', 'Most Liked', "Editor's Picks"].freeze
#create_page
  PUBLISHPOPUPNORMALUSEROPTIONS = ["STORY TITLE", "SYNOPSIS", "READING LEVEL", "CATEGORY", "COPYRIGHT YEAR"]
  PUBLISHPOPUPCMOPTIONS = SWCONSTANTS::PUBLISHPOPUPNORMALUSEROPTIONS + ["EMAIL", "FIRST NAME"]
  EDITORILLUSTRATIONNORMALUSER = ["IMAGE TITLE", "CATEGORY", "IMAGE STYLE", "IMAGE LICENSE"]
  EDITORILLUSTRATIONPUBLISHERUSER = ["IMAGE TITLE", "CATEGORY", "IMAGE STYLE", "IMAGE LICENSE", "EMAIL","ILLUSTRATOR FIRST NAME","ILLUSTRATOR LAST NAME"]
  CP_AVALIABLE_OPTIONS = ["LANGUAGE", "BOOK TITLE", "READING LEVEL", "BOOK ORIENTATION"].freeze
#story details page
  READSTORY = 'Read Story'.freeze
  LOGINSIGNUPPOP = ["Log In", "Sign Up"].freeze
  MOREPOPUP = ["Re-level", "Embed Copy paste the source code on to your website or blog to embed this story!", "View attributions"].freeze
  SHAREPOPUP =["Twitter", "Facebook", "Google+"].freeze
  CONTENTMOREPOPUP = ["Edit", "Add to Editor's Picks", "Re-level", "Embed Copy paste the source code on to your website or blog to embed this story!", "View attributions", "Edit Level"].freeze
  NORMALMOREPOPUP = ["Re-level", "Embed Copy paste the source code on to your website or blog to embed this story!", "View attributions"].freeze   
#list_page
  LISTSHAREACTIONS = ["Twitter", "Facebook", "Google+"].freeze
  LISTSORTOPTIONS = ['Relevance', 'New Arrivals', 'Most Viewed', 'Most Liked'].freeze
  LISTMANDATORYFIELDS = ["How would you rate the Lists feature?", "How do Lists help you?", "How well do Lists support themes for your classroom?", "Would you like to suggest other themes for Lists?", "What do you like about the Lists feature?", "Will you be returning to download more Lists?"].freeze
  LISTFEEDBACKURL = 'https://docs.google.com/forms/d/e/1FAIpQLSfe1Wn1hnbjEHILZ72b04IeN8JLN7QjQTGX0Am33CbewRdfLQ/viewform'.freeze
#urls
  PROFILE = 'v0/profile'.freeze
#flash_messages
  FALSHDRAFTDELETED = 'Draft deleted successfully'.freeze
#general keywords
  DELETE = 'delete'.freeze
  EDIT = 'edit'.freeze
#read along
  READALONG = 'Readalong'.freeze
end
