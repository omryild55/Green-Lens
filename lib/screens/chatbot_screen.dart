import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:greenlens/main.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _mesajKontrolcu = TextEditingController();
  final List<Map<String, dynamic>> _mesajlar = [];
  bool _isBotLoading = false;
  final ScrollController _scrollController = ScrollController();
  
  // : Dil değişimini takip edebilmek için son bilinen dili hafızada tutuyoruz!
  String _sonBilinenDil = '';

  @override
  void initState() {
    super.initState();
    _sonBilinenDil = dilNotifier.value.languageCode;
    _karsilamaMesajiEkle(_sonBilinenDil);
  }

  // : Dile göre karşılama mesajını listeye ekleyen temiz fonksiyon!
  void _karsilamaMesajiEkle(String dilKodu) {
    String acilisMesaji = 'GreenLens Botanik Asistan Sistemine Hoş Geldiniz. 🌿\n\nEndemik floradan ev bitkilerine kadar; bitki bakımı, sulama periyotları, toprak analizi ve bitki hastalıkları konusunda teknik bilgi ve destek alabilirsiniz.\n\nLütfen danışmak istediğiniz soruyu yazınız.';
    
    if (dilKodu == 'en') {
      acilisMesaji = 'Welcome to GreenLens Botanical Assistant System. 🌿\n\nFrom endemic flora to house plants; you can receive technical information and support regarding plant care, watering periods, soil analysis, and plant diseases.\n\nPlease type your question.';
    } else if (dilKodu == 'de') {
      acilisMesaji = 'Willkommen beim botanischen Assistenzsystem GreenLens. 🌿\n\nVon der endemischen Flora bis zu Zimmerpflanzen; Sie erhalten technische Informationen und Unterstützung zu Pflanzenpflege, Bewässerungsperioden, Bodenanalyse und Pflanzenkrankheiten.\n\nBitte geben Sie Ihre Frage ein.';
    }

    _mesajlar.add({
      'isUser': false,
      'text': acilisMesaji,
      'time': _guncelSaatGetir(),
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _guncelSaatGetir() {
    final simdi = DateTime.now();
    return '${simdi.hour.toString().padLeft(2, '0')}:${simdi.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _mesajGonder(String gonderilenMetin) async {
    if (gonderilenMetin.trim().isEmpty) return;

    _mesajKontrolcu.clear();
    HapticFeedback.lightImpact();

    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 100));
    
    setState(() {
      _mesajlar.add({
        'isUser': true,
        'text': gonderilenMetin,
        'time': _guncelSaatGetir(),
      });
      _isBotLoading = true;
    });
    _scrollToBottom();

    try {
      final String apiAnahtari = "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";
      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

      final String aktifDilKodu = dilNotifier.value.languageCode;
	  
      String sistemTalimati = "";

      if (aktifDilKodu == 'en') {
        sistemTalimati = "You are the AI-powered expert nature and botanical assistant of the GreenLens mobile application. Your sole duty is to deal with real plant science (botany), plant care, diseases, and soil analysis. You must answer completely in English. If the user writes daily words like 'umbrella' or 'money', and if these words match a real plant species in the botanical world (e.g., Umbrella plant, Money plant), explain only that real plant and its care guidelines in an academic, formal, and emojified bulleted format. However, if the user asks a completely off-topic question that has no connection to botany and natural science, such as computers, transistors, software, politics, history, economics, or automobiles, absolutely do not give made-up answers and do not pivot the topic; reply word-for-word with exactly this response: 'I am an AI-powered nature and plant assistant, I cannot answer questions outside of botanical science.'";
      } else if (aktifDilKodu == 'de') {
        sistemTalimati = "Sie sind der KI-gestützte Experte für Natur und Botanik der mobilen GreenLens-App. Ihre einzige Aufgabe ist es, sich mit realer Pflanzenwissenschaft (Botanik), Pflanzenpflege, Krankheiten und Bodenanalyse zu befassen. Sie müssen vollständig auf Deutsch antworten. Wenn der Benutzer alltägliche Wörter wie 'Regenschirm' oder 'Geld' schreibt und diese Wörter mit einer realen Pflanzenart in der botanischen Welt übereinstimmen (z. B. Regenschirmpflanze, Geldbaum), erklären Sie nur diese reale Pflanze und ihre Pflegerichtlinien in einem akademischen, formellen und mit Emojis versehenen Aufzählungsformat. Wenn der Benutzer jedoch eine völlig themenfremde Frage stellt, die keinen Bezug zur Botanik und Naturwissenschaft hat, wie Computer, Transistoren, Software, Politik, Geschichte, Wirtschaft oder Automobile, geben Sie absolut keine erfundenen Antworten und weichen Sie nicht vom Thema ab; antworten Sie wortwörtlich mit genau dieser Antwort: 'Ich bin ein KI-gestützter Natur- und Pflanzenassistent, Fragen außerhalb der botanischen Wissenschaft kann ich nicht beantworten.'";
      } else {
        sistemTalimati = "Sen GreenLens mobil uygulamasının yapay zeka destekli uzman doğa ve botanik asistanısın. Görevin sadece gerçek bitki bilimi (botanik), bitki bakımı, hastalıklar ve toprak analizi ile ilgilenmektir. Tamamen Türkçe cevap vereceksin. Kullanıcı sana 'şemsiye' veya 'para' gibi günlük kelimeler yazdığında, eğer bu kelimeler botanik dünyasında gerçekten var olan bir bitki türüyle (Örn: Şemsiye bitkisi, Para çiçeği) doğrudan eşleşiyorsa, sadece o gerçek bitkiyi ve bakım yönergelerini akademik, resmi ve emojili maddeler halinde açıkla. Ancak kullanıcı sana bilgisayar, transistör, yazılım, siyaset, tarih, ekonomi veya otomobil gibi botanik ve doğa bilimiyle hiçbir bağı olmayan tamamen konu dışı bir soru sorarsa, kesinlikle uydurma cevaplar verme ve konuyu başka bir şeye bağlama; kelimesi kelimesine tam olarak şu resmi ve net cevabı ver: 'Ben yapay zeka destekli bir doğa ve bitki asistanıyım, botanik bilimi dışındaki sorularınıza cevap veremem.'";
      }

      final Map<String, dynamic> istekObjesi = {
        "model": "llama-3.1-8b-instant",
        "messages": [
          {"role": "system", "content": sistemTalimati},
          {"role": "user", "content": gonderilenMetin}
        ],
        "temperature": 0.2,
        "max_tokens": 1024
      };

      final yanit = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiAnahtari'
        },
        body: jsonEncode(istekObjesi),
      ).timeout(const Duration(seconds: 20));

      if (yanit.statusCode == 200) {
        final String utf8Body = utf8.decode(yanit.bodyBytes);
        final veri = jsonDecode(utf8Body);
        
        String botCevabi = veri['choices'][0]['message']['content'].toString();
        botCevabi = botCevabi.replaceAll(RegExp(r'\n\s*\n'), '\n\n');
        
        setState(() {
          _mesajlar.add({
            'isUser': false,
            'text': botCevabi.trim(),
            'time': _guncelSaatGetir(),
          });
        });
        _scrollToBottom();
      } else {
        setState(() {
          _mesajlar.add({
            'isUser': false,
            'text': '⚠️ Sistem entegrasyonunda teknik bir hata oluştu. Lütfen isteğinizi tekrar iletiniz.\n\nHata Kodu: ${yanit.statusCode}',
            'time': _guncelSaatGetir(),
          });
        });
      }
    } catch (e) {
      print("Hata: $e");
      setState(() {
        _mesajlar.add({
          'isUser': false,
          'text': '⚠️ Sunucu bağlantısı sağlanamadı. Lütfen internet bağlantınızı kontrol ediniz.\n\nHata: $e',
          'time': _guncelSaatGetir(),
        });
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBotLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String aktifDilKodu = dilNotifier.value.languageCode;

    // : Dil değiştiği an eski sohbeti temizleyen ve yeni dilde başlatan sihirli kontrol!
    if (_sonBilinenDil != aktifDilKodu) {
      _sonBilinenDil = aktifDilKodu;
      _mesajlar.clear(); // Eski dildeki tüm sohbeti uçuruyoruz!
      _karsilamaMesajiEkle(aktifDilKodu); // Yeni dildeki karşılama mesajını basıyoruz!
    }

    // : Input alanındaki ipucu yazısını da seçili dile göre dinamik yapıyoruz!
    String ipucuYazisi = 'Sorunuzu yazınız (Orkide bakimi, sulama, gubre vb.)...';
    if (aktifDilKodu == 'en') {
      ipucuYazisi = 'Type your question (Orchid care, watering, fertilizer etc.)...';
    } else if (aktifDilKodu == 'de') {
      ipucuYazisi = 'Geben Sie Ihre Frage ein (Orchideenpflege, Bewässerung usw.)...';
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
          (route) => false,
        );
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.green),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainNavigation()),
                (route) => false,
              );
            },
          ),
          title: const Row(
            children: [
              Icon(Icons.smart_toy_rounded, color: Colors.green),
              SizedBox(width: 10),
              Text('GreenBot Asistan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _mesajlar.length,
                itemBuilder: (context, index) {
                  final mesaj = _mesajlar[index];
                  final isUser = mesaj['isUser'] as bool;

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isUser
                            ? Colors.green
                            : (isDark ? const Color(0xFF2D2D2D) : Colors.green.shade50),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(isUser ? 20 : 0),
                          bottomRight: Radius.circular(isUser ? 0 : 20),
                        ),
                      ),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mesaj['text'] as String,
                            style: TextStyle(
                              color: isUser ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              mesaj['time'] as String,
                              style: TextStyle(
                                color: isUser ? Colors.white70 : Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isBotLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      aktifDilKodu == 'en' 
                          ? 'Analyzing and preparing response...' 
                          : (aktifDilKodu == 'de' ? 'Analysieren und Antwort vorbereiten...' : 'Analiz ediliyor ve yanıt hazırlanıyor...'),
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            _buildInputArea(isDark, ipucuYazisi),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDark, String ipucuYazisi) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2D2D2D) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextFormField(
                controller: _mesajKontrolcu,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: ipucuYazisi, // : İşte o dile göre güncellenen kutsal ipucu!
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: InputBorder.none,
                ),
                onFieldSubmitted: (val) => _mesajGonder(val),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _mesajGonder(_mesajKontrolcu.text),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}