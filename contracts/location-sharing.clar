;; GeoToken: Secure Location Sharing Contract
;; A privacy-preserving platform for tokenized location data management

;; Error Codes
(define-constant ERR_UNAUTHORIZED u403)
(define-constant ERR_LOCATION_NOT_FOUND u404)
(define-constant ERR_INSUFFICIENT_PERMISSIONS u405)
(define-constant ERR_INVALID_ENCRYPTION_KEY u406)

;; Data Structures
;; Location data with encryption hints and privacy settings
(define-map locations 
  { user: principal }
  {
    encrypted-location: (buff 256),  ;; Location data encrypted
    encryption-key-hash: (buff 32),  ;; Hash of the encryption key
    privacy-level: uint,             ;; 0-100 privacy granularity
    last-updated: uint               ;; Timestamp of last update
  }
)

;; Permission map for location access
(define-map location-permissions
  { 
    owner: principal, 
    viewer: principal 
  }
  {
    access-level: uint,     ;; Granular access permissions
    valid-until: uint       ;; Expiration of permission
  }
)

;; Access token tracking
(define-map access-tokens
  { token-id: uint }
  {
    owner: principal,
    location-owner: principal,
    access-level: uint,
    valid-until: uint
  }
)

;; Tracks the next available access token ID
(define-data-var next-token-id uint u0)

;; Private Helper Functions
;; Validate encryption key format and basic security
(define-private (is-valid-encryption-key (key (buff 32)))
  (and 
    (> (len key) u0)
    (< (len key) u33)
  )
)

;; Authenticate location owner
(define-private (is-location-owner (user principal))
  (is-some (map-get? locations { user: user }))
)

;; Public Read-Only Functions
;; Check if a viewer has permission to access a location
(define-read-only (has-location-permission 
  (owner principal) 
  (viewer principal)
)
  (match (map-get? location-permissions { owner: owner, viewer: viewer })
    permission (> (get access-level permission) u0)
    false
  )
)

;; Public Functions
;; Add or update encrypted location
(define-public (set-location 
  (encrypted-location (buff 256))
  (encryption-key-hash (buff 32))
  (privacy-level uint)
)
  (begin
    ;; Authorization: Only the location owner can set their location
    (asserts! (is-eq tx-sender contract-caller) (err ERR_UNAUTHORIZED))
    
    ;; Validate encryption key
    (asserts! (is-valid-encryption-key encryption-key-hash) 
              (err ERR_INVALID_ENCRYPTION_KEY))
    
    ;; Store or update location
    (map-set locations 
      { user: tx-sender }
      {
        encrypted-location: encrypted-location,
        encryption-key-hash: encryption-key-hash,
        privacy-level: privacy-level,
        last-updated: block-height
      }
    )
    
    (ok true)
  )
)

;; Grant location access permission
(define-public (grant-location-access 
  (viewer principal)
  (access-level uint)
  (valid-duration uint)
)
  (let 
    (
      (current-time block-height)
      (expiration (+ current-time valid-duration))
    )
    ;; Authorization: Only location owner can grant permissions
    (asserts! (is-location-owner tx-sender) (err ERR_UNAUTHORIZED))
    
    ;; Set permission
    (map-set location-permissions 
      { owner: tx-sender, viewer: viewer }
      {
        access-level: access-level,
        valid-until: expiration
      }
    )
    
    (ok true)
  )
)

;; Revoke location access
(define-public (revoke-location-access (viewer principal))
  (begin
    ;; Authorization: Only location owner can revoke
    (asserts! (is-location-owner tx-sender) (err ERR_UNAUTHORIZED))
    
    ;; Delete permission entry
    (map-delete location-permissions 
      { owner: tx-sender, viewer: viewer }
    )
    
    (ok true)
  )
)

;; Issue a time-limited access token
(define-public (issue-access-token 
  (location-owner principal)
  (access-level uint)
  (valid-duration uint)
)
  (let 
    (
      (current-token-id (var-get next-token-id))
      (current-time block-height)
      (expiration (+ current-time valid-duration))
    )
    ;; Authorization: Only location owner can issue tokens
    (asserts! (is-location-owner location-owner) (err ERR_UNAUTHORIZED))
    
    ;; Create access token
    (map-set access-tokens 
      { token-id: current-token-id }
      {
        owner: tx-sender,
        location-owner: location-owner,
        access-level: access-level,
        valid-until: expiration
      }
    )
    
    ;; Increment token ID
    (var-set next-token-id (+ current-token-id u1))
    
    (ok current-token-id)
  )
)

;; Retrieve location with proper access validation
(define-read-only (get-location-if-authorized 
  (user principal)
  (viewer principal)
)
  (let 
    (
      (location-data (map-get? locations { user: user }))
      (permission 
        (map-get? location-permissions 
          { owner: user, viewer: viewer }
        )
      )
    )
    (match location-data
      loc 
        (match permission
          perm 
            ;; Check if permission is valid and not expired
            (if 
              (and 
                (> (get access-level perm) u0)
                (<= block-height (get valid-until perm))
              )
              (some loc)
              none
            )
          none
        )
      none
    )
  )
)