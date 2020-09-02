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

  public type DFNProposal = {
    title: Text;
    content: Text;
    voteNeurons: [Text];
    //signatures: [Text];
    totalRewards: Nat64;
  };
};
