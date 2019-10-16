;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright 2019 Linus Björnstam
;;
;; You may use this code under either the license in the SRFI document or the
;; license below.
;;
;; Permission to use, copy, modify, and/or distribute this software for any
;; purpose with or without fee is hereby granted, provided that the above
;; copyright notice and this permission notice appear in all source copies.
;; The software is provided "as is", without any express or implied warranties.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; This module name is guile-specific. The correct name is of course
;; (srfi 171 meta)
(define-module (srfi srfi-171 meta)
  #:use-module (srfi srfi-9)
  #:use-module ((rnrs bytevectors) #:select (bytevector-length bytevector-u8-ref))
  #:export (reduced reduced?
            unreduce
            ensure-reduced
            preserving-reduced

            list-reduce
            vector-reduce
            string-reduce
            bytevector-u8-reduce
            port-reduce
            generator-reduce))

(include "../srfi-171-meta.scm")

