# frozen_string_literal: true

class TranslationService
  def translate(text:, from:, to:, split_newlines: false)
    return text if unsopported_languages.include?(to)

    if split_newlines
      result = text.split("\n").map do |sub_text|
        translator.translate(sub_text, from: from, to: to, model: :nmt).text
      end.join("\n")

      OpenStruct.new(text: result)
    else
      translator.translate(text, from: from, to: to, model: :nmt)
    end
  end

  private

  def translator
    @translator ||= Google::Cloud::Translate.new(key: api_key)
  end

  def api_key
    ENV['GOOGLE_CLOUD_KEY']
  end

  def unsopported_languages
    ENV['UNSOPPORTED_LANGAUGES'].split(":")
  end
end
