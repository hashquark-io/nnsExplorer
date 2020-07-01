import Principal "mo:base/Principal";

module {
  public type UserId = Principal;

  public type NewProfile = {
    accountAddr: Text;
    description: Text;
    commissionRate: Text;
  };

  public type Profile = {
    id: UserId;
    accountAddr: Text;
    totalNeurons: Text;
    description: Text;
    commissionRate: Text;
  };
};
