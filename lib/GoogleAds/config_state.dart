import 'package:equatable/equatable.dart';
import 'package:two_one_two_messenger/GoogleAds/config_model.dart';

class ConfigState extends Equatable {
  final bool isCall;
  final ConfigModel? configModel;
  final bool isLoading;
  final String? errorMessage;

  const ConfigState({
    this.isCall = false,
    this.configModel,
    this.isLoading = false,
    this.errorMessage,
  });

  ConfigState copyWith({
    bool? isCall,
    ConfigModel? configModel,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ConfigState(
      isCall: isCall ?? this.isCall,
      configModel: configModel ?? this.configModel,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isCall, configModel, isLoading, errorMessage];
}
