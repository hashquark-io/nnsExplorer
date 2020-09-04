## An open demo for DFINITY NNS Explorer.

## Screenshots

### Overview

![Screenshots](screenshots/screenshot1.png)

### Profile page

![Screenshots](screenshots/screenshot2.png)

### Neuron details

![Screenshots](screenshots/screenshot3.png)

### Proposal page

![Screenshots](screenshots/screenshot4.png)

## Installation steps

Install the required Node modules (only needed the first time).

```bash
npm install
```

Start the replica, then build and install the canisters.

```bash
dfx start --background
dfx canister create --all
dfx build
dfx canister install --all
```

Open the URL printed by following command in your web browser. (http://127.0.0.1:8000/?canisterId=*******************)

```bash
echo "http://localhost:8000/?canisterId=$(dfx canister id nnsexplorer_assets)"
```

## Description and presentation

This demo runs [Internet Computer] as a canister with mock data for DFINITY NNS(Network Neuron System), but it's still a WIP. It shows informations about the system(now mock data), and you can use it to do delegation, withdraw rewards, and even to become a neuron and earn rewards. To start or stop the simulation for running with mock data, use following commands:

```bash
dfx canister call nnsexplorer_sim start // Start simulation
dfx canister call nnsexplorer_sim stop // Stop simulation
```

[Internet Computer]: https://dfinity.org/