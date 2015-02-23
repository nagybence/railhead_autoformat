module RailheadAutoformat

  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      class_attribute :format_options
      before_validation :format_fields
    end
  end

  def format_fields
    self.class.columns.each do |column|
      next unless column.type == :string or column.type == :text
      field = column.name.to_sym
      if self[field].is_a?(String) and not (format_options and format_options[:except].include?(field))
        self[field] = self[field].gsub(/ +/, ' ').strip
      end
    end
  end

  module ClassMethods

    def auto_format(options = {})
      self.format_options = {
        except: (options[:except] || [])
      }
    end
  end
end


ActiveRecord::Base.send :include, RailheadAutoformat
