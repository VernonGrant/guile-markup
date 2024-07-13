(define-module (markup helpers)
  #:export (pair-strings?))

(define (pair-strings? x)
  "Return true, when both elements in a pair is of string type."
  (if (pair? x)
      (and (string? (car x))
           (string? (cdr x)))
      #f))
