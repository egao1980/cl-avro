;;; Copyright (C) 2019 Sahil Kang <sahil.kang@asilaycomputing.com>
;;;
;;; This file is part of cl-avro.
;;;
;;; cl-avro is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; cl-avro is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with cl-avro.  If not, see <http://www.gnu.org/licenses/>.

(in-package #:cl-avro)

;;; avro primitive types

(deftype null-schema () 'null)

(deftype boolean-schema () 'boolean)

(defmacro get-signed-range (bits)
  (let* ((max (1- (expt 2 (1- bits))))
         (min (- (1+ max))))
    `'(,min ,max)))

(deftype int-schema ()
  (let ((min-max (get-signed-range 32))
        (signed-32-bit-p (gensym)))
    (setf (symbol-function signed-32-bit-p)
          (lambda (int)
            (and (typep int 'integer)
                 (>= int (first min-max))
                 (<= int (second min-max)))))
    `(satisfies ,signed-32-bit-p)))

(deftype long-schema ()
  (let ((min-max (get-signed-range 64))
        (signed-64-bit-p (gensym)))
    (setf (symbol-function signed-64-bit-p)
          (lambda (long)
            (and (typep long 'integer)
                 (>= long (first min-max))
                 (<= long (second min-max)))))
    `(satisfies ,signed-64-bit-p)))

(deftype float-schema ()
  (let ((32-bit-float-p (gensym)))
    (setf (symbol-function 32-bit-float-p)
          (lambda (float)
            (or (typep float 'integer)
                (and (typep float 'float)
                     (or (= 0.0 float)
                         (= 24 (float-precision float)))))))
    `(satisfies ,32-bit-float-p)))

(deftype double-schema ()
  (let ((64-bit-float-p (gensym)))
    (setf (symbol-function 64-bit-float-p)
          (lambda (float)
            (or (typep float 'integer)
                (and (typep float 'float)
                     (or (= 0.0 float)
                         (= 53 (float-precision float)))))))
    `(satisfies ,64-bit-float-p)))

(deftype bytes-schema () '(typed-vector (unsigned-byte 8)))

(deftype string-schema () 'string)

;;; avro-name

(deftype avro-name () '(satisfies avro-name-p))

(defun avro-name-p (name)
  "True if NAME matches regex /^[A-Za-z_][A-Za-z0-9_]*$/ and nil otherwise"
  (declare (string name)
           (optimize (speed 3) (safety 0))
           (inline lowercase-p uppercase-p underscore-p digit-p))
  (when (and (typep name 'string)
             (not (zerop (length name))))
    (the boolean
         (let ((first (char-code (char name 0))))
           (when (or (lowercase-p first)
                     (uppercase-p first)
                     (underscore-p first))
             (loop
                for i from 1 below (length name)
                for char-code = (char-code (char name i))

                always (or (lowercase-p char-code)
                           (uppercase-p char-code)
                           (underscore-p char-code)
                           (digit-p char-code))))))))

(defmacro in-range-p (char-code start-char &optional end-char)
  "True if CHAR-CODE is between the char-code given by START-CHAR and END-CHAR.

If END-CHAR is nil, then determine if CHAR-CODE equals the char-code of
START-CHAR."
  (declare (character start-char)
           ((or null character) end-char))
  (let ((start (char-code start-char))
        (end (when end-char (char-code end-char))))
    (if end
        `(the boolean
              (and (>= ,char-code ,start)
                   (<= ,char-code ,end)))
        `(the boolean
              (= ,char-code ,start)))))

(defun digit-p (char-code)
  (declare (integer char-code)
           (optimize (speed 3) (safety 0)))
  (in-range-p char-code #\0 #\9))

(defun uppercase-p (char-code)
  (declare (integer char-code)
           (optimize (speed 3) (safety 0)))
  (in-range-p char-code #\A #\Z))

(defun lowercase-p (char-code)
  (declare (integer char-code)
           (optimize (speed 3) (safety 0)))
  (in-range-p char-code #\a #\z))

(defun underscore-p (char-code)
  (declare (integer char-code)
           (optimize (speed 3) (safety 0)))
  (in-range-p char-code #\_))

;;; type utilities

(deftype typed-vector (elt-type)
  (let ((pred (gensym)))
    (setf (symbol-function pred)
          (lambda (vector)
            (and (typep vector 'vector)
                 (every (lambda (elt)
                          (typep elt elt-type))
                        vector))))
    `(satisfies ,pred)))

(deftype enum (&rest enum-values)
  (let ((pred (gensym)))
    (setf (symbol-function pred)
          (lambda (maybe-enum)
            (member maybe-enum enum-values :test #'equalp)))
    `(satisfies ,pred)))