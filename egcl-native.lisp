;;;; egcl-native.lisp -- deflate, zlib and gzip through EGCL's runtime

(in-package :chipz)

;;; On EGCL, chipz's inflate runs in interpreted code at a few kilobytes a
;;; second, so unpacking a few megabytes takes many minutes.  EGCL provides
;;; EGCL-EXT:INFLATE, which decompresses a whole deflate stream, zlib stream or
;;; gzip file and checks its trailers.  DECOMPRESS of a vector or stream by
;;; format name, and MAKE-DECOMPRESSING-STREAM, use it there; chipz's
;;; incremental interface on an explicit state keeps chipz's own inflate.

#+chipz-egcl-native
(progn
  (defun native-format (format)
    "EGCL-EXT:INFLATE's name for FORMAT, or NIL for a format it does not handle."
    (case format
      ((deflate :deflate) :deflate)
      ((zlib :zlib) :zlib)
      ((gzip :gzip) :gzip)))

  (defun read-all-octets (stream)
    "All the octets remaining in STREAM, as a fresh octet vector."
    (let ((chunks '())
          (total 0))
      (loop for chunk = (make-array 65536 :element-type '(unsigned-byte 8))
            for count = (read-sequence chunk stream)
            do (push (subseq chunk 0 count) chunks)
               (incf total count)
            while (= count (length chunk)))
      (let ((octets (make-array total :element-type '(unsigned-byte 8)))
            (start 0))
        (dolist (chunk (nreverse chunks) octets)
          (replace octets chunk :start1 start)
          (incf start (length chunk))))))

  (defun native-decompress (octets format)
    "Decompress all of OCTETS, in EGCL-EXT:INFLATE format FORMAT."
    (handler-case (egcl-ext:inflate octets format)
      (stream-error (condition)
        (error 'decompression-error
               :format-control "~A"
               :format-arguments (list condition))))))
