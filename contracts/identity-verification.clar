;; Digital Identity Verification Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-already-registered (err u101)) 
(define-constant err-not-registered (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-stage (err u104))
(define-constant err-stage-not-complete (err u105))
(define-constant err-identity-revoked (err u106))
(define-constant err-cooldown-active (err u107))
(define-constant err-verification-expired (err u108))
(define-constant err-invalid-input (err u109))

;; Configuration
(define-constant verification-cooldown u100) ;; blocks
(define-constant verification-expiry u52560) ;; ~1 year in blocks

;; Data Variables
(define-map identities
    principal
    {
        full-name: (string-utf8 100),
        dob: (string-ascii 10), 
        id-hash: (buff 32),
        verified: bool,
        verification-date: uint,
        verification-stage: uint,
        verification-history: (list 10 {stage: uint, verifier: principal, timestamp: uint}),
        revoked: bool,
        revocation-date: uint,
        last-attempt: uint,
        attempt-count: uint
    }
)

(define-map authorized-verifiers 
    principal 
    {authorized: bool, allowed-stages: (list 5 uint)}
)

;; Private Functions
(define-private (is-owner)
    (is-eq tx-sender contract-owner)
)

(define-private (can-verify-stage (verifier principal) (stage uint))
    (let (
        (verifier-info (map-get? authorized-verifiers verifier))
    )
    (and 
        (is-some verifier-info)
        (get authorized (unwrap-panic verifier-info))
        (includes stage (get allowed-stages (unwrap-panic verifier-info)))
    ))
)

(define-private (check-verification-validity (identity {verified: bool, verification-date: uint}))
    (< (- block-height (get verification-date identity)) verification-expiry)
)

(define-private (check-cooldown (identity {last-attempt: uint}))
    (> verification-cooldown (- block-height (get last-attempt identity)))
)

;; Public Functions
(define-public (register-identity (full-name (string-utf8 100)) (dob (string-ascii 10)) (id-hash (buff 32)))
    (let (
        (existing-identity (map-get? identities tx-sender))
    )
    (if (is-some existing-identity)
        err-already-registered
        (ok (map-set identities tx-sender {
            full-name: full-name,
            dob: dob,
            id-hash: id-hash,
            verified: false,
            verification-date: u0,
            verification-stage: u0,
            verification-history: (list),
            revoked: false,
            revocation-date: u0,
            last-attempt: u0,
            attempt-count: u0
        })))
    ))
)

;; [Additional updated functions...]
