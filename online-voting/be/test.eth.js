const { ethers } = require("ethers");

async function run() {
    console.log("Connecting...");
    const provider = new ethers.JsonRpcProvider("http://op-geth.default.svc.cluster.local:8545");
    const network = await provider.getNetwork();
    console.log("Connected to chain:", network.chainId.toString());
}

run().catch(console.error);
