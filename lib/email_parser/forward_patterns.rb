module EmailParser
  module ForwardPatterns
    # Patterns extracted from
    # https://transvision.mozfr.org/api/v1/entity/aurora/?id=mail/chrome/messenger/messengercompose/composeMsgs.properties:mailnews.forward_header_originalmessage
    FORWARD_HEADER_PATTERNS = [
      # ar:
      'رسالة ممرّرة',
      # ast:
      'Mensaxe reunviáu',
      # be:
      'Накіраваны ліст',
      # bg:
      'Оригинално писмо',
      # br:
      'Kemennadenn orinel',
      # ca:
      'Missatge reenviat',
      # cs:
      'Přeposlaná zpráva',
      # cy:
      'Neges Wreiddiol',
      # da:
      'Videresendt meddelelse',
      # de:
      'Weitergeleitete Nachricht',
      # dsb:
      'Dalej pósrědnjona powěsć',
      # el:
      'Forwarded Message',
      # en-GB:
      'Forwarded Message',
      # en-US:
      'Forwarded Message',
      # es-AR:
      'Mensaje reenviado',
      # es-ES:
      'Mensaje reenviado',
      # et:
      'Edastatud kiri',
      # eu:
      'Birbidalitako mezua',
      # fi:
      'Välitetty viesti / Fwd.Msg',
      'Välitetty viesti',
      # fr:
      'Message transféré',
      # fy-NL:
      'Trochstjoerd berjocht',
      # ga-IE:
      'Teachtaireacht Ar Aghaidh',
      # gd:
      'An teachdaireachd a tha ’ga shìneadh air adhart',
      # gl:
      'Mensaxe reenviada',
      # hr:
      'Proslijeđena poruka',
      # hsb:
      'Dale sposrědkowana powěsć',
      # hu:
      'Továbbított üzenet',
      # hy-AM:
      'Փոխանցվող նամակը',
      # is:
      'Áframsendur póstur',
      # it:
      'Messaggio Inoltrato',
      # ja:
      'Forwarded Message',
      # ja-JP-mac:
      'Forwarded Message',
      # km:
      'បាន​បញ្ជូន​សារ​បន្ត',
      # ko:
      '전달된 메시지',
      # lt:
      'Persiųstas laiškas',
      # nb-NO:
      'Videresendt melding',
      # nl:
      'Doorgestuurd bericht',
      # nn-NO:
      'Vidaresend melding',
      # pl:
      'Treść przekazanej wiadomości',
      # pt-BR:
      'Mensagem encaminhada',
      # pt-PT:
      'Mensagem reencaminhada',
      # rm:
      'Messadi renvià',
      # ro:
      'Mesajul original',
      # ru:
      'Перенаправленное сообщение',
      # sk:
      'Preposlaná správa --- Forwarded Message',
      'Preposlaná správa',
      # sl:
      'Posredovano sporočilo',
      # sq:
      'Mesazhi i Përcjellë',
      # sv-SE:
      'Vidarebefordrat meddelande',
      # tr:
      'İletilmiş İleti',
      # uk:
      'Forwarded Message',
      # xh:
      'Forwarded Message',
      # zh-CN:
      '转发的消息',
      # zh-TW:
      '轉寄郵件',
      # Extra headers found
      # Spanish
      'Mensaje reenviado de .*',
      'Mensaje remitido',
      'Mensaje enviado',
    ]

    FORWARD_BODY_START_PATTERNS = [
      # English
      'Begin forwarded message:',
      # Spanish
      'Inicio del mensaje reenviado:',
      # German
      'Anfang der weitergeleiteten E-Mail:',
      'Anfang der weitergeleiteten Nachricht:',
      # Italian
      'Inizio messaggio inoltrato:',
    ]

    FORWARD_BODY_RE = Regexp.new(
      '^(' + FORWARD_BODY_START_PATTERNS.uniq.join('|') + '|' \
        '---+ ?(' + FORWARD_HEADER_PATTERNS.uniq.join('|') + ') ?---+' \
      ')$',
      Regexp::IGNORECASE)

    # List of forwarded subjects taken from
    # https://en.wikipedia.org/wiki/List_of_email_subject_abbreviations#Abbreviations_in_other_languages
    FORWARD_SUBJECTS = [
      # English
      'Fw',
      'Fwd',
      'Forwarded',
      # Chinese (Traditional)
      '轉寄',
      # Chinese (Simplified)
      '转发',
      # Danish
      'VS',
      'Videresendt',
      # Dutch
      'Doorst',
      'Doorsturen',
      # Finnish
      'VL',
      'Välitetty',
      # French
      'TR',
      'Transfert',
      # German
      'WG',
      'Weitergeleitet',
      # Greek
      'ΠΡΘ',
      'Προωθημένο',
      # Hebrew
      'הועבר',
      # Hungarian
      'Továbbítás',
      # Italian
      'I',
      'Inoltro',
      # Icelandic
      'FS',
      'Framsenda',
      # Indonesian
      'TRS',
      'Terusan',
      # Norwegian
      'VS',
      'Videresendt',
      # Swedish
      'VB',
      'Vidarebefordrat',
      # Spanish
      'RV',
      'Reenviar',
      # Portuguese
      'ENC',
      'Encaminhado',
      # Polish
      'PD',
      'Podaj dalej',
      # Turkish
      'İLT',
      'İlet',
    ]

    FORWARD_SUBJECT_RE = Regexp.new(
      '^(' + FORWARD_SUBJECTS.uniq.join('|') + '): ',
      Regexp::IGNORECASE)
  end
end
