enum LiveFormState {
  onFire,
  good,
  normal,
  off,
  bad,
}

LiveFormState getLiveFormState(double delta) {
  if (delta >= 2.0) return LiveFormState.onFire;
  if (delta >= 1.0) return LiveFormState.good;
  if (delta <= -2.0) return LiveFormState.bad;
  if (delta <= -1.0) return LiveFormState.off;
  return LiveFormState.normal;
}


