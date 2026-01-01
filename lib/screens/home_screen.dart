import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test/database_helper.dart';

class StationMemo {
  final int? id;
  final String station;
  final String memo;
  final String? imagePath;
  final double latitude;
  final double longitude;

  StationMemo({
    this.id,
    required this.station,
    required this.memo,
    this.imagePath,
    required this.latitude,
    required this.longitude,
  });

  factory StationMemo.fromMap(Map<String, dynamic> map) {
    return StationMemo(
      id: map['id'],
      station: map['station'],
      memo: map['memo'],
      imagePath: map['imagePath'],
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _stationController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  String _locationMessage = "緯度・軽度はまだ取得していません。";
  double _lat = 35.6812;
  double _lng = 139.7671;
  AppleMapController? _mapController;
  Set<Annotation> _annotations = {};

  List<StationMemo> _memoList = [];
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _refreshJourneys();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _locationMessage = "緯度: $_lat, 経度: $_lng";
      _lat = position.latitude;
      _lng = position.longitude;

      _annotations = {
        Annotation(
          annotationId: AnnotationId('current_location'),
          position: LatLng(_lat, _lng),
          infoWindow: const InfoWindow(title: '現在地', snippet: 'ここにいるよ！'),
        ),
      };
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(_lat, _lng)));
  }

  Future<void> _refreshJourneys() async {
    final data = await DatabaseHelper.instance.queryAllStations();
    setState(() {
      _memoList = data.map((item) => StationMemo.fromMap(item)).toList();
    });
  }

  void _updateMarkers() {
    setState(() {
      _annotations.clear();

      for (var memo in _memoList) {
        _annotations.add(
          Annotation(
            annotationId: AnnotationId(memo.id.toString()),
            position: LatLng(_lat, _lng),
            infoWindow: InfoWindow(title: memo.station, snippet: memo.memo),
          ),
        );
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _addStation() async {
    if (_stationController.text.isNotEmpty) {
      await DatabaseHelper.instance.insertStation({
        'station': _stationController.text,
        'memo': _memoController.text,
        'imagePath': _selectedImage?.path,
      });
      await _refreshJourneys();
      _updateMarkers();
    }
  }

  Future<void> _deleteStation(int id) async {
    await DatabaseHelper.instance.deleteStation(id);
    _refreshJourneys();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text(_locationMessage),
          ElevatedButton.icon(
            onPressed: _getCurrentLocation,
            icon: const Icon(Icons.location_on),
            label: const Text('現在地を取得'),
          ),
          TextField(
            controller: _stationController,
            decoration: const InputDecoration(labelText: '駅名を保存'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _memoController,
            decoration: const InputDecoration(labelText: 'メモを入力'),
            maxLines: 2,
          ),
          SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('画像を選択'),
              ),
              const SizedBox(width: 10),
              _selectedImage != null
                  ? SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                  : const Text('未選択'),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1A237E),
                foregroundColor: Colors.yellow,
              ),
              onPressed: _addStation,
              child: const Text('リストに追加'),
            ),
          ),
          const Divider(height: 40),

          Expanded(
            flex: 1,
            child: AppleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(_lat, _lng),
                zoom: 14.0,
              ),
              annotations: _annotations,
              myLocationEnabled: true,
              onMapCreated: (AppleMapController controller) {
                _mapController = controller;
              },
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            flex: 1,
            child: _memoList.isEmpty
                ? const Center(child: Text('まだメモがありません。'))
                : ListView.builder(
                    itemCount: _memoList.length,
                    itemBuilder: (context, index) {
                      final item = _memoList[index];
                      return Card(
                        child: ListTile(
                          leading: item.imagePath != null
                              ? Image.file(
                                  File(item.imagePath!),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.train),
                          title: Text(item.station),
                          subtitle: Text(item.memo),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteStation(item.id!),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stationController.dispose();
    _memoController.dispose();
    super.dispose();
  }
}
