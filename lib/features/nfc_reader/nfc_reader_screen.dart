import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nfc_reader_flutter/features/nfc_reader/nfc_reader_bloc.dart';

class NfcReaderScreen extends StatelessWidget {
  const NfcReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NfcReaderBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('NFC Reader'),
        ),
        body: BlocBuilder<NfcReaderBloc, NfcReaderState>(
          builder: (context, state) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state is NfcReaderInitial) ...[
                    const Text(
                      'Ready to scan NFC tags',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<NfcReaderBloc>().add(StartNfcSession());
                      },
                      child: const Text('Start NFC Session'),
                    ),
                  ],
                  if (state is NfcReaderLoading) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    const Text('Scanning for NFC tags...'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<NfcReaderBloc>().add(StopNfcSession());
                      },
                      child: const Text('Stop Scanning'),
                    ),
                  ],
                  if (state is NfcReaderError) ...[
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<NfcReaderBloc>().add(StartNfcSession());
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                  if (state is NfcReaderSuccess) ...[
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tag Data: ${state.tagData}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<NfcReaderBloc>().add(StartNfcSession());
                      },
                      child: const Text('Scan Another Tag'),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
} 