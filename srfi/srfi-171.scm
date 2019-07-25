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


(define-module (transducers)
  #:use-module (srfi srfi-9)
  #:use-module ((srfi srfi-43)
                #:select (vector->list))
  #:use-module ((rnrs bytevectors)
                #:select (bytevector-length bytevector-u8-ref))
  #:export (reduced reduced? deref-reduced ensure-reduced preserving-reduced
                    rcons reverse-rcons
                    rcount
                    rany
                    revery
                    list-reduce vector-reduce string-reduce bytevector-u8-transduce
                    transduce vector-transduce string-transduce bytevector-u8-transduce
                    tmap
                    tfilter
                    tremove
                    treplace
                    tfilter-map
                    tdrop
                    tdrop-while
                    ttake
                    ttake-while
                    thalt-when
                    tcat
                    tappend-map
                    tdedupe
                    tdelete-duplicates
                    tflatten
                    tpartition-all
                    tpartition-by
                    tinterpose
                    tindex
                    tlog))



;; Here we define the things that can't be implemented in portable scheme that is
;; needed in transducers-impl
(define-record-type <reduced>
  (reduced val)
  reduced?
  (val deref-reduced))

;; A special value to be used as a placeholder where no value has been set and #f
;; doesn't cut it. Not exported, and not really needed. 
(define-record-type <nothing>
  (make-nothing)
  nothing?)
(define nothing (make-nothing))

(include "transducers-impl.scm")



