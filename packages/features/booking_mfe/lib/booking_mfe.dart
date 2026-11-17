import 'package:material_ui/material_ui.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key, required this.carId, required this.onClose});

  final String carId;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendamento')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('booking_mfe'),
            const SizedBox(height: 16),
            Text('Veículo: $carId'),
            const SizedBox(height: 24),
            FilledButton(onPressed: onClose, child: const Text('Voltar')),
          ],
        ),
      ),
    );
  }
}
