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
    name: "Test multi-stage verification process",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const user1 = accounts.get('wallet_1')!;
        const stage1Verifier = accounts.get('wallet_2')!;
        const stage2Verifier = accounts.get('wallet_3')!;
        const stage3Verifier = accounts.get('wallet_4')!;
        
        let block = chain.mineBlock([
            // Register identity
            Tx.contractCall('identity-verification', 'register-identity', [
                types.utf8("John Doe"),
                types.ascii("1990-01-01"),
                types.buff('0x1234567890123456789012345678901234567890123456789012345678901234')
            ], user1.address),
            
            // Add verifiers with specific stage permissions
            Tx.contractCall('identity-verification', 'add-verifier', [
                types.principal(stage1Verifier.address),
                types.list([types.uint(1)])
            ], deployer.address),
            
            Tx.contractCall('identity-verification', 'add-verifier', [
                types.principal(stage2Verifier.address),
                types.list([types.uint(2)])
            ], deployer.address),
            
            Tx.contractCall('identity-verification', 'add-verifier', [
                types.principal(stage3Verifier.address),
                types.list([types.uint(3)])
            ], deployer.address),
            
            // Complete verification stages
            Tx.contractCall('identity-verification', 'verify-identity-stage', [
                types.principal(user1.address),
                types.uint(1)
            ], stage1Verifier.address),
            
            Tx.contractCall('identity-verification', 'verify-identity-stage', [
                types.principal(user1.address),
                types.uint(2)
            ], stage2Verifier.address),
            
            Tx.contractCall('identity-verification', 'verify-identity-stage', [
                types.principal(user1.address),
                types.uint(3)
            ], stage3Verifier.address)
        ]);
        
        block.receipts.map(receipt => receipt.result.expectOk());
        
        // Verify final status
        let result = chain.callReadOnlyFn(
            'identity-verification',
            'is-verified',
            [types.principal(user1.address)],
            deployer.address
        );
        
        assertEquals(result.result, '(ok true)');
    },
});
