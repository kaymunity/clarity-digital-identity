;; Digital Identity Verification Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-already-registered (err u101))
(define-constant err-not-registered (err u102))
(define-constant err-unauthorized (err u103))

;; Data Variables
(define-map identities
    principal
    {
        full-name: (string-utf8 100),
        dob: (string-ascii 10),
        id-hash: (buff 32),
        verified: bool,
        verification-date: uint
    }
)

(define-map authorized-verifiers principal bool)

;; Private Functions
(define-private (is-owner)
    (is-eq tx-sender contract-owner)
)

(define-private (is-authorized-verifier)
    (default-to false (map-get? authorized-verifiers tx-sender))
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
            verification-date: u0
        }))
    ))
)

(define-public (verify-identity (user principal))
    (let (
        (identity (map-get? identities user))
    )
    (if (and (is-authorized-verifier) (is-some identity))
        (ok (map-set identities user (merge (unwrap-panic identity) {
            verified: true,
            verification-date: block-height
        })))
        err-unauthorized
    ))
)

(define-public (add-verifier (verifier principal))
    (if (is-owner)
        (ok (map-set authorized-verifiers verifier true))
        err-not-owner
    )
)

(define-public (remove-verifier (verifier principal))
    (if (is-owner)
        (ok (map-set authorized-verifiers verifier false))
        err-not-owner
    )
)

;; Read-only Functions
(define-read-only (get-identity (user principal))
    (ok (map-get? identities user))
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
