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

(in-package #:cl-user)

(defpackage #:test/logical
  (:use #:cl #:1am))

(in-package #:test/logical)

(test decimal-bytes
  (flet ((make-json (precision &optional scale)
           (format nil
                   "{type: \"bytes\",
                     logicalType: \"decimal\",
                     precision: ~A~@[,
                     scale: ~A~]}"
                   precision
                   scale)))
    (let* ((expected-precision 3)
           (expected-scale 2)
           (json (make-json expected-precision expected-scale))
           (schema (avro:json->schema json)))
      (is (= expected-precision (avro:precision schema)))
      (is (= expected-scale (avro:scale schema)))
      (let ((value 200))
        (is (= value (avro:deserialize
                      (avro:serialize nil schema value)
                      schema))))
      (signals error
        (avro:serialize nil schema 2000)))
    (let* ((expected-precision 3)
           (expected-scale expected-precision)
           (json (make-json expected-precision expected-scale))
           (schema (avro:json->schema json)))
      (is (= expected-precision (avro:precision schema)))
      (is (= expected-scale (avro:scale schema)))
      (let ((value 200))
        (is (= value (avro:deserialize
                      (avro:serialize nil schema value)
                      schema))))
      (signals error
        (avro:serialize nil schema 2000)))
    (let* ((expected-precision 3)
           (expected-scale (1+ expected-precision))
           (json (make-json expected-precision expected-scale))
           (schema (avro:json->schema json)))
      (is (eq 'avro:bytes-schema schema)))
    (let* ((expected-precision 3)
           (json (make-json expected-precision))
           (schema (avro:json->schema json)))
      (is (= expected-precision (avro:precision schema)))
      (is (= 0 (avro:scale schema))))))

(test decimal-fixed
  (flet ((make-json (precision size &optional scale)
           (format nil
                   "{type: {type: \"fixed\", name: \"foo\", size: ~A},
                     logicalType: \"decimal\",
                     precision: ~A~@[,
                     scale: ~A~]}"
                   size
                   precision
                   scale)))
    (let* ((expected-precision 3)
           (expected-scale 2)
           (expected-size 2)
           (json (make-json expected-precision expected-size expected-scale))
           (schema (avro:json->schema json)))
      (is (= expected-precision (avro:precision schema)))
      (is (= expected-scale (avro:scale schema)))
      (is (= expected-size (avro:size (avro::underlying-schema schema))))
      (let ((value 200))
        (is (= value (avro:deserialize
                      (avro:serialize nil schema value)
                      schema))))
      (signals error
        (avro:serialize nil schema 2000)))
    (let* ((expected-precision 3)
           (expected-scale expected-precision)
           (expected-size 2)
           (json (make-json expected-precision expected-size expected-scale))
           (schema (avro:json->schema json)))
      (is (= expected-precision (avro:precision schema)))
      (is (= expected-scale (avro:scale schema)))
      (is (= expected-size (avro:size (avro::underlying-schema schema))))
      (let ((value 200))
        (is (= value (avro:deserialize
                      (avro:serialize nil schema value)
                      schema))))
      (signals error
        (avro:serialize nil schema 2000)))
    (let* ((expected-precision 3)
           (expected-scale (1+ expected-precision))
           (expected-size 2)
           (json (make-json expected-precision expected-size expected-scale))
           (schema (avro:json->schema json)))
      (is (eq 'avro:fixed-schema (type-of schema)))
      (is (= expected-size (avro:size schema))))
    (let* ((expected-precision 3)
           (expected-scale 2)
           (expected-size 1)
           (json (make-json expected-precision expected-size expected-scale))
           (schema (avro:json->schema json)))
      (is (eq 'avro:fixed-schema (type-of schema)))
      (is (= expected-size (avro:size schema))))
    (let* ((expected-precision 3)
           (expected-size 4)
           (json (make-json expected-precision expected-size))
           (schema (avro:json->schema json)))
      (is (= expected-precision (avro:precision schema)))
      (is (= 0 (avro:scale schema)))
      (is (= expected-size (avro:size (avro::underlying-schema schema)))))))


(test uuid
  (let ((schema (avro:json->schema "{type: \"string\", logicalType: \"uuid\"}"))
        (expected "6ba7b810-9dad-11d1-80b4-00c04fd430c8"))
    (is (eq 'avro:uuid-schema schema))
    (is (string= expected (avro:deserialize
                           (avro:serialize nil schema expected)
                           schema)))
    (signals error
      (avro:serialize nil schema "abc"))
    (signals error
      (avro:serialize nil schema ""))
    (signals error
      (avro:serialize nil schema 123))
    (signals error
      (avro:serialize nil schema nil)))
  (let ((schema (avro:json->schema "{type: \"bytes\", logicalType: \"uuid\"}")))
    (is (eq 'avro:bytes-schema schema))))


(test date
  (let ((schema (avro:json->schema "{type: \"int\", logicalType: \"date\"}"))
        (expected 123))
    (is (eq 'avro:date-schema schema))
    (is (= expected (avro:deserialize
                     (avro:serialize nil schema expected)
                     schema)))
    (signals error
      (avro:serialize nil schema "abc"))
    (signals error
      (avro:serialize nil schema nil)))
  (let ((schema (avro:json->schema "{type: \"string\", logicalType: \"date\"}")))
    (is (eq 'avro:string-schema schema))))


(test time-millis
  (let ((schema (avro:json->schema "{type: \"int\", logicalType: \"time-millis\"}"))
        (expected 123))
    (is (eq 'avro:time-millis-schema schema))
    (is (= expected (avro:deserialize
                     (avro:serialize nil schema expected)
                     schema)))
    (signals error
      (avro:serialize nil schema -1))
    (signals error
      (avro:serialize nil schema nil)))
  (let ((schema (avro:json->schema "{type: \"bytes\", logicalType: \"time-millis\"}")))
    (is (eq 'avro:bytes-schema schema))))


(test time-micros
  (let ((schema (avro:json->schema "{type: \"long\", logicalType: \"time-micros\"}"))
        (expected 123))
    (is (eq 'avro:time-micros-schema schema))
    (is (= expected (avro:deserialize
                     (avro:serialize nil schema expected)
                     schema)))
    (signals error
      (avro:serialize nil schema -1))
    (signals error
      (avro:serialize nil schema nil)))
  (let ((schema (avro:json->schema "{type: \"bytes\", logicalType: \"time-micros\"}")))
    (is (eq 'avro:bytes-schema schema))))


(test timestamp-millis
  (let ((schema (avro:json->schema "{type: \"long\", logicalType: \"timestamp-millis\"}"))
        (expected 123))
    (is (eq 'avro:timestamp-millis-schema schema))
    (is (= expected (avro:deserialize
                     (avro:serialize nil schema expected)
                     schema)))
    (signals error
      (avro:serialize nil schema "abc"))
    (signals error
      (avro:serialize nil schema nil)))
  (let ((schema (avro:json->schema "{type: \"bytes\", logicalType: \"timestamp-millis\"}")))
    (is (eq 'avro:bytes-schema schema))))


(test timestamp-micros
  (let ((schema (avro:json->schema "{type: \"long\", logicalType: \"timestamp-micros\"}"))
        (expected 123))
    (is (eq 'avro:timestamp-micros-schema schema))
    (is (= expected (avro:deserialize
                     (avro:serialize nil schema expected)
                     schema)))
    (signals error
      (avro:serialize nil schema "abc"))
    (signals error
      (avro:serialize nil schema nil)))
  (let ((schema (avro:json->schema "{type: \"bytes\", logicalType: \"timestamp-micros\"}")))
    (is (eq 'avro:bytes-schema schema))))


(test duration
  (flet ((make-json (size)
           (format nil
                   "{type: {type: \"fixed\", name: \"foo\", size: ~A},
                     logicalType: \"duration\"}"
                   size)))
    (let* ((size 12)
           (schema (avro:json->schema (make-json size)))
           (expected #(2 4 6)))
      (is (eq 'avro:duration-schema (type-of schema)))
      (is (= size (avro:size (avro::underlying-schema schema))))
      (is (equalp expected (avro:deserialize
                            (avro:serialize nil schema expected)
                            schema)))
      (signals error
        (avro:serialize nil schema #()))
      (signals error
        (avro:serialize nil schema nil))
      (signals error
        (avro:serialize nil schema #(2 4 #.(expt 2 32)))))
    (let* ((size 11)
           (schema (avro:json->schema (make-json size))))
      (is (eq 'avro:fixed-schema (type-of schema)))
      (is (= size (avro:size schema))))))
