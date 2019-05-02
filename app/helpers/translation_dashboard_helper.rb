module TranslationDashboardHelper

  def translator_language_present(translator_stories, translate_language)
    if translate_language.present?
      translate_languages = translator_stories.map { |ts| ts.translate_language_id }
      return translate_languages.include?(translate_language.to_i)
    else
      return true
    end
  end

  def translate_language_match(translator_story, translate_language)
    if translate_language.present?
      return (translator_story.translate_language_id == translate_language.to_i)
    else
      return true
    end
  end

  def stories_languages(remove_language_ids)
    if(remove_language_ids.present?)
      languages = Language.where.not(:id => remove_language_ids)
    else
      languages = Language.all
    end
    return languages
  end

  def is_translator_story(user, story)
    user.is_translator? && story.try(:translator_story).try(:translator_id) == user.id
  end

end
