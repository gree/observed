require 'observed/hash/key_path_encoding'

module Observed
  module Hash
    class Fetcher
      include Observed::Hash::KeyPathEncoding

      def initialize(hash)
        @hash = hash || fail('The hash must not be nil')
      end

      def [](key_path)
        at_key_path_on_hash @hash, key_path, create_if_missing: false do |h, k|
          h[k]
        end
      end
    end
  end
end
