;; These are guile-specific tests. They contain guile-specific hash-tables (as are used in the reference implementation)..


(import (scheme base)
        (scheme char)
        (scheme list)
        (scheme read)
        (srfi 171))
(cond-expand
 (gauche (import (only (gauche base) compose)
                 (srfi 64)))
 (chibi (import (rapid test))))

(cond-expand
 (chibi (begin
          (define compose
            (lambda (f g)
              (lambda args
                (f (apply g args)))))))
 (else (begin)))

(include "tests.scm")
