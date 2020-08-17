module {
  public type DFNAccount = {
    accountAddr: Text;
    signature: Text;
  };

  public type NewNeuron = {
    accountAddr: Text;
    description: Text;
    commissionRate: Text;
    selfStaking: Nat64;
  };

  public type Neuron = {
    accountAddr: Text;
    description: Text;
    commissionRate: Text;
    selfStaking: Nat64;
    totalDelegations: Nat64;
  };
};
