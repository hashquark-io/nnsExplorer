// Make the Connectd app's public methods available locally
import Prelude "mo:base/Prelude";
import Prim "mo:prim";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Int "mo:base/Int";
import List "mo:base/List";
import Principal "mo:base/Principal";
import AccountDB "./database/accountdb";
import NeuronDB "./database/neurondb";
import ProposalDB "./database/proposaldb";
import Types "./types";
import KeyID "./key/id";

type DFNAccount = Types.DFNAccount;
type NewNeuron = Types.NewNeuron;
type NewDFNProposal = Types.NewDFNProposal;
type Neuron = Types.Neuron;
type Proposal = Types.DFNProposal;

actor nnsexplorer {
  var accountDb: AccountDB.AccountHashMap = AccountDB.AccountHashMap();
  var neuronDb: NeuronDB.NeuronHashMap = NeuronDB.NeuronHashMap();
  var proposaldb: ProposalDB.ProposalHashMap = ProposalDB.ProposalHashMap();

  // Healthcheck

  public query func healthcheck(): async Bool { true };

  // Account

  public shared query{
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

  public shared query{
    caller = caller;
  } func existAccount(accountAddr: Text): async Bool {
    accountDb.existAccount(accountAddr)
  };

  public shared query{
    caller = caller;
  } func verifyAccount(accountAddr: Text, signature: Text): async Bool {
    let existing = accountDb.findAccount(accountAddr);
    switch (existing) {
      case (?existing) { existing.signature == signature };
      case (null) { false };
    };
  };

  public shared query func getAccount(addr: Text): async ?DFNAccount {
    accountDb.findAccount(addr)
  };

  public shared query func getBalance(addr: Text): async Text {
    Nat64.toText(accountDb.balance(addr))
  };

  public shared query func getRewards(addr: Text): async Text {
    Nat64.toText(accountDb.rewards(addr))
  };

  public shared query func getDelegations(addr: Text): async Text {
    let neuronList = neuronDb.findList();
    var fullResultStr = "[";
    var i = 0;
    for (neuron in neuronList.vals()) {
      func getDelegationInfo((addrDele, amount): (Text, Nat64)) {
        if (addrDele == addr) {
          if (i > 0) {
            fullResultStr #= ",";
          };
          i += 1;

          let str = "{\n\"Neuron Account\": \"" # neuron.accountAddr # "\",\n\"Description\": \"" # neuron.description # "\",\n\"Commission Rate\": \"" # Nat.toText(neuron.commissionRate) # "%" # "\",\n\"Amount\": \"" # Nat64.toText(amount) # "\"\n}";
          fullResultStr #= str;
        };
      };
      List.iterate<(Text, Nat64)>(neuron.delegations, getDelegationInfo);
    };

    fullResultStr #= "]";
    return fullResultStr;
  };

  public shared(msg) func withdrawRewards(addr: Text): async Bool {
    let existing = accountDb.findAccount(addr);
    switch (existing) {
      case (?existing) {
        let new = {
          accountAddr = existing.accountAddr;
          signature = existing.signature;
          balance = existing.balance + existing.rewards;
          rewards = 0: Nat64;
          isDelegator = existing.isDelegator;
        };
        accountDb.updateAccount(new);
        true
      };
      case (null) { false };
    };
  };

  public shared(msg) func updateAccount(account: DFNAccount): async () {
    accountDb.updateAccount(account);
  };

  public shared(msg) func updateAccounts(accounts: [DFNAccount]): async () {
    for (account in accounts.vals()) {
      accountDb.updateAccount(account);
    };
  };

  // Neurons

  public shared(msg) func createNeuron(newNeuron: NewNeuron): async Bool {
    let account = accountDb.findAccount(newNeuron.accountAddr);
    switch (account) {
      case (?account) {
        if (account.isDelegator) { false } else {
          let existing = neuronDb.findNeuron(newNeuron.accountAddr);
          switch (existing) {
            case (?existing) { false };
            case (null) {
              if (accountDb.subBalance(newNeuron.accountAddr, newNeuron.selfStaking)) {
                neuronDb.createNeuron(newNeuron);
                true
              } else {
                false
              };
            };
          };
        };
      };
      case (null) { false };
    };
  };

  public shared(msg) func updateByDelegation(fromAddr: Text, toAddr: Text, amount: Nat64): async Bool {
    let existing = neuronDb.findNeuron(fromAddr);
    switch (existing) {
      case (?existing) { false };
      case (null) {
        let account = accountDb.findAccount(fromAddr);
        if (accountDb.subBalance(fromAddr, amount) and accountDb.setDelegator(fromAddr, true)) {
          if (neuronDb.updateDelegation(fromAddr, toAddr, amount)) {
            true
          } else {
            switch (account) {
              case (?account) { accountDb.updateAccount(account) };
              case (null) { assert(false) };
            };
            false
          };
        } else {
          false
        };
      };
    };
  };

  public shared(msg) func updateByUnDelegation(fromAddr: Text, toAddr: Text, amount: Nat64): async Bool {
    let existing = neuronDb.findNeuron(fromAddr);
    switch (existing) {
      case (?existing) { false };
      case (null) {
        let account = accountDb.findAccount(fromAddr);
        if (neuronDb.updateUnDelegation(fromAddr, toAddr, amount)) {
          if (accountDb.addBalance(fromAddr, amount)) {
            true
          } else {
            assert(false);
            false
          };
        } else {
          false
        };
      };
    };
  };

  public shared(msg) func updateNeuron(neuron: Neuron): async () {
    neuronDb.updateNeuron(neuron);
  };

  public shared(msg) func updateNeurons(neurons: [Neuron]): async () {
    for (neuron in neurons.vals()) {
      neuronDb.updateNeuron(neuron);
    };
  };

  public shared query func getNeuron(addr: Text): async Neuron {
    let existing = neuronDb.findNeuron(addr);
    switch (existing) {
      case (?existing) { existing };
      case (null) {
        {
          accountAddr = "";
          description = "";
          commissionRate = 0;
          selfStaking = Nat64.fromNat(0);
          totalDelegations = Nat64.fromNat(0);
          delegations = List.nil<(Text, Nat64)>();
        }
      };
    };
  };

  public shared query func search(term: Text): async [Neuron] {
    neuronDb.findBy(term)
  };

  public shared query func getNeuronList(): async Text {
    var results = neuronDb.findList();
    var fullResultStr = "[";
    var i = 0;
    for (result in results.vals()) {
      if (i > 0) {
        fullResultStr #= ",";
      };
      i += 1;

      var delegatorsNum = 0;
      func getDelegatorsNum((addr, amount): (Text, Nat64)) {
        delegatorsNum += 1;
      };
      List.iterate<(Text, Nat64)>(result.delegations, getDelegatorsNum);

      let str = "{\n\"Account Address\": \"" # result.accountAddr # "\",\n\"Description\": \"" # result.description # "\",\n\"Commission Rate\": \"" # Nat.toText(result.commissionRate) # "%" # "\",\n\"Self Staking\": \"" # Nat64.toText(result.selfStaking) # "\",\n\"Total Delegations\": \"" # Nat64.toText(result.totalDelegations) # "\",\n\"Delegators\": \"" # Nat.toText(delegatorsNum) # "\"\n}";
      fullResultStr #= str;
    };
    fullResultStr #= "]";
    return fullResultStr;
  };

  // Proposals

  public shared(msg) func createProposal(newProposal: NewDFNProposal): async () {
    proposaldb.createProposal(newProposal);
  };

  public shared(msg) func updateProposalStatus(id: Text, newStatus: Text): async () {
    proposaldb.updateStatus(id, newStatus);
  };

  public shared(msg) func voteForProposal(account: Text, id: Text, approve: Bool): async Bool {
    let existing = proposaldb.findProposalByID(id);
    switch (existing) {
      case (?existing) {
        proposaldb.voteProposal(account, id, approve);
        true
      };
      case (null) { false };
    };
  };

  public shared query func getProposalID(proposal: Proposal): async Text {
    proposaldb.calProposalID(proposal);
  };

  public shared query func getProposalContent(id: Text): async Text {
    let existing = proposaldb.findProposalByID(id);
    switch (existing) {
      case (?existing) { existing.details };
      case (null) { "" };
    };
  };

  public shared query func getProposalApprovals(id: Text): async Text {
    let existing = proposaldb.findProposalByID(id);
    switch (existing) {
      case (null) { "" };
      case (?existing) {
        var fullResultStr = "[";
        
        var str = "";
        var i = 0;
        func getApprovals((addr, approve): (Text, Bool)) {
          if (approve != true) {
            return
          };
          let neuron = neuronDb.findNeuron(addr);
          switch (neuron) {
            case (null) { };
            case (?neuron) {
              if (i > 0) {
                fullResultStr #= ",";
              };
              i += 1;

              str := "{\n\"Account\": \"" # addr # "\",\n\"Votes\": \"" # Nat64.toText(neuron.selfStaking + neuron.totalDelegations) # "\"\n}";
              fullResultStr #= str;
            };
          };
        };
        List.iterate<(Text, Bool)>(existing.votes, getApprovals);

        fullResultStr #= "]";
        return fullResultStr
      };
    };
  };

  public shared query func getProposalDisapprovals(id: Text): async Text {
    let existing = proposaldb.findProposalByID(id);
    switch (existing) {
      case (null) { "" };
      case (?existing) {
        var fullResultStr = "[";
        
        var str = "";
        var i = 0;
        func getDisapprovals((addr, approve): (Text, Bool)) {
          if (approve == true) {
            return
          };
          let neuron = neuronDb.findNeuron(addr);
          switch (neuron) {
            case (null) { };
            case (?neuron) {
              if (i > 0) {
                fullResultStr #= ",";
              };
              i += 1;

              str := "{\n\"Account\": \"" # addr # "\",\n\"Votes\": \"" # Nat64.toText(neuron.selfStaking + neuron.totalDelegations) # "\"\n}";
              fullResultStr #= str;
            };
          };
        };
        List.iterate<(Text, Bool)>(existing.votes, getDisapprovals);

        fullResultStr #= "]";
        return fullResultStr
      };
    };
  };

  public shared query func getProposalList(): async Text {
    var results = proposaldb.findList();
    var fullResultStr = "[";
    var i = 0;
    for (result in results.vals()) {
      if (i > 0) {
        fullResultStr #= ",";
      };
      i += 1;

      let (account, time) = result.created;
      let str = "{\n\"Title\": \"" # result.title # "\",\n\"Created By\": \"" # account # "\",\n\"Create Time\": \"" # Int.toText(time) # "\",\n\"Proposal ID\": \"" # proposaldb.calProposalID(result) # "\",\n\"Status\": \"" # result.status # "\",\n\"Excution Time\": \"" # Int.toText(result.excutionTime) # "\"\n}";
      fullResultStr #= str;
    };
    fullResultStr #= "]";
    return fullResultStr;
  };

  // nnsexplorer_sim for test

  public shared func signupTest(account: DFNAccount): async () {
    accountDb.createAccount(account)
  };

  public shared func signupTests(accounts: [DFNAccount]): async () {
    for (account in accounts.vals()) {
      accountDb.createAccount(account);
    };
  };

  public shared(msg) func createTestNeuron(newNeuron: NewNeuron): async () {
    neuronDb.createNeuron(newNeuron)
  };

  public shared(msg) func createTestNeurons(newNeurons: [NewNeuron]): async () {
    for (neuron in newNeurons.vals()) {
      neuronDb.createNeuron(neuron);
    };
  };

  public query func getNeuronListTest(): async [Neuron] {
    neuronDb.findList()
  };

  public shared(msg) func createProposalTest(newProposal: NewDFNProposal): async () {
    proposaldb.createProposal(newProposal);
  };

  public shared(msg) func createProposalsTest(newProposals: [NewDFNProposal]): async () {
    for (newProposal in newProposals.vals()) {
      proposaldb.createProposal(newProposal);
    };
  };

  // User Auth

  public shared query(msg) func getOwnId(): async Principal { msg.caller };
};
