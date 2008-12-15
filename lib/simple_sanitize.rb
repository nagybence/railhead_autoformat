module SimpleSanitize
  def self.included(base)
    base.extend ClassMethods
    base.send :include, ActionView::Helpers::SanitizeHelper
    base.extend ActionView::Helpers::SanitizeHelper::ClassMethods
    base.class_eval do
      before_save :sanitize_fields
      class_inheritable_reader :simple_sanitize
    end
  end

  module ClassMethods
    def sanitize_fields(options = {})
      write_inheritable_attribute(:simple_sanitize, {
        :except => (options[:except] || []),
        :allow_tags => (options[:allow_tags] || [])
      })
    end
    alias_method :sanitize_field, :sanitize_fields
  end
    
  def sanitize_fields
    self.class.columns.each do |column|
      next unless (column.type == :string || column.type == :text)
      field = column.name.to_sym
      value = self[field]
      if simple_sanitize && simple_sanitize[:except].include?(field)
        next
      elsif simple_sanitize && simple_sanitize[:allow_tags].include?(field)
        self[field] = sanitize(value)
      else
        self[field] = strip_tags(value)
      end
    end
  end
end

ActiveRecord::Base.send :include, SimpleSanitize
