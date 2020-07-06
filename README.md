## An open dfinity NNS explorer.

![Screenshot](screenshoots/1.png)

### Demo

[Screenshot](./screenshoots/1.png)

Install the required Node modules (only needed the first time).

```bash
npm install
```

Start the replica, then build and install the canisters.

```bash
dfx start --background
dfx build
dfx canister install --all
```

Open the canister frontend in your web browser.

```bash
ID=$(xxd -u -p canisters/nnsexplorer/_canister.id)
CRC=$(python2 -c "import crc8;h=crc8.crc8();h.update('$ID'.decode('hex'));print(h.hexdigest().upper())")
xdg-open "http://127.0.0.1:8000/?canisterId=ic:$ID$CRC"
```
