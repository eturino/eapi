module Eapi
  module Children
    CHILDREN = {}

    def self.list
      CHILDREN.values
    end

    def self.append(klass)
      CHILDREN[klass.to_s] = klass
    end

    def self.get(klass_name)
      kn = klass_name.to_s
      CHILDREN[kn] || CHILDREN[kn.camelize]
    end

    def self.has?(klass_name)
      !!self.get(klass_name)
    end
  end
end