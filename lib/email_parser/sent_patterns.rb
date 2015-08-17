module EmailParser
  module SentPatterns
    # Patterns extracted from
    # https://transvision.mozfr.org/api/v1/entity/aurora/?id=mail/chrome/messenger/messengercompose/composeMsgs.properties:mailnews.forward_header_originalmessage
    SENT_FROM_PATTERNS = [
      'Sent from .*',
      'Enviado desde .*',
      'Diese Nachricht wurde von meinem .* gesendet.',
      'Von meinem .* gesendet',
    ]

    SENT_FROM_RE = Regexp.new(
      '^(' + SENT_FROM_PATTERNS.uniq.join('|') + ')$',
      Regexp::IGNORECASE)
  end
end
