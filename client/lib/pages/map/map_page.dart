import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../models/tutor_model.dart';
import '../../theme/app_theme.dart';
import '../../providers/tutor_provider.dart';
import '../student_request/student_request_detail_page.dart';
import '../tutor_service/tutor_service_detail_page.dart';

class MapPage extends StatefulWidget {
  final String role;

  const MapPage({
    super.key,
    required this.role,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with AutomaticKeepAliveClientMixin {
  final List<Marker> _markers = [];
  final List<Tutor> _tutors = [];
  AMapController? _mapController;
  LatLng? _currentLocation;
  bool _isDisposed = false;
  bool _isLoadingLocation = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLocationAndMap();
    });
  }

  Future<void> _initLocationAndMap() async {
    
    final hasPermission = await _requestLocationPermission();
    if (!hasPermission) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
      _currentLocation = const LatLng(28.66999503, 115.82297033);
      
      if (_mapController != null) {
        _loadMarkers();
      }
      return;
    }

    await _getCurrentLocationOptimized();
    
    if (_mapController != null && _currentLocation != null) {
      await _loadMarkers();
    }
  }

  void _onMapCreated(AMapController controller) {
    _mapController = controller;
    
    if (_currentLocation != null) {
      _moveCameraToLocation(_currentLocation!);
      _loadMarkers();
    }
  }

  Future<bool> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      return true;
    }

    status = await Permission.location.request();
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      status = await Permission.location.request();
      return status.isGranted;
    } else if (status.isPermanentlyDenied) {
      if (!mounted) return false;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('位置权限被拒绝'),
          content: const Text('需要位置权限才能显示附近的家教/学生，请前往设置开启'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
              child: const Text('去设置'),
            ),
          ],
        ),
      );
      return false;
    }
    return false;
  }

  Future<void> _getCurrentLocation() async {
    await _getCurrentLocationOptimized();
  }

  Future<void> _getCurrentLocationOptimized() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
          });
        }
        final lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          _currentLocation = LatLng(lastPosition.latitude, lastPosition.longitude);
        } else {
          _currentLocation = const LatLng(28.66999503, 115.82297033);
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
          });
        }
        _currentLocation = const LatLng(28.66999503, 115.82297033);
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
        latitude: 28.66999503,
        longitude: 115.82297033,
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

      final newLocation = LatLng(position.latitude, position.longitude);
      if (mounted) {
        setState(() {
          _currentLocation = newLocation;
          _isLoadingLocation = false;
        });
      }

      if (_mapController != null) {
        _moveCameraToLocation(newLocation);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
      _currentLocation = const LatLng(28.66999503, 115.82297033);
    }
  }

  Future<BitmapDescriptor> _createMarkerIcon(String subject, String price, String grade) async {
    const width = 180.0;
    const height = 140.0;
    const rectHeight = 110.0;
    const triangleHeight = 30.0;
    
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final backgroundPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(10, 0);
    path.lineTo(width - 10, 0);
    path.quadraticBezierTo(width, 0, width, 10);
    path.lineTo(width, rectHeight - 10);
    path.quadraticBezierTo(width, rectHeight, width - 10, rectHeight);
    path.lineTo(width / 2 + 10, rectHeight);
    path.lineTo(width / 2, rectHeight + triangleHeight);
    path.lineTo(width / 2 - 10, rectHeight);
    path.lineTo(10, rectHeight);
    path.quadraticBezierTo(0, rectHeight, 0, rectHeight - 10);
    path.lineTo(0, 10);
    path.quadraticBezierTo(0, 0, 10, 0);
    path.close();

    canvas.drawPath(path, backgroundPaint);

    final titleText = grade.isNotEmpty ? '$grade$subject' : subject;
    final titleFontSize = titleText.length > 6 ? 20.0 : 28.0;
    textPainter.text = TextSpan(
      text: titleText,
      style: TextStyle(
        color: Colors.white,
        fontSize: titleFontSize,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout(maxWidth: width - 20);
    textPainter.paint(canvas, Offset((width - textPainter.width) / 2, 20));

    textPainter.text = TextSpan(
      text: '$price元',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
      ),
    );
    textPainter.layout(maxWidth: width - 20);
    textPainter.paint(canvas, Offset((width - textPainter.width) / 2, 55));

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(bytes);
  }

  Future<void> _loadMarkers() async {
    if (_mapController == null) return;

    try {
      setState(() {
        _markers.clear();
        _tutors.clear();
      });

      final tutorProvider = Provider.of<TutorProvider>(context, listen: false);
      
      if (widget.role == 'tutor') {
        await tutorProvider.getNearbyStudents(page: 1, limit: 100);
      } else {
        await tutorProvider.getNearbyTutors(page: 1, limit: 100);
      }

      final tutorsData = tutorProvider.tutors;
      
      final newMarkers = <Marker>[];
      final newTutors = <Tutor>[];
      
      for (var tutor in tutorsData) {
        final latitude = tutor.latitude;
        final longitude = tutor.longitude;
        if (latitude != null && longitude != null) {
          final subject = tutor.subjects.firstOrNull?.name ?? '未知';
          final grade = widget.role == 'tutor' 
              ? tutor.educationBackground
              : tutor.targetGradeLevels.map((g) => g.displayName).join(',');
          final priceRange = tutor.pricePerHour.toString();
          final price = priceRange.contains('-') 
              ? priceRange.split('-').last.trim().replaceAll('.00', '')
              : priceRange.replaceAll('.00', '');
          final icon = await _createMarkerIcon(subject, price, grade);
          
          final markerPosition = LatLng(
            double.tryParse(latitude.toString()) ?? 0,
            double.tryParse(longitude.toString()) ?? 0,
          );
          
          newTutors.add(tutor);
          newMarkers.add(Marker(
            position: markerPosition,
            icon: icon,
            onTap: (String markerId) {
              final index = newMarkers.indexWhere((m) => 
                m.position.latitude == markerPosition.latitude &&
                m.position.longitude == markerPosition.longitude
              );
              if (index != -1 && index < newTutors.length) {
                _showBottomSheet(newTutors[index]);
              }
            },
          ));
        }
      }

      if (mounted) {
        setState(() {
          _markers.addAll(newMarkers);
          _tutors.addAll(newTutors);
        });
      }

    } catch (e) {
      debugPrint('Error loading nearby tutors: $e');
    }
  }

  void _moveCameraToLocation(LatLng location) {
    if (_mapController != null) {
      _mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 14,
          ),
        ),
      );
    }
  }

  void _showBottomSheet(Tutor tutor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(tutor),
    );
  }

  Widget _buildBottomSheet(Tutor tutor) {
    Color accentColor;
    final subjectName = tutor.subjects.firstOrNull?.name.toLowerCase() ?? '';
    if (subjectName.contains('数学') || subjectName.contains('math')) {
      accentColor = AppTheme.primaryColor;
    } else if (subjectName.contains('英语') || subjectName.contains('english')) {
      accentColor = const Color(0xFF10B981);
    } else if (subjectName.contains('物理') || subjectName.contains('physics')) {
      accentColor = const Color(0xFFF59E0B);
    } else if (subjectName.contains('化学') ||
        subjectName.contains('chemistry')) {
      accentColor = const Color(0xFFEF4444);
    } else if (subjectName.contains('生物') || subjectName.contains('biology')) {
      accentColor = const Color(0xFF14B8A6);
    } else {
      accentColor = AppTheme.primaryColor;
    }

    final price = '${tutor.pricePerHour}元/小时';
    
    final bool isVerified = tutor.user.isVerified ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        tutor.user.name.isNotEmpty ? tutor.user.name[0] : 'U',
                        style: TextStyle(
                          fontSize: 28,
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                tutor.user.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isVerified == true)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified, size: 11, color: Colors.blue.shade700),
                                      const SizedBox(width: 2),
                                      Text(
                                        '已认证',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (tutor.user.badge != null && tutor.user.badge!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFDF2F8),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    tutor.user.badge!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFEC4899),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (tutor.user.gender != null && tutor.user.gender!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Text(
                                  (tutor.user.gender!.toLowerCase() == 'male' || tutor.user.gender == '男') ? '♂' : '♀',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: (tutor.user.gender!.toLowerCase() == 'male' || tutor.user.gender == '男') ? AppTheme.maleColor : AppTheme.femaleColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Text(
                                tutor.subjects.map((s) => s.name).join('、'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              price,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                              ),
                            ),
                            if (tutor.rating > 0) ...[
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tutor.rating.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (tutor.type == 'student_request') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  StudentRequestDetailPage(request: tutor),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TutorServiceDetailPage(tutor: tutor),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '查看详情',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.role == 'tutor' ? '附近学生' : '附近家教'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
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
              target: _currentLocation ?? const LatLng(28.66999503, 115.82297033),
              zoom: 13,
            ),
            onMapCreated: _onMapCreated,
            markers: Set<Marker>.of(_markers),
          ),
          if (_isLoadingLocation)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.8),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('正在获取位置...'),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'map_location_fab',
              mini: true,
              onPressed: () async {
                await _getCurrentLocation();
                if (_currentLocation != null && _mapController != null) {
                  await _loadMarkers();
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
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _mapController = null;
    super.dispose();
  }
}
