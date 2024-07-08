# frozen_string_literal: true

module InternalEventsCli
  NEW_EVENT_FIELDS = [
    :description,
    :internal_events,
    :category,
    :action,
    :value_type,
    :extra_properties,
    :identifiers,
    :additional_properties,
    :product_group,
    :milestone,
    :introduced_by_url,
    :distributions,
    :tiers
  ].freeze

  EVENT_DEFAULTS = {
    internal_events: true,
    product_group: nil,
    introduced_by_url: 'TODO'
  }.freeze

  ExistingEvent = Struct.new(*NEW_EVENT_FIELDS, :file_path, keyword_init: true)

  NewEvent = Struct.new(*NEW_EVENT_FIELDS, keyword_init: true) do
    def formatted_output
      EVENT_DEFAULTS
        .merge(to_h.compact)
        .slice(*NEW_EVENT_FIELDS)
        .transform_keys(&:to_s)
        .to_yaml(line_width: 150)
    end

    def file_path
      File.join(
        *[
          ('ee' unless distributions.include?('ce')),
          'config',
          'events',
          "#{action}.yml"
        ].compact
      )
    end

    def bulk_assign(key_value_pairs)
      key_value_pairs.each { |key, value| self[key] = value }
    end
  end

  class Event
    def self.parse(**args)
      ExistingEvent.new(**args)
    end

    def self.new(**args)
      NewEvent.new(**args)
    end
  end
end
