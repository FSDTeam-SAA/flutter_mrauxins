
import 'package:equatable/equatable.dart';

abstract class NetworkConnectionEvent extends Equatable {
  const NetworkConnectionEvent();

  @override
  List<Object?> get props => [];
}

class _NetworkStatusChanged extends NetworkConnectionEvent {}
