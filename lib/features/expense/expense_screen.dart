import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uku_app/data/uku_store.dart';
import 'package:uku_app/features/ai/ai_screen.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key, required this.store});
  final UkuStore store;

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _location = TextEditingController();
  final _purpose = TextEditingController();
  int _step = 0;
  String? category;
  String? method;
  String inputMode = 'Manual';
  DateTime selectedDate = DateTime.now();
  final _imagePicker = ImagePicker();
  Uint8List? _billImage;
  bool _showBillCamera = false;

  static const inputModes = ['Manual', 'Foto Bill', 'AIku'];

  static const categories = [
    (name: 'Makanan & Minuman', asset: 'assets/icons/Restaurant.png'),
    (name: 'Hiburan', asset: 'assets/icons/3D Glasses.png'),
    (name: 'Pendidikan', asset: 'assets/icons/Online Group Studying.png'),
    (name: 'Donasi', asset: 'assets/icons/Charity.png'),
    (name: 'Pakaian', asset: 'assets/icons/Clothes.png'),
    (name: 'Kebutuhan Rumah', asset: 'assets/icons/House.png'),
    (name: 'Transportasi', asset: 'assets/icons/Public Transportation.png'),
    (name: 'Kecantikan', asset: 'assets/icons/Beautician.png'),
    (name: 'Liburan', asset: 'assets/icons/Airplane Landing.png'),
    (name: 'Kesehatan', asset: 'assets/icons/Hospital Room.png'),
    (name: 'Belanja', asset: 'assets/icons/Shopping Bag.png'),
    (name: 'Hewan Peliharaan', asset: 'assets/icons/Pet Commands Summon.png'),
  ];
  final methods = const ['Tunai', 'Bank', 'Qris'];

  @override
  void dispose() {
    _amount.dispose();
    _location.dispose();
    _purpose.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFFA9D2B))),
        child: child!,
      ),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  void _save() {
    final selectedCategory = category;
    final selectedMethod = method;
    if (selectedCategory == null || !_formKey.currentState!.validate()) return;
    if (selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih metode pembayaran')),
      );
      return;
    }
    final amount =
        double.tryParse(_amount.text.replaceAll('.', '').replaceAll(',', '')) ??
            0;
    widget.store.addExpense(Expense(
      category: selectedCategory,
      amount: amount,
      date: selectedDate,
      location: _location.text.trim(),
      purpose: _purpose.text.trim(),
      method: selectedMethod,
    ));
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengeluaran berhasil dicatat')));
    _amount.clear();
    _location.clear();
    _purpose.clear();
    setState(() {
      selectedDate = DateTime.now();
      category = null;
      method = null;
      _step = 0;
      _billImage = null;
      _showBillCamera = false;
    });
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop();
  }

  void _selectCategory(String value) {
    setState(() {
      category = value;
      _showBillCamera = inputMode == 'Foto Bill';
    });
    if (inputMode == 'Foto Bill') return;
    Future<void>.delayed(const Duration(milliseconds: 280), () {
      if (!mounted || category != value || _step != 0) return;
      setState(() => _step = 1);
    });
  }

  Future<void> _pickBillImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() => _billImage = bytes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka gambar')),
      );
    }
  }

  void _continueFromBillCamera() {
    setState(() {
      _showBillCamera = false;
      _step = 1;
    });
  }

  Widget _cameraActionButton({
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFFF8800),
          foregroundColor: Colors.white,
        ),
        icon: Icon(icon, size: 23),
      ),
    );
  }

  Widget _buildBillCamera() {
    return SafeArea(
      child: Container(
        color: const Color(0xFF424242),
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Catat Pengeluaran foto bill',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ColoredBox(
                color: Colors.black,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_billImage != null)
                      Image.memory(_billImage!, fit: BoxFit.contain),
                    Positioned(
                      top: 12,
                      left: 8,
                      child: IconButton(
                        tooltip: 'Kembali ke kategori',
                        onPressed: () => setState(() {
                          _showBillCamera = false;
                          _billImage = null;
                        }),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFFFF8800),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _cameraActionButton(
                            tooltip: 'Pilih foto dari galeri',
                            icon: Icons.image_outlined,
                            onPressed: () =>
                                _pickBillImage(ImageSource.gallery),
                          ),
                          const SizedBox(width: 20),
                          _cameraActionButton(
                            tooltip: 'Ambil foto',
                            icon: Icons.camera_alt_outlined,
                            onPressed: () => _pickBillImage(ImageSource.camera),
                          ),
                          const SizedBox(width: 20),
                          _cameraActionButton(
                            tooltip: 'Lanjutkan',
                            icon: Icons.check,
                            onPressed: _continueFromBillCamera,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectMethod(String value) {
    setState(() => method = value);
  }

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black12)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black12)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFFA9D2B))),
      );

  Widget _buildInputModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          for (final mode in inputModes)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (mode == 'AIku') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AiScreen(store: widget.store),
                      ),
                    );
                    return;
                  }
                  setState(() => inputMode = mode);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: inputMode == mode
                        ? const Color(0xFFFF8800)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    mode,
                    style: TextStyle(
                      color: inputMode == mode
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showBillCamera) return _buildBillCamera();

    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            SizedBox(
              height: 100,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 12,
                    child: IconButton(
                      tooltip: 'Kembali',
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFFAAE36),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 58),
                      child: const Text(
                        'Catat Pengeluaran',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildInputModeSelector(),
            const SizedBox(height: 18),
            if (_step == 0) ...[
              const Align(
                alignment: Alignment.center,
                child: Text(
                  'Pilih jenis pengeluaran',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 7),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisExtent: 88,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 4,
                ),
                itemBuilder: (context, index) {
                  final item = categories[index];
                  final selected = category == item.name;
                  return Semantics(
                    button: true,
                    selected: selected,
                    label: item.name,
                    child: InkWell(
                      onTap: () => _selectCategory(item.name),
                      borderRadius: BorderRadius.circular(10),
                      child: Column(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFF9C846)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFFFAAE36)
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Image.asset(
                              item.asset,
                              width: 42,
                              height: 42,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, height: 1.1),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ] else ...[
              const Text('Jumlah',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 7),
              TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                decoration: _decoration('Rp 0'),
                validator: (value) {
                  final n = double.tryParse((value ?? '')
                          .replaceAll('.', '')
                          .replaceAll(',', '')) ??
                      0;
                  if (n <= 0) return 'Masukkan jumlah pengeluaran';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              const Text('Mau catat untuk kapan?',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 7),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: _decoration('Pilih tanggal'),
                  child: Text(
                      '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}'),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Lokasi pengeluaran',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 7),
              TextFormField(
                  controller: _location,
                  decoration: _decoration('Contoh: Mall / Kampus')),
              const SizedBox(height: 14),
              const Text('Pengeluaran untuk apa?',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 7),
              TextFormField(
                  controller: _purpose,
                  decoration: _decoration('Untuk apa pengeluaran ini?')),
              const SizedBox(height: 14),
              const Text('Jenis Pengeluaran',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 7),
              InputDecorator(
                decoration: _decoration(''),
                child: Text(category ?? ''),
              ),
              const SizedBox(height: 14),
              const Text('Metode',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 7),
              Row(
                  children: methods
                      .map((item) => Expanded(
                              child: Padding(
                            padding: const EdgeInsets.only(right: 7),
                            child: ChoiceChip(
                              label: SizedBox(
                                  width: double.infinity,
                                  child: Center(
                                      child: Text(item,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: method == item
                                                  ? Colors.white
                                                  : Colors.black)))),
                              selected: method == item,
                              selectedColor: const Color(0xFFFA9D2B),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.black12),
                              onSelected: (_) => _selectMethod(item),
                            ),
                          )))
                      .toList()),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFA9D2B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
