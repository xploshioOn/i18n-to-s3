class IcuParser
  FROM = 'en'.freeze

  attr_reader :pattern, :lang

  def initialize(pattern:, lang:)
    @pattern = pattern
    @lang = lang
  end

  def output
    parsed.map { |text| translate(text) }
  end

  private

  def handle_array(array, level, force_brackets = false)
    array.map { |text| translate(text, level + 1, force_brackets) }
  end

  def handle_hash(hash, level)
    return hash unless hash.values.find { |v| v.is_a?(Array) }

    new_hash = {}

    hash.each_pair do |k, v|
      if v.size == 1
        new_hash[k] = translate_text(v.first)
      else
        mapped = v.map do |value|
          if value.is_a?(Array)
            handle_array(value, 0, true)
          elsif level.odd?
            translate_text(value)
          else
            "{#{value}}"
          end
        end.join(' ')

        new_hash[k] = mapped
      end
    end

    new_hash
  end

  def translate(text, level = 0, force_brackets = false)
    if text.is_a?(Array)
      handle_array(text, level)
    elsif text.is_a?(Hash)
      handle_hash(text, level)
    elsif level.even?
      translate_text(text)
    elsif force_brackets && text != '#'
      "{#{text}}"
    else
      text
    end
  end

  def parsed
    @parsed ||= MessageFormat::Parser.new.parse(pattern)
  end

  def translate_text(text)
    TranslationService.new.translate(
      text: text,
      from: FROM,
      to: lang,
      split_newlines: true
    ).text
  end
end
