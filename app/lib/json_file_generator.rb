class JsonFileGenerator
  include FileGenerator
  include TranslationsUpdater

  ICU_NON_BASIC_FORMAT_REGEX = /{.*{.*}.*}/.freeze

  def generate_file!
    translate_hash(source_hash)
  end

  def update_file!
    update_translations(translated_hash, source_hash)
  end

  def source_hash
    instance_eval(source_file)
  end

  def translated_hash
    instance_eval(target_file)
  end

  private

  def retrieve_translation_result(text:, to:)
    if text.match?(ICU_NON_BASIC_FORMAT_REGEX)
      build_icu(pattern: text, lang: to)
    else
      super
    end
  end

  def build_icu(pattern:, lang:)
    icu_parser = IcuParser.new(pattern: pattern, lang: lang)
    IcuTranslator.new(icu_parser.output).build
  end
end
