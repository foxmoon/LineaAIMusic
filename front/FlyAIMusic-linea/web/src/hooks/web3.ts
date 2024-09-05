import {web3Accounts, web3Enable} from "@polkadot/extension-dapp";
import { ApiPromise, WsProvider } from '@polkadot/api';
// 连接钱包
export const getWeb3Accounts = async () => {
    // Enable the Polkadot.js extension
    const extensions = await web3Enable('Polkadot Wallet Login1');
    console.log(extensions.length);
    if (extensions.length === 0) {
        return [];
    }

    // Get all accounts from the extension
    const allAccounts = await web3Accounts();
    return allAccounts;
};


export const payNFT = async () => {
    const provider = new WsProvider('ws://47.106.245.127:9944'); // Polkadot public RPC endpoint
    const api = await ApiPromise.create({provider});

};