class FileContent

  def initialize(options = {})
    @source = options[:source]
    @target = options[:target]
    @language = options[:language]
    @file_type = options[:file_type]
  end

  FILES = ["#{@language}.#{@type}"].freeze
  PLACEHOLDER_REGEXP_JSON = /{[a-zA-Z_-]*}/.freeze
  PLACEHOLDER_REGEXP_YAML =  /%{[a-zA-Z_-]*}/.freeze

  def generate_file
    new_generator(@file_type).generate_file!
  end

  def update_file
    new_generator(@file_type).update_file!
  end

  private

  def new_generator(file_type)
    return json_generator if file_type == "json"
    
    yaml_generator
  end

  def json_generator
    JsonFileGenerator.new(
      lang: @language,
      source_file: @source,
      target_file: @target,
      regexp: PLACEHOLDER_REGEXP_JSON,
      placeholder_repl: "{---}"
    )
  end

  def yaml_generator
    @target = @source.gsub("en:", "#{@language}:")
    YamlFileGenerator.new(
      lang: @language,
      source_file: @source,
      target_file: @target,
      regexp: PLACEHOLDER_REGEXP_YAML
    )
  end
end
