require 'spec_helper'

# TODO(skreft): create a folder for each case
describe EmailParser do
  it 'has a version number' do
    expect(EmailParser::VERSION).not_to be nil
  end

  describe 'subject' do
    it 'handles non encoded' do
      message = get_message('subject/non_encoded')
      subject = EmailParser.parse(message)[:subject]
      expect(subject).to eq('A non encoded subject')
    end

    it 'handles encoded' do
      message = get_message('subject/encoded')
      subject = EmailParser.parse(message)[:subject]
      expect(subject).to eq('Re: Y cuándo hablamos? por skype')
    end

    it 'handles no subject' do
      message = get_message('subject/no_subject')
      subject = EmailParser.parse(message)[:subject]
      expect(subject).to be(nil)
    end

    it 'handles utf8' do
      message = get_message('subject/utf8_encoded')
      subject = EmailParser.parse(message)[:subject]
      expect(subject).to eq('Meldebestätigung Berlin Triathlon XL')
    end
  end

  describe 'sender' do
    it 'extracts sender' do
      message = get_message('sender/sender')
      sender = EmailParser.parse(message)[:sender]
      expect(sender).to eq(email: 'juanadiaz@gmail.com', name: 'Juana Díaz')
    end

    it 'extracts sender with no name' do
      message = get_message('sender/no_name')
      sender = EmailParser.parse(message)[:sender]
      expect(sender).to eq(email: 'juanadiaz@gmail.com', name: nil)
    end

    it 'fallbacks to FROM header' do
      message = get_message('sender/no_sender')
      sender = EmailParser.parse(message)[:sender]
      expect(sender).to eq(email: 'juanadiaz+from@gmail.com',
                           name: 'Juana Díaz')
    end

    it 'does not fail with invalid header' do
      message = get_message('sender/invalid')
      sender = EmailParser.parse(message)[:sender]
      expect(sender).to eq(email: 'someone@unix.edu', name: nil)
    end

    it 'returns nil with malformed sender field' do
      message = get_message('sender/malformed')
      sender = EmailParser.parse(message)[:sender]
      expect(sender).to eq(email: nil, name: nil)
    end
  end

  describe 'from' do
    it 'extracts from with no name' do
      message = get_message('from/no_name')
      from = EmailParser.parse(message)[:from]
      expect(from).to eq(email: 'juanadiaz@gmail.com', name: nil)
    end

    it 'extracts from' do
      message = get_message('from/from')
      from = EmailParser.parse(message)[:from]
      expect(from).to eq(email: 'juanadiaz@gmail.com', name: 'Juana Díaz')
    end

    it 'handles invalid header' do
      message = get_message('from/invalid')
      from = EmailParser.parse(message)[:from]
      expect(from).to eq(email: nil, name: nil)
    end
  end

  describe 'recipients' do
    it 'includes TO, CC and BCC' do
      message = get_message('recipients/recipients')
      recipients = EmailParser.parse(message)[:recipients]
      expect(recipients).to eq([
        { name: 'Pablo Egaña', email: 'egana@mail.com', type: 'to' },
        { name: 'Juan Acuña', email: 'jacuna@mail.com', type: 'to' },
        { name: 'Andrés Muñoz', email: 'munoz@mail.com', type: 'cc' },
        { name: 'Antonio Antunez', email: 'antonio@mail.com', type: 'cc' },
        { name: 'Bruno Magic', email: 'bruno@mail.com', type: 'bcc' },
        { name: 'Carla Cavada', email: 'carla@mail.com', type: 'bcc' }
      ])
    end

    it 'handles undisclosed-recipients' do
      message = get_message('recipients/undisclosed_recipients')
      recipients = EmailParser.parse(message)[:recipients]
      expect(recipients).to eq([
        { name: nil, email: 'bcc@gmail.com', type: 'bcc' }
      ])
    end

    it 'handles empty TO header' do
      message = get_message('recipients/no_to')
      recipients = EmailParser.parse(message)[:recipients]
      expect(recipients).to eq([
        { name: 'Andrés Muñoz', email: 'munoz@mail.com', type: 'cc' },
        { name: 'Antonio Antunez', email: 'antonio@mail.com', type: 'cc' },
        { name: 'Bruno Magic', email: 'bruno@mail.com', type: 'bcc' },
        { name: 'Carla Cavada', email: 'carla@mail.com', type: 'bcc' }
      ])
    end

    it 'handles empty CC header' do
      message = get_message('recipients/no_cc')
      recipients = EmailParser.parse(message)[:recipients]
      expect(recipients).to eq([
        { name: 'Pablo Egaña', email: 'egana@mail.com', type: 'to' },
        { name: 'Juan Acuña', email: 'jacuna@mail.com', type: 'to' },
        { name: 'Bruno Magic', email: 'bruno@mail.com', type: 'bcc' },
        { name: 'Carla Cavada', email: 'carla@mail.com', type: 'bcc' }
      ])
    end

    it 'handles empty BCC header' do
      message = get_message('recipients/no_bcc')
      recipients = EmailParser.parse(message)[:recipients]
      expect(recipients).to eq([
        { name: 'Pablo Egaña', email: 'egana@mail.com', type: 'to' },
        { name: 'Juan Acuña', email: 'jacuna@mail.com', type: 'to' },
        { name: 'Andrés Muñoz', email: 'munoz@mail.com', type: 'cc' },
        { name: 'Antonio Antunez', email: 'antonio@mail.com', type: 'cc' }
      ])
    end

    it 'handles invalid headers' do
      message = get_message('recipients/invalid')
      recipients = EmailParser.parse(message)[:recipients]
      expect(recipients).to eq([])
    end
  end

  describe 'headers' do
    it 'includes all headers' do
      message = get_message('headers/headers')
      headers = EmailParser.parse(message)[:headers]
      expect(headers).to eq(
        'Message-Id' => ['<201105071003@limestone.edu>'],
        'Date' => ['Sat, 07 May 2011 04:52:00 -0400'],
        'Subject' => ['A non encoded subject'],
        'To' => ['everyone@limestone.edu'],
        'From' => ['"Juana Díaz" <juanadiaz@gmail.com>'],
        'Mime-Version' => ['1.0'],
        'Content-Type' => ['text/plain'],
        'X-Header' => ['a', 'b']
      )
    end
  end

  describe 'body_plain' do
    it 'correctly decodes the body' do
      message = get_message('body_plain/encoded_body')
      body = EmailParser.parse(message)[:body_plain]
      expect(body).to eq('Sample message with áccents')
    end

    it 'correctly decodes a quote-printable encoded body' do
      message = get_message('body_plain/encoded_body_qp')
      body = EmailParser.parse(message)[:body_plain]
      expect(body).to eq('evaluación')
    end

    it 'correctly decodes multipart messages' do
      message = get_message('body_plain/encoded_body_parts')
      body = EmailParser.parse(message)[:body_plain]
      expect(body).to eq('Multipart')
    end

    it 'only considers text/plain parts' do
      message = get_message('body_plain/encoded_body_unknown_mime')
      body = EmailParser.parse(message)[:body_plain]
      expect(body).to be(nil)
    end

    it 'returns nil if no text/plain is found in parts' do
      message = get_message('body_plain/encoded_body_parts_no_plain')
      body = EmailParser.parse(message)[:body_plain]
      expect(body).to be(nil)
    end

    it 'correctly decodes with malformed charset' do
      message = get_message('body_plain/encoded_body_malformed_charset')
      body = EmailParser.parse(message)[:body_plain]
      expect(body).to eq('Sample message with áccents')
    end
  end

  describe 'attachment' do
    it 'correctly extract the attachments' do
      message = get_message('attachments/attachment')
      attachments = EmailParser.parse(message)[:attachments]
      expect(attachments).to eq([
        { name: 'image001.jpg', size: 9, mime_type: 'image/jpeg' },
        { name: 'image002.jpg', size: 9, mime_type: 'image/jpeg' },
        { name: 'image003.jpg', size: 9, mime_type: 'image/jpeg' }
      ])
    end
  end

  describe 'subscription' do
    it 'identifies subscription emails' do
      message = get_message('subscription/subscription')
      is_subscription = EmailParser.parse(message)[:is_subscription]
      expect(is_subscription).to be(true)
    end

    it 'identifies no subscription emails' do
      message = get_message('subscription/no_subscription')
      is_subscription = EmailParser.parse(message)[:is_subscription]
      expect(is_subscription).to be(false)
    end
  end

  describe 'forward' do
    it 'detects forwarded messages from subject' do
      message = get_message('forward/subject_forward')
      is_forwarded = EmailParser.parse(message)[:is_forwarded]
      expect(is_forwarded).to be(true)
    end

    it 'detects forwarded messages from body' do
      message = get_message('forward/body')
      is_forwarded = EmailParser.parse(message)[:is_forwarded]
      expect(is_forwarded).to be(true)
    end

    it 'returns false for not forwarded messages' do
      message = get_message('forward/not_forward')
      is_forwarded = EmailParser.parse(message)[:is_forwarded]
      expect(is_forwarded).to be(false)
    end
  end

  describe 'stripped_text' do
    it 'correctly extracts the new text' do
      message = get_message('stripped_text/stripped_text')
      text = EmailParser.parse(message)[:stripped_text]
      expect(text).to eq(
        "This is a sample message\nin two lines\n\nSome more text")
    end
  end

  describe 'stripped subject' do
    it 'correctly removes email patterns from the subject' do
      message = get_message('stripped_subject/subject')
      subject = EmailParser.parse(message)[:stripped_subject]
      expect(subject).to eq(
        'Dieses Email ist weitergeleitet')
    end
  end

  describe 'bugs' do
    it 'correctly decodes emails with invalid byte sequences' do
      message = get_message('bugs/invalid_byte_sequence')
      parsed_message = JSON.parse(
        EmailParser.parse(message).to_json, symbolize_names: true)

      expect(parsed_message).to include(
        is_forwarded: false,
        attachments: [
          { name: 'image001.jpg', mime_type: 'image/jpeg', size: 0 },
          { name: 'INVITACIO�N.pdf', mime_type: 'application/pdf', size: 0 },
          { name: 'Inscripci�n.docx', mime_type: 'application/docx', size: 0 }
        ],
        subject: 'Investigaci�n sobre'
      )
    end
  end
end
