(define-module (markup escape)
  #:export (escape-html
            escape-js))

(define (escape-html str)
  (define (escape str)
    (map (lambda (c)
           (case c
             ((#\&) "&amp;")
             ((#\") "&quot;")
             ((#\<) "&lt;")
             ((#\>) "&gt;")
             ((#\') "&#39;")
             (else (string c))))
         (string->list str)))
  (let ((str-escaped (escape str)))
    (string-join str-escaped "")))

(define (escape-js str)
  (define (escape str)
    (map (lambda (c)
           (case c
             ((#\") "\\\"")
             (else (string c))))
         (string->list str)))
  (let ((str-escaped (escape str)))
    (string-join str-escaped "")))
