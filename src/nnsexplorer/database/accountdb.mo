import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Text "mo:base/Text";
import Nat64 "mo:base/Nat64";
import Types "../types";
import KeyID "../key/id";

module {
  type DFNAccount = Types.DFNAccount;

  public class AccountHashMap() {
    // The "database" is just a local hash map
    let hashMap = HashMap.HashMap<Text, DFNAccount>(1, Text.equal, Text.hash);

    public func createAccount(account: DFNAccount) {
      hashMap.put(account.accountAddr, account);
    };

    public func updateAccount(account: DFNAccount) {
      let existing = findAccount(account.accountAddr);
      switch (existing) {
        case (null) { };
        case (?existing) { 
          hashMap.put(account.accountAddr, account);
        };
      };
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

    public func setDelegator(accountAddr: Text, value: Bool): Bool {
      let existing = findAccount(accountAddr);
      switch (existing) {
        case (?existing) {
          var new = {
            accountAddr = existing.accountAddr;
            signature = existing.signature;
            balance = existing.balance;
            rewards = existing.rewards;
            isDelegator = value;
          };
          hashMap.put(accountAddr, new);
          true
        };
        case (null) { false };
      };
    };

    public func balance(accountAddr: Text): Nat64 {
      let existing = findAccount(accountAddr);
      switch (existing) {
        case (?existing) { existing.balance };
        case (null) { Nat64.fromNat(0) };
      };
    };

    public func updateBalance(accountAddr: Text, newValue: Nat64): Bool {
      let existing = findAccount(accountAddr);
      switch (existing) {
        case (?existing) {
          var new = {
            accountAddr = existing.accountAddr;
            signature = existing.signature;
            balance = newValue;
            rewards = existing.rewards;
            isDelegator = existing.isDelegator;
          };
          hashMap.put(accountAddr, new);
          true
        };
        case (null) { false };
      };
    };

    public func addBalance(accountAddr: Text, value: Nat64): Bool {
      let existing = findAccount(accountAddr);
      switch (existing) {
        case (?existing) {
          var new = {
            accountAddr = existing.accountAddr;
            signature = existing.signature;
            balance = existing.balance + value;
            rewards = existing.rewards;
            isDelegator = existing.isDelegator;
          };
          hashMap.put(accountAddr, new);
          true
        };
        case (null) { false };
      };
    };

    public func subBalance(accountAddr: Text, value: Nat64): Bool {
      let existing = findAccount(accountAddr);
      switch (existing) {
        case (?existing) {
          if (existing.balance < value) {
            return false;
          };
          var new = {
            accountAddr = existing.accountAddr;
            signature = existing.signature;
            balance = existing.balance - value;
            rewards = existing.rewards;
            isDelegator = existing.isDelegator;
          };
          hashMap.put(accountAddr, new);
          true
        };
        case (null) { false };
      };
    };

    public func rewards(accountAddr: Text): Nat64 {
      let existing = findAccount(accountAddr);
      switch (existing) {
        case (?existing) { existing.rewards };
        case (null) { Nat64.fromNat(0) };
      };
    };

    public func updateRewards(accountAddr: Text, newValue: Nat64): Bool {
      let existing = findAccount(accountAddr);
      switch (existing) {
        case (?existing) {
          var new = {
            accountAddr = existing.accountAddr;
            signature = existing.signature;
            balance = existing.balance;
            rewards = newValue;
            isDelegator = existing.isDelegator;
          };
          hashMap.put(accountAddr, new);
          true
        };
        case (null) { false };
      };
    };

    public func addRewards(accountAddr: Text, value: Nat64): Bool {
      let existing = findAccount(accountAddr);
      switch (existing) {
        case (?existing) {
          var new = {
            accountAddr = existing.accountAddr;
            signature = existing.signature;
            balance = existing.balance;
            rewards = existing.rewards + value;
            isDelegator = existing.isDelegator;
          };
          hashMap.put(accountAddr, new);
          true
        };
        case (null) { false };
      };
    };

  };
};
