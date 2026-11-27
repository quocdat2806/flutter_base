class AppBlocObserver extends BlocObserver {
  const AppBlocObserver(); // ← không cần truyền gì
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log.d(
      '${bloc.runtimeType}: ${change.currentState.runtimeType} → ${change.nextState.runtimeType}',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log.e('${bloc.runtimeType} failed', error: error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
