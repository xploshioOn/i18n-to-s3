# frozen_string_literal: true

module FileGenerator
  FROM = "en"

  def initialize(options = {})
    @lang = options.fetch(:lang)
    @source_file = options.fetch(:source_file)
    @target_file = options.fetch(:target_file)
    @regexp = options.fetch(:regexp)
    @placeholder_repl = options.fetch(:placeholder_repl, "{{---}}")
    @translator = TranslationService.new
  end

  private

  attr_reader :lang, :source_file, :target_file, :regexp, :translator, :placeholder_repl

  def translate_hash(hash)
    hash.each_with_object({}) do |(k, v), result|
      result[k] = v.is_a?(Hash) ? translate_hash(v) : translate(v)
    end
  end

  def translate(text)
    return text if text.blank?

    matches = text.scan(regexp)

    result =
      if matches.blank?
        retrieve_translation(text)
      else
        translatable = text.gsub(regexp, placeholder_repl)
        translated = retrieve_translation(translatable)
        matches.inject(translated) { |s, m| s.sub(placeholder_repl, m) }
      end
    result
  end

  def retrieve_translation(text)
    result = retrieve_translation_result(text: text, to: lang)
    CGI.unescapeHTML(result)
  end

  def retrieve_translation_result(text:, to:)
    translator.translate(text: text, from: FROM, to: to).text
  end

end

