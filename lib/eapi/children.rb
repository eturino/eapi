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

    def self.get(klass_name)
      k = self.key_for klass_name
      CHILDREN[k] ||
        CHILDREN[k.gsub('__', '/')] ||
        CHILDREN.select { |key, _| key.gsub('/', '_') == k }.values.first
    end

    def self.has?(klass_name)
      !!self.get(klass_name)
    end

    def self.key_for(klass_name)
      k = klass_name.to_s
      k.underscore
    end
  end
end