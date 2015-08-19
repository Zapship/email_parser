require 'csv'

module EmailParser
  module EmojiPatterns
    def self.chr(codepoint)
      [codepoint].pack('U')
    end

    def self.codepoints_to_string(codepoints)
      codepoints.strip.split(' ').map do |string_codepoint|
        chr(string_codepoint.hex)
      end.join('')
    end

    def self.read_emojis
      # Extracts the emojis from
      # http://www.unicode.org/Public/emoji/1.0//emoji-data.txt
      emojis = []
      filename = File.expand_path(
        File.join('..', '..', '..', 'data', 'emoji-data.txt'), __FILE__)
      CSV.foreach(
          filename, col_sep: " ;\t",
          headers: [:code, :default_style, :level, :status, :sources]) do |row|
        next if row[:default_style] != 'emoji'
        emojis << codepoints_to_string(row[:code])
      end

      emojis
    end

    EMOJIS = read_emojis

    EMOJI_RE = Regexp.union(EMOJIS.uniq)
  end
end
