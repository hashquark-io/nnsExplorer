// import Array "mo:base/Array";
// import HashMap "mo:base/HashMap";
// import Iter "mo:base/Iter";
// import Option "mo:base/Option";
// import Nat64 "mo:base/Nat64";
// import Text "mo:base/Text";
// import Types "../types";
// import KeyID "../key/id";

// module {
//   type NewNeuron = Types.NewNeuron;
//   type Neuron = Types.Neuron;

//   public class NeuronHashMap() {
//     // The "database" is just a local hash map
//     let hashMap = HashMap.HashMap<Text, Neuron>(1, isEq, Text.hash);

//     public func createOne(neuron: NewNeuron) {
//       hashMap.put(neuron.accountAddr, makeNeuron(neuron));
//     };

//     public func updateDelegation(fromAddr: Text, toAddr: Text, amount: Nat64): Bool {
//       let existing = findNeuron(toAddr);
//       switch (existing) {
//         case (?existing) {
//           if (fromAddr == toAddr) {
//             let neuron = {
//               accountAddr = existing.accountAddr;
//               description = existing.description;
//               commissionRate = existing.commissionRate;
//               selfStaking = existing.selfStaking + amount;
//               totalDelegations = existing.totalDelegations;
//             };
//             hashMap.put(toAddr, neuron);
//           } else {
//             let neuron = {
//               accountAddr = existing.accountAddr;
//               description = existing.description;
//               commissionRate = existing.commissionRate;
//               selfStaking = existing.selfStaking;
//               totalDelegations = existing.totalDelegations + amount;
//             };
//             hashMap.put(toAddr, neuron);
//           };

//           true
//         };
//         case (null) { false };
//       };
//     };

//     public func updateOne(neuron: Neuron) {
//       hashMap.put(neuron.accountAddr, neuron);
//     };

//     public func findNeuron(accountAddr: Text): ?Neuron {
//       hashMap.get(accountAddr)
//     };

//     public func findMany(accountAddrs: [Text]): [Neuron] {
//       func getNeuron(addr: Text): Neuron {
//         Option.unwrap<Neuron>(hashMap.get(addr))
//       };
//       Array.map<Text, Neuron>(accountAddrs, getNeuron)
//     };

//     public func findBy(term: Text): [Neuron] {
//       var neurons: [Neuron] = [];
//       for ((id, neuron) in hashMap.entries()) {
//         let address = neuron.accountAddr; // # " " #;
//         if (includesText(address, term)) {
//           neurons := Array.append<Neuron>(neurons, [neuron]);
//         };
//       };
//       neurons
//     };

//     public func findList(): [Neuron] {
//       var neurons: [Neuron] = [];
//       for ((id, neuron) in hashMap.entries()) {
//         neurons := Array.append<Neuron>(neurons, [neuron]);
//       };
//       neurons
//     };

//     // Helpers

//     func makeNeuron(neuron: NewNeuron): Neuron {
//       {
//         accountAddr = neuron.accountAddr;
//         description = neuron.description;
//         commissionRate = neuron.commissionRate;
//         selfStaking = neuron.selfStaking;
//         totalDelegations = Nat64.fromNat(0);
//       }
//     };

//     func includesText(string: Text, term: Text): Bool {
//       let stringArray = Iter.toArray<Char>(string.chars());
//       let termArray = Iter.toArray<Char>(term.chars());

//       var i = 0;
//       var j = 0;

//       while (i < stringArray.size() and j < termArray.size()) {
//         if (stringArray[i] == termArray[j]) {
//           i += 1;
//           j += 1;
//           if (j == termArray.size()) { return true; }
//         } else {
//           i += 1;
//           j := 0;
//         }
//       };
//       false
//     };
//   };

//   func isEq(x: Text, y: Text): Bool { x == y };
// };
