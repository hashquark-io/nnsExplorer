import Prim "mo:prim";
import Nat64 "mo:base/Nat64";
import Array "mo:base/Array";
import Text "mo:base/Text";
import List "mo:base/List";
import Assoc "mo:base/AssocList";
import Types "../nnsexplorer/types";
import NNSExplorer "canister:nnsexplorer";
import Debug "mo:base/Debug";

actor nnsexplorer_sim {
  // table of mock accounts
  let accounts =
    [ 
        {
          accountAddr = "A5AEC167AC201B67C6EF6B267361B3D2595C2EC798EB8D7DD52489BC02DC";
          signature = "Dominic Williams";
          balance = 10000: Nat64;
          rewards = 0: Nat64;
          isDelegator = false;
        },
        {
          accountAddr = "A19BA9C73839E92644491D0901071267D115D1FE1A1A4870C3DB5CA50228";
          signature = "Diego Prats";
          balance = 10000: Nat64;
          rewards = 0: Nat64;
          isDelegator = false;
        },
        {
          accountAddr = "CE1D6EDC4B7383D84187BB9056659DC6135EDF239F0E8DD0FB518A510257";
          signature = "Jan Camenisch";
          balance = 10000: Nat64;
          rewards = 0: Nat64;
          isDelegator = false;
        },
        {
          accountAddr = "CEDDBCA8FA100E5E177F1E3934E98A366CEDFB3968D8915E6E1933970224";
          signature = "Donald Trump";
          balance = 10000: Nat64;
          rewards = 0: Nat64;
          isDelegator = false;
        },
        {
          accountAddr = "B5B5E0924288954CE5427AC456366E7DD50837723DA10D04998AD7CE0273";
          signature = "Sanam Saaber";
          balance = 10000: Nat64;
          rewards = 0: Nat64;
          isDelegator = false;
        },
        {
          accountAddr = "3BA830E39688DE354E40084C21FCB0C86E190DBDB322021C2A4843C002D5";
          signature = "Barack Obama";
          balance = 10000: Nat64;
          rewards = 0: Nat64;
          isDelegator = false;
        }
    ];

  // table of mock neurons
  let neurons =
    [ 
        {
          accountAddr = "A5AEC167AC201B67C6EF6B267361B3D2595C2EC798EB8D7DD52489BC02DC";
          description = "Dominic Williams - Founder & Chief Scientist";
          commissionRate = 5;
          selfStaking = 300000: Nat64;
        },
        {
          accountAddr = "A19BA9C73839E92644491D0901071267D115D1FE1A1A4870C3DB5CA50228";
          description = "Diego Prats - Director of Product";
          commissionRate = 10;
          selfStaking = 200000: Nat64;
        },
        {
          accountAddr = "CE1D6EDC4B7383D84187BB9056659DC6135EDF239F0E8DD0FB518A510257";
          description = "Jan Camenisch - VP of Research";
          commissionRate = 10;
          selfStaking = 50000: Nat64;
        },
        {
          accountAddr = "CEDDBCA8FA100E5E177F1E3934E98A366CEDFB3968D8915E6E1933970224";
          description = "Donald Trump - President";
          commissionRate = 5;
          selfStaking = 900000: Nat64;
        },
        {
          accountAddr = "B5B5E0924288954CE5427AC456366E7DD50837723DA10D04998AD7CE0273";
          description = "Sanam Saaber - General Counsel";
          commissionRate = 10;
          selfStaking = 100000: Nat64;
        },
        {
          accountAddr = "3BA830E39688DE354E40084C21FCB0C86E190DBDB322021C2A4843C002D5";
          description = "Barack Obama - President (Retired)";
          commissionRate = 20;
          selfStaking = 600000: Nat64;
        }
    ];

  // table of mock proposals
  let proposals =
    [ 
        {
          title = "Adjust new mining identity security deposit to 2,135 ICP";
          details = "content of \"Adjust new mining identity security deposit to 2,135 ICP\"";
          createdBy = "A19BA9C73839E92644491D0901071267D115D1FE1A1A4870C3DB5CA50228";
          excutionTime = 0: Int;
        },
        {
          title = "Reduce ICP emmissions by 10%";
          details = "content of \"Reduce ICP emmissions by 10%\"";
          createdBy = "A5AEC167AC201B67C6EF6B267361B3D2595C2EC798EB8D7DD52489BC02DC";
          excutionTime = 0: Int;
        },
        {
          title = "Add USDT support";
          details = "content of \"Add USDT support\"";
          createdBy = "CE1D6EDC4B7383D84187BB9056659DC6135EDF239F0E8DD0FB518A510257";
          excutionTime = 0: Int;
        },
    ];

  type DFNAccount = Types.DFNAccount;
  type Neuron = Types.Neuron;

  var inited = false;
  var started = false;
  var rewardAmount: Nat64 = 256: Nat64;

  var netTotalVotes: Nat64 = 0: Nat64;
  var netTotalRewardsDist: Nat64 = 0: Nat64;
  var netTotalDelegated: Nat64 = 0: Nat64;

  public query func healthcheck(): async Bool { true };

  public query func status(): async Bool { started };

  public query func totalRewardsDist(addr: Text): async Text {
    Nat64.toText(netTotalRewardsDist)
  };

  public query func totalDelegated(addr: Text): async Text {
    Nat64.toText(netTotalDelegated)
  };


  // dfx canister call nnsexplorer_sim init
  public func init() : async () {
    if inited assert(false);
    inited := true;

    await NNSExplorer.signupTests(accounts);
    await NNSExplorer.createTestNeurons(neurons);

    let p: async () = NNSExplorer.createProposalsTest(proposals);
  };

  public func createTestProposal() : async Bool {
    let now = Prim.nat64ToNat(Prim.time()/1000000000);
    await NNSExplorer.createProposalTest(proposals[now%3]);
    true
  };

  // dfx canister call nnsexplorer_sim start
  public func start(): async Text {
    if (not inited) { await init() };
    inited := true;
    if started { return "Already started!" };
    started := true;

    let l: async () = startLoop();

    "Started successfully!"
  };

  // dfx canister call nnsexplorer_sim stop
  public func stop(): async Text {
    started := false;
    "Stopped successfully!"
  };

  func startLoop() : async () {
    while(started) {
      let existings = await NNSExplorer.getNeuronListTest();
      var accounts: [DFNAccount] = [];
      var netTotalVotesTemp: Nat64 = 0: Nat64;
      var delegatorsTemp: Assoc.AssocList<Text, Nat64> = List.nil<(Text, Nat64)>();
      var delegatorsAddr: [Text] = [];
      netTotalDelegated := 0;
      for (existing in existings.vals()) {
        netTotalDelegated += existing.totalDelegations;
        netTotalVotesTemp += existing.totalDelegations + existing.selfStaking;
        let account = await NNSExplorer.getAccount(existing.accountAddr);
        switch (account) {
        case (null) { assert(false) };
        case (?account) { 
            let newAccount = {
              accountAddr = account.accountAddr;
              signature = account.signature;
              balance = account.balance;
              rewards = account.rewards + calcNeuronRewards(existing.selfStaking, existing.totalDelegations, existing.commissionRate);
              isDelegator = account.isDelegator;
            };
            accounts := Array.append<DFNAccount>(accounts, [newAccount]);
          };
        };
        
        func addDelegationRewards((addr, amount): (Text, Nat64)) {
          var rewardsAdd = calcDelegatorRewards(amount, existing.commissionRate);
          let rewardsOld = Assoc.find<Text, Nat64>(delegatorsTemp, addr, Text.equal);
          switch (rewardsOld) {
            case (null) { delegatorsAddr := Array.append<Text>(delegatorsAddr, [addr]); };
            case (?rewardsOld) {
              rewardsAdd += rewardsOld;
            };
          };
          let (delegatorsTempNew, _) =
          Assoc.replace<Text, Nat64>(delegatorsTemp, addr, Text.equal, ?rewardsAdd);
          delegatorsTemp := delegatorsTempNew;
        };
        List.iterate<(Text, Nat64)>(existing.delegations, addDelegationRewards);
      };

      for (addr in delegatorsAddr.vals()) {
        let account = await NNSExplorer.getAccount(addr);
        switch (account) {
        case (null) { assert(false) };
        case (?account) {
            let rewardsAddTotal = Assoc.find<Text, Nat64>(delegatorsTemp, addr, Text.equal);
            switch (rewardsAddTotal) {
              case (null) { assert(false) };
              case (?rewardsAddTotal) {
                let newAccount = {
                  accountAddr = account.accountAddr;
                  signature = account.signature;
                  balance = account.balance;
                  rewards = account.rewards + rewardsAddTotal;
                  isDelegator = account.isDelegator;
                };
                accounts := Array.append<DFNAccount>(accounts, [newAccount]);
              };
            };
          };
        };
      };
      await NNSExplorer.updateAccounts(accounts);

      netTotalVotes := netTotalVotesTemp;
    };
  };

  func calcNeuronRewards(selfVotes: Nat64, delegations: Nat64, commissionRate: Nat): Nat64 {
    if (netTotalVotes == Nat64.fromNat(0)) {
      return Nat64.fromNat(0);
    };
    let selfRewards: Nat64 = selfVotes * rewardAmount / netTotalVotes;
    let commission: Nat64 = delegations * rewardAmount / netTotalVotes * Nat64.fromNat(commissionRate) / Nat64.fromNat(100);

    let rewards = selfRewards + commission;
    netTotalRewardsDist += rewards;
    return rewards;
  };

  func calcDelegatorRewards(delegation: Nat64, commissionRate: Nat): Nat64 {
    if (netTotalVotes == Nat64.fromNat(0)) {
      return Nat64.fromNat(0);
    };
    let selfRewards: Nat64 = delegation * rewardAmount / netTotalVotes;
    let commission: Nat64 = selfRewards * Nat64.fromNat(commissionRate) / Nat64.fromNat(100);

    let rewards = selfRewards - commission;
    netTotalRewardsDist += rewards;
    return rewards;
  };

};