module Eapi
  module Children
    CHILDREN = {}

    def self.list
      CHILDREN.values
    end

    def self.append(klass)
      k           = self.key_for klass
      CHILDREN[k] = klass
    end

    def self.get(klass_name, base_class = nil)
      k = key_for klass_name

      find(k) || find_bare(base_class, k)
    end

    def self.has?(klass_name)
      !!self.get(klass_name)
    end

    private
    def self.find(k)
      CHILDREN[k] ||
        CHILDREN[k.gsub('__', '/')] ||
        CHILDREN.select { |key, _| key.gsub('/', '_') == k }.values.first
    end

    def self.key_for(klass_name)
      k = klass_name.to_s
      k.underscore
    end

    def self.find_bare(base_class, k)
      if base_class.present?
        base_key = key_for(base_class)
        find "#{base_key}/#{k}"
      else
        nil
      end
    end

    def self.remove_base_from_key(base_key, k)
      k.sub("#{base_key}/", '')
    end

  end
end