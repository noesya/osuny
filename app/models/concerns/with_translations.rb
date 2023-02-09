module WithTranslations
  extend ActiveSupport::Concern

  included do
    belongs_to  :language
    belongs_to  :original, class_name: base_class.to_s, optional: true
    has_many    :translations, class_name: base_class.to_s, foreign_key: :original_id, dependent: :nullify

    scope :for_language, -> (language) { for_language_id(language.id) }
    # The for_language_id scope can be used when you have the ID without needing to load the Language itself
    scope :for_language_id, -> (language_id) { where(language_id: language_id) }
  end

  def available_languages
    @available_languages ||= begin
      languages = respond_to?(:website) ? website.languages : Language.all
      languages.ordered
    end
  end

  def find_or_translate!(language)
    translation = translation_for(language)
    translation ||= translate!(language)
    translation
  end

  def translation_for(language)
    # If the requested language is the object language, we return itself
    return self if language_id == language.id
    # All translations share the same original.
    # If the current object is a translation, we call translation_for on the original.
    # Else, if the current object is the original, we search the translation with the language.
    original_id.present?  ? original.translation_for(language)
                          : translations.find_by(language_id: language.id)
  end

  def original_object
    @original_object ||= (self.original || self)
  end

  def original_with_translations
    original_object.translations + [original_object]
  end

  # Used by Hugo to link translations with themselves
  def static_translation_key
    "#{self.class.polymorphic_name.parameterize}-#{self.original_object.id}"
  end

  def translate!(language)
    translation = self.dup

    # Translate parent if needed
    if respond_to?(:parent_id) && parent_id.present?
      parent_translation = parent.find_or_translate!(language)
      translation.parent_id = parent_translation&.id
    end

    # Inherits from original_id or set it to itself
    translation.assign_attributes(
      original_id: original_object.id,
      language_id: language.id
    )

    # Handle publication
    translation.published = false if respond_to?(:published)
    # Handle featured image if object has one
    translate_attachment(translation, :featured_image) if respond_to?(:featured_image) && featured_image.attached?
    translation.save
    # Handle blocks if object has any
    translate_blocks!(translation) if respond_to?(:blocks)
    translate_additional_data!(translation)

    translation
  end

  protected

  def translate_blocks!(translation)
    blocks.ordered.each do |block|
      block.translate!(translation)
    end
  end

  # Utility method to duplicate attachments
  def translate_attachment(translation, attachment_name)
    translation.public_send(attachment_name).attach(
      io: URI.open(public_send(attachment_name).url),
      filename: public_send(attachment_name).filename.to_s,
      content_type: public_send(attachment_name).content_type
    )
  end

  def translate_additional_data!(translation)
    # Overridable method to handle custom cases
  end
end