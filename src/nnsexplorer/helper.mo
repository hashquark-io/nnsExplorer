import Array "mo:base/Array";
import Option "mo:base/Option";
import ProfileDB "../database/profiledb";
import Types "../nnsexplorer/types";

module {
  type NewProfile = Types.NewProfile;
  type Profile = Types.Profile;
  type UserId = Types.UserId;

  // Profiles
  
  public func getProfile(profileDb: ProfileDB.ProfileHashMap, userId: UserId): Profile {
    let existing = profileDb.findOne(userId);
    switch (existing) {
      case (?existing) { existing };
      case (null) {
        {
          id = userId;
          accountAddr = "";
          totalNeurons = "";
          description = "";
          commissionRate = "";
        }
      };
    };
  };


  // Connections

  public func includes(x: UserId, xs: [UserId]): Bool {
    func isX(y: UserId): Bool { x == y };
    switch (Array.find<UserId>(isX, xs)) {
      case (null) { false };
      case (_) { true };
    };
  };


  // Authorization

  let adminIds: [UserId] = [];

  public func isAdmin(userId: UserId): Bool {
    func identity(x: UserId): Bool { x == userId };
    Option.isSome(Array.find<UserId>(identity, adminIds))
  };

  public func hasAccess(userId: UserId, profile: Profile): Bool {
    userId == profile.id or isAdmin(userId)
  };
};
