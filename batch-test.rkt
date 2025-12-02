#lang racket
(require racket/system)

(define tmp-file "batch-input.txt")
(define tmp-out "batch-output.txt")
(define calc-path "D:/College/Paradigms CS 4337/Project 1/prefix-calculator.rkt")

;; Create the batch input file
(define batch-input
  "+ 2 3\n* #1 4\nquit\n")

(call-with-output-file tmp-file
  (lambda (out)
    (display batch-input out))
  #:exists 'replace)

;; ----------------------------------------------------------------------
;; DEBUG CHECKS
;; ----------------------------------------------------------------------

(displayln "=== DEBUG INFO ===")
(display "Calculator file exists? ") (displayln (file-exists? calc-path))
(display "Input file exists? ") (displayln (file-exists? tmp-file))
(display "Output file exists (before run)? ") (displayln (file-exists? tmp-out))
(newline)

;; Open real file-stream ports
(define in-port (open-input-file tmp-file))
(define out-port (open-output-file tmp-out #:exists 'replace))


;; Run your calculator in batch mode
(define-values (proc _in _out _err)
  (subprocess
    #f              ; stdout -> current output
    in-port         ; stdin
    out-port        ; stderr (we're using this to capture)
    "racket"
    calc-path
    "-b"))
  ;; "C:/Users/brayd/Documents/prefix-calculator.rkt"

;; Wait for the process to finish
(subprocess-wait proc)

;; Important: close ports to flush output buffer
(close-input-port in-port)
(close-output-port out-port)

;; Give the OS a moment to flush buffers (helps on Windows)
(sleep 0.2)

;; -----------------------------------------------------
;; Step 8: Check if output file was created and its size
;; -----------------------------------------------------
(displayln (format "Output file exists? ~a" (file-exists? tmp-out)))
(when (file-exists? tmp-out)
  (displayln (format "Output file size: ~a bytes" (file-size tmp-out))))

;; -----------------------------------------------------
;; Step 9: Read and show output file contents
;; -----------------------------------------------------
(displayln "=== Batch Mode Output ===")
(when (file-exists? tmp-out)
  (displayln (file->string tmp-out)))


;; ----------------------------------------------------------------------
;; DEBUG OUTPUT CHECK
;; ----------------------------------------------------------------------

(displayln "=== File Info After Run ===")
(display "Output file exists? ") (displayln (file-exists? tmp-out))
(when (file-exists? tmp-out)
  (display "Output file size: ")
  (displayln (file-size tmp-out)))

