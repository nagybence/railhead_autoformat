module RailheadSanitize
  def self.included(base)
    base.extend ClassMethods
    base.send :include, ActionView::Helpers::SanitizeHelper
    base.extend ActionView::Helpers::SanitizeHelper::ClassMethods
    base.class_eval do
      class_inheritable_reader :sanitize_options
      before_validation :sanitize_fields
    end
  end

  module ClassMethods
    def auto_sanitize(options = {})
      write_inheritable_attribute(:sanitize_options, {
        :except => (options[:except] || []),
        :allow_tags => (options[:allow_tags] || [])
      })
    end
  end

  def sanitize_fields
    self.class.columns.each do |column|
      next unless (column.type == :string || column.type == :text)
      field = column.name.to_sym
      value = self[field] && self[field].strip
      if sanitize_options && sanitize_options[:except].include?(field)
        self[field] = value
      elsif sanitize_options && sanitize_options[:allow_tags].include?(field)
        self[field] = sanitize(value)
      else
        self[field] = strip_tags(value)
      end
    end
  end
end

ActiveRecord::Base.send :include, RailheadSanitize
