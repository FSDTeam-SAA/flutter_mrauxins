// lib/bloc/network/network_connection_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  late final StreamSubscription _subscription;

  ConnectivityCubit()
      : super(const ConnectivityState(status: ConnectivityStatus.connected)) {
    _subscription = Connectivity().onConnectivityChanged.listen(_checkStatus);
    _initialize();
  }

  Future<void> _initialize() async {
    final result = await Connectivity().checkConnectivity();
    _checkStatus(result);
  }

  void _checkStatus(List<ConnectivityResult> result) {
    final status = _mapResultToStatus(result);
    emit(ConnectivityState(status: status));
  }

  ConnectivityStatus _mapResultToStatus(List<ConnectivityResult> result) {
    return (result.any(
      (element) => element == ConnectivityResult.none,
    ))
        ? ConnectivityStatus.disconnected
        : ConnectivityStatus.connected;
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}

class ConnectionRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  bool _isConnectionScreenOpen = false;

  bool get isConnectionScreenOpen => _isConnectionScreenOpen;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/connection_lost') {
      _isConnectionScreenOpen = true;
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (route.settings.name == '/connection_lost') {
      _isConnectionScreenOpen = false;
    }
  }
}
