import Array "mo:base/Array";
import Hex "../vendor/hex/src/Hex";
import Iter "mo:base/Iter";
import Prim "mo:prim";
import SHA256 "../vendor/sha/src/SHA256";

module {

  public type Key = {
    image : [Word8];
    preimage : [Word8];
  };

  public func key(data : [Word8]) : Key {
    { image = SHA256.sha256(data);
      preimage = data;
    };
  };

  public func equal(k1 : Key, k2 : Key) : Bool {
    for (i in Iter.range(0, k1.image.len() - 1)) {
      if (k1.image[i] != k2.image[i]) {
        return false;
      };
    };
    return true;
  };

  public func compare(k1 : Key, k2 : Key) : Int {
    for (i in Iter.range(0, k1.image.len() - 1)) {
      if (k1.image[i] < k2.image[i]) {
        return -1;
      };
      if (k1.image[i] > k2.image[i]) {
        return 1;
      };
    };
    return 0;
  };

  public func show(key : Key) : Text {
    "{\n  preimage = " #
    Hex.encode(key.preimage) #
    ";\n  image = " #
    Hex.encode(key.image) #
    ";\n}"
  };

  public func sort(keys : [Key]) : [Key] {
    let n = keys.len();
    if (n < 2) {
      return keys
    } else {
      let result = Array.thaw<Key>(keys);
      sortBy<Key>(compare, result, 0, n - 1);
      return Array.freeze<Key>(result);
    };
  };

  public func distance(k1 : Key, k2 : Key) : Nat {
    var n = 0;
    for (i in Iter.range(0, k1.image.len() - 1)) {
      n += Prim.word8ToNat(k1.image[i] ^ k2.image[i]) * 256 ** i;
    };
    return n;
  };

  public func compareByDistance(to : Key, k1 : Key, k2 : Key) : Int {
    let a = distance(to, k1);
    let b = distance(to, k2);
    if (a < b) {
      return -1;
    };
    if (a > b) {
      return 1;
    };
    return 0;
  };

  public func sortByDistance(to : Key, keys : [Key]) : [Key] {
    let n = keys.len();
    if (n < 2) {
      return keys
    } else {
      let result = Array.thaw<Key>(keys);
      sortBy<Key>(func (k1, k2) {
        return compareByDistance(to, k1, k2);
      }, result, 0, n - 1);
      return Array.freeze<Key>(result);
    };
  };

  private func sortBy<X>(f : (X, X) -> Int, xs : [var X], l : Int, r : Int) {
    if (l < r) {
      var i = l;
      var j = r;
      var swap  = xs[0];
      let pivot = xs[Prim.abs(l + r) / 2];
      while (i <= j) {
        while (f(xs[Prim.abs(i)], pivot) < 0) {
          i += 1;
        };
        while (f(xs[Prim.abs(j)], pivot) > 0) {
          j -= 1;
        };
        if (i <= j) {
          swap := xs[Prim.abs(i)];
          xs[Prim.abs(i)] := xs[Prim.abs(j)];
          xs[Prim.abs(j)] := swap;
          i += 1;
          j -= 1;
        };
      };
      if (l < j) {
        sortBy<X>(f, xs, l, j);
      };
      if (i < r) {
        sortBy<X>(f, xs, i, r);
      };
    };
  };
};
