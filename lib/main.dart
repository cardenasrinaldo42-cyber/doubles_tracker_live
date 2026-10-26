import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';

void main() { runApp(const DoublesApp()); }

class DoublesApp extends StatelessWidget {
  const DoublesApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trinidad Doubles Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.red),
      home: const MapScreen(),
    );
  }
}

class Vendor {
  String name; String area; LatLng pos; bool open;
  String price; String hours; String phone; String special;
  List<String> dishes; List<String> images; List<File> localPhotos;
  Vendor(this.name, this.area, this.pos, this.open,
      {this.price = "\$6", this.hours = "6am-2pm", this.phone = "N/A", this.special = "Doubles", List<String>? dishes, List<String>? images})
      : dishes = dishes ?? [special],
        images = images ?? ["https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=600&q=80"],
        localPhotos = [];
}

class MapScreen extends StatefulWidget { const MapScreen({super.key}); @override State<MapScreen> createState() => _MapScreenState(); }

class _MapScreenState extends State<MapScreen> {
  final MapController mapCtrl = MapController();
  double currentZoom = 11;

  final List<Vendor> vendors = [
    Vendor("Singh's Hot Tasty Doubles & Pies", 'Freeport', const LatLng(10.4604, -61.40995), true, price: "\$6", hours: "6am-9pm", phone: "+18687980202", special: "Singh's Special", dishes: ["Singh's Doubles - \$6", "Aloo Pie - \$5", "Pepper Roti - \$8"], images: ["https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=600&q=80"]),
    Vendor("Sauce Doubles", 'Curepe', const LatLng(10.648724, -61.409479), true, price: "\$6", hours: "5:30pm-11:45pm", phone: "+18687553288", special: "Famous Curepe Doubles", dishes: ["Sauce Doubles - \$6", "Aloo Pie - \$5"], images: ["https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=600&q=80"]),
    Vendor("Ali's Doubles", 'Vistabella', const LatLng(10.286758, -61.463511), true, price: "\$6", hours: "7am-10:30am", phone: "+18687501927", special: "Since 1938", dishes: ["Ali's Doubles - \$6", "Aloo Pie"], images: ["https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=600&q=80"]),
  ];

  void addVendor(Vendor v) { setState(() { vendors.add(v); }); }

  Widget buildPin(Vendor v) {
    Color pinColor = v.name.contains("Singh") ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    String label = v.name.contains("Singh") ? "SINGH'S" : v.name.contains("Sauce") ? "SAUCE" : "ALI'S";
    double size = (currentZoom * 3.6).clamp(16, 50);

    if (currentZoom < 8.5) {
      return Container(
        width: 14, height: 14,
        decoration: BoxDecoration(color: pinColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5)),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.location_pin, size: size + 10, color: pinColor),
            Positioned(
              top: size * 0.18,
              child: Container(
                width: size * 0.52, height: size * 0.52,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Center(child: Text("🫓", style: TextStyle(fontSize: size * 0.32))),
              ),
            ),
          ],
        ),
        if (currentZoom > 10.5)
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)),
            child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: pinColor)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trinidad Doubles Tracker", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFFC62828),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFC62828)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VendorPinLoginScreen(vendors: vendors, mapCtrl: mapCtrl, onUpdated: () => setState(() {})))),
              icon: const Icon(Icons.lock, size: 18),
              label: const Text('Vendors', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: FlutterMap(
        mapController: mapCtrl,
        options: MapOptions(
          initialCenter: const LatLng(10.45, -61.43),
          initialZoom: 11,
          onPositionChanged: (pos, _) { setState(() { currentZoom = pos.zoom; }); },
        ),
        children: [
          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.trinidad_doubles'),
          MarkerLayer(
            markers: vendors.map((v) {
              return Marker(
                point: v.pos,
                width: 90, height: 90,
                child: GestureDetector(onTap: () => showVendor(v), child: buildPin(v)),
              );
            }).toList(),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(heroTag: 'add', backgroundColor: const Color(0xFFC62828), foregroundColor: Colors.white, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddVendorMapScreen(onAdd: addVendor))), child: const Icon(Icons.add_location_alt)),
          const SizedBox(height: 12),
          FloatingActionButton(heroTag: 'loc', backgroundColor: Colors.white, foregroundColor: const Color(0xFFC62828), onPressed: () => mapCtrl.move(const LatLng(10.45, -61.43), 11), child: const Icon(Icons.my_location)),
        ],
      ),
    );
  }

  void showVendor(Vendor v) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75, maxChildSize: 0.9, minChildSize: 0.5, expand: false,
        builder: (_, ctrl) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: ctrl,
            children: [
              Row(children: [
                Icon(Icons.verified, color: v.open ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
                const SizedBox(width: 8),
                Expanded(child: Text(v.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: v.open ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(12)), child: Text(v.open ? "OPEN" : "CLOSED", style: TextStyle(color: v.open ? const Color(0xFF2E7D32) : const Color(0xFFC62828), fontWeight: FontWeight.bold, fontSize: 11))),
              ]),
              const SizedBox(height: 8),
              Text("${v.area} • ${v.price} • ${v.hours} • ${v.phone}", style: const TextStyle(color: Colors.black54, fontSize: 13)),
              const SizedBox(height: 12),
              if (v.localPhotos.isNotEmpty) ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.file(v.localPhotos.last, height: 240, width: double.infinity, fit: BoxFit.cover)) else ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.network(v.images.first, height: 240, width: double.infinity, fit: BoxFit.cover)),
              const SizedBox(height: 12),
              Text("Special: ${v.special}", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Full Menu:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ...v.dishes.map((d) => ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: const Icon(Icons.restaurant, size: 16, color: Color(0xFFC62828)), title: Text(d))),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, padding: const EdgeInsets.all(16)), onPressed: () async { final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${v.pos.latitude},${v.pos.longitude}'); if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication); }, icon: const Icon(Icons.directions), label: Text('Navigate to ${v.area}'))),
            ],
          ),
        ),
      ),
    );
  }
}

class AddVendorMapScreen extends StatefulWidget {
  final Function(Vendor) onAdd; const AddVendorMapScreen({super.key, required this.onAdd});
  @override State<AddVendorMapScreen> createState() => _AddVendorMapScreenState();
}

class _AddVendorMapScreenState extends State<AddVendorMapScreen> {
  LatLng? picked;
  final nameCtrl = TextEditingController(); final areaCtrl = TextEditingController(); final priceCtrl = TextEditingController(text: "\$6");
  final hoursCtrl = TextEditingController(text: "6am-2pm"); final phoneCtrl = TextEditingController(); final specialCtrl = TextEditingController();
  final dishCtrl = TextEditingController(); List<String> tempDishes = [];

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Vendor - Tap Map', style: TextStyle(color: Colors.white, fontSize: 16)), backgroundColor: const Color(0xFFC62828), iconTheme: const IconThemeData(color: Colors.white)),
      body: Column(children: [
        Expanded(flex: 2, child: FlutterMap(options: MapOptions(initialCenter: const LatLng(10.45, -61.43), initialZoom: 11, onTap: (_, p) => setState(() => picked = p)), children: [TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.trinidad_doubles'), if (picked != null) MarkerLayer(markers: [Marker(point: picked!, width: 60, height: 60, child: const Icon(Icons.location_pin, color: Colors.red, size: 50))])])),
        Expanded(flex: 3, child: Padding(padding: const EdgeInsets.all(12), child: ListView(children: [
          if (picked == null) const Text('📍 Tap map to drop pin', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)) else Text('✅ Picked: ${picked!.latitude.toStringAsFixed(5)}, ${picked!.longitude.toStringAsFixed(5)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Stall Name *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 8),
          Row(children: [Expanded(child: TextField(controller: areaCtrl, decoration: InputDecoration(labelText: 'Area', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))), const SizedBox(width: 8), Expanded(child: TextField(controller: priceCtrl, decoration: InputDecoration(labelText: 'Price', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))))]),
          const SizedBox(height: 8),
          Row(children: [Expanded(child: TextField(controller: hoursCtrl, decoration: InputDecoration(labelText: 'Hours', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))), const SizedBox(width: 8), Expanded(child: TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: 'Phone', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))))]),
          const SizedBox(height: 8),
          TextField(controller: specialCtrl, decoration: InputDecoration(labelText: 'Special / Signature', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 12),
          const Text('Dishes:', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(children: [Expanded(child: TextField(controller: dishCtrl, decoration: const InputDecoration(hintText: 'e.g. Aloo Pie - \$5'))), IconButton(icon: const Icon(Icons.add_circle, color: Color(0xFF2E7D32)), onPressed: () { if (dishCtrl.text.isNotEmpty) setState(() { tempDishes.add(dishCtrl.text); dishCtrl.clear(); }); })]),
          ...tempDishes.map((d) => Chip(label: Text(d), deleteIcon: const Icon(Icons.close, size: 16), onDeleted: () => setState(() => tempDishes.remove(d)))),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, padding: const EdgeInsets.all(16)), onPressed: () { if (picked != null && nameCtrl.text.isNotEmpty) { final newV = Vendor(nameCtrl.text, areaCtrl.text.isEmpty ? 'New Area' : areaCtrl.text, picked!, true, price: priceCtrl.text, hours: hoursCtrl.text, phone: phoneCtrl.text, special: specialCtrl.text.isEmpty ? nameCtrl.text : specialCtrl.text, dishes: tempDishes.isEmpty ? [nameCtrl.text] : tempDishes); widget.onAdd(newV); Navigator.pop(context); } }, child: const Text('ADD VENDOR', style: TextStyle(fontWeight: FontWeight.bold)))),
        ]))),
      ]),
    );
  }
}

class VendorPinLoginScreen extends StatefulWidget {
  final List<Vendor> vendors; final MapController mapCtrl; final VoidCallback onUpdated;
  const VendorPinLoginScreen({super.key, required this.vendors, required this.mapCtrl, required this.onUpdated});
  @override State<VendorPinLoginScreen> createState() => _VendorPinLoginScreenState();
}

class _VendorPinLoginScreenState extends State<VendorPinLoginScreen> {
  final pinCtrl = TextEditingController(); String error = "";
  void checkPin() { if (pinCtrl.text == "1234") Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => VendorDashboard(vendors: widget.vendors, mapCtrl: widget.mapCtrl, onUpdated: widget.onUpdated))); else setState(() => error = "Wrong PIN. Try 1234"); }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Login', style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFFC62828)),
      body: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.lock, size: 70, color: Color(0xFFC62828)), const SizedBox(height: 16),
        const Text('Vendor Secure Login', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const Text('Enter 4-digit PIN to manage stalls', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 30),
        TextField(controller: pinCtrl, keyboardType: TextInputType.number, maxLength: 4, obscureText: true, textAlign: TextAlign.center, style: const TextStyle(fontSize: 32, letterSpacing: 20, fontWeight: FontWeight.bold), decoration: InputDecoration(hintText: "••••", labelText: "Type 4-digit PIN below", counterText: "", errorText: error.isEmpty ? null : error, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))), onSubmitted: (_) => checkPin()),
        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Forgot PIN?'), content: const Text('Demo PIN is: 1234'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))])), child: const Text('Forgot PIN?', style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.bold)))),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828), foregroundColor: Colors.white, padding: const EdgeInsets.all(16)), onPressed: checkPin, child: const Text('UNLOCK', style: TextStyle(fontWeight: FontWeight.bold)))),
      ])),
    );
  }
}

class VendorDashboard extends StatefulWidget {
  final List<Vendor> vendors; final MapController mapCtrl; final VoidCallback onUpdated;
  const VendorDashboard({super.key, required this.vendors, required this.mapCtrl, required this.onUpdated});
  @override State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Dashboard - Edit All', style: TextStyle(color: Colors.white, fontSize: 16)), backgroundColor: const Color(0xFF2E7D32)),
      body: ListView.builder(itemCount: widget.vendors.length, itemBuilder: (_, i) { final v = widget.vendors[i]; return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), child: ListTile(title: Text(v.name, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text("${v.area} • ${v.price} • ${v.hours}\n${v.dishes.length} dishes • ${v.phone}"), isThreeLine: true, trailing: const Icon(Icons.edit, color: Color(0xFFC62828)), onTap: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => VendorEditScreen(vendor: v))); setState(() {}); widget.onUpdated(); })); }),
    );
  }
}

class VendorEditScreen extends StatefulWidget {
  final Vendor vendor; const VendorEditScreen({super.key, required this.vendor});
  @override State<VendorEditScreen> createState() => _VendorEditScreenState();
}

class _VendorEditScreenState extends State<VendorEditScreen> {
  late TextEditingController nameCtrl, areaCtrl, priceCtrl, hoursCtrl, phoneCtrl, specialCtrl, newDishCtrl;
  late bool isOpen; final ImagePicker picker = ImagePicker();
  @override void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.vendor.name); areaCtrl = TextEditingController(text: widget.vendor.area);
    priceCtrl = TextEditingController(text: widget.vendor.price); hoursCtrl = TextEditingController(text: widget.vendor.hours);
    phoneCtrl = TextEditingController(text: widget.vendor.phone); specialCtrl = TextEditingController(text: widget.vendor.special);
    newDishCtrl = TextEditingController(); isOpen = widget.vendor.open;
  }
  Future<void> pickGallery() async { final XFile? p = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75); if (p != null) setState(() => widget.vendor.localPhotos.add(File(p.path))); }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit ${widget.vendor.name}', style: const TextStyle(color: Colors.white, fontSize: 14)), backgroundColor: const Color(0xFFC62828)),
      body: Padding(padding: const EdgeInsets.all(14), child: ListView(children: [
        const Text('VENDOR DETAILS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFC62828))), const SizedBox(height: 12),
        TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Stall Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), onChanged: (v) => widget.vendor.name = v),
        const SizedBox(height: 8),
        Row(children: [Expanded(child: TextField(controller: areaCtrl, decoration: InputDecoration(labelText: 'Area', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), onChanged: (v) => widget.vendor.area = v)), const SizedBox(width: 8), Expanded(child: TextField(controller: priceCtrl, decoration: InputDecoration(labelText: 'Price', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), onChanged: (v) => widget.vendor.price = v))]),
        const SizedBox(height: 8),
        Row(children: [Expanded(child: TextField(controller: hoursCtrl, decoration: InputDecoration(labelText: 'Hours', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), onChanged: (v) => widget.vendor.hours = v)), const SizedBox(width: 8), Expanded(child: TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: 'Phone', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), onChanged: (v) => widget.vendor.phone = v))]),
        const SizedBox(height: 8),
        TextField(controller: specialCtrl, decoration: InputDecoration(labelText: 'Special', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), onChanged: (v) => widget.vendor.special = v),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Shop Open?', style: TextStyle(fontWeight: FontWeight.bold)), Switch(value: isOpen, activeColor: const Color(0xFF2E7D32), onChanged: (val) => setState(() { isOpen = val; widget.vendor.open = val; }))]),
        const Divider(height: 28),
        const Text('MENU / DISHES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ...widget.vendor.dishes.asMap().entries.map((e) => Card(child: ListTile(dense: true, title: Text(e.value), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => widget.vendor.dishes.removeAt(e.key)))))),
        Row(children: [Expanded(child: TextField(controller: newDishCtrl, decoration: InputDecoration(hintText: "Add dish", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))), const SizedBox(width: 8), ElevatedButton(onPressed: () { if (newDishCtrl.text.trim().isNotEmpty) { setState(() { widget.vendor.dishes.add(newDishCtrl.text.trim()); newDishCtrl.clear(); }); } }, child: const Icon(Icons.add))]),
        const Divider(height: 28),
        const Text('STALL PHOTOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 8),
        if (widget.vendor.localPhotos.isNotEmpty) GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8), itemCount: widget.vendor.localPhotos.length, itemBuilder: (_, i) => Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(widget.vendor.localPhotos[i], fit: BoxFit.cover, width: double.infinity, height: double.infinity)), Positioned(top: 4, right: 4, child: CircleAvatar(backgroundColor: Colors.red, radius: 14, child: IconButton(padding: EdgeInsets.zero, icon: const Icon(Icons.close, size: 14, color: Colors.white), onPressed: () => setState(() => widget.vendor.localPhotos.removeAt(i)))))])),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828), foregroundColor: Colors.white), onPressed: pickGallery, icon: const Icon(Icons.photo_library), label: const Text('ADD PHOTO FROM GALLERY'))),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, padding: const EdgeInsets.all(16)), onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.vendor.name} saved!'))); }, child: const Text('SAVE ALL CHANGES', style: TextStyle(fontWeight: FontWeight.bold)))),
      ])),
    );
  }
}