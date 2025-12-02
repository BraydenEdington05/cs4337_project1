;; Name: Brayden Edington
;; NetID: bre220001
;; CS/SE 3377 - Project: Prefix Calculator
;; Due: Oct 24, 2025

#lang racket

;; -------------------------------------------------------------
;; Determine whether the program runs in interactive or batch mode
;; -------------------------------------------------------------
(define interactive? 
  (let [(args (current-command-line-arguments))]
    (cond
      [(= (vector-length args) 0) #t]                ; no args → interactive mode
      [(string=? (vector-ref args 0) "-b") #f]       ; -b → batch mode
      [(string=? (vector-ref args 0) "--batch") #f]  ; --batch → batch mode
      [else #t])))                                   ; anything else → interactive

;; helper for checking string prefixes
(define (string-prefix? prefix str)
  (and (<= (string-length prefix) (string-length str))
       (string=? (substring str 0 (string-length prefix)) prefix)))

;; List of valid operators
(define valid-operators (list '+ '- '* '/))

;; Helper function to apply an operator safely
(define (apply-operator op operand1 operand2)
  (cond
    [(eq? op '+) (+ operand1 operand2)]
    [(eq? op '-) (- operand1 operand2)]
    [(eq? op '*) (* operand1 operand2)]
    [(eq? op '/) (/ operand1 operand2)]
    [else (error 'apply-operator "Invalid operator")]))

;; ====================================================================
;; 2. History and Output Functions
;; ====================================================================

;; Gets a history value (1-based ID).
(define (get-history-value id history)
  (list-ref (reverse history) (- id 1)))

(define (valid-history-id? id history)
  (and (>= id 1) (<= id (length history))))

;; Prints the error message prefixed with "Error:".
(define (print-error)
  (display "Error: Invalid Expression")
  (newline))

;; Prints the successful result in the required format: ID: result_float
(define (print-result result new-history)
  (define history-id (length new-history)) ; ID is the current length of the history list
  
  (display history-id)
  (display ": ")
  
  ;; Convert the result to a double-flonum as required
  (display (real->double-flonum result))
  (newline))

;; ====================================================================
;; 3. Core Prefix Evaluation Logic
;; ====================================================================



;; Evaluates a prefix expression given as a list of tokens.
;; Returns a pair: (result . remaining-tokens)
(define (evaluate-tokens tokens history)
  (if (null? tokens)
      (error 'evaluate-tokens "Not enough operands")
      
      (let ([token (car tokens)]
            [rest (cdr tokens)])
        
        (cond
          ;; 1. Handle Operands (Numbers)
          [(number? (string->number token))
           (cons (string->number token) rest)]
          
          ;; 2. Handle History References ($N)
          [(and (string? token) 
                (string-prefix? "$" token) 
                (string->number (substring token 1)))
           (let ([id (string->number (substring token 1))])
             (if (valid-history-id? id history)
                 (cons (get-history-value id history) rest)
                 (error 'evaluate-tokens "Invalid history ID")))]
          
          ;; 3. Handle Operators (+, *, etc.)
          [(and (symbol? (string->symbol token)) (member (string->symbol token) valid-operators))
           (define op (string->symbol token))
           
           ;; Recursively get the first operand (Operand 1)
           (define result1-pair (evaluate-tokens rest history))
           (define operand1 (car result1-pair))
           (define tokens-after-op1 (cdr result1-pair))
           
           ;; Recursively get the second operand (Operand 2)
           (define result2-pair (evaluate-tokens tokens-after-op1 history))
           (define operand2 (car result2-pair))
           (define tokens-after-op2 (cdr result2-pair))
           
           ;; Apply the operator: Op Operand1 Operand2
           (let ([result (apply-operator op operand1 operand2)])
             (cons result tokens-after-op2))]
          
          ;; 4. Error: Unknown token
          [else
           (error 'evaluate-tokens "Unknown token")])))
)

;; The wrapper function that handles tokenization and error catching.
;; Returns (result . new-history) on success, or #f on failure.
(define (evaluate-expression input history)
  (define tokens (regexp-split #px"\\s+" (string-trim input))) 
  
  ;; Filter out any empty strings that might result from splitting (e.g., from double spaces)
  (define clean-tokens (filter (lambda (s) (not (zero? (string-length s)))) tokens))

  (with-handlers 
      ([exn:fail? (lambda (ex) #f)])
    
    (if (null? clean-tokens)
        #f ; Handle completely empty or whitespace input
        
        (let ([eval-pair (evaluate-tokens clean-tokens history)])
          (define result (car eval-pair))
          (define remaining-tokens (cdr eval-pair))
          
          ;; Check for successful evaluation: one result and no remaining tokens
          (if (null? remaining-tokens)
              (cons result (cons result history)) 
              #f)))) 
)
(define (main-calculator-loop history)
  
  ;; 1. Prompt and Read Input (only in interactive mode)
  (when interactive?
    (display "calc> "))
  
  (define input (read-line (current-input-port) 'any))


  (cond
    ;; End of file (happens in batch mode)
    [(eof-object? input)
     (void)]

    
    ;; Quit command
    [(string=? input "quit")
     (void)] ; Exit the loop/program

    ;; Input is empty/just spaces
    [(zero? (string-length (string-trim input)))
     (main-calculator-loop history)]
    [else
     (define result-pair (evaluate-expression input history))
     (if (pair? result-pair)
         (let ([new-history (cdr result-pair)]
               [result (car result-pair)])
           (print-result result new-history)
           (main-calculator-loop new-history))
         (begin
           (print-error)
           (main-calculator-loop history)))]))
(module+ main
  (main-calculator-loop '()))

