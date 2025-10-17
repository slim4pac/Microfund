;; ------------------------------------------------------------
;; MicroFund - Decentralized Microloan & Repayment Contract
;; ------------------------------------------------------------
;; Enables users to request and fund small peer-to-peer loans
;; directly on the Stacks blockchain.
;; ------------------------------------------------------------

(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_NOT_FOUND (err u101))
(define-constant ERR_ALREADY_FUNDED (err u102))
(define-constant ERR_INVALID_REPAY (err u103))
(define-constant ERR_NO_FUNDS (err u104))

(define-data-var next-loan-id uint u0)

;; Data structure for loan storage
(define-map loans
  {id: uint}
  {
    borrower: principal,
    lender: (optional principal),
    amount: uint,
    interest: uint,
    duration: uint,
    start-block: (optional uint),
    repaid: bool,
    active: bool
  }
)

;; Print events using print function instead of define-event
(define-private (print-loan-requested (id uint) (borrower principal) (amount uint) (interest uint) (duration uint))
  (print {event: "loan-requested", id: id, borrower: borrower, amount: amount, interest: interest, duration: duration})
)

(define-private (print-loan-funded (id uint) (lender principal))
  (print {event: "loan-funded", id: id, lender: lender})
)

(define-private (print-loan-repaid (id uint) (borrower principal) (total uint))
  (print {event: "loan-repaid", id: id, borrower: borrower, total: total})
)

(define-private (print-loan-cancelled (id uint) (borrower principal))
  (print {event: "loan-cancelled", id: id, borrower: borrower})
)

;; Rest of the contract functions updated to use print instead of emit-event
(define-public (request-loan (amount uint) (interest uint) (duration uint))
  (begin
    (asserts! (> amount u0) (err u105))
    (let ((new-id (+ (var-get next-loan-id) u1)))
      (map-set loans {id: new-id}
        {
          borrower: tx-sender,
          lender: none,
          amount: amount,
          interest: interest,
          duration: duration,
          start-block: none,
          repaid: false,
          active: true
        })
      (var-set next-loan-id new-id)
      (print-loan-requested new-id tx-sender amount interest duration)
      (ok new-id)
    )
  )
)

;; ... existing fund-loan function with print-loan-funded ...
(define-public (fund-loan (loan-id uint))
  (let ((loan (map-get? loans {id: loan-id})))
    (match loan
      loan-data
      (begin
        (asserts! (is-none (get lender loan-data)) ERR_ALREADY_FUNDED)
        (try! (stx-transfer? (get amount loan-data) tx-sender (get borrower loan-data)))
        (map-set loans {id: loan-id}
          (merge loan-data {lender: (some tx-sender), start-block: (some stacks-block-height)}))
        (print-loan-funded loan-id tx-sender)
        (ok "Loan successfully funded")
      )
      ERR_NOT_FOUND
    )
  )
)

;; ... existing repay-loan function with print-loan-repaid ...
(define-public (repay-loan (loan-id uint))
  (let ((loan (map-get? loans {id: loan-id})))
    (match loan
      loan-data
      (begin
        (asserts! (is-eq tx-sender (get borrower loan-data)) ERR_UNAUTHORIZED)
        (asserts! (is-some (get lender loan-data)) ERR_NOT_FOUND)
        (let ((total (+ (get amount loan-data)
                        (/ (* (get amount loan-data) (get interest loan-data)) u100)))
              (lender (unwrap! (get lender loan-data) ERR_NOT_FOUND)))
          (try! (stx-transfer? total tx-sender lender))
          (map-set loans {id: loan-id}
            (merge loan-data {repaid: true, active: false}))
          (print-loan-repaid loan-id tx-sender total)
          (ok "Loan repaid successfully")
        )
      )
      ERR_NOT_FOUND
    )
  )
)

;; ... existing cancel-loan function with print-loan-cancelled ...
(define-public (cancel-loan (loan-id uint))
  (let ((loan (map-get? loans {id: loan-id})))
    (match loan
      loan-data
      (begin
        (asserts! (is-eq tx-sender (get borrower loan-data)) ERR_UNAUTHORIZED)
        (asserts! (is-none (get lender loan-data)) ERR_ALREADY_FUNDED)
        (map-set loans {id: loan-id} (merge loan-data {active: false}))
        (print-loan-cancelled loan-id tx-sender)
        (ok "Loan cancelled")
      )
      ERR_NOT_FOUND
    )
  )
)

;; ... existing get-loan-info function ...
(define-read-only (get-loan-info (loan-id uint))
  (ok (map-get? loans {id: loan-id}))
)