import Array "mo:base/Array";
import CRC8 "../vendor/crc/src/CRC8";
import Hex "../vendor/hex/src/Hex";
import Iter "mo:base/Iter";
import Key "key";
import Nat "mo:base/Nat";
import Ord "ord";
import Prim "mo:prim";
import Result "mo:base/Result";

module {

  private type Id = Text;
  private type Key = Key.Key;
  private type Ordering = Ord.Ordering;
  private type Result<Ok, Err> = Result.Result<Ok, Err>;

  public func compare(a : [Word8], b : [Word8]) : Ordering {
    let na = a.size();
    let nb = b.size();
    var i = 0;
    let n = Nat.min(na, nb);
    while (i < n) {
      if (a[i] < b[i]) {
        return #lt;
      };
      if (a[i] > b[i]) {
        return #gt;
      };
      i += 1;
    };
    if (na < nb) {
      return #lt;
    };
    if (na > nb) {
      return #gt;
    };
    return #eq;
  };

  public func isId(id : Id) : Bool {
    switch (Hex.decode(id)) {
      case (#ok buf) {
        if (buf.size() != 9) {
          return false;
        } else {
          let prefix = Array.tabulate<Word8>(8, func (i) {
            buf[i];
          });
          return CRC8.crc8(prefix) == buf[8];
        };
      };
      case _ {
        return false;
      };
    };
  };

  public func hexToKey(hex : Text) : Result<Key, Hex.DecodeError> {
    Result.mapOk<[Word8], Key, Hex.DecodeError>(Hex.decode(hex), Key.key);
  };

  // public func hexToKeyOrTrap(hex : Text) : Key {
  //   Result.assertUnwrapAny<Key>(hexToKey(hex));
  // };

  public func keyToHex(key : Key) : Text {
    Hex.encode(key.preimage);
  };

  public func principalToId(principal : Principal) : Text {
    let base = Iter.toArray<Word8>(Prim.blobOfPrincipal(principal).bytes());
    let crc8 = CRC8.crc8(base);
    return Hex.encode(Array.append<Word8>(base, [crc8]));
  };
};
