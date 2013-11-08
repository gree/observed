require 'observed/hash/key_path_encoding'

module Observed
  module Hash
    class Builder
      include Observed::Hash::KeyPathEncoding

      def initialize(defaults={})
        @hash = defaults.dup
      end

      def []=(key_path, value)
        at_key_path_on_hash @hash, key_path, create_if_missing: true do |h, k|
          h[k] = value
        end
      end

      def build
        @hash
      end

    end
  end
end
