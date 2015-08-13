require 'email_parser/parser'

module EmailParser
  def self.parse(raw_message)
    EmailParser::Parser.parse(raw_message)
  end
end
