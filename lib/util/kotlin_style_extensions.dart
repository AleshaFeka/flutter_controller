extension $KotlinStyleExtension<T> on T {
  R let<R>(R Function(T) func) {
    return func(this);
  }

  T apply(void Function() func) {
    func();
    return this;
  }

  T also(void Function(T) func) {
    func(this);
    return this;
  }

  R run<R>(R Function() func) {
    return func();
  }
}
