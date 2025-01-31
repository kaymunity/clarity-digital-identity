# Digital Identity Verification System

A blockchain-based digital identity verification system that allows users to:

- Register their identity information securely on the blockchain
- Complete a multi-stage verification process
- Get verified by authorized verifiers for specific stages
- Track verification history across stages
- Check verification status of identities
- Manage authorized verifiers with stage-specific permissions

## Features

- Secure identity registration with hashed ID documents
- Multi-stage verification process (3 stages)
- Stage-specific authorized verifier system
- Comprehensive verification history tracking
- Timestamp-based verification tracking
- Owner-controlled verifier management with stage permissions
- Verification status safeguards and stage completion requirements
- Identity revocation system with timestamp tracking
- Revocation status checks in verification process

## Security

- Only authorized verifiers can verify specific stages
- Identity information is stored securely with hashing
- Contract owner controls verifier access and stage permissions
- Verification stages must be completed sequentially
- Complete verification history is maintained
- Verification status cannot be tampered with
- Revoked identities cannot be re-verified without re-registration

## Use Cases

- KYC compliance with multiple verification layers
- Enhanced digital identity verification
- Decentralized identity management
- Multi-party verification workflows
- Regulatory compliance requiring multiple verification steps
- Identity revocation for compromised or fraudulent accounts

## Recent Enhancements

Added identity revocation functionality:
- Contract owner can revoke verified identities
- Revoked identities cannot proceed with verification
- Verification status checks include revocation status
- Revocation dates are tracked for audit purposes
