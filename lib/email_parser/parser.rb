require 'email_parser/version'
require 'email_parser/forward_patterns'
require 'email_parser/emoji_patterns'
require 'email_parser/reply_patterns'
require 'email_parser/sent_patterns'
require 'email_parser/signature_patterns'

require 'mail'
require 'json'
require 'nokogiri'

module EmailParser
  module Parser
    def self.parse(raw_message)
      message = Mail.new(raw_message)

      data = {
        subject: extract_subject(message),
        sender: extract_sender(message),
        from: extract_from(message),
        recipients: extract_recipients(message),
        headers: extract_headers(message),
        body_plain: extract_body_plain(message),
        body_html: extract_body_html(message),
        attachments: extract_attachments(message),
        is_subscription: subscription?(message)
      }

      data[:mime_type] = message.mime_type unless message.nil?
      data[:is_forwarded] = forwarded?(data[:subject], data[:body_plain])
      data[:stripped_text] = strip_text(data[:body_plain])
      data[:stripped_html] = strip_html(data[:body_html], data[:headers])
      data[:stripped_subject] = strip_subject(data[:subject])
      data[:subject_has_emojis] = emojis?(data[:subject])
      data[:email_signature] = strip_signature(data[:body_plain])

      data
    end


    def self.to_valid_utf8(value)
      return nil if value.nil?

      value.encode('utf-8', invalid: :replace)
    end
    private_class_method(:to_valid_utf8)

    def self.address_to_dict(address)
      {
        email: to_valid_utf8(address.address),
        name: (address.display_name || '').include?('@') ? nil : to_valid_utf8(address.display_name)
      }
    end
    private_class_method(:address_to_dict)

    def self.extract_subject(message)
      to_valid_utf8(message.subject)
    end
    private_class_method(:extract_subject)

    def self.extract_sender(message)
      sender_header = message.header['Sender']

      return extract_from(message) if sender_header.nil?

      begin
        sender_address = sender_header.address
      rescue NoMethodError
        return { name: nil, email: nil }
      end

      return extract_from(message) if sender_address.nil?

      address_to_dict(sender_address)
    end
    private_class_method(:extract_sender)

    def self.extract_from(message)
      from_header = message.header['From']
      begin
        address = from_header.addrs[0]
      rescue NoMethodError
        # In case the From header is malformed, instead of getting a FromField,
        # we will get a StructuredField, which does not have the attrs method.
        return { name: nil, email: nil }
      end

      address_to_dict(address)
    end
    private_class_method(:extract_from)

    def self.extract_addresses(header, type)
      return [] if header.nil?

      begin
        addrs = header.addrs
      rescue NoMethodError
        # In case the header is malformed, instead of getting a valid field,
        # we will get a StructuredField, which does not have the attrs method.
        return []
      end

      addrs.map do |address|
        address_dict = address_to_dict(address)
        address_dict[:type] = type

        address_dict
      end
    end
    private_class_method(:extract_addresses)

    def self.extract_recipients(message)
      # TODO(skreft): add type of header to each entry?
      recipients = []
      to_header = message.header['To']
      recipients += extract_addresses(to_header, 'to')

      cc_header = message.header['Cc']
      recipients += extract_addresses(cc_header, 'cc')

      bcc_header = message.header['Bcc']
      recipients += extract_addresses(bcc_header, 'bcc')

      recipients
    end
    private_class_method(:extract_recipients)

    def self.extract_headers(message)
      headers = Hash.new { |h, k| h[k] = [] }
      message.header.fields.each do |field|
        header_name = field.capitalize_field(field.name)
        headers[header_name] << to_valid_utf8(field.to_s)
      end

      headers
    end
    private_class_method(:extract_headers)

    def self.normalize_encoding_name(encoding_name)
      encoding_name.downcase.gsub(/[^a-z0-9]+/, '')
    end

    ENCODINGS = Encoding.name_list.map do |encoding_name|
      [normalize_encoding_name(encoding_name), Encoding.find(encoding_name)]
    end.to_h
    private_class_method(:normalize_encoding_name)

    def self.get_encoding(encoding_name)
      normalized_encoding_name = normalize_encoding_name(encoding_name)

      ENCODINGS.fetch(normalized_encoding_name, ENCODINGS['usascii'])
    end
    private_class_method(:get_encoding)

    def self.extract_body_plain(message)
      if message.multipart?
        part = message.text_part
        return nil if part.nil?
      else
        # TODO RA consider supporting extraction from text/html messages
        return nil if message.mime_type != 'text/plain'

        part = message
      end

      encoding = get_encoding(part.charset || part.body.charset || 'us-ascii')

      part.decode_body.force_encoding(encoding).encode('utf-8',
                                                       invalid: :replace)
    end
    private_class_method(:extract_body_plain)

    def self.extract_body_html(message)
      if message.multipart?
        part = message.html_part
        return nil if part.nil?
      else
        return nil if message.mime_type != 'text/html'

        part = message
      end

      encoding = get_encoding(part.charset || part.body.charset || 'us-ascii')

      decoded_body = part.decode_body.force_encoding(encoding).encode('utf-8', invalid: :replace)
      doc = Nokogiri::HTML(decoded_body)
      doc.to_html
    end
    private_class_method(:extract_body_html)

    def self.extract_filename(message)
      # This is a fixed version of Mail::Message.find_attachment
      content_type_name = message.header[:content_type].filename rescue nil
      content_disp_name = message.header[:content_disposition].filename rescue nil
      content_loc_name  = message.header[:content_location].location rescue nil

      filename = if content_type_name
                   content_type_name
                 elsif content_disp_name
                   content_disp_name
                 elsif content_loc_name
                   content_loc_name
                 end
      filename = Mail::Encodings.decode_encode(filename, :decode) if filename rescue filename
    end
    private_class_method(:extract_filename)

    def self.extract_attachments(message)
      attachments = []
      parts = [message] + message.all_parts
      parts.each do |part|
        # TODO: skip first plain and first html
        next if part.multipart?

        # Cannot use message.content_disposition('').downcase as it fails.
        # This is due to the same reason why Mail::Message.find_attachment fails
        content_disposition = message.header[:content_disposition]
        if content_disposition
          content_disposition = content_disposition.value.downcase
        else
          content_disposition = ''
        end

        filename = extract_filename(part)
        next if filename.nil? && content_disposition.start_with?('inline')
        # TODO(skreft): if filename is None try to extract it from the
        #    content-id

        mime_type = part.mime_type
        if content_disposition == '' &&
            (mime_type == 'text/plain' || mime_type == 'text/html')
          next
        end

        attachments.push(
          name: to_valid_utf8(filename),
          mime_type: mime_type,
          size: part.decoded.length
        )
      end

      attachments
    end
    private_class_method(:extract_attachments)

    def self.subscription?(message)
      message.header.fields.any? do |field|
        field.name.downcase.start_with? 'list-'
      end
    end
    private_class_method(:subscription?)

    def self.forwarded?(subject, body_plain)
      forwarded_subject?(subject) || forwarded_body?(body_plain)
    end
    private_class_method(:forwarded?)

    def self.forwarded_subject?(subject)
      return false if subject.nil?
      !ForwardPatterns::FORWARD_SUBJECT_RE.match(subject).nil?
    end
    private_class_method(:forwarded_subject?)

    def self.forwarded_body?(body)
      return false if body.nil?
      !ForwardPatterns::FORWARD_BODY_RE.match(body).nil?
    end
    private_class_method(:forwarded_body?)

    # Do not process lines longer than the value below, as that could trigger a
    # DOS, due to the RE engine
    MAX_LINE_LENGTH = 200

    def self.strip_text(body)
      return nil if body.nil?

      inline_re = Regexp.new('^[>|]+( |$)')
      lines = body.split("\n")

      new_lines = []
      lines.length.times do |i|
        line = lines[i].strip
        next if inline_re.match(line)

        if line.length > MAX_LINE_LENGTH
          new_lines << line
          next
        end

        next if ReplyPatterns::REPLY_WROTE_RE.match(line)
        next if SentPatterns::SENT_FROM_RE.match(line)

        break if ForwardPatterns::FORWARD_BODY_RE.match(line)
        break if ReplyPatterns::REPLY_HEADER_RE.match(line)

        new_lines << line
      end

      new_lines.pop while new_lines.last == ''

      # Remove signature
      if new_lines.length >= 2 && new_lines[new_lines.length - 2] == '--'
        new_lines.pop
        new_lines.pop
      end

      new_lines = new_lines.join("\n").strip.gsub(/\n{2,}/, "\n\n")
      new_lines
    end
    private_class_method(:strip_text)

    def self.strip_html(body, headers)
      return nil if body.nil?

      doc = Nokogiri::HTML(body)
      # TODO: Handle non-gmail html sources
      if headers.keys.include?('X-Google-Smtp-Source')
        quoted_content = doc.xpath("//div[@class='gmail_quote']").first
        quoted_content&.remove

        signature_content = doc.xpath("//div[@class='gmail_signature']").first
        signature_content&.remove
      end

      doc.to_html
    end
    private_class_method(:strip_html)

    def self.strip_signature(body)
      return nil if body.nil?

      # TODO(RA, 2016-08-24): Rewrite using feature scores and ML
      # Obtain the text following a closing
      last_match = body.scan(SignaturePatterns::CLOSING_RE).last
      return nil if last_match.nil?
      signature = $'

      # Strip phone signature
      if SignaturePatterns::PHONE_CLOSING_RE =~ signature
        signature[SignaturePatterns::PHONE_CLOSING_RE] = ''
      end

      # Strip whitespace, dots and commas
      signature.gsub(/\A[\s\.,]+|[\s\.,]+\z/m, '')
    end
    private_class_method(:strip_signature)

    STRIP_SUBJECT_RE = Regexp.union(
      ReplyPatterns::REPLY_SUBJECT_RE,
      ForwardPatterns::FORWARD_SUBJECT_RE,
      / \(fwd\)$/
    )

    def self.strip_subject(subject)
      return nil if subject.nil?

      stripped_subject = subject
      loop do
        new_stripped_subject = stripped_subject.sub(STRIP_SUBJECT_RE, '')
        break if new_stripped_subject == stripped_subject
        stripped_subject = new_stripped_subject
      end

      stripped_subject
    end
    private_class_method(:strip_subject)

    def self.emojis?(text)
      !EmojiPatterns::EMOJI_RE.match(text).nil?
    end
    private_class_method(:emojis?)
  end
end
