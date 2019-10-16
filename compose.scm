;; Fold is as defined in srfi-1. 
;; for r6rs it can be substituted for fold-left

(define (compose . functions)
  (define (make-chain thunk chain)
    (lambda args
      (call-with-values (lambda () (apply thunk args)) chain)))
  (if (null? functions)
      values
      (fold make-chain (car functions) (cdr functions))))
