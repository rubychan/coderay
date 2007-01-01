
("")
(string=? "K. Harper, M.D." ;; Taken from Section 6.3.3. (Symbols) of the R5RS
          (symbol->string
           (string->symbol "K. Harper, M.D.")))
;; BEGIN Factorial
(define factorial
  (lambda (n)
    (if (= n 1)
        1
        (* n (factorial (- n 1))))))
;; END Factorial

           ;; BEGIN Square
           (define square
             (lambda (n)  ;; My first lambda
               (if (= n 0)
                   0
           ;; BEGIN Recursive_Call
                   (+ (square (- n 1))
                      (- (+ n n) 1)))))
           ;; END Recursive_Call
           ;; END Square
           
;;LIST OF NUMBERS
(#b-1111 #xffa12 #o755 #o-755 +i -i +2i -2i 3+4i 1.6440287493492101i+2 1.344 3/4 #i23/70)

;;a vector
#('(1 2 3) #\\a 3 #t #f)

;;macros (USELESS AND INCORRECT, JUST TO CHECK THAT IDENTIFIERS ARE RECOGNIZED RIGHT)
(syntax-case ()
  ((_ name field ...)
   (with-syntax
     ((constructor (gen-id (syntax name) "make-" (syntax name)))
     (predicate (gen-id (syntax name) (syntax name) "?"))
     ((access ...)
     (map (lambda (x) (gen-id x "set-" (syntax name) "-" x "!"))))))))