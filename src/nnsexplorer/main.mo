// Make the Connectd app's public methods available locally
import Prelude "mo:base/Prelude";
import Prim "mo:prim";
import ProfileDB "../database/profiledb";
import Types "./types";
import Helper "./helper";

type NewProfile = Types.NewProfile;
type Profile = Types.Profile;
type UserId = Types.UserId;

actor nnsexplorer {
  var profileDb: ProfileDB.ProfileHashMap = ProfileDB.ProfileHashMap();

  // Healthcheck
  public func healthcheck(): async Bool { true };

  // Profiles
  public shared(msg) func createProfile(profile: NewProfile): async () {
    profileDb.createOne(msg.caller, profile);
  };

  // ============================================================================================
  // dfx canister call nnsexplorer createProfileByInputs '("0xtest", "HashQuark Limit", "5")'
  // ============================================================================================
  public shared {
    caller = caller;
  } func createProfileByInputs(addr: Text, disc: Text, com: Text): async Text {
    var testProfile: NewProfile = {
      accountAddr = addr;
      description = disc;
      commissionRate = com;
    };

    profileDb.createOne(caller, testProfile);
    return "Created a new profile: " # testProfile.accountAddr # "!";
  };

  public shared(msg) func update(profile: Profile): async () {
    if(Helper.hasAccess(msg.caller, profile)) {
      profileDb.updateOne(profile.id, profile);
    };
  };

  public query func get(userId: UserId): async Profile {
    Helper.getProfile(profileDb, userId)
  };

  // ============================================================================================
  // dfx canister call nnsexplorer getSelf
  // ============================================================================================
  public shared {
    caller = caller;
  } func getSelf(): async Text {
    var result = Helper.getProfile(profileDb, caller);
    return "{\nAccount Address: " # result.accountAddr # "\nDescription: " # result.description # "\nCommission Rate: " # result.commissionRate # "\n}";
  };

  public query func search(term: Text): async [Profile] {
    profileDb.findBy(term)
  };

  // ============================================================================================
  // dfx canister call nnsexplorer showList
  // ============================================================================================
  public query func showList(): async Text {
    var results = profileDb.findList();
    var fullResultStr = "[";
    var i = 0;
    for (result in results.vals()) {
      if (i != 0) {
        fullResultStr #= ",";
      };
      let str = "{\n\"Account Address\": \"" # result.accountAddr # "\",\n\"Description\": \"" # result.description # "\",\n\"Commission Rate\": \"" # result.commissionRate # "\"\n}";
      fullResultStr #= str;
      i += 1;
    };
    fullResultStr #= "]";
    return fullResultStr;
  };


  // // Connections

  // public shared(msg) func connect(userId: UserId): async () {
  //   // Call Connectd's public methods without an API
  //   await Connectd.connect(msg.caller, userId);
  // };

  // public func getConnections(userId: UserId): async [Profile] {
  //   let userIds = await Connectd.getConnections(userId);
  //   profileDb.findMany(userIds)
  // };

  // public shared(msg) func isConnected(userId: UserId): async Bool {
  //   let userIds = await Connectd.getConnections(msg.caller);
  //   Helper.includes(userId, userIds)
  // };

  // User Auth

  public shared query(msg) func getOwnId(): async UserId { msg.caller }

};
