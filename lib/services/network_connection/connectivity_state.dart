import 'package:equatable/equatable.dart';

enum ConnectivityStatus { connected, disconnected }

class ConnectivityState extends Equatable {
  final ConnectivityStatus status;

  const ConnectivityState({required this.status});

  @override
  List<Object> get props => [status];
}
