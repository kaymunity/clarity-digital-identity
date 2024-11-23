import {
    Clarinet,
    Tx,
    Chain,
    Account,
    types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Test identity registration",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const user1 = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('identity-verification', 'register-identity', [
                types.utf8("John Doe"),
                types.ascii("1990-01-01"),
                types.buff('0x1234567890123456789012345678901234567890123456789012345678901234')
            ], user1.address)
        ]);
        
        block.receipts[0].result.expectOk();
    },
});

Clarinet.test({
    name: "Test verifier management",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const verifier = accounts.get('wallet_2')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('identity-verification', 'add-verifier', [
                types.principal(verifier.address)
            ], deployer.address)
        ]);
        
        block.receipts[0].result.expectOk();
    },
});

Clarinet.test({
    name: "Test identity verification",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const user1 = accounts.get('wallet_1')!;
        const verifier = accounts.get('wallet_2')!;
        
        let block = chain.mineBlock([
            // Register identity
            Tx.contractCall('identity-verification', 'register-identity', [
                types.utf8("John Doe"),
                types.ascii("1990-01-01"),
                types.buff('0x1234567890123456789012345678901234567890123456789012345678901234')
            ], user1.address),
            
            // Add verifier
            Tx.contractCall('identity-verification', 'add-verifier', [
                types.principal(verifier.address)
            ], deployer.address),
            
            // Verify identity
            Tx.contractCall('identity-verification', 'verify-identity', [
                types.principal(user1.address)
            ], verifier.address)
        ]);
        
        block.receipts.map(receipt => receipt.result.expectOk());
    },
});
