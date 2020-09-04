import Prim "mo:prim";
import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Nat64 "mo:base/Nat64";
import Word32 "mo:base/Word32";
import List "mo:base/List";
import Assoc "mo:base/AssocList";
import Text "mo:base/Text";
import Types "../types";
import KeyID "../key/id";

module {
  type NewProposal = Types.NewDFNProposal;
  type Proposal = Types.DFNProposal;
  type ProposalID = Text;

  public class ProposalHashMap() {
    // The "database" is just a local hash map
    let hashMap = HashMap.HashMap<Text, Proposal>(1, Text.equal, Text.hash);

    public func createProposal(newProposal: NewProposal) {
      let proposal = makeProposal(newProposal);
      hashMap.put(calProposalID(proposal), proposal);
    };

    public func updateProposal(proposal: Proposal) {
      hashMap.put(calProposalID(proposal), proposal);
    };

    public func voteProposal(account: Text, id: Text, approve: Bool) {
      let existing = hashMap.get(id);
      switch (existing) {
        case (?existing) {
          let (newVotes, _) =
          Assoc.replace<Text, Bool>(existing.votes, account, Text.equal, ?approve);
          let new = {
            title = existing.title;
            details = existing.details;
            created = existing.created;
            votes = newVotes;
            excutionTime = existing.excutionTime;
            status = existing.status;
          };
          hashMap.put(id, new);
        };
        case (null) { };
      };
    };

    public func updateStatus(id: Text, newStatus: Text) {
      let existing = hashMap.get(id);
      switch (existing) {
        case (?existing) {
          let new = {
            title = existing.title;
            details = existing.details;
            created = existing.created;
            votes = existing.votes;
            excutionTime = existing.excutionTime;
            status = newStatus;
          };
          hashMap.put(id, new);
        };
        case (null) { };
      };
    };

    public func findProposalByID(id: Text): ?Proposal {
      hashMap.get(id)
    };

    public func findByTitle(term: Text): [Proposal] {
      var proposals: [Proposal] = [];
      for ((id, proposal) in hashMap.entries()) {
        let title = proposal.title; // # " " #;
        if (includesText(title, term)) {
          proposals := Array.append<Proposal>(proposals, [proposal]);
        };
      };
      proposals
    };

    public func findList(): [Proposal] {
      var proposals: [Proposal] = [];
      for ((id, proposal) in hashMap.entries()) {
        proposals := Array.append<Proposal>(proposals, [proposal]);
      };
      proposals
    };

    // Helpers

    func makeProposal(newProposal: NewProposal): Proposal {
      var approve = true;
      let (selfVote, _) =
      Assoc.replace<Text, Bool>(List.nil<(Text, Bool)>(), newProposal.createdBy, Text.equal, ?approve);
      {
        title = newProposal.title;
        details = newProposal.details;
        created = (newProposal.createdBy, Prim.nat64ToNat(Prim.time()/1000000000)); //ns to s
        votes = selfVote;
        excutionTime = newProposal.excutionTime;
        status = "active";
      }
    };

    public func calProposalID(proposal: Proposal): ProposalID {
      let (account, time) = proposal.created;
      account # Word32.toText(Word32.fromInt(time))
    };

    func includesText(string: Text, term: Text): Bool {
      let stringArray = Iter.toArray<Char>(string.chars());
      let termArray = Iter.toArray<Char>(term.chars());

      var i = 0;
      var j = 0;

      while (i < stringArray.size() and j < termArray.size()) {
        if (stringArray[i] == termArray[j]) {
          i += 1;
          j += 1;
          if (j == termArray.size()) { return true; }
        } else {
          i += 1;
          j := 0;
        }
      };
      false
    };
  };
};
