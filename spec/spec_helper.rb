$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'email_parser'

def get_message(filename)
  IO.read(File.join(File.dirname(__FILE__), 'data', filename))
end
