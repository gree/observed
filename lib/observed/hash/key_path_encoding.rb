module Observed
  module Hash
    module KeyPathEncoding

      def at_key_path_on_hash(hash, key_path, options = {}, &block)
        create_if_missing = options[:create_if_missing]

        if create_if_missing.nil?
          fail "The key :create_if_missing must be exist in #{options}"
        end

        if hash.nil?
          fail 'The hash must not be nil'
        end

        first, *rest = case key_path
                       when Array
                         key_path
                       when String
                         key_path.split(".")
                       end
        key_str = first.to_s
        key_sym = first.intern
        key = if hash.key? key_str
                key_str
              else
                key_sym
              end
        if rest.empty?
          block.call hash, key
        else
          child = hash[key]
          if child
            at_key_path_on_hash(child, rest, options, &block)
          end
        end
      end
    end
  end
end
