import 'package:equatable/equatable.dart';

class VersionCheckState extends Equatable {
  final bool isLoading;
  final bool updateRequired;
  final String? playStoreUrl;

  const VersionCheckState({
    this.isLoading = false,
    this.updateRequired = false,
    this.playStoreUrl,
  });

  VersionCheckState copyWith({
    bool? isLoading,
    bool? updateRequired,
    String? playStoreUrl,
  }) {
    return VersionCheckState(
      isLoading: isLoading ?? this.isLoading,
      updateRequired: updateRequired ?? this.updateRequired,
      playStoreUrl: playStoreUrl ?? this.playStoreUrl,
    );
  }

  @override
  List<Object?> get props => [isLoading, updateRequired, playStoreUrl];
}
