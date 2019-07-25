(define (compose . functions)
  (define (make-chain thunk chain)
    (lambda args
      (call-with-values (lambda () (apply thunk args)) chain)))
  (if (null? functions)
      values
      (fold-left make-chain (car functions) (cdr functions))))
