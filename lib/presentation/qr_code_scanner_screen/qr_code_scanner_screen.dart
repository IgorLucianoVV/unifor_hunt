// lib/presentation/qr_code_scanner_screen/qr_code_scanner_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/camera_permission_widget.dart';
import './widgets/error_modal_widget.dart';
import './widgets/loading_indicator_widget.dart';
import './widgets/scanner_overlay_widget.dart';

/// Lido do --dart-define=API_BASE=...
const apiBase =
    String.fromEnvironment('API_BASE', defaultValue: 'http://10.0.2.2:3000');

class QrCodeScannerScreen extends StatefulWidget {
  const QrCodeScannerScreen({super.key});

  @override
  State<QrCodeScannerScreen> createState() => _QrCodeScannerScreenState();
}

class _QrCodeScannerScreenState extends State<QrCodeScannerScreen>
    with WidgetsBindingObserver {
  MobileScannerController? _scannerController;

  bool _hasPermission = false;
  bool _isScanning = false;
  bool _isTorchOn = false;
  bool _isLoading = false;
  String? _lastScannedCode;

  // Dados da missão (vindos por argumentos ou API)
  int? _missionId;
  String? _expectedQRCode;
  int? _points;
  int? _clueIndex;
  int? _totalClues;
  String? _currentClue; // opcional (para overlay)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Recebe argumentos da rota (se houver) apenas uma vez
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null && _missionId == null) {
      _missionId = args['missionId'] as int?;
      _expectedQRCode = args['expectedQRCode'] as String?;
      _points = args['points'] as int?;
      _clueIndex = args['clueIndex'] as int?;
      _totalClues = args['totalClues'] as int?;
      _currentClue = args['currentClue'] as String?;

      // Se não veio o QR esperado pela rota, busca no backend
      if (_expectedQRCode == null && _missionId != null) {
        _fetchExpectedQrFromApi(_missionId!);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_scannerController == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _scannerController!.start();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _scannerController!.stop();
        break;
      case AppLifecycleState.hidden:
        // nada
        break;
    }
  }
  
  void _showPermissionDeniedDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppTheme.dialogDark,
      title: Text(
        'Permissão Negada',
        style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
          color: AppTheme.textHighEmphasis,
        ),
      ),
      content: Text(
        'A permissão da câmera é necessária para escanear códigos QR. '
        'Por favor, habilite nas configurações do dispositivo.',
        style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.textMediumEmphasis,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // fecha o diálogo
            Navigator.of(context).pop(); // volta para a tela anterior
          },
          child: Text(
            'Voltar',
            style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.textMediumEmphasis,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // fecha o diálogo
            openAppSettings(); // abre as configurações do app
          },
          child: Text(
            'Configurações',
            style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.primaryDark,
            ),
          ),
        ),
      ],
    ),
  );
}

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() => _hasPermission = true);
      await _initializeScanner();
    } else {
      setState(() => _hasPermission = false);
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() => _hasPermission = true);
      await _initializeScanner();
    } else {
      _showPermissionDeniedDialog();
    }
  }

  Future<void> _initializeScanner() async {
    try {
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
        // Se sua versão suportar, ative a leitura apenas de QR:
        // formats: const [BarcodeFormat.qrCode],
      );

      await _scannerController!.start();
      setState(() => _isScanning = true);
    } catch (e) {
      _showErrorDialog('Erro ao inicializar a câmera: ${e.toString()}');
    }
  }

  Future<void> _fetchExpectedQrFromApi(int missionId) async {
    try {
      setState(() => _isLoading = true);
      final resp = await http.get(Uri.parse('$apiBase/missions/$missionId'));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        // Ajuste a chave conforme a sua API
        _expectedQRCode = (data['qrCode'] ??
                data['qr_code'] ??
                data['expectedQRCode'])
            ?.toString();
      } else {
        _showErrorDialog(
            'Não foi possível obter o QR da missão (HTTP ${resp.statusCode}).');
      }
    } catch (e) {
      _showErrorDialog('Erro ao buscar QR da missão: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onQRCodeDetected(BarcodeCapture capture) {
    if (_isLoading) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    String? value;
    for (final b in barcodes) {
      value = b.rawValue;
      if (value != null && value!.trim().isNotEmpty) break;
    }
    if (value == null || value!.isEmpty) return;

    final qrCode = _normalizeQr(value!);

    // Evita reprocessar o mesmo valor
    if (_lastScannedCode == qrCode) return;
    _lastScannedCode = qrCode;

    debugPrint('QR lido (normalizado): $qrCode');
    _validateQRCode(qrCode);
  }

  String _normalizeQr(String raw) {
    String v = raw.trim();

    // Tenta JSON {"code":"..."}
    try {
      final decoded = jsonDecode(v);
      if (decoded is Map && decoded['code'] is String) {
        return (decoded['code'] as String).trim();
      }
    } catch (_) {}

    // Tenta URL: ?code=... ou último segmento do path
    Uri? uri;
    try {
      uri = Uri.parse(v);
    } catch (_) {}
    if (uri != null && (uri.hasScheme || v.startsWith('www.'))) {
      final codeParam = uri.queryParameters['code'];
      if (codeParam != null && codeParam.trim().isNotEmpty) {
        return codeParam.trim();
      }
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last.trim();
      }
    }

    // Remove prefixos comuns (ex.: UNIFOR_HUNT:CODE)
    v = v.replaceFirst(
      RegExp(r'^(UNIFOR[_-]HUNT|QR|CODE)\s*[:=]\s*', caseSensitive: false),
      '',
    );

    return v;
    }

  Future<void> _validateQRCode(String qrCode) async {
    setState(() => _isLoading = true);
    await _scannerController?.stop();

    try {
      if (_missionId == null) {
        _showErrorModal(
          'Missão não informada. Abra o scanner a partir da missão.',
          qrCode,
        );
        return;
      }

      // Caso prefira validação no servidor, use _serverValidateQr e decida pelo retorno.
      // final ok = await _serverValidateQr(_missionId!, qrCode);
      // if (ok) { _handleValidQRCode(qrCode); } else { _handleWrongLocationQRCode(qrCode); }
      // return;

      if (_expectedQRCode == null) {
        _showErrorModal('QR esperado da missão não carregado.', qrCode);
        return;
      }

      if (qrCode == _expectedQRCode) {
        _handleValidQRCode(qrCode);
      } else {
        _handleWrongLocationQRCode(qrCode);
      }
    } catch (_) {
      _handleNetworkError(qrCode);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Opcional: valida no servidor (e.g., também marca progresso/pontos)
  Future<bool> _serverValidateQr(int missionId, String qrCode) async {
    final resp = await http.post(
      Uri.parse('$apiBase/missions/$missionId/validate-qr'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': qrCode}),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return data['valid'] == true; // ajuste conforme sua API
    }
    throw Exception('Validação falhou (HTTP ${resp.statusCode})');
  }

  void _handleValidQRCode(String qrCode) {
    HapticFeedback.heavyImpact();

    Navigator.pushReplacementNamed(
      context,
      '/success-celebration-screen',
      arguments: {
        'missionId': _missionId,
        'points': _points,
        'qrCode': qrCode,
        'clueIndex': _clueIndex,
        'totalClues': _totalClues,
      },
    );
  }

  void _handleWrongLocationQRCode(String qrCode) {
    _showErrorModal(
      'QR lido não confere com o QR esperado para esta missão.',
      qrCode,
    );
  }

  void _handleNetworkError(String qrCode) {
    _showErrorModal(
      'Erro de conexão. Verifique sua internet e tente novamente.',
      qrCode,
    );
  }

  void _showErrorModal(String message, String? qrCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorModalWidget(
        errorMessage: message,
        qrCodeValue: qrCode,
        onRetry: () {
          Navigator.of(context).pop();
          _resumeScanning();
        },
        onClose: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop(); // volta à tela anterior
        },
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.dialogDark,
        title: Text(
          'Erro',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textHighEmphasis,
          ),
        ),
        content: Text(
          message,
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textMediumEmphasis,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleTorch() async {
    if (_scannerController == null) return;

    try {
      await _scannerController!.toggleTorch();
      setState(() => _isTorchOn = !_isTorchOn);
    } catch (_) {
      // Torch não disponível
    }
  }

  Future<void> _resumeScanning() async {
    _lastScannedCode = null;
    await _scannerController?.start();
    setState(() => _isScanning = true);
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          if (!_hasPermission)
            CameraPermissionWidget(
              onRequestPermission: _requestCameraPermission,
              onGoBack: _goBack,
            )
          else if (_scannerController != null)
            _buildCameraPreview()
          else
            const Center(child: CircularProgressIndicator()),

          if (_isLoading)
            const LoadingIndicatorWidget(message: 'Validando QR Code...'),

          if (_hasPermission && !_isLoading)
            Positioned(
              top: MediaQuery.of(context).padding.top + 2.h,
              left: 4.w,
              child: GestureDetector(
                onTap: _goBack,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDark.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.textMediumEmphasis.withValues(alpha: 0.3),
                    ),
                  ),
                  child: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: AppTheme.textHighEmphasis,
                    size: 6.w,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: _onQRCodeDetected,
          // Se disponível na sua versão:
          // formats: const [BarcodeFormat.qrCode],
        ),
        ScannerOverlayWidget(
          isScanning: _isScanning,
          onTorchToggle: _toggleTorch,
          isTorchOn: _isTorchOn,
          currentClue: _currentClue ?? '',
        ),
      ],
    );
  }
}
