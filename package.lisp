(defpackage :chipz
  (:use :cl)
  (:export #:decompression-state
           #:inflate-state
           #:bzip2-state

           #:make-dstate
           #:finish-dstate

           ;; Only for API compatibility
           #:make-inflate-state
           #:finish-inflate-state

           ;; Main user-visible entry point
           #:decompress

           ;; Symbols for EQL specializers
           #:deflate
           #:zlib
           #:gzip
           #:bzip2

           ;; Gray streams
           #:make-decompressing-stream

           ;; conditions

           #:chipz-error
           #:invalid-format-error
           #:decompression-error
           #:invalid-checksum-error
           #:premature-end-of-stream
           #:inflate-error
           #:invalid-zlib-header-error
           #:invalid-gzip-header-error
           #:reserved-block-type-error
           #:invalid-stored-block-length-error
           #:bzip2-error
           #:invalid-bzip2-data))

;;; EGCL decompresses deflate, zlib and gzip data in its runtime
;;; (EGCL-EXT:INFLATE); chipz's own inflate runs at a few kilobytes a second
;;; there.  See egcl-native.lisp.
#+egcl
(eval-when (:compile-toplevel :load-toplevel :execute)
  (when (fboundp (intern "INFLATE" "EGCL-EXT"))
    (pushnew :chipz-egcl-native *features*)))
