import 'package:flutter/material.dart';

import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/widgets/app_back_button.dart';

enum _AiMessageRole { user, ai }

class _AiMessage {
  const _AiMessage({required this.role, required this.text});

  final _AiMessageRole role;
  final String text;
}

class AiScreen extends StatefulWidget {
  const AiScreen({super.key, required this.store});

  final UkuStore store;

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final _aiInput = TextEditingController();
  bool _isAiReplying = false;
  String _selectedMode = 'AIKu';
  final _aiMessages = <_AiMessage>[
    _AiMessage(
      role: _AiMessageRole.ai,
      text:
          'Halo! Saya AIKu. Tulis pertanyaan tentang pengeluaranmu,\nseperti “Berapa total pengeluaran bulan ini?”',
    ),
  ];

  @override
  void dispose() {
    _aiInput.dispose();
    super.dispose();
  }

  String _buildAiResponse(String question) {
    final normalized = question.toLowerCase();
    if (normalized.contains('total') || normalized.contains('jumlah')) {
      return 'Total pengeluaranmu saat ini adalah ${rupiah(widget.store.totalExpense)}.\n\nKamu dapat mencatat pengeluaran baru dengan memilih mode Manual atau Foto Bill.';
    }
    if (normalized.contains('budget') || normalized.contains('sisa')) {
      return 'Sisa budgetmu saat ini adalah ${rupiah(widget.store.remainingBudget)}.\n\nJika anggaran habis, kita bisa bantu membuat rencana spending.';
    }
    if (normalized.contains('kategori') || normalized.contains('jenis')) {
      return 'Pengeluaranmu terbagi menjadi ${widget.store.categoryTotals().keys.join(', ')}.\n\nSaya juga bisa bantu menentukan kategori dari judul pengeluaranmu.';
    }
    return 'Saya siap membantu. Tulis pertanyaan tentang total pengeluaran, sisa budget, atau kategori pengeluaranmu.';
  }

  Future<void> _sendAiMessage() async {
    final question = _aiInput.text.trim();
    if (question.isEmpty || _isAiReplying) return;

    setState(() {
      _aiMessages.add(_AiMessage(role: _AiMessageRole.user, text: question));
      _aiInput.clear();
      _isAiReplying = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;
    setState(() {
      _aiMessages.add(
        _AiMessage(role: _AiMessageRole.ai, text: _buildAiResponse(question)),
      );
      _isAiReplying = false;
    });
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
          boxShadow: const [
            BoxShadow(
                color: Color(0x1F000000), blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 2),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Transform.translate(
                        offset: const Offset(-16, 0),
                        child: AppBackButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: const Text(
                          'Catat Pengeluaran',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1F000000),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        for (final mode in const [
                          'Manual',
                          'Foto Bill',
                          'AIKu'
                        ])
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setState(() => _selectedMode = mode),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                height: 42,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _selectedMode == mode
                                      ? const Color(0xFFFF8800)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Text(
                                  mode,
                                  style: TextStyle(
                                    color: _selectedMode == mode
                                        ? Colors.white
                                        : const Color(0xFFFF8800),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 7),
                          const Text(
                            'AIKu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            width: 38,
                            height: 38,
                            child: Image.asset(
                              'assets/icons/AI.png',
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  itemCount: _aiMessages.length + (_isAiReplying ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _aiMessages.length && _isAiReplying) {
                      return _buildTypingIndicator();
                    }

                    final message = _aiMessages[index];

                    return Align(
                      alignment: message.role == _AiMessageRole.user
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 330),
                        child: Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: message.role == _AiMessageRole.user
                                ? const Color(0xFFFAAE36)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: message.role == _AiMessageRole.ai
                                ? Border.all(color: Colors.black12)
                                : null,
                            boxShadow: message.role == _AiMessageRole.ai
                                ? const [
                                    BoxShadow(
                                      color: Color(0x1F000000),
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color: message.role == _AiMessageRole.user
                                  ? Colors.white
                                  : Colors.black87,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _aiInput,
                      onSubmitted: (_) => _sendAiMessage(),
                      decoration: InputDecoration(
                        hintText: 'Tulis pertanyaan...',
                        hintStyle: const TextStyle(color: Colors.black38),
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isAiReplying ? null : _sendAiMessage,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: const Color(0xFFFAAE36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
