// Make the Connectd app's public methods available locally
import Prelude "mo:base/Prelude";
import Prim "mo:prim";
import Nat64 "mo:base/Nat64";
import Principal "mo:base/Principal";
import AccountDB "./database/accountdb";
import NeuronDB "./database/neurondb";
import Types "./types";
import KeyID "./key/id";

type DFNAccount = Types.DFNAccount;
type NewNeuron = Types.NewNeuron;
type Neuron = Types.Neuron;

actor nnsexplorer {
  var accountDb: AccountDB.AccountHashMap = AccountDB.AccountHashMap();
  var neuronDb: NeuronDB.NeuronHashMap = NeuronDB.NeuronHashMap();

  // Healthcheck

  public func healthcheck(): async Bool { true };

  // Account

  public shared {
    caller = caller;
  } func getcid(): async Text {
    KeyID.principalToId(caller);
  };

  public shared {
    caller = caller;
  } func signup(account: DFNAccount): async Bool {
    if (accountDb.existAccount(account.accountAddr)) { return false; };
    accountDb.createAccount(account);
    true
  };

  public shared {
    caller = caller;
  } func existAccount(accountAddr: Text): async Bool {
    accountDb.existAccount(accountAddr)
  };

  public shared {
    caller = caller;
  } func verifyAccount(accountAddr: Text, signature: Text): async Bool {
    let existing = accountDb.findAccount(accountAddr);
    switch (existing) {
      case (?existing) { existing.signature == signature };
      case (null) { false };
    };
  };

  // Neurons

  public shared(msg) func createNeuron(newNeuron: NewNeuron): async () {
    // TODO verify account
    neuronDb.createOne(newNeuron);
  };

  // ============================================================================================
  // dfx canister call nnsexplorer createNeuronByInputs '("D32A68FF8DF9852A7F9B19F8C90AF64C8512B3935FACCE4E50B57A44E47BF21402F2", "HashQuark Limited", "5", 1000)'
  // ============================================================================================
  public shared {
    caller = caller;
  } func createNeuronByInputs(addr: Text, desc: Text, com: Text, selfVotes: Nat64): async Text {
    var newNeuron: NewNeuron = {
      accountAddr = addr;
      description = desc;
      commissionRate = com;
      selfStaking = selfVotes;
    };

    neuronDb.createOne(newNeuron);
    return "Created a new neuron: " # addr # "!";
  };

  public shared(msg) func updateByDelegation(fromAddr: Text, toAddr: Text, amount: Nat64): async Bool {
    neuronDb.updateDelegation(fromAddr, toAddr, amount)
  };

  public shared(msg) func update(neuron: Neuron): async () {
    //if(Helper.hasAccess(msg.caller, neuron)) {
    //  neuronDb.updateOne(neuron.id, neuron);
    //};
    neuronDb.updateOne(neuron);
  };

  public query func get(addr: Text): async Neuron {
    let existing = neuronDb.findNeuron(addr);
    switch (existing) {
      case (?existing) { existing };
      case (null) {
        {
          accountAddr = "";
          description = "";
          commissionRate = "";
          selfStaking = Nat64.fromNat(0);
          totalDelegations = Nat64.fromNat(0);
        }
      };
    };
  };

  public query func search(term: Text): async [Neuron] {
    neuronDb.findBy(term)
  };

  // ============================================================================================
  // dfx canister call nnsexplorer getList
  // ============================================================================================
  public query func getList(): async Text {
    var results = neuronDb.findList();
    var fullResultStr = "[";
    var i = 0;
    for (result in results.vals()) {
      if (i != 0) {
        fullResultStr #= ",";
      };
      let str = "{\n\"Account Address\": \"" # result.accountAddr # "\",\n\"Description\": \"" # result.description # "\",\n\"Commission Rate\": \"" # result.commissionRate # "\",\n\"Self Staking\": \"" # Nat64.toText(result.selfStaking) # "\",\n\"Total Delegations\": \"" # Nat64.toText(result.totalDelegations) # "\"\n}";
      fullResultStr #= str;
      i += 1;
    };
    fullResultStr #= "]";
    return fullResultStr;
  };

  // User Auth

  public shared query(msg) func getOwnId(): async Principal { msg.caller };

  // Simulation

  // public query func startSim(): async () {

  // };

  // public query func stopSim(): async () {
    
  // };
};
