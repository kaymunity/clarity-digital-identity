;; Digital Identity Verification Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-already-registered (err u101)) 
(define-constant err-not-registered (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-stage (err u104))
(define-constant err-stage-not-complete (err u105))

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
        verification-history: (list 10 {stage: uint, verifier: principal, timestamp: uint})
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
            verification-history: (list)
        }))
    ))
)

(define-public (verify-identity-stage (user principal) (stage uint))
    (let (
        (identity (map-get? identities user))
        (current-stage (get verification-stage (unwrap-panic identity)))
    )
    (if (and (is-some identity) (can-verify-stage tx-sender stage))
        (if (is-eq current-stage (- stage u1))
            (ok (map-set identities user (merge (unwrap-panic identity) {
                verification-stage: stage,
                verification-history: (unwrap-panic (as-max-len? 
                    (concat (get verification-history (unwrap-panic identity)) 
                    (list {stage: stage, verifier: tx-sender, timestamp: block-height}))
                    u10))
                ,verified: (is-eq stage u3)
                ,verification-date: (if (is-eq stage u3) block-height (get verification-date (unwrap-panic identity)))
            })))
            err-stage-not-complete
        )
        err-unauthorized
    ))
)

(define-public (add-verifier (verifier principal) (stages (list 5 uint)))
    (if (is-owner)
        (ok (map-set authorized-verifiers verifier {authorized: true, allowed-stages: stages}))
        err-not-owner
    )
)

(define-public (remove-verifier (verifier principal))
    (if (is-owner)
        (ok (map-set authorized-verifiers verifier {authorized: false, allowed-stages: (list)}))
        err-not-owner
    )
)

;; Read-only Functions
(define-read-only (get-identity (user principal))
    (ok (map-get? identities user))
)

(define-read-only (get-verification-stage (user principal))
    (let (
        (identity (map-get? identities user))
    )
    (if (is-some identity)
        (ok (get verification-stage (unwrap-panic identity)))
        err-not-registered
    ))
)

(define-read-only (get-verification-history (user principal))
    (let (
        (identity (map-get? identities user))
    )
    (if (is-some identity)
        (ok (get verification-history (unwrap-panic identity)))
        err-not-registered
    ))
)

(define-read-only (is-verified (user principal))
    (let (
        (identity (map-get? identities user))
    )
    (if (is-some identity)
        (ok (get verified (unwrap-panic identity)))
        err-not-registered
    ))
)
