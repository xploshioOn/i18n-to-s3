# frozen_string_literal: true

module TranslationsUpdater
  VALID_CHANGES = %w[- +].freeze

  private

  def update_translations(translated_hash, source_hash)
    changes = Hashdiff.diff(translated_hash, source_hash)
    changes.map! do |change|
      next unless change.first.in?(VALID_CHANGES)
      next(change) if change.first == VALID_CHANGES.first

      change[-1] = if change.last.is_a?(Hash)
                     translate_hash(change.last)
                   else
                     translate(change.last)
                    end
      change
    end

    Hashdiff.patch!(
      translated_hash.deep_stringify_keys,
      changes.compact
    )
  end
end
