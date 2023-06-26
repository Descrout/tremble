typedef SubscriptionCallback<T> = bool? Function(T);
typedef VoidCallback = void Function();
typedef UpdateCallback = void Function(double deltaTime);
typedef UpdateSubscriptionCallback = bool? Function(double deltaTime);
typedef TimeUpdateCallback = void Function(double deltaTime, double remainingTime);
