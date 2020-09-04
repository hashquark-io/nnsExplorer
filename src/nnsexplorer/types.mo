import Assoc "mo:base/AssocList";

module {
  public type DFNAccount = {
    accountAddr: Text;
    signature: Text;
    balance: Nat64;
    rewards: Nat64;
    
    isDelegator: Bool;
  };

  public type NewNeuron = {
    accountAddr: Text;
    description: Text;
    commissionRate: Nat;
    selfStaking: Nat64;
  };

  public type Neuron = {
    accountAddr: Text;
    description: Text;
    commissionRate: Nat;
    selfStaking: Nat64;
    totalDelegations: Nat64;
    delegations: Assoc.AssocList<Text, Nat64>;
  };

  type Time = Int;
  public type NewDFNProposal = {
    title: Text;
    details: Text;
    createdBy: Text;
    excutionTime: Time;
  };

  public type DFNProposal = {
    title: Text;
    details: Text;
    created: (Text, Time);
    votes: Assoc.AssocList<Text, Bool>;
    excutionTime: Time;
    status: Text; // "active", "passed", "failed", "excuted"
  };
};
