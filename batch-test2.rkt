#lang racket
(require racket/system
         racket/file)

;; ----------------------------------------------------------------------
;; CONFIGURATION
;; ----------------------------------------------------------------------

;; Path to your prefix-calculator.rkt file (update if needed)
(define calc-path "D:/College/Paradigms CS 4337/Project 1/prefix-calculator.rkt")

;; Temporary files for input/output
(define tmp-file "batch-input.txt")
(define tmp-out  "batch-output.txt")
(define racket-path "C:/Program Files/Racket/Racket.exe")

;; ----------------------------------------------------------------------
;; CREATE BATCH INPUT
;; ----------------------------------------------------------------------

(define batch-input
  "+ 2 3\n* #1 4\nquit\n")

(call-with-output-file tmp-file
  (lambda (out)
    (display batch-input out))
  #:exists 'replace)

;; ----------------------------------------------------------------------
;; DEBUG INFO
;; ----------------------------------------------------------------------

(displayln "=== DEBUG INFO ===")
(display "Calculator file exists? ") (displayln (file-exists? calc-path))
(display "Input file exists? ") (displayln (file-exists? tmp-file))
(display "Output file exists (before run)? ") (displayln (file-exists? tmp-out))
(newline)

;; ----------------------------------------------------------------------
;; RUN CALCULATOR USING SYSTEM COMMAND
;; ----------------------------------------------------------------------

(displayln "=== Running calculator via system ===")

;; Build and run the shell command
(define cmd (format "\"~a\" \"~a\" -b < \"~a\" > \"~a\""
                    racket-path calc-path tmp-file tmp-out))
(displayln (string-append "Command: " cmd))
(system cmd)

;; ----------------------------------------------------------------------
;; DISPLAY RESULTS
;; ----------------------------------------------------------------------

(displayln "=== Batch Mode Output ===")

(if (file-exists? tmp-out)
    (displayln (file->string tmp-out))
    (displayln "No output file was created."))

;; ----------------------------------------------------------------------
;; POST-RUN DEBUG INFO
;; ----------------------------------------------------------------------

(displayln "=== File Info After Run ===")
(display "Output file exists? ") (displayln (file-exists? tmp-out))
(when (file-exists? tmp-out)
  (display "Output file size: ")
  (displayln (file-size tmp-out)))
