class IcuTranslator
  attr_reader :parsed_text

  def initialize(parsed_text)
    @parsed_text = parsed_text
  end

  def build
    handle_array(parsed_text)
  end

  private

  def handle_pluralization_hash(hash)
    hash.map { |match, text| "#{match} {#{text}}" }.join(" ")
  end

  def handle_array(array, level = 0)
    result = array.map do |element|
      if element.is_a?(String)
        element
      elsif element.is_a?(Array)
        handle_array(element, level + 1)
      elsif element.is_a?(Hash)
        handle_pluralization_hash(element)
      end
    end.compact

    level.odd? ? "{#{result.join(', ')}}" : result.join(" ")
  end
end
