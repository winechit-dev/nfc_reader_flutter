import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

// Events
abstract class NfcReaderEvent extends Equatable {
  const NfcReaderEvent();

  @override
  List<Object> get props => [];
}

class StartNfcSession extends NfcReaderEvent {}

class StopNfcSession extends NfcReaderEvent {}

class NfcTagDiscovered extends NfcReaderEvent {
  final NfcTag tag;

  const NfcTagDiscovered(this.tag);

  @override
  List<Object> get props => [tag];
}

// States
abstract class NfcReaderState extends Equatable {
  const NfcReaderState();

  @override
  List<Object> get props => [];
}

class NfcReaderInitial extends NfcReaderState {}

class NfcReaderLoading extends NfcReaderState {}

class NfcReaderError extends NfcReaderState {
  final String message;

  const NfcReaderError(this.message);

  @override
  List<Object> get props => [message];
}

class NfcReaderSuccess extends NfcReaderState {
  final String tagData;

  const NfcReaderSuccess(this.tagData);

  @override
  List<Object> get props => [tagData];
}

// Bloc
class NfcReaderBloc extends Bloc<NfcReaderEvent, NfcReaderState> {
  NfcReaderBloc() : super(NfcReaderInitial()) {
    on<StartNfcSession>(_onStartNfcSession);
    on<StopNfcSession>(_onStopNfcSession);
    on<NfcTagDiscovered>(_onNfcTagDiscovered);
  }

  Future<void> _onStartNfcSession(
    StartNfcSession event,
    Emitter<NfcReaderState> emit,
  ) async {
    try {
      final isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        emit(const NfcReaderError('NFC is not available on this device'));
        return;
      }

      emit(NfcReaderLoading());
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          add(NfcTagDiscovered(tag));
        },
      );
    } catch (e) {
      emit(NfcReaderError(e.toString()));
    }
  }

  Future<void> _onStopNfcSession(
    StopNfcSession event,
    Emitter<NfcReaderState> emit,
  ) async {
    try {
      await NfcManager.instance.stopSession();
      emit(NfcReaderInitial());
    } catch (e) {
      emit(NfcReaderError(e.toString()));
    }
  }

  Future<void> _onNfcTagDiscovered(
    NfcTagDiscovered event,
    Emitter<NfcReaderState> emit,
  ) async {
    try {
      final tag = event.tag;
      final nfcA = NfcA.from(tag);
      if (nfcA != null) {
        final atqa = nfcA.atqa;
        final sak = nfcA.sak;
        final maxTransceiveLength = nfcA.maxTransceiveLength;
        final tagData = 'ATQA: $atqa, SAK: $sak, Max Length: $maxTransceiveLength';
        emit(NfcReaderSuccess(tagData));
      } else {
        emit(const NfcReaderError('Unsupported NFC tag type'));
      }
    } catch (e) {
      emit(NfcReaderError(e.toString()));
    }
  }
} 