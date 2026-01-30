import 'package:flutter/material.dart';

import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerPage extends StatefulWidget {
  final String? initialAddress;
  final double? initialLatitude;
  final double? initialLongitude;

  const LocationPickerPage({
    super.key,
    this.initialAddress,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> with AutomaticKeepAliveClientMixin {
  LatLng? _selectedLocation;
  final TextEditingController _addressController = TextEditingController();
  AMapController? _mapController;
  bool _isDisposed = false;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMap();
    });
  }

  Future<void> _initializeMap() async {
    _isInitialized = true;
    
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation = LatLng(widget.initialLatitude!, widget.initialLongitude!);
    } else {
      await _getCurrentLocationOptimized();
    }

    if (widget.initialAddress != null && widget.initialAddress!.isNotEmpty) {
      _addressController.text = widget.initialAddress!;
    } else if (_selectedLocation != null) {
      _addressController.text =
          '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}';
    }
  }

  Future<void> _getCurrentLocation() async {
    await _getCurrentLocationOptimized();
  }

  Future<void> _getCurrentLocationOptimized() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          _selectedLocation = LatLng(lastPosition.latitude, lastPosition.longitude);
        } else {
          _selectedLocation = const LatLng(28.66999503, 115.82297033);
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _selectedLocation = const LatLng(28.66999503, 115.82297033);
        return;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 3),
        );
      } catch (e) {
        position ??= await Geolocator.getLastKnownPosition();
      }

      position ??= Position(
        latitude: 39.9042,
        longitude: 116.4074,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

      if (_isDisposed) return;

      _selectedLocation = LatLng(position.latitude, position.longitude);

      if (_mapController != null) {
        _mapController!.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _selectedLocation!,
              zoom: 15,
            ),
          ),
        );
      }
    } catch (e) {
      _selectedLocation = const LatLng(28.66999503, 115.82297033);
    }
  }

  void _onMapCreated(AMapController controller) {
    _mapController = controller;
    
    if (_isInitialized && _selectedLocation != null) {
      _mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _selectedLocation!,
            zoom: 15,
          ),
        ),
      );
    }
  }

  void _onCameraMoveEnd(CameraPosition position) {
    if (!mounted || _isDisposed) return;
    _selectedLocation = position.target;
    
    String currentText = _addressController.text.trim();
    if (currentText.isEmpty ||
        RegExp(r'^-?\d+(\.\d+)?,\s*-?\d+(\.\d+)?$').hasMatch(currentText)) {
      _addressController.text =
          '${position.target.latitude.toStringAsFixed(6)}, ${position.target.longitude.toStringAsFixed(6)}';
    }
  }

  void _confirmSelection() {
    if (_selectedLocation != null) {
      String address = _addressController.text.trim();
      
      if (address.isEmpty) {
        address = '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}';
      }
      
      Navigator.pop(context, {
        'address': address,
        'latitude': _selectedLocation!.latitude.toDouble(),
        'longitude': _selectedLocation!.longitude.toDouble(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择位置'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _confirmSelection,
            child: const Text('确认'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                AMapWidget(
                  privacyStatement: const AMapPrivacyStatement(
                    hasContains: true,
                    hasShow: true,
                    hasAgree: true,
                  ),
                  apiKey: const AMapApiKey(
                    androidKey: '6a1e9677f4cf40f17c1cdead226d0ad2',
                    iosKey: '6a1e9677f4cf40f17c1cdead226d0ad2',
                  ),
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation ?? const LatLng(28.66999503, 115.82297033),
                    zoom: 15,
                  ),
                  onMapCreated: _onMapCreated,
                  onCameraMoveEnd: _onCameraMoveEnd,
                ),
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    child: const Icon(
                      Icons.location_on,
                      size: 40,
                      color: Colors.red,
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    heroTag: 'location_fab',
                    mini: true,
                    onPressed: () async {
                      try {
                        await _getCurrentLocation();
                        if (_isDisposed) return;
                        _addressController.text =
                            '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}';
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('获取位置失败: $e')),
                          );
                        }
                      }
                    },
                    backgroundColor: Colors.white,
                    elevation: 4,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _addressController.dispose();
    _mapController = null;
    super.dispose();
  }
}