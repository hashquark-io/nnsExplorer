import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Text "mo:base/Text";
import Types "../types";
import KeyID "../key/id";

module {
  type DFNAccount = Types.DFNAccount;

  public class AccountHashMap() {
    // The "database" is just a local hash map
    let hashMap = HashMap.HashMap<Text, DFNAccount>(1, isEq, Text.hash);

    public func createAccount(account: DFNAccount) {
      hashMap.put(account.accountAddr, account);
    };

    public func updateAccount(account: DFNAccount) {
      hashMap.put(account.accountAddr, account);
    };

    public func findAccount(address: Text): ?DFNAccount {
      hashMap.get(address)
    };

    public func existAccount(accountAddr: Text): Bool {
      let existing = findAccount(accountAddr);
      switch (existing) {
        case (?existing) { true };
        case (null) { false };
      };
    };

  };

  func isEq(x: Text, y: Text): Bool { x == y };
};
