;;; -*- scheme -*-

;;; @@PLEAC@@_NAME
;;; @@SKIP@@ Guile 1.8

;;; @@PLEAC@@_WEB
;;; @@SKIP@@ http://www.gnu.org/software/guile/

;;; @@PLEAC@@_INTRO
;;; @@SKIP@@ Sections 1 - 3, and 7 - 9, largely completed using Guile 1.5; subsequent additions use Guile 1.8.

;;; @@PLEAC@@_APPENDIX
;;; @@SKIP@@ General-purpose, custom functions that might be used in several sections, appear here 

;; Helper which aims to reduce code clutter by:
;; * Replacing the oft-used, '(display item) (newline)' combination
;; * Avoiding overuse of '(string-append)' for simple output tasks
(define (print item . rest)
  (let ((all-item (cons item rest)))
    (for-each
      (lambda (item) (display item) (display " "))      
      all-item))
  (newline))

;; ------------

;; Slightly modified version of '(qx)' from Chapter 4
(use-modules (ice-9 popen) (srfi srfi-1) (srfi srfi-13))

(define (drain-output port)
  (let loop ((chars '())
             (next (read-char port)))
    (if (eof-object? next)
        ; Modified to not return last 'line' with newline
        (list->string (reverse! (cdr chars)))
        (loop (cons next chars)
              (read-char port)))))

(define (qx pipeline)
  (let* ((pipe (open-input-pipe pipeline))
         (output (drain-output pipe)))
    (close-pipe pipe)
    output))

;; ------------

;; @@PLEAC@@_1.0
(define string "\\n")                    ; two characters, \ and an n
(define string "\n")                     ; a "newline" character
(define string "Jon \"Maddog\" Orwant")  ; literal double quotes
(define string "Jon 'Maddog' Orwant")    ; literal single quotes

(define a "This is a multiline here document
terminated by a closing double quote")

;; @@PLEAC@@_1.1
;; Use substring

(substring str start end)
(substring str start)

;; You can fill portions of a string with another string

(substring-move-right! str start end newstring newstart)
(substring-move-left! str start end newstring newstart)

;; Guile has a separate character type, and you can treat strings as a
;; character array.

(string-ref str pos)
(string-set! str pos char)
(string-fill! str char)
(substring-fill! str start end char)

(define s "This is what you have")
(define first (substring s 0 1))                     ; "T"
(define start (substring s 5 7))                     ; "is"
(define rest  (substring s 13))                      ; "you have"
(define last  (substring s (1- (string-length s))))  ; "e"
(define end   (substring s (- (string-length s) 4))) ; "have"
(define piece (let ((len (string-length s)))
                (substring s (- len 8) (- len 5))))  ; "you"


;;; Or use the string library SRFI-13
(use-modules (srfi srfi-13))

(define s "This is what you have")
(define first (string-take s 1))                     ; "T"
(define start (xsubstring s 5 7))                    ; "is"
(define rest  (xsubstring s 13 -1))                  ; "you have"
(define last  (string-take-right s 1))               ; "e"
(define end   (string-take-right s 4))               ; "have"
(define piece (xsubstring s -8 -5))                  ; "you"

;; Mutation of different sized strings is not allowed.  You have to
;; use set! to change the variable.

(set! s (string-replace s "wasn't" 5 7))
;; This wasn't what you have
(set! s (string-replace s "ondrous" 13 25))
;; This wasn't wondrous
(set! s (string-take-right s (1- (string-length s))))
;; his wasn't wondrous
(set! s (string-take s 9))

;; @@PLEAC@@_1.2
(define a (or b c))
(define a (if (defined? b) b c))
(define a (or (and (defined? b) b) c))

;; @@PLEAC@@_1.3
;; This doesn't really make sense in Scheme... temporary variables are
;; a natural construct and cheap.  If you want to swap variables in a
;; block without introducing any new variable names, you can use let:

(let ((a b) (b a))
  ;; ...
  )

(let ((alpha beta) (beta production) (production alpha))
  ;; ...
  )

;; @@PLEAC@@_1.4
(define num (char->integer char))
(define char (integer->char num))

(use-modules (srfi srfi-13))
(let ((str "sample"))
  (display (string-join
            (map number->string
                 (map char->integer (string->list str))) " "))
  (newline))

(let ((lst '(115 97 109 112 108 101)))
  (display (list->string (map integer->char lst)))
  (newline))

(letrec ((next (lambda (c) (integer->char (1+ (char->integer c))))))
  (let* ((hal "HAL")
         (ibm (list->string (map next (string->list hal)))))
    (display ibm)
    (newline)))

;; @@PLEAC@@_1.5
;; Convert the string to a list of characters
(map proc
     (string->list str))

(use-modules (srfi srfi-1))
(format #t "unique chars are: ~A\n"
        (apply string (sort (delete-duplicates
                             (string->list "an apple a day")) char<?)))

(let* ((str "an apple a day")
       (sum (apply + (map char->integer (string->list str)))))
  (format #t "sum is ~A\n" sum))

;;; or use string-fold/string-map/string-for-each from SRFI-13
(use-modules (srfi srfi-13))

(let* ((str "an apple a day")
       (sum (string-fold (lambda (c acc) (+ acc (char->integer c)))
                         0 str)))
  (format #t "sum is ~A\n" sum))

#!/usr/local/bin/guile -s
!#
;; sum - compute 16-bit checksum of all input files
(use-modules (srfi srfi-13))
(define (checksum p)
  (let loop ((line (read-line p 'concat)) (sum 0))
    (if (eof-object? line)
      (format #t "~A ~A\n" sum (port-filename p))
      (let ((line-sum (string-fold (lambda (c acc)
                                     (+ acc (char->integer c)))
                                   0 line)))
        (loop (read-line p 'concat) (modulo (+ sum line-sum)
                                            (1- (expt 2 16))))))))
(let ((args (cdr (command-line))))
  (if (null? args)
    (checksum (current-input-port))
    (for-each (lambda (f) (call-with-input-file f checksum)) args)))

#!/usr/local/bin/guile -s
!#
;; slowcat - emulate a  s l o w  line printer
(use-modules (ice-9 regex) (srfi srfi-2) (srfi srfi-13))
(define args (cdr (command-line)))
(define delay 1)
(and-let* ((p (pair? args))
           (m (string-match "^-([0-9]+)$" (car args))))
  (set! delay (string->number (match:substring m 1)))
  (set! args (cdr args)))
(define (slowcat p)
  (let loop ((line (read-line p 'concat)))
    (cond ((not (eof-object? line))
           (string-for-each
            (lambda (c) (display c) (usleep (* 5 delay))) line)
           (loop (read-line p 'concat))))))
(if (null? args)
  (slowcat (current-input-port))
  (for-each (lambda (f) (call-with-input-file f slowcat)) args))

;; @@PLEAC@@_1.6
(define revbytes (list->string (reverse (string->list str))))

;;; Or from SRFI-13
(use-modules (srfi srfi-13))
(define revbytes (string-reverse str))
(string-reverse! str) ; modifies in place

(define revwords (string-join (reverse (string-tokenize str)) " "))

(with-input-from-file "/usr/share/dict/words"
  (lambda ()
    (do ((word (read-line) (read-line)))
        ((eof-object? word))
      (if (and (> (string-length word) 5)
               (string=? word (string-reverse word)))
        (write-line word)))))

;; A little too verbose on the command line
;; guile --use-srfi=13 -c '(with-input-from-file "/usr/share/dict/words" (lambda () (do ((word (read-line) (read-line))) ((eof-object? word)) (if (and (> (string-length word) 5) (string=? word (string-reverse word))) (write-line word)))))'

;; @@PLEAC@@_1.7
;; Use regexp-substitute/global
(regexp-substitute/global
 #f "([^\t]*)(\t+)" str
 (lambda (m)
   (let* ((pre-string (match:substring m 1))
          (pre-len (string-length pre-string))
          (match-len (- (match:end m 2) (match:start m 2))))
     (string-append
      pre-string
      (make-string
       (- (* match-len 8)
          (modulo pre-len 8))
       #\space))))
 'post)

;; @@PLEAC@@_1.8
;; just interpolate $abc in strings:
(define (varsubst str)
  (regexp-substitute/global #f "\\$(\\w+)" str
   'pre (lambda (m) (eval (string->symbol (match:substring m 1))
                          (current-module)))
   'post))

;; interpolate $abc with error messages:
(define (safe-varsubst str)
  (regexp-substitute/global #f "\\$(\\w+)" str
   'pre (lambda (m)
          (catch #t
            (lambda () (eval (string->symbol (match:substring m 1))
                             (current-module)))
            (lambda args
              (format #f "[NO VARIABLE: ~A]" (match:substring m 1)))))
   'post))

;; interpolate ${(any (scheme expression))} in strings:
(define (interpolate str)
  (regexp-substitute/global #f "\\${([^{}]+)}" str
   'pre (lambda (m) (eval-string (match:substring m 1))) 'post))

;; @@PLEAC@@_1.9
(use-modules (srfi srfi-13))

(string-upcase "bo beep")     ; BO PEEP
(string-downcase "JOHN")      ; john
(string-titlecase "bo")       ; Bo
(string-titlecase "JOHN")     ; John

(string-titlecase "thIS is a loNG liNE")  ; This Is A Long Line

#!/usr/local/bin/guile -s
!#
;; randcap: filter to randomly capitalize 20% of the time
(use-modules (srfi srfi-13))
(seed->random-state (current-time))
(define (randcap p)
  (let loop ((line (read-line p 'concat)))
    (cond ((not (eof-object? line))
           (display (string-map (lambda (c)
                                  (if (= (random 5) 0)
                                    (char-upcase c)
                                    (char-downcase c)))
                                line))
           (loop (read-line p 'concat))))))
(let ((args (cdr (command-line))))
  (if (null? args)
    (randcap (current-input-port))
    (for-each (lambda (f) (call-with-input-file f randcap)) args)))

;; @@PLEAC@@_1.10
;; You can do this with format.  Lisp/Scheme format is a little
;; different from what you may be used to with C/Perl style printf
;; (actually far more powerful) , but if you keep in mind that we use
;; ~ instead of %, and , instead of . for the prefix characters, you
;; won't have trouble getting used to Guile's format.

(format #f "I have ~A guanacos." n)

;; @@PLEAC@@_1.11
(define var "
        your text
        goes here")

(use-modules (ice-9 regexp))
(set! var (regexp-substitute/global #f "\n +" var 'pre "\n" 'post))

(use-modules (srfi srfi-13))
(set! var (string-join (map string-trim (string-tokenize var #\newline)) "\n"))

(use-modules (ice-9 regexp) (srfi srfi-13) (srfi srfi-14))
(define (dequote str)
  (let* ((str (if (char=? (string-ref str 0) #\newline)
                (substring str 1) str))
         (lines (string-tokenize str #\newline))
         (rx (let loop ((leader (car lines)) (lst (cdr lines)))
               (cond ((string= leader "")
                      (let ((pos (or (string-skip (car lines)
                                                  char-set:whitespace) 0)))
                        (make-regexp (format #f "^[ \\t]{1,~A}" pos)
                                     regexp/newline)))
                     ((null? lst)
                      (make-regexp (string-append "^[ \\t]*"
                                                  (regexp-quote leader))
                                   regexp/newline))
                     (else
                      (let ((pos (or (string-prefix-length leader (car lst)) 0)))
                        (loop (substring leader 0 pos) (cdr lst))))))))
    (regexp-substitute/global #f rx str 'pre 'post)))

;; @@PLEAC@@_1.12
(use-modules (srfi srfi-13))

(define text "Folding and splicing is the work of an editor,
not a mere collection of silicon
and
mobile electrons!")

(define (wrap str max-col)
  (let* ((words (string-tokenize str))
         (all '())
         (first (car words))
         (col (string-length first))
         (line (list first)))
    (for-each
     (lambda (x)
       (let* ((len (string-length x))
              (new-col (+ col len 1)))
         (cond ((> new-col max-col)
                (set! all (cons (string-join (reverse! line) " ") all))
                (set! line (list x))
                (set! col len))
               (else
                (set! line (cons x line))
                (set! col new-col)))))
     (cdr words))
    (set! all (cons (string-join (reverse! line) " ") all))
    (string-join (reverse! all) "\n")))

(display (wrap text 20))

;; @@PLEAC@@_1.13
(define str "Mom said, \"Don't do that.\"")
(set! str (regexp-substitute/global #f "['\"]" str 'pre "\\"
                                    match:substring 'post))
(set! str (regexp-substitute/global #f "[^A-Z]" str 'pre "\\"
                                    match:substring 'post))
(set! str (string-append "this " (regexp-substitute/global
                                  #f "\W" "is a test!" 'pre "\\"
                                  match:substring 'post)))

;; @@PLEAC@@_1.14
(use-modules (srfi srfi-13))

(define str "  space  ")
(string-trim str)          ; "space  "
(string-trim-right str)    ; "  space"
(string-trim-both str)     ; "space"

;; @@PLEAC@@_1.15
(use-modules (srfi srfi-2) (srfi srfi-13) (ice-9 format))

(define parse-csv
  (let* ((csv-match (string-join '("\"([^\"\\\\]*(\\\\.[^\"\\\\]*)*)\",?"
                                   "([^,]+),?"
                                   ",")
                                 "|"))
         (csv-rx (make-regexp csv-match)))
    (lambda (text)
      (let ((start 0)
            (result '()))
        (let loop ((start 0))
          (and-let* ((m (regexp-exec csv-rx text start)))
            (set! result (cons (or (match:substring m 1)
                                   (match:substring m 3))
                               result))
            (loop (match:end m))))
        (reverse result)))))

(define line "XYZZY,\"\",\"O'Reilly, Inc\",\"Wall, Larry\",\"a \\\"glug\\\" bit,\",5,\"Error, Core Dumped\"")

(do ((i 0 (1+ i))
     (fields (parse-csv line) (cdr fields)))
    ((null? fields))
  (format #t "~D : ~A\n" i (car fields)))

;; @@PLEAC@@_1.16
(use-modules (srfi srfi-13) (srfi srfi-14))

;; Knuth's soundex algorithm from The Art of Computer Programming, Vol 3
(define soundex
  (letrec ((chars "AEIOUYBFPVCGJKQSXZDTLMNR")
           (nums "000000111122222222334556")
           (skipchars (string->char-set "HW"))
           (trans (lambda (c)
                    (let ((i (string-index chars c)))
                      (if i (string-ref nums i) c)))))
    (lambda (str)
      (let* ((ustr (string-upcase str))
             (f (string-ref ustr 0))
             (skip (trans f)))
        (let* ((mstr (string-map trans (string-delete ustr skipchars 1)))
               (dstr (string-map (lambda (c)
                                   (cond ((eq? c skip) #\0)
                                         (else (set! skip c) c)))
                                 mstr))
               (zstr (string-delete dstr #\0)))
          (substring (string-append (make-string 1 f) zstr "000") 0 4))))))

(soundex "Knuth")  ; K530
(soundex "Kant")   ; K530
(soundex "Lloyd")  ; L300
(soundex "Ladd")   ; L300

;; @@PLEAC@@_1.17
#!/usr/local/bin/guile -s
!#

(use-modules (srfi srfi-13)
             (srfi srfi-14)
             (ice-9 rw)
             (ice-9 regex))

(define data "analysed        => analyzed
built-in        => builtin
chastized       => chastised
commandline     => command-line
de-allocate     => deallocate
dropin          => drop-in
hardcode        => hard-code
meta-data       => metadata
multicharacter  => multi-character
multiway        => multi-way
non-empty       => nonempty
non-profit      => nonprofit
non-trappable   => nontrappable
pre-define      => predefine
preextend       => pre-extend
re-compiling    => recompiling
reenter         => re-enter
turnkey         => turn-key")

(define input (if (null? (cdr (command-line)))
                (current-input-port)
                (open-input-file (cadr (command-line)))))

(let* ((newline-char-set (string->char-set "\n"))
       (assoc-char-set (string->char-set " =>"))
       (dict (map
              (lambda (line)
                (string-tokenize line assoc-char-set))
              (string-tokenize data newline-char-set)))
       (dict-match (string-join (map car dict) "|")))
  (let loop ((line (read-line input)))
    (cond ((not (eof-object? line))
           (regexp-substitute/global
            (current-output-port) dict-match line
            'pre
            (lambda (x)
              (cadr (assoc (match:substring x 0) dict)))
            'post)
           (loop (read-line input 'concat))))))

(close-port input)

;; @@PLEAC@@_2.1
;; Strings and numbers are separate data types in Scheme, so this
;; isn't as important as it is in Perl.  More often you would use the
;; type predicates, string? and number?.

(if (string-match "[^\\d]" str) (display "has nondigits"))
(or (string-match "^\\d+$" str) (display "not a natural number"))
(or (string-match "^-?\\d+$" str) (display "not an integer"))
(or (string-match "^[\\-+]?\\d+$" str) (display "not an integer"))
(or (string-match "^-?\\d+\.?\d*$" str) (display "not a decimal number"))
(or (string-match "^-?(\d+(\.\d*)?|\.\d+)$" str)
    (display "not a decimal number"))
(or (string-match "^([+-]?)(\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$" str)
    (display "not a C float"))

(define num1 (string->number str))

(define num2 (read))

;; @@PLEAC@@_2.2
;; (approx-equal? num1 num2 accuracy) : returns #t if num1 and num2 are
;;   equal to accuracy number of decimal places
(define (approx-equal? num1 num2 accuracy)
  (< (abs (- num1 num2)) (expt 10.0 (- accuracy))))

(define wage 536)                     ;; $5.36/hour
(define week (* 40 wage))             ;; $214.40
(format #t "One week's wage is: $~$\n" (/ week 100.0))

;; @@PLEAC@@_2.3
(round num)                           ;; rounds to inexact whole number
(inexact->exact num)                  ;; rounds to exact integer

;; You can also use format to convert numbers to more precisely
;; formatted strings.  Note Guile has a builtin format which is a more
;; limited version of that found in the (ice-9 format) module, to save
;; load time.  Basically, if you are doing anything you couldn't do
;; with a series of (display), (write) and (newline), then you'll need
;; to use the module.
(use-modules (ice-9 format))

(define a 0.255)
(define b (/ (round (* 100.0 a)) 100.0))
(format #t "Unrounded: ~F\nRounded: ~F\n" a b)
(format #t "Unrounded: ~F\nRounded: ~,2F\n" a a)

(define a '(3.3 3.5 3.7 -3.3))
(display "number\tint\tfloor\tceil\n")
(for-each
 (lambda (n)
   (format #t "~,1F\t~,1F\t~,1F\t~,1F\n"
           n (round n) (floor n) (ceiling n)))
 a)

;; @@PLEAC@@_2.4
;; numbers are radix independent internally, so you usually only
;; convert on output, however to convert strings:
(define (dec->bin num)
  (number->string (string->number num 10) 2))

(define (bin->dec num)
  (number->string (string->number num 2) 10))

(define num (bin->dec "0110110"))  ; 54
(define binstr (dec->bin "54"))    ; 110110

;; @@PLEAC@@_2.5
;; do is the most general loop iterator
(do ((i x (1+ i)))   ; var  init-value  step-value
    ((> i y))        ; end when true
  ;; i is set to every integer from x to y, inclusive
  ;; ...
  )

;; Guile also offers a while loop
(let ((i x))
  (while (<= i y)
         ;; i is set to every integer from x to y, inclusive
         ; ...
         (set! i (1+ i))))

;; named let is another common loop
(let loop ((i x))
  (cond ((<= i y)
         ;; i is set to every integer from x to y, step-size 7
         ;; ...
         (loop (+ i 7)))))  ; tail-recursive call

(display "Infancy is: ")
(do ((i 0 (1+ i)))
    ((> i 2))
  (format #t "~A " i))
(newline)

(display "Toddling is: ")
(let ((i 3))
  (while (<= i 4)
         (format #t "~A " i)
         (set! i (1+ i))))
(newline)

(display "Childhood is: ")
(let loop ((i 5))
  (cond ((<= i 12)
         (format #t "~A " i)
         (loop (1+ i)))))
(newline)

;; @@PLEAC@@_2.6
;; format can output roman numerals - use ~:@R

(use-modules (ice-9 format))

(format #t "Roman for ~R is ~:@R\n" 15 15)

;; @@PLEAC@@_2.7
(random 5)        ; an integer from 0 to 4
(random 5.0)      ; an inexact real in the range [0,5)

;; char sets from SRFI-14 and string-unfold from SRFI-13 make a quick
;; way to generate passwords

(use-modules (srfi srfi-13) (srfi srfi-14))

(define chars (char-set->string char-set:graphic))
(define size (char-set-size char-set:graphic))
(define password
  (string-unfold (lambda (x) (= x 8))
                 (lambda (x) (string-ref chars (random size)))
                 1+ 0))

;; @@PLEAC@@_2.8
;; if you're working with random numbers you'll probably want to set
;; the random seed

(seed->random-state (current-time))

;; you can also save random states and pass them to any of the above
;; random functions

(define state (copy-random-state))
(random:uniform)
;; 0.939377327721761
(random:uniform state)
;; 0.939377327721761

;; @@PLEAC@@_2.9
;; @@INCOMPLETE@@
;; very inefficient
(use-modules (ice-9 rw))
(define make-true-random
  (letrec ((bufsize 8)
           (accum (lambda (c acc) (+ (* 256 acc)
                                     (char->integer c))))
           (getbuf (lambda ()
                     (call-with-input-file "/dev/urandom"
                       (lambda (p)
                         (let ((buf (make-string bufsize)))
                           (read-string!/partial buf p)
                           buf))))))
    (lambda (rand-proc)
      (lambda args
        (let ((state (seed->random-state (string-fold accum 0 (getbuf)))))
          (apply rand-proc (append args (list state))))))))

(define urandom (make-true-random random))
(define urandom:exp (make-true-random random:exp))
(define urandom:normal (make-true-random random:normal))
(define urandom:uniform (make-true-random random:uniform))

;; @@PLEAC@@_2.10
;; Guile offers a number of random distributions

(random:exp)      ; an inexact real in an exponential dist with mean 1
(random:normal)   ; an inexact real in a standard normal distribution
(random:uniform)  ; a uniformly distributed inexact real in [0,1)

;; There are also functions to fill vectors with random distributions

;; Fills vector v with inexact real random numbers the sum of whose
;; squares is equal to 1.0.
(random:hollow-sphere! v)

;; Fills vector v with inexact real random numbers that are
;; independent and standard normally distributed (i.e., with mean 0
;; and variance 1).
(random:normal-vector! v)

;; Fills vector v with inexact real random numbers the sum of whose
;; squares is less than 1.0.
(random:solid-sphere! v)

;; @@PLEAC@@_2.11
;; Guile's trigonometric functions use radians.

(define pi 3.14159265358979)

(define (degrees->radians deg)
  (* pi (/ deg 180.0)))

(define (radians->degrees rad)
  (* 180.0 (/ rad pi)))

(define (degree-sine deg)
  (sin (degrees->radians deg)))

;; @@PLEAC@@_2.12

;; Guile provides the following standard trigonometric functions (and
;; their hyperbolic equivalents), defined for all real and complex
;; numbers:

(sin z)
(cos z)
(tan z)
(asin z)
(acos z)
(atan z)

(acos 3.7)  ; 0.0+1.9826969446812i

;; @@PLEAC@@_2.13
;; Guile provides log in base e and 10 natively, defined for any real
;; or complex numbers:

(log z)    ; natural logarithm
(log10 z)  ; base-10 logarithm

;; For other bases, divide by the log of the base:

(define (log-base n z)
  (/ (log z) (log n)))

;; To avoid re-computing (log n) for a base you want to use
;; frequently, you can create a custom log function:

(define (make-log-base n)
  (let ((divisor (log n)))
    (lambda (z) (/ (log z) divisor))))

(define log2 (make-log-base 2))

(log2 1024)

;; @@PLEAC@@_2.14
;; In addition to simple vectors, Guile has builtin support for
;; uniform arrays of an arbitrary dimension.

;; a rows x cols integer matrix
(define a (make-array 0 rows cols))
(array-set! a 3 row col)
(array-ref a row col)

;; a 3D matrix of reals
(define b (make-array 0.0 x y z))

;; a literal boolean truth table for logical and
'#2((#f #f) (#f #t))

;; simple matrix multiplication

(define (matrix-mult m1 m2)
  (let* ((d1 (array-dimensions m1))
         (d2 (array-dimensions m2))
         (m1rows (car d1))
         (m1cols (cadr d1))
         (m2rows (car d2))
         (m2cols (cadr d2)))
    (if (not (= m1cols m2rows))
      (error 'index-error "matrices don't match"))
    (let ((result (make-array 0 m1rows m2cols)))
      (do ((i 0 (1+ i)))
          ((= i m1rows))
        (do ((j 0 (1+ j)))
            ((= j m2cols))
          (do ((k 0 (1+ k)))
              ((= k m1cols))
            (array-set! result (+ (array-ref result i j)
                                  (* (array-ref m1 i k)
                                     (array-ref m2 k j)))
                        i j))))
      result)))

(matrix-mult '#2((3 2 3) (5 9 8)) '#2((4 7) (9 3) (8 1)))

;; @@PLEAC@@_2.15
;; Guile has builtin support for complex numbers:

(define i 0+1i)       ; 0.0+1.0i
(define i (sqrt -1))  ; 0.0+1.0i

(complex? i)          ; #t
(real-part i)         ; 0.0
(imag-part i)         ; 1.0

(* 3+5i 2-2i)         ; 16+4i
(sqrt 3+4i)           ; 2+i

;; Classic identity:  -e^(pi*i) => 1
(inexact->exact (real-part (- (exp (* pi 0+1i))))) ; 1

;; @@PLEAC@@_2.16
;; You can type in literal numbers in alternate radixes:

#b01101101     ; 109 in binary
#o155          ; 109 in octal
#d109          ; 109 in decimal
#x6d           ; 109 in hexadecimal

;; number->string and string->number also take an optional radix:

(define number (string->number hexadecimal 16))
(define number (string->number octal 8))

;; format will also output in different radixes:

(format #t "~B ~O ~D ~X\n" num num num num)

;; converting Unix file permissions read from stdin:

(let loop ((perm (read-line)))
  (cond ((not (eof-object? perm))
         (format #t "The decimal value is ~D\n" (string->number perm 8))
         (loop (read-line)))))

;; @@PLEAC@@_2.17
;; once again, format is our friend :)
(use-modules (ice-9 format))

;; the : prefix to the D directive causes commas to be output every
;; three digits.
(format #t "~:D\n" (random 10000000000000000))
; => 2,301,267,079,619,540

;; the third prefix arg to the D directive is the separator character
;; to use instead of a comma, useful for European style numbers:
(format #t "~,,'.:D\n" (random 10000000000000000))
; => 6.486.470.447.356.534

;; the F directive, however, does not support grouping by commas.  to
;; achieve this, we can format the integer and fractional parts
;; separately:
(define (commify num)
  (let ((int (inexact->exact (truncate num))))
    (if (= num int)
      (format #f "~:D" int)
      (string-append (format #f "~:D" int)
                     (let ((str (format #f "~F" num)))
                       (substring str (or (string-index str #\.)
                                          (string-length str))))))))

;; @@PLEAC@@_2.18
;; format can handle simple 's' plurals with ~p, and 'y/ies' plurals
;; with the @ prefix:

(format #t "It took ~D hour~P\n" hours hours)

(format #t "It took ~D centur~@P\n" centuries centuries)

(define noun-plural
  (let* ((suffixes '(("ss"  . "sses")
                     ("ph"  . "phes")
                     ("sh"  . "shes")
                     ("ch"  . "ches")
                     ("z"   . "zes")
                     ("ff"  . "ffs")
                     ("f"   . "ves")
                     ("ey"  . "eys")
                     ("y"   . "ies")
                     ("ix"  . "ices")
                     ("s"   . "ses")
                     ("x"   . "xes")
                     ("ius" . "ii")))
        (suffix-match
         (string-append "(" (string-join (map car suffixes) "|") ")$"))
        (suffix-rx (make-regexp suffix-match)))
    (lambda (noun)
      (let ((m (regexp-exec suffix-rx noun)))
        (if m
          (string-append (regexp-substitute #f m 'pre)
                         (cdr (assoc (match:substring m) suffixes)))
          (string-append noun "s"))))))

;; @@PLEAC@@_2.19
#!/usr/local/bin/guile -s
!#

;; very naive factoring algorithm
(define (factor n)
  (let ((factors '())
        (limit (inexact->exact (round (sqrt n))))
        (twos 0))
    ;; factor out 2's
    (while (even? n)
           (set! n (ash n -1))
           (set! twos (1+ twos)))
    (if (> twos 0) (set! factors (list (cons 2 twos))))
    ;; factor out odd primes
    (let loop ((i 3))
      (let ((r (remainder n i)))
        (cond ((= r 0)
               (set! n (quotient n i))
               (let* ((old-val (assv i factors))
                      (new-val (if old-val (1+ (cdr old-val)) 1)))
                 (set! factors (assv-set! factors i new-val)))
               (loop i))
              ((< i limit)
               (loop (+ 2 i))))))
    ;; remainder
    (if (> n 1) (set! factors (cons (cons n 1) factors)))
    (reverse! factors)))

;; pretty print a term of a factor
(define (pp-term pair)
  (if (= (cdr pair) 1)
    (number->string (car pair))
    (format #f "~A^~A" (car pair) (cdr pair))))

;; factor each number given on the command line
(for-each
 (lambda (n)
   (let ((factors (factor n)))
     (format #t "~A = ~A" n (pp-term (car factors)))
     (for-each
      (lambda (x) (format #t " * ~A" (pp-term x)))
      (cdr factors))
     (newline)))
 (map string->number (cdr (command-line))))

;; @@PLEAC@@_3.0
;; Use the builtin POSIX time functions

;; get the current time
(current-time)   ; number of seconds since the epoch
(gettimeofday)   ; pair of seconds and microseconds since the epoch

;; create a time object from an integer (e.g. returned by current-time)
(localtime time) ; in localtime
(gmtime time)    ; in UTC

;; get/set broken down components of a time object

(tm:sec time)    (set-tm:sec time secs)    ; seconds (0-59)
(tm:min time)    (set-tm:min time mins)    ; minutes (0-59)
(tm:hour time)   (set-tm:hour time hours)  ; hours (0-23)
(tm:mday time)   (set-tm:mday time mday)   ; day of the month (1-31)
(tm:mon time)    (set-tm:mon time month)   ; month (0-11)
(tm:year time)   (set-tm:year time year)   ; year minus 1900 (70-)
(tm:wday time)   (set-tm:wday time wday)   ; day of the week (0-6)
                                           ; where Sunday is 0
(tm:yday time)   (set-tm:yday time yday)   ; day of year (0-365)
(tm:isdst time)  (set-tm:isdst time isdst) ; daylight saving indicator
                                           ; 0 for "no", > 0 for "yes",
                                           ; < 0 for "unknown"
(tm:gmtoff time) (set-tm:gmtoff time off)  ; time zone offset in seconds
                                           ; west of UTC (-46800 to 43200)
(tm:zone time)   (set-tm:zone time zone)   ; Time zone label (a string),
                                           ; not necessarily unique.

(format #t "Today is day ~A of the current year.\n"
        (tm:yday (localtime (current-time))))

;; Or use SRFI-19 - Time and Date Procedures
(use-modules (srfi srfi-19))

(define now (current-date))  ; immutable once created

(date-nanosecond now)        ; 0-9,999,999
(date-second now)            ; 0-60 (60 represents a leap second)
(date-minute now)            ; 0-59
(date-hour now)              ; 0-23
(date-day now)               ; 0-31
(date-month now)             ; 1-12
(date-year now)              ; integer representing the year
(date-year-day now)          ; day of year (Jan 1 is 1, etc.)
(date-week-day now)          ; day of week (Sunday is 0, etc.)
(date-week-number now start) ; week of year, ignoring a first partial week
                             ; start is the first day of week as above
(date-zone-offset now)       ; integer number of seconds east of GMT

(format #t "Today is day ~A of the current year.\n"
        (date-year-day (current-date)))

;; @@PLEAC@@_3.1
;; using format and POSIX time components
(use-modules (ice-9 format))
(let ((now (localtime (current-time))))
  (format #t "The current date is ~4'0D ~2'0D ~2'0D\n"
          (+ 1900 (tm:year now)) (tm:mon now) (tm:mday now)))

;; using format and SRFI-19 time components
(use-modules (srfi srfi-19) (ice-9 format))
(let ((now (current-date)))
  (format #t "The current date is ~4'0d-~2'0D-~2'0D\n"
          (date-year now) (date-month now) (date-day now)))

;; using POSIX strftime with a libc time format string
(display (strftime "%Y-%m-%d\n" (localtime (current-time))))

;; @@PLEAC@@_3.2
;; set the individual components of a time struct and use mktime
(define time (localtime (current-time)))
(set-tm:mday time mday)
(set-tm:mon time mon)
(set-tm:year time year)
(car (mktime time))  ; mktime returns a (epoch-seconds . time) pair

;; or use SRFI-19's make-date and date->time-monotonic
(use-modules (srfi srfi-19))
(date->time-monotonic
 (make-date nanosecond second minute hour day month year zone-offset))

;; @@PLEAC@@_3.3
;; use localtime or gmtime with the accessors mentioned in the
;; introduction to this chapter
(let ((time (localtime seconds)))  ; or gmtime
  (format #t "Dateline: ~2'0d:~2'0d:~2'0d-~4'0d/~2'0d/~2'0d\n"
          (tm:hour time) (tm:min time) (tm:sec time)
          (+ 1900 (tm:year time)) (1+ (tm:mon time)) (tm:mday time)))

;; or use SRFI-19
(use-modules (srfi srfi-19))
(let* ((time (make-time time-monotonic nanosecond second)))
  (display (date->string (time-monotonic->date time) "~T-~1\n")))

;; @@PLEAC@@_3.4
;; just add or subtract epoch seconds
(define when (+ now difference))
(define then (- now difference))

;; if you have DMYHMS values, you can convert them to times or add
;; them as seconds:
(define birthtime 96176750)
(define interval (+ 5                  ; 5 seconds
                    (* 17 60)          ; 17 minutes
                    (* 2 60 60)        ; 2 hours
                    (* 55 60 60 24)))  ; and 55 days
(define then (+ birthtime interval))
(format #t "Then is ~A\n" (strftime "%a %b %d %T %Y" (localtime then)))

;; @@PLEAC@@_3.5
;; subtract the epoch seconds:
(define bree 361535725)
(define nat 96201950)
(define difference (- bree nat))
(format #t "There were ~A seconds between Nat and Bree\n" difference)

;; or use SRFI-19's time arithmetic procedures:
(use-modules (srfi srfi-19))
(define time1 (make-time time-monotonic nano1 sec1))
(define time2 (make-time time-monotonic nano2 sec2))
(define duration (time-difference time1 time2))
(time=? (subtract-duration time1 duration) time2) ; #t
(time=? (add-duration time2 duration) time1)      ; #t

;; @@PLEAC@@_3.6
;; convert to a SRFI-19 date and use the accessors
(use-modules (srfi srfi-19))
(date-day date)
(date-year-day date)
(date-week-day date)
(date-week-number date start-day-of-week)

;; @@PLEAC@@_3.7
;; use the strptime function:
(define time-pair (strptime "%Y-%m-%d" "1998-06-03"))
(format #t "Time is ~A\n." (strftime "%b %d, %Y" (car time-pair)))

;; or use SRFI-19's string->date:
(use-modules (srfi srfi-19))
(define date (string->date "1998-06-03" "~Y-~m-~d"))
(format #t "Time is ~A.\n" (date->string date))

;; @@PLEAC@@_3.8
;; use the already seen strftime:
(format #t "strftime gives: ~A\n"
        (strftime "%A %D" (localtime (current-time))))

;; or SRFI-19's date->string:
(use-modules (srfi srfi-19))
(format #t "default date->string gives: ~A\n" (date->string (current-date)))
(format #t "date->string gives: ~A\n"
        (date->string (current-date) "~a ~b ~e ~H:~M:~S ~z ~Y"))

;; @@PLEAC@@_3.9
;; gettimeofday will return seconds and microseconds:
(define t0 (gettimeofday))
;; do your work here
(define t1 (gettimeofday))
(format #t "You took ~A seconds and ~A microseconds\n"
        (- (car t1) (car t0)) (- (cdr t1) (cdr t0)))

;; you can also get more detailed info about the real and processor
;; times:
(define runtime (times))
(tms:clock runtime)  ; the current real time
(tms:utime runtime)  ; the CPU time units used by the calling process
(tms:stime runtime)  ; the CPU time units used by the system on behalf
                     ; of the calling process.
(tms:cutime runtime) ; the CPU time units used by terminated child
                     ; processes of the calling process, whose status
                     ; has been collected (e.g., using `waitpid').
(tms:cstime runtime) ; the CPU times units used by the system on
		     ; behalf of terminated child processes

;; you can also use the time module to time execution:
(use-modules (ice-9 time))
(time (sleep 3))
;; clock utime stime cutime cstime gctime
;; 3.01  0.00  0.00   0.00   0.00   0.00
;; 0

;; @@PLEAC@@_3.10
(sleep i)   ; sleep for i seconds
(usleep i)  ; sleep for i microseconds (not available on all platforms)

;; @@PLEAC@@_4.0
(define nested '("this" "that" "the" "other"))
(define nested '("this" "that" ("the" "other")))
(define tune '("The" "Star-Spangled" "Banner"))

;; @@PLEAC@@_4.1
(define a '("quick" "brown" "fox"))
(define a '("Why" "are" "you" "teasing" "me?"))

(use-modules (srfi srfi-13))
(define lines
  (map string-trim
       (string-tokenize "\
    The boy stood on the burning deck,
    It was as hot as glass."
			#\newline)))

(define bigarray
  (with-input-from-file "mydatafile"
    (lambda ()
      (let loop ((lines '())
		 (next-line (read-line)))
	(if (eof-object? next-line)
	    (reverse lines)
	    (loop (cons next-line lines)
		  (read-line)))))))

(define banner "The Mines of Moria")

(define name "Gandalf")
(define banner
  (string-append "Speak, " name ", and enter!"))
(define banner
  (format #f "Speak, ~A, and welcome!" name))

;; Advanced shell-like function is provided by guile-scsh, the Guile
;; port of SCSH, the Scheme shell.  Here we roll our own using the
;; pipe primitives that come with core Guile.
(use-modules (ice-9 popen))

(define (drain-output port)
  (let loop ((chars '())
             (next (read-char port)))
    (if (eof-object? next)
        (list->string (reverse! chars))
        (loop (cons next chars)
              (read-char port)))))

(define (qx pipeline)
  (let* ((pipe (open-input-pipe pipeline))
         (output (drain-output pipe)))
    (close-pipe pipe)
    output))

(define his-host "www.perl.com")
(define host-info (qx (format #f "nslookup ~A" his-host)))

(define perl-info (qx (format #f "ps ~A" (getpid))))
(define shell-info (qx "ps $$"))

(define banner '("Costs" "only" "$4.95"))
(define brax    (map string (string->list "()<>{}[]")))
(define rings   (string-tokenize "Nenya Narya Vilya"))
(define tags    (string-tokenize "LI TABLE TR TD A IMG H1 P"))
(define sample
  (string-tokenize "The vertical bar (|) looks and behaves like a pipe."))
(define ships  '("Niña" "Pinta" "Santa María"))

;; @@PLEAC@@_4.2
(define array '("red" "yellow" "green"))

(begin
  (display "I have ")
  (for-each display array)
  (display " marbles.\n"))
;; I have redyellowgreen marbles.

(begin
  (display "I have ")
  (for-each (lambda (colour)
	      (display colour)
	      (display " "))
	    array)
  (display "marbles.\n"))
;; I have red yellow green marbles.

;; commify - insertion of commas into list output
(define (commify strings)
  (let ((len (length strings)))
    (case len
      ((0) "")
      ((1) (car strings))
      ((2) (string-append (car strings) " and " (cadr strings)))
      ((3) (string-append (car strings) ", "
                          (cadr strings) ", and "
                          (caddr strings)))
      (else
       (string-append (car strings) ", "
                      (commify (cdr strings)))))))

(define lists '(("just one thing")
                ("Mutt" "Jeff")
                ("Peter" "Paul" "Mary")
                ("To our parents" "Mother Theresa" "God")
                ("pastrami" "ham and cheese" "peanut butter and jelly" "tuna")
                ("recycle tired, old phrases" "ponder big, happy thoughts")
                ("recycle tired, old phrases"
                 "ponder big, happy thoughts"
                 "sleep and dream peacefully")))

(for-each (lambda (list)
            (display "The list is: ")
            (display (commify list))
            (display ".\n"))
          lists)

;; The list is: just one thing.
;; The list is: Mutt and Jeff.
;; The list is: Peter, Paul, and Mary.
;; The list is: To our parents, Mother Theresa, and God.
;; The list is: pastrami, ham and cheese, peanut butter and jelly, and tuna.
;; The list is: recycle tired, old phrases and ponder big, happy thoughts.
;; The list is: recycle tired, old phrases, ponder big, happy thoughts, and sleep and dream peacefully.

;; @@PLEAC@@_4.3
;;-----------------------------

;; Scheme does not normally grow and shrink arrays in the way that
;; Perl can.  The more usual operations are adding and removing from
;; the head of a list using the `cons' and `cdr' procedures.
;; However ...
(define (grow/shrink list new-size)
  (let ((size (length list)))
    (cond ((< size new-size)
           (grow/shrink (cons "" list) new-size))
          ((> size new-size)
           (grow/shrink (cdr list) new-size))
          (else list))))

(define (element list i)
  (list-ref list (- (length list) i 1)))

(define (set-element list i value)
  (if (>= i (length list))
      (set! list (grow/shrink list (- i 1))))
  (set-car! (list-cdr-ref list (- (length list) i 1)))
  list)

(define (what-about list)
  (let ((len (length list)))
    (format #t "The array now has ~A elements.\n" len)
    (format #t "The index of the last element is ~A.\n" (- len 1))
    (format #t "Element #3 is `~A'.\n" (if (> len 3)
                                           (element list 3)
                                           ""))))

;; In the emulation of Perl arrays implemented here, the elements are
;; in reverse order when compared to normal Scheme lists.
(define people (reverse '("Crosby" "Stills" "Nash" "Young")))
(what-about people)
;;-----------------------------
;; The array now has 4 elements.
;; The index of the last element is 3.
;; Element #3 is `Young'.
;;-----------------------------
(set! people (grow/shrink people 3))
(what-about people)
;;-----------------------------
;; The array now has 3 elements.
;; The index of the last element is 2.
;; Element #3 is `'.
;;-----------------------------
(set! people (grow/shrink people 10001))
(what-about people)
;;-----------------------------
;; The array now has 10001 elements.
;; The index of the last element is 10000.
;; Element #3 is `'.
;;-----------------------------

;; @@PLEAC@@_4.4
; Using a 'list' i.e. chain of pairs
(define *mylist* '(1 2 3))

; Apply procedure to each member of 'mylist'
(for-each
  (lambda (item) (print item))
  *mylist*)

;; ------------

; Using a 'vector' i.e. one-dimensional array
(define *bad-users* '#("lou" "mo" "sterling" "john"))

(define (complain user)
  (print "You're a *bad user*," user))

(array-for-each
  (lambda (user) (complain user))
  *bad-users*)

;; ------------

; Could probably get away with sorting a list of strings ...
(define *sorted-environ*
  (sort (environ) string<?))

(for-each
  (lambda (var) (display var) (newline))
  *sorted-environ*)

;; ----

; ... but the intent here is to sort a hash table, so we'll use
; an 'assoc', Scheme's native dictionary type, which is really
; nothing more than a list of conses / dotted pairs [hash tables
; will be used in later examples]
(define (cons->env-string a)
  (string-append (car a) "=" (cdr a)))

(define (env-string->cons s)
  (let ((key-value (string-split s #\=)))
    (cons (car key-value) (cadr key-value))))

(define *sorted-environ-assoc*
  (sort
    (map
      (lambda (var) (env-string->cons var))
      (environ))
    (lambda (left right) (string<? (car left) (car right))) ))

(for-each
  (lambda (var)
    (print (car var) "=" (cdr var)))
  *sorted-environ-assoc*)

;; ----------------------------

(define *MAX-QUOTA* 100)

(define (get-all-users) ...)
(define (get-usage user) ...)
(define (complain user) ...)

(for-each
  (lambda (user)
    (let ((disk-usage (get-usage user)))
      (if (> disk-usage *MAX-QUOTA*)
        (complain user))))
  (get-all-users))

;; ----------------------------

(for-each
  (lambda (user) (if (string=? user "tchrist") (print user)))
  (string-split (qx "who|cut -d' ' -f1|uniq") #\newline))

;; ----------------------------

(use-modules (srfi srfi-13) (srfi srfi-14))

(do ((line (read-line) (read-line)))
    ((eof-object? line))
  (for-each
    (lambda (word) (print (string-reverse word)))
    (string-tokenize line char-set:graphic)))

;; ----------------------------

; Updates vector in-place [accepts variable number of vectors]
; See also the library function, 'array-map-in-order!' and its
; brethren
(define (vector-map-in-order! proc vec . rest)
  (let ((all-vec (cons vec rest)))
    (for-each
      (lambda (vec)
        (let ((end (vector-length vec)))
          (let loop ((idx 0))
            (cond
              ((= idx end) '())
              (else
                (vector-set! vec idx (apply proc (list (vector-ref vec idx))))
                (loop (+ idx 1)))) )))
      all-vec)))

;; ----

; A non-mutating version - illustration only, as library routines
; [SRFI-43 and built-ins] should be preferred
(define (vector-map-in-order proc vec . rest)
  (let* ((all-vec (cons vec rest))
         (new-vec-len (reduce + 0 (map vector-length all-vec)))
         (new-vec (make-vector new-vec-len))
         (new-vec-idx 0))
    (let loop ((all-vec all-vec))
      (cond
        ((= new-vec-idx new-vec-len) new-vec)
        (else
          (array-for-each
            (lambda (element)
              (vector-set! new-vec new-vec-idx (apply proc (list element)))
              (set! new-vec-idx (+ new-vec-idx 1)))
            (car all-vec))
          (loop (cdr all-vec)) ))) ))

;; ------------

(define *array* '#(1 2 3))

(array-for-each
  (lambda (item)
    (print "i =" item))
  *array*)

;; ------------

(define *array* '#(1 2 3))

(array-for-each
  (lambda (item)
    (print "i =" item))
  *array*)

; Since a 'vector' is mutable, in-place updates allowed
(vector-map-in-order!
  (lambda (item) (- item 1))
  *array*)

(print *array*)

;; ------------

(define *a* '#(0.5 3))
(define *b* '#(0 1))

(vector-map-in-order!
  (lambda (item) (* item 7))
  *a* *b*)

(print *a* *b*)

;; ----------------------------

; Using 'for-each' to iterate over several container items is a
; simple matter of passing a list of those items e.g. a list of
; strings, or of arrays etc.
;
; However, complications arise when:
; * Heterogenous list of items e.g. list contains all of arrays,
;   hashes, strings, etc. Necesitates different handling based on type
; * Item needs updating. It is not possible to alter the item reference
;   and updating an item's internals is only possible if the relevant
;   mutating procedures are implemented e.g. specified string characters
;   may be altered in-place, but character deletion requires a new be
;   created [i.e. altering the item reference], so is not possible

(define *scalar* "123 ")
(define *array* '#(" 123 " "456 "))
(define *hash* (list (cons "key1" "123 ") (cons "key2" " 456")))

; Illustrates iteration / handling of heterogenous types
(for-each
  (lambda (item)
    (cond
      ((string? item) (do-stuff-with-string item))
      ((vector? item) (do-stuff-with-vector item))
      ((pair? item) (do-stuff-with-hash item))
      (else (print "unknown type"))))
  (list *scalar* *array* *hash*))

; So, for item-replacement-based updating you need to use explicit
; iteration e.g. 'do' loop, or recursion [as is done in the code for
; 'vector-map-in-order!'] - examples in next section. Or, you could
; create a new 'for-each' type control structure using Scheme's
; macro facility [example not shown]

;; @@PLEAC@@_4.5
(define *array* '#(1 2 3))

;; ----

; Whilst a 'vector' is mutable, 'array-for-each' passes only a copy
; of each cell, thus there is no way to perform updates
(array-for-each
  (lambda (item)
    ... do some non-array-mutating task with 'item'...)
  *array*)

;; ------------

; For mutating operations, use one of the mutating 'array-map-...' routines
; or the custom, 'vector-map-in-order!'
(vector-map-in-order!
  (lambda (item)
    ... do some array-mutating task with 'item'...)
  *array*)

;; ------------

; Alternatively, use 'do' to iterate over the array and directly update 
(let ((vector-length (vector-length *array*)))
  (do ((i 0 (+ i 1)))
      ((= i vector-length))
    ... do some array-mutating task with current array element ...))

;; ------------

; Alternatively, use a 'named let' to iterate over array and directly update 
(let ((vector-length (vector-length *array*)))
  (let loop ((i 0))
    (cond
      ((= i vector-length) '())
      (else
        ... do some array-mutating task with current array element ...
        (loop (+ i 1)))) ))

;; ----------------------------

(define *fruits* '#("Apple" "Blackberry"))

;; ------------

(array-for-each
  (lambda (fruit)
    (print fruit "tastes good in a pie."))
  *fruits*)

;; ------------

(let ((vector-length (vector-length *fruits*)))
  (do ((i 0 (+ i 1)))
      ((= i vector-length))
    (print (vector-ref *fruits* i) "tastes good in a pie.") ))

;; ----------------------------

(define *rogue-cats* '("Blacky" "Ginger" "Puss"))

(define *name-list* (acons 'felines *rogue-cats* '()))

;; ------------

(for-each
  (lambda (cat)
    (print cat "purrs hypnotically.."))
  (cdr (assoc 'felines *name-list*)))

;; ------------

(let loop ((felines (cdr (assoc 'felines *name-list*))))
  (cond
    ((null? felines) '())
    (else
      (print (car felines) "purrs hypnotically..")
      (loop (cdr felines)))))

;; @@PLEAC@@_4.6
(use-modules (srfi srfi-1))

; Simplest [read: least code] means of removing duplicates is to use 
; SRFI-1's 'delete-duplicates' routine

(define *non-uniq-num-list* '(1 2 3 1 2 3))
(define *uniq* (delete-duplicates *my-non-uniq-num-list*)

;; ------------

(use-modules (srfi srfi-1))

; Another simple alternative is to use SRFI-1's 'lset-union' routine. In
; general, the 'lset-...' routines:
; - convenient, but not fast; probably best avoided for 'large' sets
; - operate on standard lists, so simple matter of type-converting arrays and such
; - care needs to be taken in choosing the needed equality function

(define *non-uniq-string-list* '("abc" "def" "ghi" "abc" "def" "ghi"))
(define *uniq* (lset-union string=? *non-uniq-string-list* *non-uniq-string-list*))

;; ----

(define *non-uniq-sym-list* '('a 'b 'c 'a 'b 'c))
(define *uniq* (lset-union equal? *my-non-uniq-sym-list* *my-non-uniq-sym-list*))

;; ----

(define *non-uniq-num-list* '(1 2 3 1 2 3))
(define *uniq* (lset-union = *my-non-uniq-num-list* *my-non-uniq-num-list*))

;; ----------------------------

;; Perl Cookbook-based examples - illustrative only, *not* recommended approaches

(use-modules (srfi srfi-1))

(define *list* '(1 2 3 1 2 7 8 1 8 2 1 3))
(define *seen* '())

; Use hash to filter out unique items
(for-each
  (lambda (item)
    (if (not (assoc-ref *seen* item))
      (set! *seen* (assoc-set! *seen* item #t))))
  *list*)

; Generate list of unique items
(define *uniq*
  (fold-right
    (lambda (pair accum) (cons (car pair) accum))
    '()
    *seen*))

;; ------------

(define *list* '(1 2 3 1 2 7 8 1 8 2 1 3))
(define *seen* '())

; Build list of unique items by checking set membership
(for-each
  (lambda (item)
    (if (not (member item *seen*))
      (set! *seen* (cons item *seen*))))
  *list*)

;; ------------

(define *users*
  (sort
    (string-split (qx "who|cut -d' ' -f1") #\newline)
    string<?))

(define *seen* '())

; Build list of unique users by checking set membership
(for-each
  (lambda (user)
    (if (not (member user *seen*))
      (set! *seen* (cons item *seen*))))
  *list*)

;; @@PLEAC@@_4.7
; All problems in this section involve, at core, set difference
; operations. Thus, the most compact and straightforward approach is
; to utilise SRFI-1's 'lset-difference' routine

(use-modules (srfi srfi-1))

(define *a* '(1 3 5 6 7 8))
(define *b* '(2 3 5 7 9))

; *difference* contains elements in *a* but not in *b*: 1 6 8
(define *difference* (lset-difference = *a* *b*))

; *difference* contains elements in *b* but not in *a*: 2 9
(set! *difference* (lset-difference = *b* *a*))

;; ----------------------------

;; Perl Cookbook-based example - illustrative only, *not* recommended approaches

(use-modules (srfi srfi-1))

(define *a* '(1 3 5 6 7 8))
(define *b* '(2 3 5 7 9))

(define *a-only* '())

; Build list of items in *a* but not in *b*
(for-each
  (lambda (item)
    (if (not (member item *b*))
      (set! *a-only* (cons item *a-only*))))
  *a*)

;; @@PLEAC@@_4.8
; The SRFI-1 'lset-xxx' routines are appropriate here

(use-modules (srfi srfi-1))

(define *a* '(1 3 5 6 7 8))
(define *b* '(2 3 5 7 9))

; Combined elements of *a* and *b* sans duplicates: 1 2 3 5 6 7 8 9
(define *union* (lset-union = *a* *b*))

; Elements common to both *a* and *b*: 3 5 7
(define *intersection* (lset-intersection = *a* *b*))

; Elements in *a* but not in *b*: 1 6 8
(define *difference* (lset-difference = *a* *b*))

;; ----------------------------

;; Perl Cookbook-based example - illustrative only, *not* recommended approaches

(use-modules (srfi srfi-1))

(define *a* '(1 3 5 6 7 8))
(define *b* '(2 3 5 7 9))

(define *union* '())
(define *isect* '())
(define *diff* '())

;; ------------

; Union and intersection
(for-each
  (lambda (item) (set! *union* (assoc-set! *union* item #t)))
  *a*)

(for-each
  (lambda (item)
    (if (assoc-ref *union* item)
      (set! *isect* (assoc-set! *isect* item #t)))
    (set! *union* (assoc-set! *union* item #t)))
  *b*)

; Difference *a* and *b*
(for-each
  (lambda (item)
    (if (not (assoc-ref *isect* item))
      (set! *diff* (assoc-set! *diff* item #t))))
  *a*)

(set! *union*
  (fold
    (lambda (pair accum) (cons (car pair) accum))
    '()
    *union*))

(set! *isect*
  (fold
    (lambda (pair accum) (cons (car pair) accum))
    '()
    *isect*))

(set! *diff*
  (fold
    (lambda (pair accum) (cons (car pair) accum))
    '()
    *diff*))

(print "Union count:       " (length *union*))
(print "Intersection count:" (length *isect*))
(print "Difference count:  " (length *diff*))

;; @@PLEAC@@_4.9
; Arrays, specifically vectors in the current context, are fixed-size
; entities; joining several such together requires copying of their
; contents into a new, appropriately-sized, array. This task may be
; performed:

; * Directly: loop through existing arrays copying elements into a
;   newly-created array

(define (vector-join vec . rest)
  (let* ((all-vec (cons vec rest))
         (new-vec-len (reduce + 0 (map vector-length all-vec)))
         (new-vec (make-vector new-vec-len))
         (new-vec-idx 0))
    (let loop ((all-vec all-vec))
      (cond
        ((= new-vec-idx new-vec-len) new-vec)
        (else
          (array-for-each
            (lambda (element)
              (vector-set! new-vec new-vec-idx element)
              (set! new-vec-idx (+ new-vec-idx 1)))
            (car all-vec))
          (loop (cdr all-vec)) ))) ))

;; ----

(define *array1* '#(1 2 3))
(define *array2* '#(4 5 6))

(define *newarray*
  (vector-join *array1* *array2*))

;; ----------------------------

; * Indirectly; convert arrays to lists, append the lists, convert
;   resulting list back into an array

(define *array1* '#(1 2 3))
(define *array2* '#(4 5 6))

(define *newarray*
  (list->vector (append (vector->list *array1*) (vector->list *array2*)) ))

; Of course if random access is not required, it is probably best to simply
; use lists since a wealth of list manipulation routines are available

;; ----------------------------

; While Perl offers an all-purpose 'splice' routine, a cleaner approach is
; to separate out such functionality; here three routines are implemented
; together offering an equivalent to 'splice'. The routines are:
; * vector-replace! [use with 'vector-copy' to avoid changing original]
;   e.g. (vector-replace! vec ...)
;        (set! new-vec (vector-replace! (vector-copy vec) ...))
; * vector-delete
; * vector-insert

(define (vector-replace! vec pos item . rest)
  (let* ((all-items (cons item rest))
         (pos (if (< pos 0) (+ (vector-length vec) pos) pos))
         (in-bounds
           (not (> (+ pos (length all-items)) (vector-length vec)))))
    (if in-bounds
      (let loop ((i pos) (all-items all-items))
        (cond
          ((null? all-items) vec)
          (else
            (vector-set! vec i (car all-items))
            (loop (+ i 1) (cdr all-items))) ))
    ;else
      vec)))

(define (vector-delete vec pos len)
  (let* ((new-vec-len (- (vector-length vec) len))
         (new-vec #f)
         (pos (if (< pos 0) (+ (vector-length vec) pos) pos)))
    (cond
      ((< new-vec-len 0) vec)
      (else
        (set! new-vec (make-vector new-vec-len))
        (let loop ((vec-idx 0) (new-vec-idx 0))
          (cond
            ((= new-vec-idx new-vec-len) new-vec)
            (else
              (if (= vec-idx pos) (set! vec-idx (+ vec-idx len)))
              (vector-set! new-vec new-vec-idx (vector-ref vec vec-idx))
              (loop (+ vec-idx 1) (+ new-vec-idx 1)) ))) )) ))

; This routine would probably benefit from having 'cmd' implemented as a keyword
; argument. However, 'cmd' implemented as a positional to keep example simple
(define (vector-insert vec pos cmd item . rest)
  (let* ((all-item-vec (list->array 1 (cons item rest)))
         (all-item-vec-len (vector-length all-item-vec))
         (vec-len (vector-length vec))
         (new-vec (make-vector (+ vec-len all-item-vec-len)))
         (pos (if (< pos 0) (+ (vector-length vec) pos) pos)))
    (if (eq? cmd 'after) (set! pos (+ pos 1)))
    (vector-move-left! vec 0 pos new-vec 0)
    (vector-move-left! all-item-vec 0 all-item-vec-len new-vec pos)
    (vector-move-left! vec pos vec-len new-vec (+ pos all-item-vec-len))
    new-vec))

;; ----

(define *members* '#("Time" "Flies"))
(define *initiates* '#("An" "Arrow"))

(set! *members* (vector-join *members* *initiates*))

;; ------------

(set! *members* (vector-insert *members* 1 'after "Like" *initiates*))
(print *members*)

(set! *members* (vector-replace *members* 0 "Fruit"))
(set! *members* (vector-replace *members* -2 "A" "Banana"))
(print *members*)

; was: '#("Time" "Flies" "An" "Arrow")
; now: '#("Fruit" "Flies" "Like" "A" "Banana")

;; @@PLEAC@@_4.10
; As for appending arrays, there is the choice of iterating through
; the array:
(define (vector-reverse! vec)
  (let loop ((i 0) (j (- (vector-length vec) 1)))
    (cond
      ((>= i j) vec)
      (else
        (vector-ref-swap! vec i j)
        (loop (+ i 1) (- j 1)))) ))

;; ------------

(define *array* '#(1 2 3))

(vector-reverse! *array*)

;; ------------

(define *array* '#(1 2 3))

(do ((i (- (vector-length *array*) 1) (- i 1)))
    ((< i 0))
  ... do something with *array* ...)

;; ----------------------------

; or of converting to / from a list, performing any manipulation using
; the list routines

(define *array* '#(1 2 3))

(define *newarray*
  (list->vector (reverse (sort (vector->list *array*) <)) ))

;; @@PLEAC@@_4.11
(define *array* '#(1 2 3 4 5 6 7 8))

;; ------------

; Remove first 3 elements
(define *front* (vector-delete *array* 0 3))

; Remove last 3 elements
(define *end* (vector-delete *array* -1 3))

;; ----------------------------

; Another helper routine
(define (vector-slice vec pos len)
  (let* ((vec-len (vector-length vec))
         (pos (if (< pos 0) (+ vec-len pos) pos))
         (in-bounds
           (not (> (+ pos len) vec-len))))
    (if in-bounds
      (let ((new-vec (make-vector len)))
        (let loop ((vec-idx pos) (new-vec-idx 0))
          (cond
            ((= new-vec-idx len) new-vec)
            (else
              (vector-set! new-vec new-vec-idx (vector-ref vec vec-idx))
              (loop (+ vec-idx 1) (+ new-vec-idx 1))) )))
    ;else
      vec)))

; Both the following use, 'values', to return two values; this approach
; is quite contrived and is taken to mimic the Perl examples, not
; because it is a recommended one [returning a single list would probably
; be more sensible]
(define (shift2 vec)
  (let ((vec (vector-slice vec 0 2)))
    (values (vector-ref vec 0) (vector-ref vec 1)) ))

(define (pop2 vec)
  (let ((vec (vector-slice vec -1 2)))
    (values (vector-ref vec 0) (vector-ref vec 1)) ))

;; ------------

(define *friends* '#('Peter 'Paul 'Mary 'Jim 'Tim))

(let-values ( ((this that) (shift2 *friends*)) )
  (print this ":" that))

;; ------------

(define *beverages* '#('Dew 'Jolt 'Cola 'Sprite 'Fresca))

(let-values ( ((d1 d2) (pop2 *beverages*)) )
  (print d1 ":" d2))

;; @@PLEAC@@_4.12
; SRFI-1 [list manipulation] routines are ideal for the types of task
; in this and the next section, in particular, 'for-each' and 'find',
; 'list-index', and many others for more specialist functions. The same
; applies to vectors with the SRFI-43 routines, 'vector-index' and
; 'vector-skip', though the approach taken in this chapter has been to
; implement functionally similar vector manipulation routines to more
; closely mimic the Perl examples

; Return #f, or first index for which 'pred' returns true
(define (vector-first-idx pred vec) 
  (let ((vec-len (vector-length vec)))
    (let loop ((idx 0))
      (cond
        ((= idx vec-len) #f)
        (else
          (if (pred (vector-ref vec idx))
            idx
          ;else
            (loop (+ idx 1))) )))))

; Return #f, or first index for which 'pred' returns true
(define (list-first-idx pred list)
  (let loop ((idx 0) (list list))
    (cond
      ((null? list) #f)
      (else
        (if (pred (car list))
          idx
        ;else
          (loop (+ idx 1) (cdr list))) ))))

;; ------------

(define *array* '#(1 2 3 4 5 6 7 8))

(print
  (vector-first-idx
    (lambda (x) (= x 9))
    *array*))

;; ----

(define *list* '(1 2 3 4 5 6 7 8))

(print
  (list-first-idx
    (lambda (x) (= x 4))
    *list*))

;; ----

(use-modules (srfi srfi-1))

(print
  (list-index
    (lambda (x) (= x 4))
    *list*))

;; ----------------------------

; The Perl 'highest paid engineer' example isn't really a 'first match'
; type of problem - the routines shown earlier really aren't suited to
; this. Better suited, instead, are the SRFI-1 routines like 'fold',
; 'fold-right' and 'reduce', even old standbys like 'filter' and 'for-each'

(define +null-salary-rec+
  (list '() 0 '()))

(define *salaries*
  (list
    (list 'engineer 43000 'Bob)
    (list 'programmer 48000 'Andy)
    (list 'engineer 35000 'Champ) 
    (list 'engineer 49000 'Bubbles)
    (list 'programmer 47000 'Twig)
    (list 'engineer 34000 'Axel) ))

;; ----------------------------

(define *highest-paid-engineer*
  (reduce
    (lambda (salary-rec acc)
      (if
        (and
          (eq? (car salary-rec) 'engineer)
          (> (cadr salary-rec) (cadr acc)))
        salary-rec
      ;else
        acc))
    +null-salary-rec+
    *salaries*))

(print *highest-paid-engineer*)

;; ------------

(define *highest-paid-engineer*
  (fold-right
    (lambda (salary-rec acc)
      (if (> (cadr salary-rec) (cadr acc))
        salary-rec
      ;else
        acc))
    +null-salary-rec+
    (filter
      (lambda (salary-rec)
        (eq? (car salary-rec) 'engineer))
      *salaries*)) )

(print *highest-paid-engineer*)

;; ------------

(define *highest-paid-engineer* +null-salary-rec+)

(for-each
  (lambda (salary-rec)
    (if
      (and
        (eq? (car salary-rec) 'engineer)
        (> (cadr salary-rec) (cadr *highest-paid-engineer*)))
      (set! *highest-paid-engineer* salary-rec)))
  *salaries*)

(print *highest-paid-engineer*)

;; @@PLEAC@@_4.13
; All tasks in this section consist of either generating a collection,
; or filtering a larger collection, of elements matching some criteria;
; obvious candidates are the 'filter' and 'array-filter' routines, though
; others like 'for-each' can also be applied

(define *list-matching* (filter PRED LIST))
(define *vector-matching* (array-filter PRED ARRAY))

;; ----------------------------

(define *nums* '(1e7 3e7 2e7 4e7 1e7 3e7 2e7 4e7))

(define *bigs* 
  (filter
    (lambda (num) (> num 1000000))
    *nums*))

;; ------------

(define *users*
  (list
    '(u1 . 2e7)
    '(u2 . 1e7)
    '(u3 . 4e7)
    '(u4 . 3e7) ))

(define *pigs*
  (fold-right
    (lambda (pair accum) (cons (car pair) accum))
    '()
    (filter
      (lambda (pair) (> (cdr pair) 1e7))
      *users*)))

(print *pigs*)

;; ------------

(define *salaries*
  (list
    (list 'engineer 43000 'Bob)
    (list 'programmer 48000 'Andy)
    (list 'engineer 35000 'Champ) 
    (list 'engineer 49000 'Bubbles)
    (list 'programmer 47000 'Twig)
    (list 'engineer 34000 'Axel) ))

(define *engineers*
  (filter
    (lambda (salary-rec)
      (eq? (car salary-rec) 'engineer))
    *salaries*))

(print *engineers*)

;; ------------

(define *applicants*
  (list
    (list 'a1 26000 'Bob)
    (list 'a2 28000 'Andy)
    (list 'a3 24000 'Candy) ))

(define *secondary-assistance*
  (filter
    (lambda (salary-rec)
      (and
        (> (cadr salary-rec) 26000)
        (< (cadr salary-rec) 30000)))
    *applicants*))

(print *secondary-assistance*)

;; @@PLEAC@@_4.14
; Sorting numeric data in Scheme is very straightforward ...

(define *unsorted* '(5 8 1 7 4 2 3 6)) 

;; ------------

; Ascending sort - use '<' as comparator
(define *sorted* 
  (sort
    *unsorted*
    <))

(print *sorted*)

;; ------------

; Descending sort - use '>' as comparator
(define *sorted* 
  (sort
    *unsorted*
    >))

(print *sorted*)

;; @@PLEAC@@_4.15
; A customised lambda may be passed as comparator to 'sort', so
; sorting on one or more 'fields' is quite straightforward

(define *unordered* '( ... ))

; COMPARE is some comparator suited for the element type being
; sorted
(define *ordered*
  (sort
    *unordered*
    (lambda (left right)
      (COMPARE left right))))

;; ------------

(define *unordered*
  (list
    (cons 's 34)
    (cons 'e 12)
    (cons 'c 45)
    (cons 'q 11)
    (cons 'g 24) ))

(define *pre-computed*
  (map
    ; Here element is returned unaltered, but it would normally be
    ; transformed in som way
    (lambda (element) element)
    *unordered*))

(define *ordered-pre-computed*
  (sort
    *pre-computed*
    ; Sort on the first field [assume it is the 'key'] 
    (lambda (left right)
      (string<?
        (symbol->string (car left))
        (symbol->string (car right))))))

; Extract the second field [assume it is the 'value']
(define *ordered*
  (map 
    (lambda (element) (cdr element))
    *ordered-pre-computed*))

;; ----------------------------

(define *employees*
  (list
    (list 'Bob 43000 123 42)
    (list 'Andy 48000 124 35)
    (list 'Champ 35000 125 37) 
    (list 'Bubbles 49000 126 34)
    (list 'Twig 47000 127 36)
    (list 'Axel 34000 128 31) ))

(define *ordered*
  (sort
    *employees*
    (lambda (left right)
      (string<?
        (symbol->string (car left))
        (symbol->string (car right))))))

;; ------------

(for-each
  (lambda (employee)
    (print (car employee) "earns $" (cadr employee)))
  (sort
    *employees*
    (lambda (left right)
      (string<?
        (symbol->string (car left))
        (symbol->string (car right))))))

;; ------------

(define *bonus*
  (list
    '(125 . 1000)
    '(127 . 1500) ))

(for-each
  (lambda (employee)
    (let ((bonus (assoc-ref *bonus* (caddr employee))))
      (if (not bonus)
        '()
      ;else
        (print (car employee) "earned bonus" bonus) )))
  (sort
    *employees*
    (lambda (left right)
      (string<?
        (symbol->string (car left))
        (symbol->string (car right))))))

;; ----------------------------

(use-modules (srfi srfi-1) (ice-9 rdelim) (ice-9 regex))

(define *filename* "/etc/passwd")
(define *users* '())

(let ((port (open-input-file *filename*)))
  (let loop ((line&terminator (read-line port 'split)))
    (cond
      ((eof-object? (cdr line&terminator)) '())
      (else
        (set! *users*
          (assoc-set!
            *users*
            (car (string-split (car line&terminator) #\:))
            #t))
        (loop (read-line port 'split)) ))) 
  (close-input-port port))

(for-each
  (lambda (user) (print (car user)))
  (sort
    *users*
    (lambda (left right)
      (string<?
        (car left)
        (car right)))))

;; @@PLEAC@@_4.16
; Use SRFI-1's 'circular-list' routine to build a circular list
(use-modules (srfi srfi-1))

(define *processes* (circular-list 1 2 3 4 5))

(let loop ((processes *processes*))
  (print "Handling process" (car processes))
  (sleep 1)
  (loop (cdr processes)))

;; @@PLEAC@@_4.17
(use-modules (srfi srfi-1))

; Implements Fischer-Yates shuffle algorithm
(define (vector-shuffle! vec)
  (let ((vector-length (vector-length vec)))
    (let loop ((i vector-length) (j (+ 1 (random vector-length))))
      (cond
        ((= i 1) '())
        ((not (= i j))
          (vector-ref-swap! vec (- i 1) (- j 1))
          (loop (- i 1) (+ 1 (random (- i 1)))))
        (else
          (loop (- i 1) (+ 1 (random (- i 1))))) ))))

(define (vector-ref-swap! vec idx1 idx2)
  (let ((tmp (vector-ref vec idx1)))
    (vector-set! vec idx1 (vector-ref vec idx2))
    (vector-set! vec idx2 tmp)))

; Generate vector of values 1 .. 10
(define *irange* (list->vector (iota 10 1 1)))

; Shuffle array values
(vector-shuffle! *irange*)

;; @@PLEAC@@_4.18
;; @@INCOMPLETE@@
;; @@INCOMPLETE@@

;; @@PLEAC@@_4.19
;; @@INCOMPLETE@@
;; @@INCOMPLETE@@

;; @@PLEAC@@_5.0
;; ---------------------------------------------------------------------
;; Scheme offers two dictionary types:
;;
;; * Association list [list of pairs e.g. '((k1 . v1) (k2 . v2) ...)]
;; * Hash table [vector of pairs plus hash algorithm]
;;
;; Implementation differences aside, they are remarkably similar in that
;; the functions operating on them are similar named, and offer the same
;; interface. Examples:
;;
;; * Retrieve an item: (assoc-ref hash key) (hash-ref hash key)
;; * Update an item:   (assoc-set! hash key value) (hash-set! hash key value) 
;;
;; Hash tables would tend to be used where performance was critical e.g.
;; near constant-time lookups, or where entry updates are frequent, whilst
;; association lists would be used where table-level traversals and 
;; manipulations require maximum flexibility
;;
;; Many of the sections include examples using both association lists and
;; hash tables. However, where only one of these is shown, implementing
;; the other is usually a trivial exercise. Finally, any helper functions
;; will be included in the Appendix
;; ---------------------------------------------------------------------

; Association lists
(define *age*
  (list
    (cons 'Nat 24)
    (cons 'Jules 25)
    (cons 'Josh 17)))

;; or, perhaps more compactly:
(define *age*
  (list
    '(Nat . 24)
    '(Jules . 25)
    '(Josh . 17)))

;; ------------

; Guile built-in association list support
(define *age* (acons 'Nat 24 '()))
(set! *age* (acons 'Jules 25 *age*))
(set! *age* (acons 'Josh 17 *age*))

;; ----

; SRFI-1 association list support
(use-modules (srfi srfi-1))

(define *age* (alist-cons 'Nat 24 '()))
(set! *age* (alist-cons 'Jules 25 *age*))
(set! *age* (alist-cons 'Josh 17 *age*))

;; ------------

(define *food-colour*
  (list
    '(Apple . "red")
    '(Banana . "yellow")
    '(Lemon . "yellow")
    '(Carrot . "orange")))

;; ----------------------------

; Hash tables. Guile offers an implementation, and it is also 
; possible to use SRFI-69 hash tables; only the former will be
; illustrated here

(define *age* (make-hash-table 20))
; or
(define *age* (make-vector 20 '()))

(hash-set! *age* 'Nat 24)
(hash-set! *age* 'Jules 25)
(hash-set! *age* 'Josh 17)

(hash-for-each
  (lambda (key value) (print key))
  *age*)

; or, if vector used as hash table, can also use:

(array-for-each
  (lambda (pair)
    (if (not (null? pair)) (print (car pair))))
  *age*)

;; ------------

(define *food-colour* (make-hash-table 20))

(hash-set! *food-colour* 'Apple "red")
(hash-set! *food-colour* 'Banana "yellow")
(hash-set! *food-colour* 'Lemon "yellow")
(hash-set! *food-colour* 'Carrot "orange")

;; @@PLEAC@@_5.1
(set! *hash* (acons key value *hash*))

;; ------------

(set! *food-colour* (acons 'Raspberry "pink" *food-colour*))

(print "Known foods:")
(for-each
  (lambda (pair) (print (car pair)))
  *food-colour*)

;; ----------------------------

(hash-set! *hash* key value)

;; ------------

(hash-set! *food-colour* 'Raspberry "pink")

(print "Known foods:")
(hash-for-each
  (lambda (key value) (print key))
  *food-colour*)

;; @@PLEAC@@_5.2
; 'assoc' returns the pair, (key . value)
(if (assoc key hash)
  ... found ...
;else
  ... not found ...

; 'assoc-ref' returns the value only
(if (assoc-ref hash key)
  ... found ...
;else
  ... not found ...

;; ------------

; *food-colour* association list from an earlier section

(for-each
  (lambda (name)
    (let ((pair (assoc name *food-colour*)))
      (if pair
        (print (symbol->string (car pair)) "is a food")
      ;else
        (print (symbol->string name) "is a drink") )))
  (list 'Banana 'Martini))

;; ----------------------------

; 'hash-get-handle' returns the pair, (key . value)
(if (hash-get-handle hash key)
  ... found ...
;else
  ... not found ...

; 'hash-ref' returns the value only
(if (hash-ref hash key)
  ... found ...
;else
  ... not found ...

;; ------------

; *food-colour* hash table from an earlier section

(for-each
  (lambda (name)
    (let ((value (hash-ref *food-colour* name)))
      (if value
        (print (symbol->string name) "is a food")
      ;else
        (print (symbol->string name) "is a drink") )))
  (list 'Banana 'Martini))

;; ----------------------------

(define *age* (make-hash-table 20))

(hash-set! *age* 'Toddler 3)
(hash-set! *age* 'Unborn 0)
(hash-set! *age* 'Phantasm '())

(for-each
  (lambda (thing)
    (let ((value (hash-ref *age* thing)))
      (display thing)
      (if value (display " Exists"))
      (if (and value (not (string-null? value))) (display " Defined"))
      ; Testing for non-zero as true is not applicable, so testing
      ; for non-equality with zero 
      (if (and value (not (eq? value 0))) (display " True"))
      (print "") ))
  (list 'Toddler 'Unborn 'Phantasm 'Relic))

;; @@PLEAC@@_5.3
(assoc-remove! hash key)

;; ------------

(use-modules (srfi srfi-1))

; *food-colour* association list from an earlier section

(define (print-foods)
  (let ((foods
          (fold-right
            (lambda (pair accum) (cons (car pair) accum))
            '()
            *food-colour*)))
    (display "Keys: ") (print foods)
    (print "Values:")
    (for-each
      (lambda (food)
        (let ((colour (assoc-ref *food-colour* food)))
          (cond
            ((string-null? colour) (display "(undef) "))
            (else (display (string-append colour " "))) )))
      foods))
    (newline))

(print "Initially:")
(print-foods)

(print "\nWith Banana undef")
(assoc-set! *food-colour* 'Banana "")
(print-foods)

(print "\nWith Banana deleted")
(assoc-remove! *food-colour* 'Banana)
(print-foods)

;; ----------------------------

(hash-remove! hash key)

;; ------------

(use-modules (srfi srfi-1))

; *food-colour* hash table from an earlier section

(define (print-foods)
  (let ((foods
          (hash-fold
            (lambda (key value accum) (cons key accum))
            '()
            *food-colour*)))
    (display "Keys: ") (print (reverse foods))
    (print "Values:")
    (for-each
      (lambda (food)
        (let ((colour (hash-ref *food-colour* food)))
          (cond
            ((string-null? colour) (display "(undef) "))
            (else (display (string-append colour " "))) )))
      foods))
    (newline))

(print "Initially:")
(print-foods)

(print "\nWith Banana undef")
(hash-set! *food-colour* 'Banana "")
(print-foods)

(print "\nWith Banana deleted")
(hash-remove! *food-colour* 'Banana)
(print-foods)

;; @@PLEAC@@_5.4
; Since an association list is nothing more than a list of pairs, it
; may be traversed using 'for-each'
(for-each
  (lambda (pair)
    (let ((key (car pair))
          (value (cdr pair)))
      ... do something with key / value ...))
  hash)

;; ----------------------------

; A 'for-each'-like function is available for hash table traversal
(hash-for-each
  (lambda (key value)
    ... do something with key / value ...)
  hash)

; If the hash table is directly implemented as a vector, then it is
; also possible to traverse it using, 'array-for-each', though a 
; check for empty slots is needed 
(array-for-each
  (lambda (pair)
    (if (not (null? pair)) ... do something with key / value ...))
  hash)

;; ----------------------------

; *food-colour* association list from an earlier section

(for-each
  (lambda (pair)
    (let ((food (car pair))
          (colour (cdr pair)))
      (print (symbol->string food) "is" colour) ))
  *food-colour*)

;; ------------

; *food-colour* association list from an earlier section

(for-each
  (lambda (food)
    (print (symbol->string food) "is" (assoc-ref *food-colour* food)))
  (sort
    (fold-right
      (lambda (pair accum) (cons (car pair) accum))
      '()
      *food-colour*)
    (lambda (left right)
      (string<? (symbol->string left) (symbol->string right)))))

;; ----------------------------

(use-modules (srfi srfi-1) (ice-9 rdelim) (ice-9 regex))

(define *filename* "from.txt")
(define *from* '())

(let ((port (open-input-file *filename*)))
  (let loop ((line&terminator (read-line port 'split)))
    (cond
      ((eof-object? (cdr line&terminator)) '())
      (else
        (let* ((key (string->symbol
                      (match:substring
                        (string-match
                          "^From: (.*)" (car line&terminator))
                        1) ))
               (value (assoc-ref *from* key)))
          (if (not value) (set! value 0))
          (set! *from* (assoc-set! *from* key (+ 1 value))))
        (loop (read-line port 'split)) ))) 
  (close-input-port port))

(for-each
  (lambda (person)
    (print (symbol->string person) ":" (number->string (assoc-ref *from* person))))
  (sort
    (fold-right
      (lambda (pair accum) (cons (car pair) accum))
      '()
      *from*)
    (lambda (left right)
      (string<? (symbol->string left) (symbol->string right)))))

;; @@PLEAC@@_5.5
; All approaches shown in the previous section apply here also, so
; there is little to be gained by repeating those examples [i.e. the
; use of 'for-each' and similar]. It is always possible, of course,
; to directly recurse over an association list:

; *food-colour* association list from an earlier section

(define *sorted-food-colour*
  (sort
    *food-colour*
    (lambda (left right)
      (string<?
        (symbol->string (car left))
        (symbol->string (car right)))) ))

(let loop ((hash *sorted-food-colour*))
  (cond
    ((null? hash) '())
    (else  
      (print
        (symbol->string (car (car hash))) "=>" (cdr (car hash)) )
      (loop (cdr hash))) ))

;; @@PLEAC@@_5.6
; AFAIK, Scheme doesn't offer a facility similar to Perl's 'Tie::IxHash'.
; Therefore, use an association list if retrieval [from a dictionary
; type container] in insertion order is required.

(define *food-colour* (acons 'Banana "Yellow" '()))
(set! *food-colour* (acons 'Apple "Green" *food-colour*))
(set! *food-colour* (acons 'Lemon "yellow" *food-colour*))

(print "In insertion order, the foods are:")
(for-each
  (lambda (pair)
    (let ((food (car pair))
          (colour (cdr pair)))
      (print "  " (symbol->string food)) ))
  *food-colour*)

(print "Still in insertion order, the food's colours are:")
(for-each
  (lambda (pair)
    (let ((food (car pair))
          (colour (cdr pair)))
      (print (symbol->string food) "is coloured" colour) ))
  *food-colour*)

;; ----------------------------

; Of course, insertion order is lost if the association list is sorted,
; or elements removed, so if maintaining insertion order is vital, it
; might pay to associate data with a timestamp [e.g. create a timestamped
; record / structure], and manipulate those entities [no example given]

;; @@PLEAC@@_5.7
(define *ttys* '())

(for-each
  (lambda (user-tty-pair)
    (let* ((user-tty-pair (string-split user-tty-pair #\space))
           (user (string->symbol (car user-tty-pair)))
           (newtty (cadr user-tty-pair))
           (current-ttys (assoc-ref *ttys* user)))
      (set! *ttys*
        (assoc-set! *ttys* user
          (if (not current-ttys)
            newtty
            (string-append current-ttys " " newtty)) ))))
  (string-split (qx "who|cut -d' ' -f1,2") #\newline))

(for-each
  (lambda (user-ttys)
    (print (symbol->string (car user-ttys)) ":" (cdr user-ttys)))
  (sort
    *ttys*
    (lambda (left right)
      (string<?
        (symbol->string (car left))
        (symbol->string (car right))))) )

;; ----------------------------

(use-modules (ice-9 regex))

(define (multi-hash-delete hash key value)
  (let ((value-found (assoc-ref hash key)))
    (if value-found
      (assoc-ref hash key
        (regexp-substitute/global
          #f (string-match value value-found) 'pre "" 'post "")))))

;; @@PLEAC@@_5.8
; Alternate implementatons of a hash inversion function; both assume
; key is a symbol, value is a string

(define (assoc-invert assoc)
  (map
    (lambda (pair)
      (cons
        (string->symbol (cdr pair))
        (symbol->string (car pair))))
    assoc))

;; ------------

(define (assoc-invert assoc)
  (let loop ((assoc assoc) (new-assoc '()))
    (cond
      ((null? assoc) new-assoc)
      (else 
        (loop (cdr assoc)
              (acons
                (string->symbol (cdar assoc))
                (symbol->string (caar assoc)) new-assoc)) )) ))

;; ----------------------------

(define *surname*
  (list
    '(Mickey . "Mantle")
    '(Babe . "Ruth")))

(define *first-name* (assoc-invert *surname*))

(print (assoc-ref *first-name* 'Mantle))

;; ----------------------------

; foodfind

(define *given* (string->symbol (cadr (command-line))))

(define *colour*
  (list
    '(Apple . "red")
    '(Lemon . "yellow")
    '(Carrot . "orange")))

(define *food* (assoc-invert *colour*))

(if (assoc-ref *colour* *given*)
  (print
    (symbol->string *given*) 
    "is a food with colour"
    (assoc-ref *colour* *given*)))

(if (assoc-ref *food* *given*)
  (print
    (assoc-ref *food* *given*)
    "is a food with colour"
    (symbol->string *given*)))

;; @@PLEAC@@_5.9
; *food-colour* association list from an earlier section

; Use 'sort' to sort the entire hash, on key or on value, ascending or
; descending order
(define *sorted-on-key:food-colour*
  (sort
    *food-colour*
    (lambda (left right)
      (string<?
        (symbol->string (car left))
        (symbol->string (car right)))) ))

(define *sorted-on-value:food-colour*
  (sort
    *food-colour*
    (lambda (left right)
      (string<?
        (cdr left)
        (cdr right))) ))

;; ------------

(for-each
  (lambda (pair)
    (let ((food (car pair))
          (colour (cdr pair)))
      (print
        (symbol->string food)
        "is"
        colour)))
  *sorted-on-key:food-colour*)

;; ----------------------------

; Alternatively, generate a list of keys or values, sort as required,
; and use list to guide the hash traversal

(define *sorted-food-colour-keys*
  (sort
    (fold-right
      (lambda (pair accum) (cons (car pair) accum))
      '()
      *food-colour*)
    (lambda (left right)
      (string<?
        (symbol->string left)
        (symbol->string right))) ))

(define *sorted-food-colour-values*
  (sort
    (fold-right
      (lambda (pair accum) (cons (cdr pair) accum))
      '()
      *food-colour*)
    (lambda (left right)
      (string<? left right)) ))

;; ------------

(for-each
  (lambda (food)
    (print (symbol->string food) "is" (assoc-ref *food-colour* food)))
  *sorted-food-colour-keys*)

;; @@PLEAC@@_5.10
; If merging is defined as the combining of the contents of two or more
; hashes, then it is simply a matter of copying the contents of each
; into a new hash

; Association lists can simply be appended together
(define *food-colour*
  (list
    '(Apple . "red")
    '(Banana . "yellow")
    '(Lemon . "yellow")
    '(Carrot . "orange")))

(define *drink-colour*
  (list
    '(Galliano . "yellow")
    '(Mai Tai . "blue")))

(define *ingested-colour* (append *food-colour* *drink-colour*))

;; ----------------------------

; Hash tables built from vectors can be copied element by element into
; a new vector, or spliced together using 'vector-join' [see Chapter 4]

(define *food-colour* (make-vector 20 '())
; ...
(define *drink-colour* (make-vector 20 '())
; ...

(define *ingested-colour*
  (vector-join *food-colour* *drink-colour*))

;; @@PLEAC@@_5.11
(define *common* '())
(define *this-not-that* '())

;; ------------

(define *dict1*
  (list
    '(Apple . "red")
    '(Lemon . "yellow")
    '(Carrot . "orange")))

(define *dict2*
  (list
    '(Apple . "red")
    '(Carrot . "orange")))

;; ------------

; Find items common to '*dict1*' and '*dict2*'
(for-each
  (lambda (pair)
    (let ((key (car pair))
          (value (cdr pair)))
      (if (assoc-ref *dict2* key)
        (set! *common* (cons key *common*))) ))
  *dict1*)

;; ------------

; Find items in '*dict1*' but not '*dict2*'
(for-each
  (lambda (pair)
    (let ((key (car pair))
          (value (cdr pair)))
      (if (not (assoc-ref *dict2* key))
        (set! *this-not-that* (cons key *this-not-that*))) ))
  *dict1*)

;; ----------------------------

(define *non-citrus* '())

(define *citrus-colour*
  (list
    '(Lemon . "yellow")
    '(Orange . "orange")
    '(Lime . "green")))

(define *food-colour*
  (list
    '(Apple . "red")
    '(Banana . "yellow")
    '(Lemon . "yellow")
    '(Carrot . "orange")))

(for-each
  (lambda (pair)
    (let ((key (car pair))
          (value (cdr pair)))
      (if (not (assoc-ref *citrus-colour* key))
        (set! *non-citrus* (cons key *non-citrus*))) ))
  *food-colour*)

;; @@PLEAC@@_5.12
; All objects [including functions] are first class entities, so there
; is no problem / special treatment needed to use any object, including
; those classed as 'references' [e.g. file handles or ports] as keys

(use-modules (srfi srfi-1) (srfi srfi-13))

(define *ports* '())

(for-each
  (lambda (filename)
    (let ((port (open-input-file filename)))
      (set! *ports* (assoc-set! *ports* port filename)) ))
  '("/etc/termcap" "/vmlinux" "/bin/cat"))

(print
  (string-append "open files: "
    (string-drop
      (fold-right
        (lambda (pair accum) (string-append ", " (cdr pair) accum))
        ""
        *ports*)
      2)))

(for-each
  (lambda (pair)
    (let ((port (car pair))
          (filename (cdr pair)))
      (seek port 0 SEEK_END)
      (print filename "is" (number->string (ftell port)) "bytes long.")
      (close-input-port port) ))
  *ports*)

;; @@PLEAC@@_5.13
; An association list takes on the size of the number of elements with
; which it is initialised, so presizing is implicit

(define *hash* '())         ; zero elements

;; ------------

(define *hash*              ; three elements
  (list
    '(Apple . "red")
    '(Lemon . "yellow")
    '(Carrot . "orange")))

;; ----------------------------

; A size [i.e. number of entries] must be specified when a hash table
; is created, so presizing is implicit

(define *hash* (make-hash-table 100))

;; ------------

(define *hash* (make-vector 100 '()))

;; @@PLEAC@@_5.14
(define *array*
  (list 'a 'b 'c 'd 'd 'a 'a 'c 'd 'd 'e))

;; ----------------------------

(define *count* '())

(for-each
  (lambda (element)
    (let ((value (assoc-ref *count* element)))
      (if (not value) (set! value 0))
      (set! *count* (assoc-set! *count* element (+ 1 value)))))
  *array*)

;; ----------------------------

(define *count* (make-hash-table 20))

(for-each
  (lambda (element)
    (let ((value (hash-ref *count* element)))
      (if (not value) (set! value 0))
      (hash-set! *count* element (+ 1 value))))
  *array*)

;; @@PLEAC@@_5.15
(define *father*
  (list
    '(Cain . Adam)
    '(Abel . Adam)
    '(Seth . Adam)
    '(Enoch . Cain)
    '(Irad . Enoch)
    '(Mehujael . Irad)
    '(Methusael . Mehujael)
    '(Lamech . Methusael)
    '(Jabal . Lamech)
    '(Jubal . Lamech)
    '(Tubalcain . Lamech)
    '(Enos . Seth)))

;; ------------

(use-modules (srfi srfi-1) (ice-9 rdelim))

(let ((port (open-input-file *filename*)))
  (let loop ((line&terminator (read-line port 'split)))
    (cond
      ((eof-object? (cdr line&terminator)) '())
      (else
        (let ((person (string->symbol (car line&terminator))))
          (let loop ((father (assoc-ref *father* person)))
            (if father
            (begin
              (print father)
              (loop (assoc-ref *father* father)) )))
        (loop (read-line port 'split)) ))))
  (close-input-port port))

;; ------------

(use-modules (srfi srfi-1) (ice-9 rdelim))

(define (assoc-invert-N:M assoc)
  (let ((new-assoc '()))
    (for-each
      (lambda (pair)
        (let* ((old-key (car pair))
               (new-key (cdr pair))
               (new-key-found (assoc-ref new-assoc new-key)))
          (if (not new-key-found)
            (set! new-assoc (acons new-key (list old-key) new-assoc)) 
          ;else
            (set! new-assoc (assoc-set! new-assoc new-key (cons old-key new-key-found))) )))
      assoc)
  new-assoc))

(define *children* (assoc-invert-N:M *father*))

(let ((port (open-input-file *filename*)))
  (let loop ((line&terminator (read-line port 'split)))
    (cond
      ((eof-object? (cdr line&terminator)) '())
      (else
        (let* ((person (string->symbol (car line&terminator)))
               (children-found (assoc-ref *children* person)))
          (print (symbol->string person) "begat:")
          (if (not children-found)
            (print "nobody")
          ;else
            (for-each
              (lambda (child) (print (symbol->string child) ","))
              children-found))
        (loop (read-line port 'split)) ))))
  (close-input-port port))

;; @@PLEAC@@_5.16
;; @@INCOMPLETE@@
;; @@INCOMPLETE@@

;; @@PLEAC@@_7.0
;; use (open-input-file filename) or (open filename O_RDONLY)

(define input (open-input-file "/usr/local/widgets/data"))
(let loop ((line (read-line input 'concat)))
  (cond ((not (eof-object? line))
         (if (string-match "blue" line)
           (display line))
         (loop (read-line input 'concat)))))
(close input)

;; Many I/O functions default to the logical STDIN/OUT

;; You can also explicitly get the standard ports with
;; [set-]current-{input,output,error}-port.

;; format takes a port as the first argument.  If #t is given, format
;; writes to stdout, if #f is given, format returns a string.

(let loop ((line (read-line)))     ; reads from stdin
  (cond ((not (eof-object? line))
         (if (not (string-match "[0-9]" line))
           ;; writes to stderr
           (display "No digit found.\n" (current-error-port))
           ;; writes to stdout
           (format #t "Read: ~A\n" line))
         (loop (read-line)))))

;; use open-output-file

(define logfile (open-output-file "/tmp/log"))

;; increasingly specific ways of closing ports (it's safe to close a
;; closed port)

(close logfile)                ; #t
(close-port logfile)           ; #f (already closed)
(close-output-port logfile)    ; unspecified

;; you can rebind standard ports with set-current-<foo>-port:

(let ((old-out (current-output-port)))
  (set-current-output-port logfile)
  (display "Countdown initiated ...\n")
  (set-current-output-port old-out)
  (display "You have 30 seconds to reach minimum safety distance.\n"))

;; or

(with-output-to-file logfile
  (lambda () (display "Countdown initiated ...\n")))
(display "You have 30 seconds to reach minimum safety distance.\n")


;; @@PLEAC@@_7.1
(define source (open-input-file path))
(define sink (open-output-file path))

(define source (open path O_RDONLY))
(define sink (open path O_WRONLY))

;;-----------------------------
(define port (open-input-file path))
(define port (open-file path "r"))
(define port (open path O_RDONLY))
;;-----------------------------
(define port (open-output-file path))
(define port (open-file path "w"))
(define port (open path (logior O_WRONLY O_TRUNC O_CREAT)))
;;-----------------------------
(define port (open path (logior O_WRONLY O_EXCL O_CREAT)))
;;-----------------------------
(define port (open-file path "a"))
(define port (open path (logior O_WRONLY O_APPEND O_CREAT)))
;;-----------------------------
(define port (open path (logior O_WRONLY O_APPEND)))
;;-----------------------------
(define port (open path O_RDWR))
;;-----------------------------
(define port (open-file path "r+"))
(define port (open path (logior O_RDWR O_CREAT)))
;;-----------------------------
(define port (open path (logior O_RDWR O_EXCL O_CREAT)))
;;-----------------------------

;; @@PLEAC@@_7.2
;; Nothing different needs to be done with Guile

;; @@PLEAC@@_7.3
(define expand-user
  (let ((rx (make-regexp "^\\~([^/]+)?")))
    (lambda (filename)
      (let ((m (regexp-exec rx filename)))
        (if m
          (string-append
           (if (match:substring m 1)
             (passwd:dir (getpwnam (match:substring m 1)))
             (or (getenv "HOME") (getenv "LOGDIR")
                 (passwd:dir (getpwuid (cuserid))) ""))
           (substring filename (match:end m)))
          filename)))))

;; @@PLEAC@@_7.4
(define port (open-file filename mode))  ; raise an exception on error

;; use catch to trap errors
(catch 'system-error ; the type of error thrown
  (lambda () (set! port (open-file filename mode))) ; thunk to try
  (lambda (key . args)  ; exception handler
    (let ((fmt (cadr args))
          (msg&path (caddr args)))
      (format (current-error-port) fmt (car msg&path) (cadr msg&path))
      (newline))))

;; @@PLEAC@@_7.5
;; use the POSIX tmpnam
(let ((name (tmpnam)))
  (call-with-output-file name
    (lambda (port)
      ;; ... output to port
      )))

;; better to test and be sure you have exclusive access to the file
;; (temp file name will be available as (port-filename port))
(define (open-temp-file)
  (let loop ((name (tmpnam)))
    (catch 'system-error
      (lambda () (open name (logior O_RDWR O_CREAT O_EXCL)))
      (lambda (key . args) (loop (tmpnam))))))

;; or let mkstemp! do the work for you:
(define port (mkstemp! template-string-ending-in-XXXXXX))

(let* ((tmpl "/tmp/programXXXXXX")
       (port (mkstemp! tmpl)))
  ;; tmpl now contains the name of the temp file,
  ;; e.g. "/tmp/programhVoEzw"
  (do ((i 0 (1+ i)))
      ((= i 10))
    (format port "~A\n" i))
  (seek port 0 SEEK_SET)
  (display "Tmp file has:\n")
  (do ((line (read-line port 'concat) (read-line port 'concat)))
      ((eof-object? line))
    (display line))
  (close port))

;; @@PLEAC@@_7.6
;; string ports are ideal for this

(define DATA "
your data goes here
")

(call-with-input-string
 DATA
 (lambda (port)
   ;; ... process input from port
   ))

;; or

(with-input-from-string DATA
  (lambda ()
    ;; ... stdin now comes from DATA
    ))

;; @@PLEAC@@_7.7
;; to process lines of current-input-port:
(do ((line (read-line) (read-line)))
    ((eof-object? line))
  ;; ... do something with line
  )

;; a general filter template:

(define (body)
  (do ((line (read-line) (read-line)))
      ((eof-object? line))
    (display line)
    (newline)))

(let ((args (cdr (command-line))))
  ;; ... handle options here
  (if (null? args)
    (body)     ; no args, just call body on stdin
    (for-each  ; otherwise, call body with stdin set to each arg in turn
     (lambda (file)
       (catch 'system-error
         (lambda ()
           (with-input-from-file file
             body))
         (lambda (key . args)
           (format (current-error-port) (cadr args) (caaddr args)
                   (car (cdaddr args)))
           (newline (current-error-port)))))
     args)))

;; example: count-chunks:
(use-modules (srfi srfi-1) (srfi srfi-13) (ice-9 format) (ice-9 regex))

;; also use directory-files from 9.5 and globbing functions from 9.6

;; can use (ice-9 getopt-long) described in chapter 15, or process
;; options by hand
(define opt-append 0)
(define opt-ignore-ints 0)
(define opt-nostdout 0)
(define opt-unbuffer 0)

(define args (cdr (command-line)))

(do ((opts args (cdr opts)))
    ((or (null? opts) (not (eq? (string-ref (car opts) 0) #\-)))
     (set! args opts))
  (let ((opt (car opts)))
    (cond ((string=? opt "-a") (set! opt-append (1+ opt-append)))
          ((string=? opt "-i") (set! opt-ignore-ints (1+ opt-ignore-ints)))
          ((string=? opt "-n") (set! opt-nostdout (1+ opt-nostdout)))
          ((string=? opt "-u") (set! opt-unbuffer (1+ opt-unbuffer)))
          (else (throw 'usage-error "Unexpected argument: ~A" opt)))))

;; default to all C source files
(if (null? args) (set! args (glob "*.[Cch]" ".")))

(define (find-login)
  (do ((line (read-line) (read-line)))
      ((eof-object? line))
    (cond ((string-match "login" line)
           (display line)
           (newline)))))

(define (lowercase)
  (do ((line (read-line) (read-line)))
      ((eof-object? line))
    (display (string-downcase line))
    (newline)))

(define (count-chunks)
  (do ((line (read-line) (read-line))
       (chunks 0))
      ((or (eof-object? line)
           (string=? line "__DATA__") (string=? line "__END__"))
       (format #t "Found ~A chunks\n" chunks))
    (let ((tokens
           (string-tokenize (string-take line (or (string-index line #\#)
                                                  (string-length line))))))
      (set! chunks (+ chunks (length tokens))))))

(if (null? args)
  (count-chunks)     ; or find-login, lowercase, etc.
  (for-each
   (lambda (file)
     (catch 'system-error
       (lambda ()
         (with-input-from-file file
           count-chunks))
       (lambda (key . args)
         (format (current-error-port) (cadr args) (caaddr args)
                 (car (cdaddr args)))
         (newline (current-error-port)))))
   args))

;; @@PLEAC@@_7.8
;; write changes to a temporary file then rename it
(with-input-from-file old
  (lambda ()
    (with-output-to-file new
      (lambda ()
        (do ((line (read-line) (read-line)))
            ((eof-object? line))
          ;; change line, then...
          (write-line line))))))
(rename-file old (string-append old ".orig"))
(rename-file new old)

;; @@PLEAC@@_7.9
;; no -i switch

;; @@PLEAC@@_7.10
;; open the file in read/write mode, slurp up the contents, modify it,
;; then write it back out:
(let ((p (open-file file "r+"))
      (lines '()))
  ;; read in lines
  (do ((line (read-line p) (read-line p)))
      ((eof-object? line))
    (set! lines (cons line lines)))
  ;; modify (reverse lines)
  (seek p 0 SEEK_SET)
  ;; write out lines
  (for-each (lambda (x) (write-line x p)) lines)
  ;; truncate the file
  (truncate-file p)
  (close p))

(let ((p (open-file "foo" "r+"))
      (lines '())
      (date (date->string (current-date))))
  (do ((line (read-line p 'concat) (read-line p 'concat)))
      ((eof-object? line))
    (set! lines (cons line lines)))
  (seek p 0 SEEK_SET)
  (for-each
   (lambda (x)
     (regexp-substitute/global p "DATE" x 'pre date 'post))
   (reverse lines))
  (truncate-file p)
  (close p))

;; @@PLEAC@@_7.11
(define p (open-file path "r+"))
(flock p LOCK_EX)
;; update the file, then...
(close p)

;; to increment a number in a file
(define p (open "numfile" (logior O_RDWR O_CREAT)))
(flock p LOCK_EX)
;; Now we have acquired the lock, it's safe for I/O
(let* ((obj (read p))
       (num (if (eof-object? obj) 0 obj)))
  (seek p 0 SEEK_SET)
  (truncate-file p)
  (write (1+ num) p)
  (newline p))
(close p)

;; @@PLEAC@@_7.12
;; use force-output
(force-output p)

;; flush all open ports
(flush-all-ports)

;; @@PLEAC@@_7.13
;; use select
(select inputs outputs exceptions seconds)
(select (list p1 p2 p3) '() '())

(let* ((nfound (select (list inport) '() '()))
       (inputs (car nfound)))
  (if (not (null? inputs))
      (let ((line (read-line inport)))
        (format #t "I read ~A\n" line))))

;; or use char-ready? if you only need a single character
(if (char-ready? p)
  (format #t "I read ~A\n" (read-char p)))

;; @@PLEAC@@_7.14
;; use the O_NONBLOCK option with open
(define modem (open "/dev/cua0" (logior O_RDWR O_NONBLOCK)))

;; or use fcntl if you already have a port
(let ((flags (fcntl p F_GETFD)))
  (fcntl p F_SETFD (logior flags O_NONBLOCK)))

;; @@PLEAC@@_7.15
;; use stat
(let ((buf (make-string (stat:size (stat p)))))
  (read-string!/partial buf input))

;; @@PLEAC@@_7.16
;; not needed - ports are first class objects

;; @@PLEAC@@_7.18
;; use for-each on the list of ports:
(for-each (lambda (p) (display stuff-to-print p)) port-list)

;; or, if you don't want to keep track of the port list and know you
;; want to print to all open output ports, you can use port-for-each:
(port-for-each (lambda (p) (if (output-port? p) (display stuff p))))

;; @@PLEAC@@_7.19
;; use fdopen:
(define p (fdopen num mode))
(define p (fdopen 3 "r"))

(define p (fdopen (string->number (getenv "MHCONTEXTFD")) "r"))
;; after processing
(close p)

;; @@PLEAC@@_7.20
;; ports are first class objects and can be aliased and passed around
;; like any other non-immediate variables:
(define alias original)
(define old-in (current-input-port))

;; or you can open two separate ports on the same file:
(define p1 (open-input-file path))
(define p2 (open-input-file path))

;; or use fdopen:
(define copy-of-p (fdopen (fileno p) mode))

(define old-out (current-output-port))
(define old-err (current-error-port))

(define new-out (open-output-file "/tmp/program.out"))

(set-current-output-port new-out)
(set-current-error-port new-out)

(system joe-random-program)

(close new-out)

(set-current-output-port old-out)
(set-current-error-port old-out)

;; @@PLEAC@@_8.0
;; open the file and loop through the port with read-line:
(let ((p (open-input-file file)))
  (do ((line (read-line p) (read-line p)))
      ((eof-object? line))
    (format #t "~A\n" (string-length line)))
  (close p))

;; you can use with-input-from-file to temporarily rebind stdin:
(with-input-from-file file
  (lambda ()
    (do ((line (read-line) (read-line)))
        ((eof-object? line))
      (format #t "~A\n" (string-length line)))))

;; or define a utility procedure to do this
(define (for-each-line proc file)
  (with-input-from-file file
    (lambda ()
      (do ((line (read-line) (read-line)))
          ((eof-object? line))
        (proc line)))))
(for-each-line (lambda (x) (format #t "~A\n" (string-length line))) file)

;; read in the file as a list of lines
(define (read-lines file)
  (let ((ls '()))
    (with-input-from-file file
      (lambda ()
        (do ((line (read-line) (read-line)))
            ((eof-object? line))
          (set! ls (cons line ls)))
        (reverse ls)))))

;; read in the file as a single string
(define (file-contents file)
  (call-with-input-file file
    (lambda (p)
      (let* ((size (stat:size (stat p)))
             (buf (make-string size)))
        (read-string!/partial buf p)
        buf))))

;; use display to print human readable output
(display '("One" "two" "three") port)  ; (One two three)
(display "Baa baa black sheep.\n")     ; Sent to default output port

;; use write to print machine readable output
(write '("One" "two" "three") port)    ; ("One" "two" "three")

;; use (ice-9 rw) to read/write fixed-length blocks of data:
(use-modules (ice-9 rw))
(let ((buffer (make-string 4096)))
  (read-string!/partial buffer port 4096))

;; truncate-file
(truncate-file port length)  ; truncate to length
(truncate-file port)         ; truncate to current pos

;; ftell
(define pos (ftell port))
(format #t "I'm ~A bytes from the start of DATAFILE.\n" pos)

;; seek
(seek log-port 0 SEEK_END)      ; seek to end
(seek data-port pos SEEK_SET)   ; seek to pos
(seek out-port -20 SEEK_CUR)    ; seek back 20 bytes

;; block read/write
(use-modules (ice-9 rw))
(write-string/partial mystring data-port (string-length mystring))
(read-string!/partial block 256 5)

;; @@PLEAC@@_8.1
(let ((rx (make-regexp "(.*)\\\\$"))) ; or "(.*)\\\\\\s*$"
  (with-input-from-file file
    (lambda ()
      (let loop ((line (read-line)))
        (if (not (eof-object? line))
          (let ((m (regexp-exec rx line))
                (next (read-line)))
            (cond ((and m (not (eof-object? next)))
                   (loop (string-append (match:substring m 1) next)))
                  (else
                   ;; else process line here, then recurse
                   (loop next)))))))))

;; @@PLEAC@@_8.2
(do ((line (read-line p) (read-line p))
     (i 0 (1+ i)))
    ((eof-object? line) i))

;; fastest way if your terminator is a single newline
(use-modules (ice-9 rw) (srfi srfi-13))
(let ((buf (make-string (expt 2 16)))
      (count 0))
  (do ((len (read-string!/partial buf p) (read-string!/partial buf p)))
      ((not len) count)
    (set! count (+ count (string-count buf #\newline 0 len)))))

;; or use port-line
(let loop ((line (read-line p)))
  (if (eof-object? line) (port-line p) (loop (read-line p))))

;; @@PLEAC@@_8.3
;; default behaviour of string-tokenize is to split on whitespace:
(use-modules (srfi srfi-13))
(let loop ((line (read-line p)))
  (cond ((not eof-object? line)
         (for-each some-function-of-word (string-tokenize line))
         (loop (read-line p)))))

(let ((table (make-hash-table 31)))
  (let loop ((line (read-line p)))
    (cond ((not (eof-object? line))
           (for-each
            (lambda (w) (hash-set! table w (1+ (hash-ref table w 0))))
            (string-tokenize line))
           (loop (read-line p)))))
  (hash-fold (lambda (k v p) (format #t "~5D ~A\n" v k)) #f table))

;; @@PLEAC@@_8.4
;; build up the list the reverse it or fold over it:
(define lines (read-lines file))
(for-each (lambda (word) do-something-with-word) (reverse lines))
(fold (lambda (word acc) do-something-with-word) #f lines)

;; @@PLEAC@@_8.5
;; save the current position and reseek to it
(define (tail file)
  (call-with-input-file file
    (lambda (p)
      (let loop ((line (read-line p)))
        (cond ((eof-object? line)
               (sleep sometime)
               (let ((pos (ftell p)))
                 (seek p 0 SEEK_SET)
                 (seek p pos SEEK_SET)))
              (else
               ;; process line
               ))
        (loop (read-line p))))))

;; @@PLEAC@@_8.6
(let ((rand-line #f))
  (let loop ((line (read-line p)))
    (cond ((not (eof-object? line))
           (if (= 0 (random (port-line p)))
             (set! rand-line line))
           (loop (read-line p)))))
  ;; rand-line is the random line
  )

;; @@PLEAC@@_8.7
(define (shuffle list)
  (let ((v (list->vector list)))
    (do ((i (1- (vector-length v)) (1- i)))
        ((< i 0) (vector->list v))
      (let ((j (random (1+ i))))
        (cond ((not (= i j))
               (let ((temp (vector-ref v i)))
                 (vector-set! v i (vector-ref v j))
                 (vector-set! v j temp))))))))

(define rand-lines (shuffle (read-lines file))

;; @@PLEAC@@_8.8
;; looking for line number desired-line-number
(do ((line (read-line p) (read-line p)))
    ((= ((port-line p) desired-line-number) line)))
;; or read into a list
(define lines (read-lines file))
(list-ref lines desired-line-number)

;; @@INCOMPLETE@@
; (define (build-index data-file index-file)
;   )

; (define (line-with-index data-file index-file line-number)
;   )

;; @@PLEAC@@_8.9
;; use string-tokenize with an appropriate character set
(use-modules (srfi srfi-13) (srfi srfi-14))
(define fields (string-tokenize line (string->charset "+-")))
(define fields (string-tokenize line (string->charset ":")))
(define fields (string-tokenize line))

;; @@PLEAC@@_8.10
(let ((p (open-file file "r+")))
  (let ((pos 0))
    (let loop ((line (read-line p)))
      (cond ((eof-object? (peek-char p))
             (seek p 0 SEEK_SET)
             (truncate-file p pos)
             (close p))
            (else
             (set! pos (ftell p))
             (loop (read-line p)))))))

;; @@PLEAC@@_8.11
;; no equivalent - don't know how Guile under windows handles this

;; @@PLEAC@@_8.12
(let* ((address (* recsize recno))
       (buf (make-string recsize)))
  (seek p address SEEK_SET)
  (read-string!/partial buf p)
  buf)

;; @@PLEAC@@_8.13
(let* ((address (* recsize recno))
       (buf (make-string recsize)))
  (seek p address SEEK_SET)
  (read-string!/partial buf p)
  ;; modify buf, then write back with
  (seek p address SEEK_SET)
  (write-string/partial buf p)
  (close p))

;; @@INCOMPLETE@@
;; weekearly

;; @@PLEAC@@_8.14
(seek p addr SEEK_SET)
(define str (read-delimited (make-string 1 #\nul) p))

#!/usr/local/bin/guile -s
!#
;; bgets -- get a string from an address in a binary file
(use-modules (ice-9 format))

(define args (cdr (command-line)))
(define file (car args))
(define addrs (map string->number (cdr args)))
(define delims (make-string 1 #\nul))

(call-with-input-file file
  (lambda (p)
    (for-each
     (lambda (addr)
       (seek p addr SEEK_SET)
       (format #t "~X ~O ~D ~S\n" addr addr addr
               (read-delimited delims p)))
     addrs)))

;; @@INCOMPLETE@@
;; strings

;; @@PLEAC@@_9.0
(define entry (stat "/usr/bin/vi"))
(define entry (stat "/usr/bin"))
(define entry (stat port))

(use-modules (ice-9 posix))

(define inode (stat "/usr/bin/vi"))
(define ctime (stat:ctime inode))
(define size (stat:size inode))

(define F (open-input-file filename))
;; no equivalent - what defines -T?
; unless (-s F && -T _) {
;     die "$filename doesn't have text in it.\n";
; }

(define dir (opendir "/usr/bin"))
(do ((filename (readdir dir) (readdir dir)))
    ((eof-object? filename))
  (format #t "Inside /usr/bin is something called ~A\n" filename))
(closedir dir)

;; @@PLEAC@@_9.1
(define inode (stat filename))
(define readtime (stat:atime inode))
(define writetime (stat:mtime inode))

(utime newreadtime newwritetime filename)

(define seconds-per-day (* 60 60 24))
(define inode (stat file))
(define atime (stat:atime inode))
(define mtime (stat:mtime inode))
(set! atime (- atime (* 7 seconds-per-day)))
(set! mtime (- mtime (* 7 seconds-per-day)))
(utime file atime mtime)

;; mtime is optional
(utime file (current-time))
(utime file (stat:atime (stat file)) (current-time))

#!/usr/local/bin/guile -s
!#
;; uvi - vi a file without changing its access times

(define file (cadr (command-line)))
(define inode (stat file))
(define atime (stat:atime inode))
(define mtime (stat:mtime inode))
(system (string-append (or (getenv "EDITOR")  "vi") " " file))
(utime file atime mtime)

;; @@PLEAC@@_9.2
(delete-file file)

(let ((count 0))
  (for-each
   (lambda (x)
     (catch #t
       (lambda () (delete-file x) (set! count (1+ count)))
       (lambda (err . args) #f)))
   file-list)
  (if (not (= count (length file-list)))
    (format (current-error-port) "could only delete ~A of ~A files"
            count (length file-list))))

;; @@PLEAC@@_9.3
;; use builtin copy-file
(copy-file oldfile newfile)
(rename-file oldfile newfile)

;; or do it by hand (clumsy, error-prone)
(use-modules (ice-9 rw) (ice-9 posix))
(with-input-from-file oldfile
  (lambda ()
    (call-with-output-file newfile
      (lambda (p)
        (let* ((inode (stat oldfile))
               (blksize (if inode (stat:size inode) 16384))
               (buf (make-string blksize)))
          (let loop ((len (read-string!/partial buf)))
            (cond ((and len (> len 0))
                   (write-string/partial buf p 0 len)
                   (loop (read-string!/partial buf))))))))))

;; or call out to the system (non-portable, insecure)
(system (string-append "cp " oldfile " " newfile))    ; unix
(system (string-append "copy " oldfile " " newfile))  ; dos, vms

;; @@PLEAC@@_9.4
;; use a hash lookup of inodes
(use-modules (ice-9 posix))
(let ((seen (make-hash-table 31)))
  (for-each
   (lambda (file)
     (let* ((stats (stat file))
            (key (cons (stat:dev stats) (stat:ino stats)))
            (val (hash-ref seen key 0)))
       (cond ((= val 0)
              ;; do something with new file
              ))
       (hash-set! seen key (1+ val))))
   file-names))

(let ((seen (make-hash-table 31)))
  (for-each
   (lambda (file)
     (let* ((stats (stat file))
            (key (cons (stat:dev stats) (stat:ino stats)))
            (val (hash-ref seen key '())))
       (hash-set! seen key (cons file val))))
   file-names)
  (hash-fold
   (lambda (key value prior)
     ;; process key == (dev . inode), value == list of filenames
     )
   '() seen))

;; @@PLEAC@@_9.5
;; use opendir, readdir, closedir
(let ((p (opendir dir)))
  (let loop ((file (readdir p)))
    (if (eof-object? file)
      (close p)
      ;; do something with file
      )))

;; or define a utility function for this
(define (directory-files dir)
  (if (not (access? dir R_OK))
    '()
    (let ((p (opendir dir)))
      (do ((file (readdir p) (readdir p))
           (ls '()))
          ((eof-object? file) (closedir p) (reverse! ls))
        (set! ls (cons file ls))))))

;; to skip . and ..
(cddr (directory-files dir))

;; probably better to implement full Emacs style directory-files
(use-modules (ice-9 posix))
(define plain-files
  (let ((rx (make-regexp "^\\.")))
    (lambda (dir)
      (sort (filter (lambda (x) (eq? 'regular (stat:type (stat x))))
                    (map (lambda (x) (string-append dir "/" x))
                         (remove (lambda (x) (regexp-exec rx x))
                                 (cddr (directory-files dir)))))
            string<))))

;; @@PLEAC@@_9.6
(define (glob->regexp pat)
  (let ((len (string-length pat))
        (ls '("^"))
        (in-brace? #f))
    (do ((i 0 (1+ i)))
        ((= i len))
      (let ((char (string-ref pat i)))
        (case char
          ((#\*) (set! ls (cons "[^.]*" ls)))
          ((#\?) (set! ls (cons "[^.]" ls)))
          ((#\[) (set! ls (cons "[" ls)))
          ((#\]) (set! ls (cons "]" ls)))
          ((#\\)
           (set! i (1+ i))
           (set! ls (cons (make-string 1 (string-ref pat i)) ls))
           (set! ls (cons "\\" ls)))
          (else
           (set! ls (cons (regexp-quote (make-string 1 char)) ls))))))
    (string-concatenate (reverse (cons "$" ls)))))

(define (glob pat dir)
  (let ((rx (make-regexp (glob->regexp pat))))
    (filter (lambda (x) (regexp-exec rx x)) (directory-files dir))))

(define files (glob "*.c" "."))
(define files (glob "*.[ch]" "."))

;; Not sure if the Schwartzian Transform would really be more
;; efficient here... perhaps with a much larger directory where very
;; few files matched.
(define dirs (filter
              (lambda (x) (eq? 'directory (stat:type (stat x))))
              (map (lambda (x) (string-append dir "/" x))
                   (sort (filter (lambda (x) (string-match "^[0-9]+$" x))
                                 (directory-files dir))
                         (lambda (a b)
                           (< (string->number a) (string->number b)))))))

;; @@PLEAC@@_9.7
(define (find proc . dirs)
  (cond ((pair? dirs)
         (for-each proc (map (lambda (x) (string-append (car dirs) "/" x))
                             (directory-files (car dirs))))
         (apply find proc (cdr dirs)))))

(find (lambda (x) (format #t "~A~A\n" x
                          (if (equal? (stat:type (stat x)) 'directory)
                            "/" ""))) ".")

(define saved-size -1)
(define saved-name "")
(define (biggest file)
  (let ((stats (stat file)))
    (if (eq? (stat:type stats) 'regular)
      (let ((size (stat:size (stat file))))
        (cond ((> size saved-size)
               (set! saved-size size)
               (set! saved-name file)))))))
(apply find biggest (cdr (command-line)))
(format #t "Biggest file ~A in ~A is ~A bytes long.\n"
        saved-name (cdr (command-line)) saved-size)

#!/usr/local/bin/guile -s
!#
;; fdirs - find all directories
(define (print-dirs f)
  (if (eq? (stat:type (stat f)) 'directory)
    (write-line f)))
(apply find print-dirs (cdr (command-line)))

;; @@PLEAC@@_9.8
#!/usr/local/bin/guile -s
!#
;; rmtree - remove whole directory trees like rm -f
(define (finddepth proc . dirs)
  (cond ((pair? dirs)
         (apply finddepth proc (cdr dirs))
         (for-each proc (map (lambda (x) (string-append (car dirs) "/" x))
                             (directory-files (car dirs)))))))
(define (zap f)
  (let ((rm (if (eq? (stat:type (stat f)) 'directory) rmdir delete-file)))
    (format #t "deleting ~A\n" f)
    (catch #t
      (lambda () (rm f))
      (lambda args (format #t "couldn't delete ~A\n" f)))))
(let ((args (cdr (command-line))))
  (if (null? args)
    (error "usage: rmtree dir ..\n")
    (apply finddepth zap args)))

;; @@PLEAC@@_9.9
(for-each
 (lambda (file)
   (let ((newname (function-of file)))
     (catch #t
       (lambda () (rename-file file newname))
       (lambda args (format (current-error-port)
                            "couldn't rename ~A to ~A\n" file newname)))))
 names)

#!/usr/local/bin/guile -s
!#
;; rename - Guile's filename fixer
(use-modules (ice-9 regex)) ; not needed, but often useful here
(define args (cdr (command-line)))
(if (null? args) (error "usage: rename expr [files]\n"))
(define proc (eval-string (car args)))
(for-each
 (lambda (old)
   (let ((new (proc old)))
     (if (not (string=? old new))
       (catch #t
         (lambda () (rename-file old new))
         (lambda args (format (current-error-port)
                              "couldn't rename ~A to ~A\n" old new))))))
 (cdr args))

;; command-line examples:
;; rename '(lambda (x) (regexp-substitute/global #f "\\.orig\$" x (quote pre)))' *.orig
;; rename string-downcase *
;; rename '(lambda (x) (if (string-match "^Make" x) x (string-downcase x)))' *
;; rename '(lambda (x) (string-append x ".bad"))' *.pl
;; rename '(lambda (x) (format #t "~a: ") (read-line))' *

;; @@PLEAC@@_9.10
(define base (basename path))
(define base (dirname path ext))
(define dir (dirname path))

(define path "/usr/lib/libc.a")
(define file (basename path))
(define dir (dirname path))

(format #t "dir is ~A, file is ~A\n" dir file)

(basename path ".a") ; libc

(use-modules (ice-9 regex))
(define (file-parse path . args)
  (let* ((ext (if (null? args) "\\..*" (car args)))
         (rx1 (string-append "^((.*)/)?(.*)?(" ext ")$"))
         (rx2 (string-append "^((.*)/)?(.*)?()$")))
    (let ((m (or (string-match rx1 path) (string-match rx2 path))))
      (list (match:substring m 2) (match:substring m 3)
            (match:substring m 4)))))

(define (extension path . args)
  (caddr (apply file-parse path args)))

;; @@PLEAC@@_10.0
; Note: Some of the examples will show code blocks in this style:
;
;  (define
;    ... code here ...
;  )
;
; This is not generally considered good style, and is not recommended;
; it is only used here to more clearly highlight block scope 

; By convention a 'global variable' i.e. a variable that is defined at
; the top-level, and as such, visible within any scope, is named with
; beginning and ending asterisks [and one to be used as a constant
; with beginning and ending plus signs]

(define *greeted* 0)

(define (hello)
  (set! *greeted* (+ *greeted* 1))
  (print "hi there!, this procedure has been called" *greeted* "times"))

(define (how-many-greetings) *greeted*)

;; ------------

(hello)

(define *greetings* (how-many-greetings))

(print "bye there!, there have been" *greetings* "greetings so far")

;; @@PLEAC@@_10.1
; Subroutine parameters are named [whether directly, or indirectly in
; the case of variable arguments - see next example]; this is the only
; means of access [This contrasts with languages like Perl and REXX which
; allow access to arguments via array subscripting, and function calls,
; respectively]
(define (hypotenuse side1 side2)
  (sqrt (sum (* side1 side1) (* side2 side2))))

(define *diag* (hypotenuse 3 4))

;; ----

; 'other-sides' is the name of a list of containing any additional
; parameters. Note that a name is still used to access values
(define (hypotenuse side1 . other-sides)
  (let ((all-sides (cons side1 other-sides)))
    (for-each
      (lambda (side) ...)
      all-sides)
  ...))

;; ----

(define *diag* (hypotenuse 3 4))

;; ----

; Possible to pack parameters into a single structure [e.g. list or
; array], and access values contained therein
(define (hypotenuse sides)
  (let ((side1 (car sides)) (side2 (caar sides)))
    (sqrt (sum (* side1 side1) (* side2 side2)))))

;; ----

(define *args* '(3 4))
(define *diag* (hypotenuse *args*))

;; ------------

; Parameters passed by reference, however, whether original object is
; modified depends on choice of functions used to manipulate them
; [most functions create copies and return these; mutating versions of
; same functions may also exist [see next example] 
(define *nums* (vector 1.4 3.5 6.7))

(define (int-all vec)
  (vector-map-in-order
    (lambda (element) (inexact->exact (round element)))
    vec))

; Copy created
(define *ints* (int-all *nums*))

(print *nums*)
(print *ints*)

;; ----

(define *nums* (vector 1.4 3.5 6.7))

(define (trunc-all vec)
  (array-map-in-order!
    (lambda (element) (inexact->exact (round element)))
    vec))

; Original modified
(trunc-all *nums*)

;; @@PLEAC@@_10.2
; Scheme is lexically-scoped; variables defined within a block are
; visible only within that block. Whilst nested / subordinate blocks
; have access to those variables, neither the caller, nor any called
; procedures have direct access to those same variables

(define (some-func parm1 parm2 parm3)
  ... paramaters visible here ...

  (let ((var1 ...) (var2 ...) (var3 ...) ...)
    ... parameters also visible here, but variables, 'var1' etc
        only visible within this block ...
  )
  ... paramaters also visible here, but still within procedure body ...
)

;; ------------

; Top-level definitions - accessable globally 
(define *name* (caar (command-line)))
(define *age* (cadr (command-line)))

(define *start* (fetch-time))

;; ----

; Lexical binding - accessable only within this block
(let ((name (caar (command-line)))
      (age (cadr (command-line)))
      (start (fetch-time)))
   ... variables only visible here ...
)

;; ------------

(define *pair* '(1 . 2))

; 'a' and 'b' need to be dereferenced and separately defined [Also,
; since globally defined, should really be named, '*a*', '*b*', etc]
(define a (car *pair*))
(define b (cdr *pair*))
(define c (fetch-time))

(define (run-check)
  ... do something with 'a', 'b', and 'c' ...
)

(define (check-x x y)
  (if (run-check)
    (print "got" x)))

; Calling 'check-x'; 'run-check' has access to 'a', 'b', and 'c'
(check-x ...)

;; ----

; If defined within a block, variables 'a', 'b', and 'c' are no longer
; accessable anywhere except that scope. Therefore, 'run-check' as
; defined above can no longer access these variables [in fact, the code
; will fail because variables 'a', 'b', and 'c' do not exist when
; 'run-check' is defined]
(let ((a (car *pair*))
      (b (cdr *pair*))
      (c (fetch-time)))
   ...
   (check-x ...)  
   ...
)

;; ----

; The procedures, 'run-check' and 'check-x' are defined within the
; same block as variables, 'a', 'b', and 'c', so have direct access to
; them
(let* ((a (car *pair*))
       (b (cdr *pair*))
       (c (fetch-time))

       (run-check
         (lambda () ... do something with 'a', 'b', and 'c' ...))

       (check-x
         (lambda (x y)
           (if (run-check)
             (print "got" x)))) )
   ...
   (check-x ...)  
   ...
)

;; @@PLEAC@@_10.3
; Ordinarily, a variable must be initialised when it is defined,
; whether at the top-level: 
(define *variable* 1)

; ... or within a 'let' binding
(let* ((variable 1)
       (mysub
         (lambda () ... accessing 'variable' ...)))
  ... do stuff ...
)

; However, since Scheme allows syntactic extensions via 'macros' [of
; which there are two varieties: hygenic and LISP-based], it is
; possible to create new forms which alter this behaviour. For example,
; in this tutorial: http://home.comcast.net/~prunesquallor/macro.txt
; there is a macro implementation equivalent to 'let, 'called,
; 'bind-values', which allows variables to be defined without initial
; values; an example follows:

; Initialisation values for 'a' and 'b' not specified
(bind-values ((a) b (c (+ *global* 5)))
  ... do stuff ...
)

; In Scheme many things are possible, but not all those things are
; offered as standard features :) !

;; ------------

(let* ((counter 42)
       (next-counter
         (lambda () (set! counter (+ counter 1)) counter))
       (prev-counter
         (lambda () (set! counter (- counter 1)) counter)))

  ... do stuff with 'next-counter' and 'prev-counter' ...
)

;; ----

; A more complete, and practical, variation of the above code:

; 'counter' constructor
(define (make-counter start)
  (let* ((counter 42)
         (next-counter
           (lambda () (set! counter (+ counter 1)) counter))
         (prev-counter
           (lambda () (set! counter (- counter 1)) counter)))
  (lambda (op)
    (cond
      ((eq? op 'prev) prev-counter)
      ((eq? op 'next) next-counter)
      (else (lambda () (display "error:counter"))) ))))

; Interface functions to 'counter' functionality
(define (prev-counter counter) (apply (counter 'prev) '()))
(define (next-counter counter) (apply (counter 'next) '()))

; Create a 'counter'
(define *counter* (make-counter 42))

; Use the 'counter' ...
(print (prev-counter *counter*))
(print (prev-counter *counter*))
(print (next-counter *counter*))

;; @@PLEAC@@_10.4
; Scheme interpreters generally provide a rich collection of procedure
; metadata, as well as easy access to a program's current 'execution
; state'. Put simply, provision of a powerful, highly customisable
; debugging / tracing facility is almost taken for granted. However, using
; it to perform as trivial a task as obtaining the current function name
; is less than trivial [at least it seems so in Guile] as it appears to
; require quite some setup work. Additionally, the documentation talks
; about facilities e.g. trap installation, that don't appear to be
; available [at least, I couldn't find them].
;
; Example below uses in-built debugging facilities to dump a backtrace
; to a string port and extract the caller's name from the resulting
; string. Not exactly elegant ...

; Execute using: guile --debug ... else no useful output seen
(use-modules (ice-9 debug))

(define (child num)
  ; Create stack [i.e. activation record] object, discarding
  ; irrelevant frames
  (let ((s (make-stack #t 3 1))
        (trace-string-port (open-output-string))
        (parent-name ""))

    ; Dump backtrace to string port
    (display-backtrace s trace-string-port)

    ; Extract caller's name from backtrace data
    ; [shamefully crude - don't do this at home !]
    (set! parent-name
      (caddr (string-tokenize
               (cadr (string-split
                       (get-output-string trace-string-port)
                       #\newline))
               char-set:graphic)))

    ; Who's your daddy ?
    (print parent-name)))

; Each invocation of 'child' should see 'parent' displayed as
; the caller
(define (parent)
  (child 1)
  (child 2)
  (child 3))

(parent) 

;; @@PLEAC@@_10.5
; Procedure parameters are references to entities, so there is no special
; treatment required. If an argument represents a mutable object such
; as an array, then care should be taken to not mutate the object within
; the procedure, or a copy of the object be made and used

(array-diff *array1* *array2*)

;; ------------

(define (add-vector-pair x y)
  (let* ((vector-length (vector-length x))
         (new-vec (make-vector vector-length)))
    (let loop ((i 0))
      (cond 
        ((= i vector-length) new-vec)
        (else
          (vector-set! new-vec i (+ (vector-ref x i) (vector-ref y i)))
          (loop (+ i 1)) ))) ))

;; ----

(define *a* '#(1 2))
(define *b* '#(5 8))

(define *c* (add-vector-pair *a* *b*))

(print *c*)

;; ----

  ...

  (if (and (vector? a1) (vector? a2))
    (print (add-vector-pair a1 a2))
  ;else
    (print "usage: add-vector-pair a1 a2"))

  ...

;; @@PLEAC@@_10.6
; AFAIK there is no Scheme equivalent to Perl's 'return context' where
; it is possible to use language primitives [e.g. 'wantarray'] to 
; dynamically specify the return type of a procedure. It is, however,
; possible to:
; * Return one of several types from a procedure, whether based on 
;   processing results [e.g. 'false' on error, numeric on success], or
;   perhaps specified via control argument
; * Check procedure return type and take appropriate action

(define (my-sub)
  (let* ((datatype (vector '() 7 '(1 2 3) "abc" 'sym)))
    (vector-ref datatype (random (vector-length datatype))) ))

;; ----

; '*result*' is bound to a randomly chosen datatype
(define *result* (my-sub))

(cond
  ; It is common to return an empty list to represent 'void'
  ((null? *result*) (print "void context"))

  ((list? *result*) (print "list context"))
  ((number? *result*) (print "scalar context"))
  ((string? *result*) (print "string context"))
  ((symbol? *result*) (print "atom context"))
  (else (print "Unknown type")))

;; @@PLEAC@@_10.7
; Keyword parameters are fully supported. Note that pairs have
; replaced Perl strings in the examples since they are easier to
; manipulate

(use-modules (ice-9 optargs))

(define* (the-func #:key (increment (cons 10 's))
                         (finish (cons 0 'm))
                         (start (cons 0 'm)))
  (print increment)
  (print finish)
  (print start))

(the-func)
(the-func #:increment (cons 20 's) #:start (cons 5 'm) #:finish (cons 30 'm))
(the-func #:start (cons 5 'm) #:finish (cons 30 'm))
(the-func #:finish (cons 30 'm))
(the-func #:start (cons 5 'm) #:increment (cons 20 's))

;; @@PLEAC@@_10.8
;; @@INCOMPLETE@@
;; @@INCOMPLETE@@

;; @@PLEAC@@_10.9
; The return of multiple values, whether arrays or other items, may be 
; achieved via:
; * Packaging return items as a single list, structure or array, an
;   approach which is usable across many languages, though can be
;   clunky because the procedure caller must manually extract all
;   items
; * The 'values' procedure, a more Schemish idiom, is usually used in
;   conjunction with the 'call-with-values' procedure [the former combines
;   multiple values, the latter captures and cleanly extracts them]. It
;   comes into its own, however, when used to create a 'macro' [an
;   extension to the Scheme language] like 'let-values', a variation of
;   the 'let' form that allows multiple return values to be placed directly
;   into separate variables. Implementation shown here is from 'The
;   Scheme Programming Language, 3rd Edition' by R. Kent Dybvig, though
;   there exists a more standard implementation in SRFI-11. There is also
;   the 'receive' functionality accessable via: (use-modules (ice-9 receive))

; [1] Implementation of 'somefunc' returning muliple values via packaging
; items within a list that is returned
(define (somefunc)
  (let ((a (make-vector 5))
        (h (make-hash-table 5)))
    (list a h) ))

; Retrieving procedure values requires that the return list be captured
; and each contained item separately extracted ['let*' used in place of
; 'let' to ensure correct retrieval order]
(let* ((return-list (somefunc))
       (a (car return-list))
       (b (cadr return-list)))

  ... do something with 'a' and 'b' ...)

;; ----------------------------

; [2] Implementation of 'somefunc' returning muliple values using the
; 'values' procedure 

(use-syntax (ice-9 syncase)) 

; 'let-values' from: http://www.scheme.com/tspl3/syntax.html#fullletvalues
(define-syntax let-values
  (syntax-rules ()
    ((_ () f1 f2 ...) (let () f1 f2 ...))
    ((_ ((fmls1 expr1) (fmls2 expr2) ...) f1 f2 ...)
     (lvhelp fmls1 () () expr1 ((fmls2 expr2) ...) (f1 f2 ...))))) 

(define-syntax lvhelp
  (syntax-rules ()
    ((_ (x1 . fmls) (x ...) (t ...) e m b)
     (lvhelp fmls (x ... x1) (t ... tmp) e m b))
    ((_ () (x ...) (t ...) e m b)
     (call-with-values
       (lambda () e)
       (lambda (t ...)
         (let-values m (let ((x t) ...) . b)))))
    ((_ xr (x ...) (t ...) e m b)
     (call-with-values
       (lambda () e)
       (lambda (t ... . tmpr)
         (let-values m (let ((x t) ... (xr tmpr)) . b))))))) 

;; ------------

(define (somefunc)
  (let ((a (make-vector 5))
        (h (make-hash-table 5)))
    (values a h) ))

; Multiple return items placed directly into separate variables
(let-values ( ((a h) (somefunc)) )
  (print (array? a))
  (print (hash-table? h)))

;; @@PLEAC@@_10.10
; Like most modern languages, Scheme supports exceptions for handling
; failure, something that will be illustrated in another section. However,
; conventions exist as to the choice of value used to indicate failure:
; * Empty list i.e. '() is often used for this task, as is it's string
;   counterpart, "", the empty string
; * Return false i.e. #f to indicate failed / not found etc, and a valid
;   value otherwise [e.g. testing set membership: if not a member, return
;   #f, but if a member, return the item itself rather than #t]

; Return empty list as indicating 'failure'
(define (sub-failed) '())

;; ------------

(define (look-for-something)
  ...
  (if (something-found)
    ; Item found, return the item
    something
  ;else
    ; Not found, indicate failure
    #f
  ))

;; ----

(if (not (look-for-something))
  (print "Item could not be found ...")
;else
  ; do something with item ...
  ...

;; ------------

; An interesting variation on returning #f as a failure indicator is
; in using the, 'false-if-exception' procedure whereby a procedure is
; executed, any exceptions it may throw caught, and handled by simply
; returning #f. See example in section on Exception Handling below.

;; ------------

(define (ioctl) ... #f)

(or (ioctl) (begin (print "can't ioctl") (exit 1)))

;; @@PLEAC@@_10.11
; Whether Scheme is seen to support prototyping depends on the definition
; of this term used:
; * Prototyping along the lines used in Ada, Modula X, and even C / C++,
;   in which a procedure's interface is declared separately from its
;   implementation, is *not* supported
; * Prototyping in which, as part of the procedure definition, parameter 
;   information must be supplied. This is a requirement in Scheme in that
;   parameter number and names must be given, though there is no need to
;   supply type information [optional and keyword parameters muddy the
;   waters somewhat, but the general principle applies]

(define (func-with-no-arg) ...)
(define (func-with-one-arg arg1) ...)
(define (func-with-two-arg arg1 arg2) ...)
(define (func-with-three-arg arg1 arg2 arg3) ...)

;; @@PLEAC@@_10.12
; Not exactly like the Perl example, but a way of immediately
; exiting from an application
(define (die msg . error-code)
  (display (string-append msg "\n") (current-error-port))
  (exit (if (null? error-code) 1 (car error-code))))

;; ----

(die "some message")

;; ------------

; An exception is thrown via 'throw'; argument must be a symbol
(throw 'some-exception)

; Invalid attempts - these, themselves force a 'wrong-type-arg
; exception to be thrown
(throw #t)
(throw "my message")
(throw 1)

;; ------------

; Example of a 'catch all' handler - 'proc' is executed, and any
; exception thrown is handled, in this case by simply returning false
(define (false-if-exception proc)
  (catch #t
    proc
    (lambda (key . args) #f)))

(define (func)
  (print "Starting 'func' ...")
  (throw 'myexception 1)
  (print "Leaving 'func' ..."))

;; ----

(if (not (false-if-exception main))
  (print "'func' raised an exception")
  (print "'func' executed normally"))

;; ------------

; More typical exception handling example in which:
; * 'func' is executed
; * 'catch' either:
;   - returns return value of 'func' [if successful]
;   - executes handler(s)

(define (full-moon-exception-handler key . args)
  (print "I'm executing after stack unwound !"))

(define (full-moon-exception-prewind-handler key . args)
  (print "I'm executing with the stack still intact !"))

(define (func)
  (print "Starting 'func' ...")
  (throw 'full-moon-exception 1)
  (print "Leaving 'func' ..."))

(catch 'full-moon-exception
   func
   full-moon-exception-handler
   full-moon-exception-prewind-handler)

;; @@PLEAC@@_10.13
; Scheme is lexically-scoped, so same-name, higher-level variables
; are merely shadowed in lower-level blocks. Upon exit from those
; blocks the higher-level values are again available. Therefore, the
; saving of global variables, as required by Perl, is not necessary

; Global variable
(define age 18)

; Procedure definition creates a closure - it captures the earlier
; version of, age', and will retain it
(define (func)
  (print age))

(if (condition)
  ; New 'local' variable created which acts to shadow the global
  ; version
  (let ((age 23))

    ; Prints 23 because the global variable is shadowed within 
    ; this block 
    (print age)

    ; However, lexical-scoping ensures 'func' still accesses the
    ; 'age' which was active when it was defined
    (func) ))

; The use of 'fluid-let' allows for similar behaviour to Perl's i.e.
; it mimics dynamic scope, but it does so cleanly in that once its
; scope ends any affected global variables are restored to previous
; values
(if (condition)

  ; This does not create a new 'local' variables but temporarily
  ; sets the global variable, 'age' to 23
  (fluid-let ((age 23))

    ; Prints 23 because it is accessing the global version of 'age'
    (print age)

    ; Prints 23 because it is its lexically-scoped version of 'age'
    ; that has its value altered, albeit temporarily
    (func) ))

;; @@PLEAC@@_10.14
; Define two procedures, bind them to identifiers
(define (grow) (print "grow"))
(define (shrink) (print "shrink"))

; Separate procedures executed
(grow)
(shrink)

; Rebind identifier; now acts as alias for latter
(define grow shrink)

; Same procedure executed in both cases
(grow)
(shrink)

;; ------------

; As for previous except that rebinding is localised and
; ends once local scope exited
(let ((grow shrink))
  (grow)
  (shrink))

;; ----------------------------

; Example of dynamically creating [from text data] and binding
; procedures. The example here is conceptually similar to the Perl
; example in that it makes use of an 'eval' type of facility to
; generate code from text. In Scheme such tasks are generally better
; dealt with using macros 

; List of procedure name / first argument pairs
(define *colours*
  (list
    '("red" . "baron")
    '("blue" . "zephyr")
    '("green" . "beret")
    '("yellow" . "ribbon")
    '("orange" . "county")
    '("purple" . "haze")
    '("violet" . "temper") ))

; Build a series of procedures dynamically by traversing the
; *colours* list and obtaining:
; * Procedure name from first item of pair
; * Procedure argument from second item of pair
(for-each
  (lambda (colour)
    (let ((proc-string
            (string-append
              "(define " (car colour) " (lambda () "
              "\"<FONT COLOR=" (car colour) ">" (cdr colour)
              "</FONT>\"))" )))
      (eval-string proc-string)))
   *colours*)

; Apply each of the dynamically-built procedures
(for-each
  (lambda (colour)
    (print (apply (string->procedure (car colour)) '())))
  *colours*)

;; @@PLEAC@@_10.15
; AFAICT Guile doesn't implement an AUTOLOAD facility in which a
; 'replacement' function is available should another one fail to
; load [though there is an autoload feature available with modules
; which is a load-on-demand facility aimed at conserving memory and
; speeding up initial program load time].
;
; One might think it would be feasable, however, to use exception
; handling to provide roughly similar functionality:

; Catch all exceptions
(catch #t
  ; Undefined procedure, 'x'
  x
  ; Exception handler could load missing code ?
  (lambda (key . args) ... ))

; However, an undefined function call is reported as:
;
;    ERROR: Unbound variable: ...
;
; and this situation doesn't appear to be user-trappable. 
;

;; @@PLEAC@@_10.16
; Both implementations below  are correct, and exhibit identical
; behaviour 

(define (outer arg)
  (let* ((x (+ arg 35))
         (inner (lambda () (* x 19))))
    (+ x (inner))))

;; ----------------------------

(define (outer arg)
  (let ((x (+ arg 35)))
    (define (inner) (* x 19))
    (+ x (inner))))

;; @@PLEAC@@_10.17
;; @@INCOMPLETE@@
;; @@INCOMPLETE@@

;; @@PLEAC@@_13.0
;; Guile OOP is in the (oop goops) module (based on CLOS).  All
;; following sections assume you have (oop goops loaded).
(use-modules (oop goops))
(define-class <data-encoder> ())
(define obj (make <data-encoder>))

(define obj #(3 5))
(format #t "~A ~A\n" (class-of obj) (array-ref obj 1))
(change-class v <human-cannibal>) ; has to be defined
(format #t "~A ~A\n" (slot-ref obj stomach) (slot-ref obj name))

(slot-ref obj 'stomach)
(slot-set! obj 'stomach "Empty")
(name obj)
(set! (name obj) "Thag")

;; inheritance
(define-class <lawyer> (<human-cannibal>))

(define lector (make <human-cannibal>))
(feed lector "Zak")
(move lector "New York")

;; @@PLEAC@@_13.1
(define-class <my-class> ()
  (start #:init-form (current-time))
  (age #:init-value 0))

;; classes must have predefined slots, but you could use one as a
;; dictionary:
(define-class <my-class> ()
  (start #:init-form (current-time))
  (age #:init-value 0)
  (properties #:init-value '()))
(define (initialize (m <my-class>) initargs)
  (and-let* ((extra (memq #:extra initargs)))
    (slot-set! m 'properties (cdr extra))))

;; @@PLEAC@@_13.2
;; For smobs (external C objects), you can specify a callback to be
;; performed when the object is garbage collected with the C API
;; function `scm_set_smob_free'.  This solves the problem of cleaning up
;; after external objects and connections.  Guile doesn't use reference
;; count garbage collection, so circular data structures aren't a
;; problem.

;; @@PLEAC@@_13.3
;; either use slot-ref/set!
(slot-ref obj 'name)
(slot-set! obj 'name value)

;; or define the class with accessors
(define-class <my-class> ()
  (name #:accessor name))
(name obj)
(set! (name obj) value)

;; or use getters/setters to implement read/write-only slots
(define-class <my-class> ()
  (name #:getter name)
  (age #:setter age))
(name obj)
(set! (age obj) value)

;; or implement getters/setters manually
(define-method ((setter name) (obj <my-class>) value)
  (cond ((string-match "[^-\\w0-9']" value)
         (warn "funny characters in name"))
        ((string-match "[0-9]" value)
         (warn "numbers in name"))
        ((not (string-match "\\w+\\W+\\w+" value))
         (warn "prefer multiword names"))
        ((not (string-match "\\w" value))
         (warn "name is blank")))
  (slot-set! obj 'name (string-downcase value)))

;; @@PLEAC@@_13.4
;; override the initialize method
(define body-count 0)

(define-method (initialize (obj <person>) initargs)
  (set! body-count (1+ body-count))
  (next-method))

(define people '())
(do ((i 1 (1+ i)))
    ((> i 10))
  (set! people (cons (make <person>) people)))

(format #t "There are ~A people alive.\n" body-count)

(define him (make <person>))
(slot-set! him 'gender "male")

(define her (make <person>))
(slot-set! her 'gender "female")

;; use the :class allocation method
(slot-set! (make <fixed-array>) 'max-bounds 100) ; set for whole class
(define alpha (make <fixed-array>))
(format #t "Bound on alpha is ~D\n" (slot-ref alpha 'max-bounds))
;; 100

(define beta (make <fixed-array>))
(slot-set! beta 'max-bounds 50)          ; still sets for whole class
(format #t "Bound on alpha is ~D\n" (slot-ref alpha 'max-bounds))
;; 50

;; defined simply as
(define-class <fixed-array> ()
  (max-bounds #:init-value 7 #:allocation #:class))

;; @@PLEAC@@_13.5
;; Guile classes are basically structs by definition.  If you don't care
;; about OO programming at all, you can use records, which are portable
;; across most Schemes.  This is, however, an OO chapter so I'll stick
;; to classes.
(define-class <person> () name age peers)

(define p (make <person>))
(slot-set! p 'name "Jason Smythe")
(slot-set! p 'age 13)
(slot-set! p 'peers '("Wilbur" "Ralph" "Fred"))
(format #t "At age ~D, ~A's first friend is ~A.\n"
        (slot-ref p 'age) (slot-ref p 'name) (car (slot-ref p 'peers)))

;; For type-checking and field validation, define the setters
;; accordingly.
(define-class <person> ()
  (name #:accessor name)
  (age #:accessor age))

(define-method ((setter age) (p <person>) a)
  (cond ((not (number? a))
         (warn "age" a "isn't numeric"))
        ((> a 150)
         (warn "age" a "is unreasonable")))
  (slot-set! p 'age a))

(define-class <family> ()
  (head #:init-form (make <person>) #:accessor head)
  (address #:init-value "" #:accessor address)
  (members #:init-value '() #:accessor members))

(define folks (make <family>))

(define dad (head folks))
(set! (name dad) "John")
(set! (age dad) 34)

(format #t "~A's age is ~D\n" (name dad) (age dad))

;; Macros are the usual way to add syntactic sugar

;; For all fields of the same type, let's use _ to mean the slot name in
;; the options expansion.
(define-macro (define-uniform-class name supers slots . options)
  `(define-class ,name ,supers
     ,@(map (lambda (s) (cons s (map (lambda (o) (if (eq? o '_) s o)) options)))
            slots)))

(define-uniform-class <card> (name color cost type release text)
  #:accessor _ #:init-value "")

;; If you *really* wanted to enforce slot types you could use something
;; like the above with the custom setter.  To illustrate reversing
;; normal slot definition args, we'll reverse an init-value:
(define-macro (define-default-class name supers . default&slots)
  `(define-class ,name ,supers
     ,@(map (lambda (d&s) (list (cadr d&s)
                                #:init-value (car d&s)
                                #:accessor (cadr d&s)))
            default&slots)))

(define-default-class hostent ()
  ("" name)
  ('() aliases)
  ("" addrtype)
  (0  length)
  ('() addr-list))

;; Nothing special needed for Aliases - all names are equal
(define type addrtype)
(define-method (addr (h <hostent>))
  (car (addr-list h)))

;; @@PLEAC@@_13.6
;; A little more clear than the Perl, but not very useful.
(define obj1 (make <some-class>))
(define obj2 (make (class-of obj1)))

;; Use the shallow-clone or deep-clone methods to initialize from
;; another instance.
(define obj1 (make <widget>))
(define obj2 (deep-clone obj1))

;; @@PLEAC@@_13.7
;; Use eval or a variant to convert from a symbol or string to the
;; actual method.  As shown in 13.5 above, methods are first class and
;; you'd be more likely to store the actual method than the name in a
;; real Scheme program.
(define methname "flicker")
(apply-generic (eval-string methname) obj 10)

(for-each (lambda (m) (apply-generic obj (eval-string m)))
          '("start" "run" "stop"))

;; really, don't do this...
(define methods '("name" "rank" "serno"))
(define his-info
  (map (lambda (m) (cons m (apply-generic (eval-string m) obj)))
       methods))

;; same as this:
(define his-info (list (cons "name" (name obj))
                       (cons "rank" (rank obj))
                       (cons "serno" (serno obj))))

;; a closure works
(define fnref (lambda args (method obj args)))
(fnref 10 "fred")
(method obj 10 fred)

;; @@PLEAC@@_13.8
;; use is-a?
(is-a? obj <http-message>)
(is-a? <http-response> <http-message>)