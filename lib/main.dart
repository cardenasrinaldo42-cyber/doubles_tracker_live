import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(DoublesApp());

class DoublesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doubles Tracker Live',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.orange),
      home: MapScreen(),
    );
  }
}

class Vendor {
  String name; LatLng pos; String status; DateTime lastUpdate;
  Vendor(this.name, this.pos, this.status, this.lastUpdate);
}

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Singh's and Dons - put your real GPS here
  List<Vendor> vendors = [
    Vendor("Singh's Doubles", LatLng(10.5365, -61.3112), "YES OPEN", DateTime.now()),
    Vendor("Dons Doubles", LatLng(10.5350, -61.3100), "SOLD OUT", DateTime.now()),
  ];

  void showVendorCard(Vendor v) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            SizedBox(height: 16),
            Text(v.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: v.status == "YES OPEN"? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(v.status, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 12),
            Text("Last update: ${v.lastUpdate.hour}:${v.lastUpdate.minute.toString().padLeft(2,'0')}", style: TextStyle(color: Colors.grey)),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: () => setState(() { v.status = "YES OPEN"; v.lastUpdate = DateTime.now(); Navigator.pop(context); }), child: Text("Mark YES OPEN"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white))),
                SizedBox(width: 10),
                Expanded(child: ElevatedButton(onPressed: () => setState(() { v.status = "SOLD OUT"; v.lastUpdate = DateTime.now(); Navigator.pop(context); }), child: Text("Mark SOLD OUT"), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white))),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Doubles Tracker Live - San Fernando"), backgroundColor: Colors.orange),
      body: FlutterMap(
        options: MapOptions(initialCenter: LatLng(10.536, -61.311), initialZoom: 15),
        children: [
          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
          MarkerLayer(
            markers: vendors.map((v) => Marker(
              point: v.pos,
              width: 80, height: 80,
              child: GestureDetector(
                onTap: () => showVendorCard(v),
                child: Column(children: [
                  Icon(Icons.location_pin, size: 45, color: v.status == "YES OPEN"? Colors.green : Colors.red),
                  Container(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all()), child: Text(v.name.split(" ")[0], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                ]),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}