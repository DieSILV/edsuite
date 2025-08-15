import 'package:edsuite/features/pos/presentation/bloc/pos/pos_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PostConfigurationScreenArguments {
  final String baseUrl;

  PostConfigurationScreenArguments({required this.baseUrl});
}

class PosConfigurationScreen extends StatefulWidget {
  final PostConfigurationScreenArguments args;
  const PosConfigurationScreen({super.key, required this.args});

  @override
  State<PosConfigurationScreen> createState() => _PosConfigurationScreenState();
}

class _PosConfigurationScreenState extends State<PosConfigurationScreen> {
  final TextEditingController _ipController = TextEditingController();
  String _selectedProtocol = 'http';
  String? _message;
  Color _messageColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _loadServerConfig();
  }

  Future<void> _loadServerConfig() async {
    final url = widget.args.baseUrl;

    if (url.isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        setState(() {
          _selectedProtocol = uri.scheme;
          _ipController.text = uri.host;
        });
      }
    }
  }

  Future<void> _saveServerConfig() async {
    final ip = _ipController.text.trim();

    if (ip.isEmpty) {
      setState(() {
        _message = 'Ingrese una IP válida';
        _messageColor = Colors.red;
      });
      return;
    }

    final baseUrl = '$_selectedProtocol://$ip';
    context.read<PosBloc>().add(SetBaseUrl(baseUrl));
    //final prefs = await SharedPreferences.getInstance();
    //await prefs.setString('base_url', baseUrl);

    /* setState(() {
      _message = 'Configuración guardada correctamente';
      _messageColor = Colors.green;
    }); */
  }

  Future<void> _cerrarSesion() async {
    /* final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } */
    context.read<PosBloc>().add(ClearPosData());
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF2196F3);
    final logoutColor = Colors.redAccent;

    return BlocListener<PosBloc, PosState>(
      listener: (context, state) {
        switch (state.status) {
          case PosStatus.successClear:
            context.replace("/");
            break;
          default:
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Configuración POS',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ajustes de servidor',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedProtocol,
                items: const [
                  DropdownMenuItem(value: 'http', child: Text('HTTP')),
                  DropdownMenuItem(value: 'https', child: Text('HTTPS')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedProtocol = value;
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Protocolo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ipController,
                decoration: const InputDecoration(
                  labelText: 'Dirección IP o dominio',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (_message != null)
                Text(
                  _message!,
                  style: TextStyle(
                    color: _messageColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveServerConfig,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'Guardar configuración',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _cerrarSesion,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Cerrar sesión y salir',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: logoutColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
