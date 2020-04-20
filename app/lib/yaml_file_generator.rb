class YamlFileGenerator
  include FileGenerator
  include TranslationsUpdater

  def generate_file!
    { lang => translate_hash(source_yaml) }
  end

  def update_file!
    { lang => update_translations(translated_yaml, source_yaml) }
  end

  private

  def source_yaml
    YAML.load(source_file)[FROM]
  end

  def translated_yaml
    YAML.load(target_file)[lang]
  end
end
