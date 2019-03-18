module EmailParser
  module ReplyPatterns
    # Patterns extracted from
    # https://transvision.mozfr.org/api/v1/entity/aurora/?id=mail/chrome/messenger/messengercompose/composeMsgs.properties:mailnews.reply_header_originalmessage
    REPLY_HEADER_PATTERNS = [
      # af:
      'Oorspronklike boodskap',
      # ar:
      'الرسالة الأصليَّة',
      # ast:
      'Mensaxe orixinal',
      # be:
      'Зыходны ліст',
      # bg:
      'Оригинално писмо',
      # bn-BD:
      'মূল বার্তা',
      # bn-IN:
      'Original Message',
      # br:
      'Kemennadenn orinel',
      # ca:
      'Missatge original',
      # cs:
      'Původní zpráva',
      # cy:
      'Neges Wreiddiol',
      # da:
      'Oprindelig meddelelse',
      # de:
      'Original-Nachricht',
      # dsb:
      'Originalna powěsć',
      # el:
      'Αρχικό μήνυμα',
      # en-GB:
      'Original Message',
      # en-US:
      'Original Message',
      # en-ZA:
      'Original Message',
      # es-AR:
      'Mensaje original',
      # es-ES:
      'Mensaje original',
      # et:
      'Algne kiri',
      # eu:
      'Jatorrizko mezua',
      # fa:
      'Original Message',
      # fi:
      'Alkuperäinen viesti / Orig.Msg.',
      'Alkuperäinen viesti',
      # fr:
      'Message original',
      # fy-NL:
      'Oarspronklik berjocht',
      # ga-IE:
      'Teachtaireacht Bhunaidh',
      # gd:
      'An teachdaireachd thùsail',
      # gl:
      'Mensaxe orixinal',
      # gu-IN:
      'મૂળ સંદેશો',
      # he:
      'הודעה מקורית',
      # hi-IN:
      'मूल संदेश',
      # hr:
      'Izvorna poruka',
      # hsb:
      'Originalna powěsć',
      # hu:
      'Eredeti üzenet',
      # hy-AM:
      'Օրիգինալ նամակը',
      # id:
      'Pesan Asli',
      # is:
      'Upprunalegur póstur',
      # it:
      'Messaggio originale',
      # ja:
      'Original Message',
      # ja-JP-mac:
      'Original Message',
      # ka:
      'საწყისი წერილი',
      # km:
      'Original Message',
      # ko:
      '원본 메시지',
      # lt:
      'Originalus laiškas',
      # mk:
      'Оригинална порака',
      # nb-NO:
      'Opprinnelig melding',
      # nl:
      'Oorspronkelijk bericht',
      # nn-NO:
      'Opphavleg melding',
      # pa-IN:
      'Original Message',
      # pl:
      'Treść oryginalnej wiadomości',
      # pt-BR:
      'Mensagem original',
      # pt-PT:
      'Mensagem original',
      # rm:
      'Messadi original',
      # ro:
      'Mesajul original',
      # ru:
      'Исходное сообщение',
      # si:
      'මුල් ලිපිය',
      # sk:
      'Pôvodná správa --- Original Message',
      'Pôvodná správa',
      # sl:
      'Izvirno sporočilo',
      # sq:
      'Mesazhi Origjinal',
      # sv-SE:
      'Ursprungligt meddelande',
      # tr:
      'Özgün İleti',
      # uk:
      'Початкове повідомлення',
      # vi:
      'Thư Gốc',
      # xh:
      'Umyalezo Wakuqala',
      # zh-CN:
      '原始消息',
      # zh-TW:
      '原始郵件',
      # Extra patterns
      # English
      'Original Appointment',
      # German
      'Ursprüngliche Mitteilung',
      'Ursprüngliche Nachricht',
    ].freeze

    REPLY_HEADER_RE = Regexp.new(
      '^---+ ?(' + REPLY_HEADER_PATTERNS.uniq.join('|') + ') ?---+$',
      Regexp::IGNORECASE
    )

    # Patterns taken from
    # https://transvision.mozfr.org/api/v1/entity/aurora/?id=mail/chrome/messenger/messengercompose/composeMsgs.properties:mailnews.reply_header_authorwrotesingle
    # https://transvision.mozfr.org/api/v1/entity/aurora/?id=mail/chrome/messenger/messengercompose/composeMsgs.properties:mailnews.reply_header_authorwroteondate
    # https://transvision.mozfr.org/api/v1/entity/aurora/?id=mail/chrome/messenger/messengercompose/composeMsgs.properties:mailnews.reply_header_ondateauthorwrote
    REPLY_WROTE_PATTERNS = [
      # Authorwrotesingle
      # ar:
      'كتب .*:',
      # ast:
      '.* escribió:',
      # be:
      '.* напісаў:',
      # bg:
      '.* написа:',
      # br:
      'Skrivet eo bet gant .* :',
      # ca:
      '.* ha escrit:',
      # cs:
      '.* napsal(a):',
      # cy:
      'Ysgrifennodd .*:',
      # da:
      '.* skrev:',
      # de:
      '.* schrieb:',
      # dsb:
      '.* jo napisał:',
      # el:
      'ο/η %s έγραψε',
      # en-GB:
      '.* wrote:',
      # en-US:
      '.* wrote:',
      # es-AR:
      '.* escribió:',
      # es-ES:
      '.* escribió:',
      # et:
      '.* kirjutas:',
      # eu:
      '.*k idatzi zuen:',
      # fi:
      '.* kirjoitti:',
      # fr:
      '.* a écrit :',
      # fy-NL:
      '.* skreau:',
      # ga-IE:
      'Scríobh .*:',
      # gd:
      'Sgrìobh .* na leanas:',
      # gl:
      '.* escribiu:',
      # hr:
      '.* je napisao/la:',
      # hsb:
      '.* napisa:',
      # hu:
      '.* írta:',
      # hy-AM:
      '.*-ը գրել է.',
      # is:
      '.* skrifaði:',
      # it:
      '.* ha scritto:',
      # ja:
      '.* wrote:',
      # ja-JP-mac:
      '.* wrote:',
      # km:
      '.* បាន​សរសេរ៖',
      # ko:
      '%s 이(가) 쓴 글',
      # lt:
      '.* rašė:',
      # nb-NO:
      'skrev .*:',
      # nl:
      '.* schreef:',
      # nn-NO:
      '.* skreiv:',
      # pl:
      '.* pisze:',
      # pt-BR:
      '.* escreveu:',
      # pt-PT:
      '.* escreveu:',
      # rm:
      '.* ha scrit:',
      # ro:
      '.* a scris:',
      # ru:
      '.* пишет:',
      # sk:
      '.* napísal(a):',
      # sl:
      '.* je napisal(a):',
      # sq:
      '.* shkroi:',
      # sv-SE:
      '.* skrev:',
      # tr:
      '.* yazdı:',
      # uk:
      '.* wrote:',
      # xh:
      '.* wrote:',
      # zh-CN:
      '.* 写道:',
      # zh-TW:
      '.* 寫道:',

      # Authorwroteondate
      # ar:
      'كتب .* على .* ‫.*:',
      # ast:
      '.* escribió\'l .* a les .*:',
      # be:
      '.* напісаў .* у .*:',
      # bg:
      '.* написа на .* в .*:',
      # br:
      'D\'an/ar .* .* eo bet skrivet gant .* :',
      # ca:
      '.* ha escrit el .* a les .*:',
      # cs:
      '.* napsal(a) dne .* v .*:',
      # cy:
      'Ysgrifennodd .* ar .* .*:',
      # da:
      '.* skrev den .* kl. .*:',
      # de:
      '.* schrieb am .* um .*:',
      # dsb:
      '.* jo .* .* napisał:',
      # el:
      '.* wrote on .* .*:',
      # en-GB:
      '.* wrote on .* .*:',
      # en-US:
      '.* wrote on .* .*:',
      # es-AR:
      '.* escribió el .* a las .*:',
      # es-ES:
      '.* escribió el .* a las .*:',
      # et:
      '.* kirjutas .* .*:',
      # eu:
      '.* igorleak .* .*(e)an idatzi zuen:',
      # fi:
      '.* kirjoitti .* .*:',
      # fr:
      '.* a écrit le .* .* :',
      # fy-NL:
      '.* skreau op .* om .*:',
      # ga-IE:
      'Scríobh .* ar .* .*:',
      # gd:
      'Sgrìobh .* na leanas .* aig .*:',
      # gl:
      '.* escribiu o .* ás .*:',
      # hr:
      '.* napisao je .* u .*:',
      # hsb:
      '.* .* .* napisa:',
      # hu:
      '.* írta .* .* dátummal:',
      # hy-AM:
      '.*-ը գրել է .* .*-ին.',
      # is:
      '.* skrifaði þann .* .*:',
      # it:
      '.* ha scritto il .* alle .*:',
      # ja:
      '.* wrote on .* .*:',
      # ja-JP-mac:
      '.* wrote on .* .*:',
      # km:
      '.* បាន​សរសេរ​នៅ​លើ .* .* ៖',
      # ko:
      '.* 이(가) .* .* 에 쓴 글:',
      # lt:
      '.* rašė .* .*:',
      # nb-NO:
      '.* skrev den .* .*:',
      # nl:
      '.* schreef op .* om .*:',
      # nn-NO:
      '.* skreiv den .* .*:',
      # pl:
      'W dniu .* o .*, .* pisze:',
      # pt-BR:
      '.* escreveu em .* .*:',
      # pt-PT:
      '.* escreveu às .* de .*:',
      # rm:
      '.* ha scrit ils .* a las .*:',
      # ro:
      '.* a scris la .* .*:',
      # ru:
      '.* пишет .* .*:',
      # sk:
      '.* napísal(a) dňa .* o .*:',
      # sl:
      '.* je .* ob .* napisal:',
      # sq:
      '.* shkroi më .*, .*:',
      # sv-SE:
      '.* skrev den .* kl. .*:',
      # tr:
      '.*, .* .* tarihinde yazdı:',
      # uk:
      '.* wrote on .* .*:',
      # xh:
      '.* wrote on .* .*:',
      # zh-CN:
      '.* 写于 .* .*:',
      # zh-TW:
      '.* 於 .* .* 寫道:',

      # Ondateauthorwrote
      # ar:
      'على .* ‫.*، كتب .*:',
      # ast:
      'El .* a les .*, .* escribió:',
      # be:
      '.* у .* .* напісаў:',
      # bg:
      'На .* в .*, .* написа:',
      # br:
      'D\'an/ar .* .* eo bet skrivet gant .* :',
      # ca:
      'El .* a les .*, .* ha escrit:',
      # cs:
      'Dne .* v .* .* napsal(a):',
      # cy:
      'Ar .* .*, ysgrifennodd .*:',
      # da:
      'Den .* kl. .* skrev .*:',
      # de:
      'Am .* um .* schrieb .*:',
      # dsb:
      '.* .* jo .* napisał:',
      # el:
      'On .* .*, .* wrote:',
      # en-GB:
      'On .* .*, .* wrote:',
      # en-US:
      'On .* .*, .* wrote:',
      # es-AR:
      'El .* a las .*, .* escribió:',
      # es-ES:
      'El .* a las .*, .* escribió:',
      # et:
      '.* .* .* kirjutas:',
      # eu:
      '.* .*(e)an, .* igorleak idatzi zuen:',
      # fi:
      '.*, .*, .* kirjoitti:',
      # fr:
      'Le .* .*, .* a écrit :',
      # fy-NL:
      'Op .* om .*, skreau .*:',
      # ga-IE:
      'Ar .* .*, scríobh .*:',
      # gd:
      'Sgrìobh .* na leanas .* aig .*:',
      # gl:
      'O .* ás .*, .* escribiu:',
      # hr:
      '.* u .*, .* je napisao/la:',
      # hsb:
      '.* .* .* napisa:',
      # hu:
      '.* .* keltezéssel, .* írta:',
      # hy-AM:
      '.* .*-ին .*ը գրել է.',
      # is:
      'Þann .* .*, skrifaði .*:',
      # it:
      'Il .* .*, .* ha scritto:',
      # ja:
      'On .* .*, .* wrote:',
      # ja-JP-mac:
      'On .* .*, .* wrote:',
      # km:
      'នៅ​លើ .* .*, .* បាន​សរសេរ៖',
      # ko:
      '.* .*에 .* 이(가) 쓴 글:',
      # lt:
      '.* .*, .* rašė:',
      # nb-NO:
      'Den .* .*, skrev .*:',
      # nl:
      'Op .* om .* schreef .*:',
      # nn-NO:
      'Den .* .*, .* skreiv:',
      # pl:
      'W dniu .* o .*, .* pisze:',
      # pt-BR:
      'Em .* .*, .* escreveu:',
      # pt-PT:
      'Às .* de .*, .* escreveu:',
      # rm:
      'Ils .* a las .* ha .* scrit:',
      # ro:
      'La .* .*, .* a scris:',
      # ru:
      '.* .*, .* пишет:',
      # sk:
      'Dňa .* o .* .* napísal(a):',
      # sl:
      '.* je .* ob .* napisal:',
      # sq:
      'Më .*, .*, .* shkroi:',
      # sv-SE:
      'Den .* kl. .*, skrev .*:',
      # tr:
      '.* .* tarihinde .* yazdı:',
      # uk:
      'On .* .*, .* wrote:',
      # xh:
      'On .* .*, .* wrote:',
      # zh-CN:
      '在 .* .*, .* 写道:',
      # zh-TW:
      '.* 於 .* .* 寫道:',

      # Extra patterns
      # English
      'On .* wrote:$',
      '.* wrote:$',
      '.* writes:$',
      '.* wrote on .*:',
      'On .* via IntroLogic .*',

      # Spanish
      'El .* escribió:',
      '.* escribió:',
      '.* ha escrito:',
      # German
      '.* shrieb:',
      'Am .* schrieb .*:',
      'Am .* hat .* geschrieben:',
      # French
      'Le .* écrit :',
      # Korean
      '.* 오후 .*에 .*님이 작성:',
      # General
      '.* GMT.* <.+@.+>:',
    ].freeze

    REPLY_WROTE_RE = Regexp.new(
      '^(' + REPLY_WROTE_PATTERNS.uniq.join('|') + ')$',
      Regexp::IGNORECASE
    )

    # List of reply subjects taken from
    # https://en.wikipedia.org/wiki/List_of_email_subject_abbreviations#Abbreviations_in_other_languages
    REPLY_SUBJECTS = [
      # English
      'RE',
      # Chinese (Traditional)
      '關於',
      # Chinese (Simplified)
      '关于',
      # Danish
      'SV',
      'Svar',
      # Dutch
      'Antw',
      'Antwoord',
      # Finnish
      'VS',
      'Vastaus',
      # French
      'RE',
      'Réponse',
      # German
      'AW',
      'Antwort',
      # Greek
      'ΑΠ',
      'Απάντηση',
      'ΣΧΕΤ',
      'Σχετικό',
      # Hebrew
      'תגובה',
      'הועבר',
      # Hungarian
      'Vá',
      'Válasz',
      # Italian
      'R',
      'RIF',
      'Riferimento',
      # Icelandic
      'SV',
      'Svara',
      # Indonesian
      'BLS',
      'Balas',
      # Norwegian
      'SV',
      'Svar',
      # Swedish
      'SV',
      'Svar',
      # Spanish
      'RE',
      'Responder',
      # Portuguese
      'RE',
      'Resposta',
      # Polish
      'Odp',
      'Odpowiedź',
      # Turkish
      'YNT',
      'Yanıt',
    ].freeze

    REPLY_SUBJECT_RE = Regexp.new(
      '^(' + REPLY_SUBJECTS.uniq.join('|') + '): ',
      Regexp::IGNORECASE
    )
  end
end
