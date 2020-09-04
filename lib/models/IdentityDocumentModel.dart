class IdentityDocumentModel {
  Map _data;

  IdentityDocumentModel(Map data) {
    _data = new Map();
    data.forEach((k, v) => _data[new Symbol(k).toString()] = v);
  }

  noSuchMethod(Invocation invocation) {
    if (invocation.isGetter) {
      var ret = _data[invocation.memberName.toString()];
      if (ret != null) {
        return ret;
      } else {
        return null;
      }
    }
    if (invocation.isSetter) {
      _data[invocation.memberName.toString().replaceAll('=', '')] =
          invocation.positionalArguments.first;
    } else {
      super.noSuchMethod(invocation);
    }
  }
}
