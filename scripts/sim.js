const fetch = require("node-fetch");
const fs = require("fs");
const os = require("os");
const path = require("path");
const { crc8 } = require("node-crc");
const { Crypto } = require("node-webcrypto-ossl");

global.crypto = new Crypto();

const { defaults, dfx } = require("../dfx.json");
const DFX_VERSION = dfx;
const DEFAULT_HOST = `http://${defaults.start.address}:${defaults.start.port}`;
const OUTPUT_DIR = defaults.build.output;

const userLib = require(path.join(
    os.homedir(),
    "/.cache/dfinity/versions/",
    DFX_VERSION,
    "/js-user-library/src"
));
const {
    generateKeyPair,
    HttpAgent,
    makeActorFactory,
    makeAuthTransform,
    makeNonceTransform,
} = userLib;

// addSimulatedData
const addSimulatedData = async() => {
    console.log("Adding data...");
    const simData = require("./sim-data");
    simData.forEach(async(data) => {
        const nnsexplorerSim = await getActor("nnsexplorer");
        await nnsexplorerSim.createProfile(data);
        console.log("...data added");
    });
};

// Helpers
const getActor = (
    canisterName,
    host = DEFAULT_HOST,
    keypair = generateKeyPair()
) => {
    const candid = eval(getCandid(canisterName));
    const canisterId = getCanisterId(canisterName);
    const httpAgent = new HttpAgent({ host: host, fetch: fetch });
    httpAgent.addTransform(makeNonceTransform());
    httpAgent.addTransform(makeAuthTransform(keypair));
    return makeActorFactory(candid)({ canisterId, httpAgent });
};

const getCanisterPath = (canisterName) =>
    path.join(__dirname, "..", OUTPUT_DIR, canisterName);

const getCandid = (canisterName) =>
    fs
    .readFileSync(`${getCanisterPath(canisterName)}/main.did.js`)
    .toString()
    .replace("export default ", "");

const format = (canisterId) => canisterId.toString("hex").toUpperCase();
const getCanisterId = (canisterName) => {
    let id = fs.readFileSync(`${getCanisterPath(canisterName)}/_canister.id`);
    return `ic:${format(id)}${format(crc8(id))}`;
};

// Run addSimulatedData()
addSimulatedData();