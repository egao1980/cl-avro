;;; Copyright (C) 2019-2020 Sahil Kang <sahil.kang@asilaycomputing.com>
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

(defclass message (doc-type)
  ((request
    :reader request
    :type (typed-vector field-schema)
    :documentation "Message request parameters.")
   (response
    :reader response
    :type avro-schema
    :documentation "Message response schema.")
   (errors
    :reader errors
    :type (or null union-schema)
    :documentation "Message error schemas.")
   (one-way
    :reader one-way
    :type boolean)
   (one-way-p
    :reader one-way-p
    :type boolean)))

;; TODO error-schema same as record schema but with type error instead of record
(defclass protocol (named-type doc-type)
  ((types
    :reader types
    :type (or null (typed-vector (or record-schema error-schema enum-schema fixed-schema)))
    :documentation "Protocol types.")
   (messages
    :reader messages
    :type (or null hash-table)
    :documentation "Protocol messages.")
   (message-order
    :type (or null (typed-vector string))
    :documentation "Indexes into messages slot to define ordering."))
  (:documentation
   "Represents an avro protocol."))
