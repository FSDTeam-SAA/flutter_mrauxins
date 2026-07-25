import 'package:flutter_bloc/flutter_bloc.dart';

/// Collapses the emit(loading) -> try -> emit(success) -> catch -> emit(error)
/// idiom repeated across every cubit into one call. Never takes a
/// BuildContext, so snackbar/navigation side effects can't sneak back into
/// the catch block here — those belong in the UI layer via BlocListener.
abstract class BaseCubit<S> extends Cubit<S> {
  BaseCubit(super.initialState);

  Future<T?> guard<T>(
    Future<T> Function() action, {
    S Function()? onLoading,
    required S Function(T result) onSuccess,
    required S Function(String message) onError,
  }) async {
    if (isClosed) return null;
    if (onLoading != null) emit(onLoading());
    try {
      final result = await action();
      if (isClosed) return null;
      emit(onSuccess(result));
      return result;
    } catch (e) {
      if (isClosed) return null;
      emit(onError(e.toString().replaceAll('Exception: ', '')));
      return null;
    }
  }
}
