;; GeoToken: Secure Location Sharing Token

;; Error Constants
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_INSUFFICIENT_BALANCE (err u401))
(define-constant ERR_MINT_FAILED (err u500))
(define-constant ERR_BURN_FAILED (err u501))

;; Token Parameters
(define-constant TOKEN_NAME "GeoToken")
(define-constant TOKEN_SYMBOL "GEO")
(define-constant TOKEN_DECIMALS u6)

;; Admin Principal (contract deployer)
(define-data-var contract-owner principal tx-sender)

;; Token Balance Tracking
(define-map balances principal uint)
(define-map allowances {owner: principal, spender: principal} uint)

;; Total Supply Tracking
(define-data-var total-supply uint u0)

;; Authorization Check
(define-private (is-contract-owner (user principal))
  (is-eq user (var-get contract-owner)))

;; Get Token Balance
(define-read-only (get-balance (user principal))
  (default-to u0 (map-get? balances user)))

;; Get Total Supply
(define-read-only (get-total-supply)
  (var-get total-supply))

;; Token Name (SIP-010)
(define-read-only (get-name)
  (ok TOKEN_NAME))

;; Token Symbol (SIP-010)
(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL))

;; Token Decimals (SIP-010)
(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS))

;; Mint Tokens (Admin Only)
(define-public (mint (amount uint) (recipient principal))
  (begin
    ;; Validate sender is contract owner
    (asserts! (is-contract-owner tx-sender) ERR_UNAUTHORIZED)
    
    ;; Update total supply and recipient balance
    (var-set total-supply (+ (var-get total-supply) amount))
    (map-set balances recipient 
      (+ (default-to u0 (map-get? balances recipient)) amount))
    
    (ok true)
  )
)

;; Burn Tokens
(define-public (burn (amount uint))
  (let 
    ((sender tx-sender)
     (current-balance (default-to u0 (map-get? balances sender))))
    
    ;; Validate sufficient balance
    (asserts! (>= current-balance amount) ERR_INSUFFICIENT_BALANCE)
    
    ;; Update total supply and sender balance
    (var-set total-supply (- (var-get total-supply) amount))
    (map-set balances sender (- current-balance amount))
    
    (ok true)
  )
)

;; Transfer Tokens
(define-public (transfer (amount uint) (recipient principal))
  (let 
    ((sender tx-sender)
     (sender-balance (default-to u0 (map-get? balances sender))))
    
    ;; Validate sufficient balance
    (asserts! (>= sender-balance amount) ERR_INSUFFICIENT_BALANCE)
    
    ;; Update sender and recipient balances
    (map-set balances sender (- sender-balance amount))
    (map-set balances recipient 
      (+ (default-to u0 (map-get? balances recipient)) amount))
    
    (ok true)
  )
)

;; Approve Spending Allowance
(define-public (approve (spender principal) (amount uint))
  (begin
    ;; Set allowance for spender
    (map-set allowances {owner: tx-sender, spender: spender} amount)
    (ok true)
  )
)

;; Transfer From (with Allowance)
(define-public (transfer-from (owner principal) (recipient principal) (amount uint))
  (let 
    ((current-allowance (default-to u0 (map-get? allowances {owner: owner, spender: tx-sender})))
     (owner-balance (default-to u0 (map-get? balances owner))))
    
    ;; Validate allowance and owner balance
    (asserts! (>= current-allowance amount) ERR_UNAUTHORIZED)
    (asserts! (>= owner-balance amount) ERR_INSUFFICIENT_BALANCE)
    
    ;; Update allowance, owner, and recipient balances
    (map-set allowances {owner: owner, spender: tx-sender} (- current-allowance amount))
    (map-set balances owner (- owner-balance amount))
    (map-set balances recipient 
      (+ (default-to u0 (map-get? balances recipient)) amount))
    
    (ok true)
  )
)

;; Optional: Change Contract Owner
(define-public (change-contract-owner (new-owner principal))
  (begin
    ;; Only current owner can change ownership
    (asserts! (is-contract-owner tx-sender) ERR_UNAUTHORIZED)
    (var-set contract-owner new-owner)
    (ok true)
  )
)