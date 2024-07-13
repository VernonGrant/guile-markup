(define-module (markup)
  #:export (markup
            markup-el
            set-indentation-size))

(use-modules
 (markup helpers)
 (markup escape)
 (ice-9 match)
 (srfi srfi-37))

;;;;;;;;;;;;;;
;; Internal ;;
;;;;;;;;;;;;;;

(define indentation-size 2)

(define (set-indentation-size num)
  (set! indentation-size num))

(define* (opening-tag tag #:key (attrs '()) (type 'default) (lvl 0))
  "Builds the elements opening tag.
ATTRS: A list of pairs and or strings. Pairs will be used to construct basic
element attributes, while strings will be used as stand along attributes, for
example the `disabled` attribute used on form elements."

  (define (attr-supports-js? str)
    (member str '("onclick",
                  "onload",
                  "onchange",
                  "onsubmit",
                  "onmouseover",
                  "onkeydown",
                  "href")))

  (define (attrs->ls-str x)
    (match x
      ((? pair-strings?)
       (let* ((key (string-trim-both (car x)))
              (val (string-trim-both (cdr x)))
              (key-escaped (escape-html key))
              (val-escaped (if (attr-supports-js? key)
                               (escape-js val)
                               (escape-html val))))
         (string-append key-escaped "=" "\"" val-escaped "\"")))
      ((? string?)
       (escape-html (string-trim-both x)))
      (_ "")))

  (let* ((tag-prepared (escape-html (string-trim-both tag)))
         (attrs? (not (null? attrs)))
         (attrs-str (if attrs?
                        (string-append " " (string-join (map attrs->ls-str attrs) " "))
                        ""))
         (ot (cond
              ((equal? type 'sc) (format #f "<~a~a~a>" tag-prepared attrs-str "/"))
              (else (format #f "<~a~a>" tag-prepared attrs-str)))))
    (string-pad ot (+ (* lvl indentation-size) (string-length ot)))))

(define* (closing-tag tag #:key (lvl 0) (type 'default))
  "Builds the elements closing tag."
  (let* ((tag-prepared (escape-html (string-trim-both tag)))
         (ct (format #f "</~a>" tag-prepared)))
    (cond
     ((equal? type 'default)
      (string-pad ct (+ (* lvl indentation-size) (string-length ct))))
     (else ""))))

;;;;;;;;;;;;;
;; Library ;;
;;;;;;;;;;;;;

(define* (markup-el tag #:key (attrs '()) (inner "") (type 'default) (void #f) (sc #f) (lvl 0) (inner! #f))
  "Creates a single HTML element with optional children."

  (define (maybe-append-lvl ls lvl)
    (let ((lvl-exists? (member '#:lvl ls)))
      (if lvl-exists? ls (append ls `(#:lvl ,lvl)))))

  (define (inner-builder inner lvl)
    (let* ((inner-with-lvls (map (lambda (ls) (maybe-append-lvl ls lvl)) inner))
           (inner->str-ls (map (lambda (ls) (apply markup-el ls)) inner-with-lvls)))
      (string-append "\n" (string-join inner->str-ls "\n") "\n")))

  (if (not inner!)
      (match inner
        ((? list?)
         (string-append (opening-tag tag #:attrs attrs #:lvl lvl)
                        (inner-builder inner (+ lvl 1))
                        (closing-tag tag #:lvl lvl)))

        ((? string?)
         (string-append (opening-tag tag #:attrs attrs #:lvl lvl #:type type)
                        (if (equal? type 'default) (escape-html inner) "")
                        (closing-tag tag #:type type)))

        (_ (string-append (opening-tag tag #:attrs attrs #:lvl lvl #:type type)
                          (closing-tag tag #:type type))))

      ;; Raw inner strings:
      (string-append (opening-tag tag #:attrs attrs #:lvl lvl #:type type)
                     (if (equal? type 'default) inner! "")
                     (closing-tag tag #:type type))))

(define* (markup-els inner #:key (lvl 0))
  "Creates html elements at root level."
  (define (maybe-append-lvl ls lvl)
    (let ((lvl-exists? (member '#:lvl ls)))
      (if lvl-exists? ls (append ls `(#:lvl ,lvl)))))

  (let* ((inner-with-lvls (map (lambda (ls) (maybe-append-lvl ls lvl)) inner))
         (inner->str-ls (map (lambda (ls) (apply markup-el ls)) inner-with-lvls)))
    (string-join inner->str-ls "\n")))
