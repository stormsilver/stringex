require 'stringex/acts_as_url'
require 'stringex/string_extensions'
require 'stringex/unidecoder'

String.send :include, Stringex::StringExtensions

if defined?(ActiveRecord)
  ActiveRecord::Base.send :include, Stringex::ActsAsUrl
end
