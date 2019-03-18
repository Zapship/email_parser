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

  describe 'body_html' do
    it 'correctly decodes the body' do
      message = get_message('body_html/gmail_encoded_body_parts')
      body_html = EmailParser.parse(message)[:body_html]
      expect(body_html).to eq("<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\" \"http://www.w3.org/TR/REC-html40/loose.dtd\">\n<html><body>\n<div dir=\"ltr\">Awesome, thank you so much! <br><div><br></div>\n<div>Was able to install and get in. thx - will give it a whirl.</div>\n</div>\n<br><div class=\"gmail_quote\">\n<div dir=\"ltr\" class=\"gmail_attr\">On Wed, Feb 27, 2019 at 3:01 PM Amit Koren &lt;<a href=\"mailto:amit@intrologic.com\">amit@intrologic.com</a>&gt; wrote:<br>\n</div>\n<blockquote class=\"gmail_quote\" style=\"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex\">\n<div dir=\"ltr\">Hey Alok,<div><br></div>\n<div>Fantastic, and apologies for the delay.  I just sent you an invitation to download the app (it came via TestFlight).  The link in that email will allow you to download the app, and from there you can sign in with the same email address you used to sign up.  Let me know if you encounter any issues or have any questions about the app.</div>\n<div><br></div>\n<div>Best,</div>\n<div>Amit<br clear=\"all\"><div><div dir=\"ltr\" class=\"gmail-m_-717428531104908585gmail_signature\"><div dir=\"ltr\">\n<div style=\"font-family:Calibri,sans-serif;font-size:14px\">\n<span style=\"color:rgb(0,0,0);font-family:Verdana,Arial,Helvetica,sans-serif;font-size:11px\">_________________________</span><span style=\"color:rgb(0,0,0);font-family:Verdana,Arial,Helvetica,sans-serif;font-size:11px\">____</span><br>\n</div>\n<div style=\"font-family:Calibri,sans-serif;font-size:14px\">\n<span style=\"font-weight:bold;font-family:Verdana,Arial,Helvetica,sans-serif;font-size:11px;color:rgb(103,103,112)\">Amit Koren |</span><span style=\"font-weight:bold;color:rgb(0,0,0);font-family:Verdana,Arial,Helvetica,sans-serif;font-size:11px\"> </span><span style=\"font-weight:bold;font-family:Verdana,Arial,Helvetica,sans-serif;font-size:11px\"><font color=\"#0000ff\">IntroLogic</font></span><span style=\"font-weight:bold;font-family:Verdana,Arial,Helvetica,sans-serif;font-size:11px;color:rgb(51,197,103)\"> </span>\n</div>\n<div style=\"font-size:12.8px;font-family:Calibri,sans-serif\">\n<span style=\"color:rgb(103,103,112);font-size:small\">617-320-4073</span><br>\n</div>\n<div style=\"font-size:12.8px\"><font face=\"Calibri, sans-serif\"><a href=\"http://www.intrologic.com/\" target=\"_blank\">www.intrologic.com</a></font></div>\n<div style=\"font-size:12.8px\"><span style=\"color:rgb(103,103,112);font-family:Calibri,sans-serif;font-size:small\">Menlo Park</span></div>\n</div></div></div>\n<br>\n</div>\n</div>\n<br><div class=\"gmail_quote\">\n<div dir=\"ltr\" class=\"gmail_attr\">On Sun, Feb 24, 2019 at 3:58 PM Alok Nandan &lt;<a href=\"mailto:alok@emergent.vc\" target=\"_blank\">alok@emergent.vc</a>&gt; wrote:<br>\n</div>\n<blockquote class=\"gmail_quote\" style=\"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex\">\n<div dir=\"ltr\">Thanks Amit. Nice to e-meet you too. <div><br></div>\n<div>I have done the steps 1 &amp; 2. </div>\n</div>\n<br><div class=\"gmail_quote\">\n<div dir=\"ltr\" class=\"gmail_attr\">On Sat, Feb 23, 2019 at 10:52 AM Amit Koren &lt;<a href=\"mailto:amit@intrologic.com\" target=\"_blank\">amit@intrologic.com</a>&gt; wrote:<br>\n</div>\n<blockquote class=\"gmail_quote\" style=\"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex\">\n<div dir=\"ltr\">Hi Alok,<div><br></div>\n<div>Nice to e-meet you.  Bhupesh mentioned to me that you were interested in joining the beta of our app.  I'm excited to get you on board and get your feedback.  It's currently available only via TestFlight (Apple's app testing framework), so here are the steps to get started:</div>\n<div><ol>\n<li>Sign up on our website <a href=\"https://intrologic.com/start?invitation_code=5c42a783585b4ad8b250cdc994a06073\" target=\"_blank\">here</a>.  Make sure to connect your email account and optionally upload an export of your LinkedIn contacts<br>\n</li>\n<li>Download TestFlight from the app store<br>\n</li>\n<li>Let me know once you complete those two steps, and I'll send you an invitation code (from TestFlight) to download the app.<br>\n</li>\n</ol></div>\n<div>Looking forward to your feedback!</div>\n<div><br></div>\n<div>Regards,</div>\n<div>Amit</div>\n<div><br></div>\n<div><div><div><div dir=\"ltr\" class=\"gmail-m_-717428531104908585gmail-m_-480547900614623239gmail-m_2206114303149594800gmail_signature\"><div dir=\"ltr\">\n<div style=\"font-family:Calibri,sans-serif;font-size:14px\">\n<span style=\"color:rgb(0,0,0);font-family:Verdana,Arial,Helvetica,sans-serif;font-size:11px\">_________________________</span><span style=\"color:rgb(0,0,0);font-family:Verdana,Arial,Helvetica,sans-serif;font-size:11px\">____</span><br>\n</div>\n<div style=\"font-family:Calibri,sans-serif;font-size:14px\">\n<span style=\"font-weight:bold;font-family:Verdana,Arial,Helvetica,sans-serif;font-size:11px;color:rgb(103,103,112)\">Amit Koren |</span><span style=\"font-weight:bold;color:rgb(0,0,0);font-family:Verdana,Arial,Helvetica,sans-serif;font-size:11px\"> </span><span style=\"font-weight:bold;font-family:Verdana,Arial,Helvetica,sans-serif;font-size:11px\"><font color=\"#0000ff\">IntroLogic</font></span><span style=\"font-weight:bold;font-family:Verdana,Arial,Helvetica,sans-serif;font-size:11px;color:rgb(51,197,103)\"> </span>\n</div>\n<div style=\"font-size:12.8px;font-family:Calibri,sans-serif\">\n<span style=\"color:rgb(103,103,112);font-size:small\">617-320-4073</span><br>\n</div>\n<div style=\"font-size:12.8px\"><font face=\"Calibri, sans-serif\"><a href=\"http://www.intrologic.com/\" target=\"_blank\">www.intrologic.com</a></font></div>\n<div style=\"font-size:12.8px\"><span style=\"color:rgb(103,103,112);font-family:Calibri,sans-serif;font-size:small\">Menlo Park</span></div>\n</div></div></div></div></div>\n</div>\r\n</blockquote>\n</div>\r\n</blockquote>\n</div>\r\n</blockquote>\n</div>\r\n</body></html>\n")
    end
  end

  describe 'stripped_html' do
    it 'correctly decodes and strips the body of gmail messages' do
      message = get_message('body_html/gmail_encoded_body_parts')
      stripped_html = EmailParser.parse(message)[:stripped_html]
      expect(stripped_html).to eq("<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\" \"http://www.w3.org/TR/REC-html40/loose.dtd\">\n<html><body>\n<div dir=\"ltr\">Awesome, thank you so much! <br><div><br></div>\n<div>Was able to install and get in. thx - will give it a whirl.</div>\n</div>\n<br>\r\n</body></html>\n")
    end

    it 'correctly decodes and strips the signature of gmail messages' do
      message = get_message('body_html/gmail_encoded_with_signature')
      stripped_html = EmailParser.parse(message)[:stripped_html]
      expect(stripped_html).to eq("<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\" \"http://www.w3.org/TR/REC-html40/loose.dtd\">\n<html><body>\n<div dir=\"ltr\">Bhupesh -- Thanks for the intro to Amit. <div><br></div>\n<div>Amit -- Thanks for sending the link to get connected to Charles. I really appreciate it.</div>\n<div><br></div>\n<div>Best,<br>Sandeep<br clear=\"all\"><div></div>\n<br>\n</div>\n</div>\n<br>\r\n</body></html>\n")
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
    it 'does not discard lines starting with asterisks' do
      message = get_message('stripped_text/text_between_asterisks')
      text = EmailParser.parse(message)[:stripped_text]
      expect(text).to eq(
        "*Please reply to me with the percentage you'd like taken out of each\n\
paycheck starting in 2017 by December 15th.\n\nSome more text")
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

  describe 'subject_has_emojis' do
    it 'returns false when no emojis' do
      message = get_message('subject_has_emojis/no_emojis')
      emojis = EmailParser.parse(message)[:subject_has_emojis]
      expect(emojis).to be(false)
    end

    it 'returns false when text emojis' do
      message = get_message('subject_has_emojis/text_emojis')
      emojis = EmailParser.parse(message)[:subject_has_emojis]
      expect(emojis).to be(false)
    end

    it 'returns true when emojis' do
      message = get_message('subject_has_emojis/many_emojis')
      emojis = EmailParser.parse(message)[:subject_has_emojis]
      expect(emojis).to be(true)
    end
  end

  describe 'email signature' do
    it 'correctly parses a signature after double dash' do
      message = get_message('email_signature/simple_signature')
      signature = EmailParser.parse(message)[:email_signature]
      expect(signature).to eq('John')
    end
    it 'correctly parses a signature after a closing' do
      message = get_message('email_signature/long_name_signature')
      signature = EmailParser.parse(message)[:email_signature]
      expect(signature).to eq('Aloysius Paulus van Gaal')
    end
    it 'correctly parses a signature after a closing in the same line' do
      message = get_message('email_signature/closing_no_newline_signature')
      signature = EmailParser.parse(message)[:email_signature]
      expect(signature).to eq('John')
    end
    it 'correctly parses a signature w/closing when before a phone signature' do
      message = get_message('email_signature/long_signature_with_phone_sig')
      signature = EmailParser.parse(message)[:email_signature]
      expect(signature).to eq("John Doe\n"\
                              "Sudo Technologies Inc\n"\
                              "Software Development\n"\
                              "530 Oak Grove Ave\n"\
                              "Suite 207\n"\
                              "Menlo Park, CA 94025\n"\
                              "Phone: 111-222-7890\n"\
                              "john@domain.com\n"\
                              'www.domain.com')
    end
    # TODO(RA, 2016-08-24): Use ML tools to detect signature lines
    xit 'correctly parses a long signature without closing' do
      message = get_message('email_signature/long_signature_no_closing')
      signature = EmailParser.parse(message)[:email_signature]
      expect(signature).to eq("John Doe\n"\
                              "Sudo Technologies Inc\n"\
                              "Software Development\n"\
                              "530 Oak Grove Ave\n"\
                              "Suite 207\n"\
                              "Menlo Park, CA 94025\n"\
                              "Phone: 111-222-7890\n"\
                              "john@domain.com\n"\
                              'www.domain.com')
    end
    xit 'correctly parses a long signature with footer without closing' do
      message = get_message('email_signature/long_signature_with_footer_no_closing')
      signature = EmailParser.parse(message)[:email_signature]
      expect(signature).to eq("John Doe\n"\
                              "Sudo Technologies Inc\n"\
                              "Software Development\n"\
                              "530 Oak Grove Ave\n"\
                              "Suite 207\n"\
                              "Menlo Park, CA 94025\n"\
                              "Phone: 111-222-7890\n"\
                              "john@domain.com\n"\
                              'www.domain.com')
    end
    xit 'correctly parses a pipe separated signature without closing' do
      message = get_message('email_signature/pipe_signature_no_closing')
      signature = EmailParser.parse(message)[:email_signature]
      expect(signature).to eq("John Doe\n"\
                              "Sudo Technologies Inc\n"\
                              "Software Development\n"\
                              "530 Oak Grove Ave\n"\
                              "Suite 207\n"\
                              "Menlo Park, CA 94025\n"\
                              "Phone: 111-222-7890\n"\
                              "john@domain.com\n"\
                              'www.domain.com')
    end
  end

  describe 'bugs' do
    xit 'correctly decodes emails with invalid byte sequences' do
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
