;   Copyright (c) Rich Hickey. All rights reserved.
;   The use and distribution terms for this software are covered by the
;   Eclipse Public License 1.0 (http://opensource.org/licenses/eclipse-1.0.php)
;   which can be found in the file epl-v10.html at the root of this distribution.
;   By using this software in any fashion, you are agreeing to be bound by
;   the terms of this license.
;   You must not remove this notice, or any other, from this software.

(ns clojure.core)

(def unquote)
(def unquote-splicing)

(def
 #^{:arglists '([& items])
    :doc "Creates a new list containing the items."}
  list (. clojure.lang.PersistentList creator))

(def
 #^{:arglists '([x seq])
    :doc "Returns a new seq where x is the first element and seq is
    the rest."}

 cons (fn* cons [x seq] (. clojure.lang.RT (cons x seq))))

;during bootstrap we don't have destructuring let, loop or fn, will redefine later
(def
 #^{:macro true}
  let (fn* let [& decl] (cons 'let* decl)))

(def
 #^{:macro true}
 loop (fn* loop [& decl] (cons 'loop* decl)))

(def
 #^{:macro true}
 fn (fn* fn [& decl] (cons 'fn* decl)))

(def
 #^{:arglists '([coll])
    :doc "Returns the first item in the collection. Calls seq on its
    argument. If coll is nil, returns nil."}
 first (fn first [coll] (. clojure.lang.RT (first coll))))

(def
 #^{:arglists '([coll])
    :tag clojure.lang.ISeq
    :doc "Returns a seq of the items after the first. Calls seq on its
  argument.  If there are no more items, returns nil."}  
 next (fn next [x] (. clojure.lang.RT (next x))))

(def
 #^{:arglists '([coll])
    :tag clojure.lang.ISeq
    :doc "Returns a possibly empty seq of the items after the first. Calls seq on its
  argument."}  
 rest (fn rest [x] (. clojure.lang.RT (more x))))

(def
 #^{:arglists '([coll x] [coll x & xs])
    :doc "conj[oin]. Returns a new collection with the xs
    'added'. (conj nil item) returns (item).  The 'addition' may
    happen at different 'places' depending on the concrete type."}
 conj (fn conj 
        ([coll x] (. clojure.lang.RT (conj coll x)))
        ([coll x & xs]
         (if xs
           (recur (conj coll x) (first xs) (next xs))
           (conj coll x)))))

(def
 #^{:doc "Same as (first (next x))"
    :arglists '([x])}
 second (fn second [x] (first (next x))))

(def
 #^{:doc "Same as (first (first x))"
    :arglists '([x])}
 ffirst (fn ffirst [x] (first (first x))))

(def
 #^{:doc "Same as (next (first x))"
    :arglists '([x])}
 nfirst (fn nfirst [x] (next (first x))))

(def
 #^{:doc "Same as (first (next x))"
    :arglists '([x])}
 fnext (fn fnext [x] (first (next x))))

(def
 #^{:doc "Same as (next (next x))"
    :arglists '([x])}
 nnext (fn nnext [x] (next (next x))))

(def
 #^{:arglists '([coll])
    :doc "Returns a seq on the collection. If the collection is
    empty, returns nil.  (seq nil) returns nil. seq also works on
    Strings, native Java arrays (of reference types) and any objects
    that implement Iterable."
    :tag clojure.lang.ISeq}
 seq (fn seq [coll] (. clojure.lang.RT (seq coll))))

(def
 #^{:arglists '([#^Class c x])
    :doc "Evaluates x and tests if it is an instance of the class
    c. Returns true or false"}
 instance? (fn instance? [#^Class c x] (. c (isInstance x))))

(def
 #^{:arglists '([x])
    :doc "Return true if x implements ISeq"}
 seq? (fn seq? [x] (instance? clojure.lang.ISeq x)))

(def
 #^{:arglists '([x])
    :doc "Return true if x is a String"}
 string? (fn string? [x] (instance? String x)))

(def
 #^{:arglists '([x])
    :doc "Return true if x implements IPersistentMap"}
 map? (fn map? [x] (instance? clojure.lang.IPersistentMap x)))

(def
 #^{:arglists '([x])
    :doc "Return true if x implements IPersistentVector "}
 vector? (fn vector? [x] (instance? clojure.lang.IPersistentVector x)))

(def
 #^{:private true}
 sigs
 (fn [fdecl]
   (if (seq? (first fdecl))
     (loop [ret [] fdecl fdecl]
       (if fdecl
         (recur (conj ret (first (first fdecl))) (next fdecl))
         (seq ret)))
     (list (first fdecl)))))

(def
 #^{:arglists '([map key val] [map key val & kvs])
    :doc "assoc[iate]. When applied to a map, returns a new map of the
    same (hashed/sorted) type, that contains the mapping of key(s) to
    val(s). When applied to a vector, returns a new vector that
    contains val at index. Note - index must be <= (count vector)."}
 assoc
 (fn assoc
   ([map key val] (. clojure.lang.RT (assoc map key val)))
   ([map key val & kvs]
    (let [ret (assoc map key val)]
      (if kvs
        (recur ret (first kvs) (second kvs) (nnext kvs))
        ret)))))

;;;;;;;;;;;;;;;;; metadata ;;;;;;;;;;;;;;;;;;;;;;;;;;;
(def
 #^{:arglists '([obj])
    :doc "Returns the metadata of obj, returns nil if there is no metadata."}
 meta (fn meta [x]
        (if (instance? clojure.lang.IMeta x)
          (. #^clojure.lang.IMeta x (meta)))))

(def
 #^{:arglists '([#^clojure.lang.IObj obj m])
    :doc "Returns an object of the same type and value as obj, with
    map m as its metadata."}
 with-meta (fn with-meta [#^clojure.lang.IObj x m]
             (. x (withMeta m))))

(def 
 #^{:arglists '([coll])
    :doc "Return the last item in coll, in linear time"}
 last (fn last [s]
        (if (next s)
          (recur (next s))
          (first s))))

(def 
 #^{:arglists '([coll])
    :doc "Return a seq of all but the last item in coll, in linear time"}
 butlast (fn butlast [s]
           (loop [ret [] s s]
             (if (next s)
               (recur (conj ret (first s)) (next s))
               (seq ret)))))

(def 

 #^{:doc "Same as (def name (fn [params* ] exprs*)) or (def
    name (fn ([params* ] exprs*)+)) with any doc-string or attrs added
    to the var metadata"
    :arglists '([name doc-string? attr-map? [params*] body]
                [name doc-string? attr-map? ([params*] body)+ attr-map?])}
 defn (fn defn [name & fdecl]
        (let [m (if (string? (first fdecl))
                  {:doc (first fdecl)}
                  {})
              fdecl (if (string? (first fdecl))
                      (next fdecl)
                      fdecl)
              m (if (map? (first fdecl))
                  (conj m (first fdecl))
                  m)
              fdecl (if (map? (first fdecl))
                      (next fdecl)
                      fdecl)
              fdecl (if (vector? (first fdecl))
                      (list fdecl)
                      fdecl)
              m (if (map? (last fdecl))
                  (conj m (last fdecl))
                  m)
              fdecl (if (map? (last fdecl))
                      (butlast fdecl)
                      fdecl)
              m (conj {:arglists (list 'quote (sigs fdecl))} m)]
          (list 'def (with-meta name (conj (if (meta name) (meta name) {}) m))
                (cons `fn fdecl)))))

(. (var defn) (setMacro))

(defn cast
  "Throws a ClassCastException if x is not a c, else returns x."
  [#^Class c x] 
  (. c (cast x)))

(defn to-array
  "Returns an array of Objects containing the contents of coll, which
  can be any Collection.  Maps to java.util.Collection.toArray()."
  {:tag "[Ljava.lang.Object;"}
  [coll] (. clojure.lang.RT (toArray coll)))
 
(defn vector
  "Creates a new vector containing the args."
  ([] [])
  ([& args]
   (. clojure.lang.LazilyPersistentVector (create args))))

(defn vec
  "Creates a new vector containing the contents of coll."
  ([coll]
   (. clojure.lang.LazilyPersistentVector (createOwning (to-array coll)))))

(defn hash-map
  "keyval => key val
  Returns a new hash map with supplied mappings."
  ([] {})
  ([& keyvals]
   (. clojure.lang.PersistentHashMap (create keyvals))))

(defn hash-set
  "Returns a new hash set with supplied keys."
  ([] #{})
  ([& keys]
   (. clojure.lang.PersistentHashSet (create keys))))

(defn sorted-map
  "keyval => key val
  Returns a new sorted map with supplied mappings."
  ([& keyvals]
   (. clojure.lang.PersistentTreeMap (create keyvals))))

(defn sorted-set
  "Returns a new sorted set with supplied keys."
  ([& keys]
   (. clojure.lang.PersistentTreeSet (create keys))))

(defn sorted-map-by
  "keyval => key val
  Returns a new sorted map with supplied mappings, using the supplied comparator."
  ([comparator & keyvals]
   (. clojure.lang.PersistentTreeMap (create comparator keyvals))))
 
;;;;;;;;;;;;;;;;;;;;
(def

 #^{:doc "Like defn, but the resulting function name is declared as a
  macro and will be used as a macro by the compiler when it is
  called."
    :arglists '([name doc-string? attr-map? [params*] body]
                [name doc-string? attr-map? ([params*] body)+ attr-map?])}
 defmacro (fn [name & args]
            (list 'do
                  (cons `defn (cons name args))
                  (list '. (list 'var name) '(setMacro))
                  (list 'var name))))

(. (var defmacro) (setMacro))

(defmacro when
  "Evaluates test. If logical true, evaluates body in an implicit do."
  [test & body]
  (list 'if test (cons 'do body)))

(defmacro when-not
  "Evaluates test. If logical false, evaluates body in an implicit do."
  [test & body]
    (list 'if test nil (cons 'do body)))

(defn nil?
  "Returns true if x is nil, false otherwise."
  {:tag Boolean}
  [x] (identical? x nil))

(defn false?
  "Returns true if x is the value false, false otherwise."
  {:tag Boolean}
  [x] (identical? x false))

(defn true?
  "Returns true if x is the value true, false otherwise."
  {:tag Boolean}
  [x] (identical? x true))

(defn not
  "Returns true if x is logical false, false otherwise."
  {:tag Boolean}
  [x] (if x false true))

(defn str
  "With no args, returns the empty string. With one arg x, returns
  x.toString().  (str nil) returns the empty string. With more than
  one arg, returns the concatenation of the str values of the args."
  {:tag String}
  ([] "")
  ([#^Object x]
   (if (nil? x) "" (. x (toString))))
  ([x & ys]
     ((fn [#^StringBuilder sb more]
          (if more
            (recur (. sb  (append (str (first more)))) (next more))
            (str sb)))
      (new StringBuilder #^String (str x)) ys)))


(defn symbol?
  "Return true if x is a Symbol"
  [x] (instance? clojure.lang.Symbol x))

(defn keyword?
  "Return true if x is a Keyword"
  [x] (instance? clojure.lang.Keyword x))

(defn symbol
  "Returns a Symbol with the given namespace and name."
  ([name] (if (symbol? name) name (. clojure.lang.Symbol (intern name))))
  ([ns name] (. clojure.lang.Symbol (intern ns name))))

(defn keyword
  "Returns a Keyword with the given namespace and name.  Do not use :
  in the keyword strings, it will be added automatically."
  ([name] (if (keyword? name) name (. clojure.lang.Keyword (intern nil name))))
  ([ns name] (. clojure.lang.Keyword (intern ns name))))

(defn gensym
  "Returns a new symbol with a unique name. If a prefix string is
  supplied, the name is prefix# where # is some unique number. If
  prefix is not supplied, the prefix is 'G__'."
  ([] (gensym "G__"))
  ([prefix-string] (. clojure.lang.Symbol (intern (str prefix-string (str (. clojure.lang.RT (nextID))))))))

(defmacro cond
  "Takes a set of test/expr pairs. It evaluates each test one at a
  time.  If a test returns logical true, cond evaluates and returns
  the value of the corresponding expr and doesn't evaluate any of the
  other tests or exprs. (cond) returns nil."
  [& clauses]
    (when clauses
      (list 'if (first clauses)
            (if (next clauses)
                (second clauses)
                (throw (IllegalArgumentException.
                         "cond requires an even number of forms")))
            (cons 'clojure.core/cond (next (next clauses))))))

(defn spread
  {:private true}
  [arglist]
  (cond
   (nil? arglist) nil
   (nil? (next arglist)) (seq (first arglist))
   :else (cons (first arglist) (spread (next arglist)))))

(defn apply
  "Applies fn f to the argument list formed by prepending args to argseq."
  {:arglists '([f args* argseq])}
  [#^clojure.lang.IFn f & args]
    (. f (applyTo (spread args))))

(defn vary-meta
 "Returns an object of the same type and value as obj, with
  (apply f (meta obj) args) as its metadata."
 [obj f & args]
  (with-meta obj (apply f (meta obj) args)))

(defn list*
  "Creates a new list containing the item prepended to more."
  [item & more]
    (spread (cons item more)))

(defmacro lazy-seq
  "Takes a body of expressions that returns an ISeq or nil, and yields
  a Seqable object that will invoke the body only the first time seq
  is called, and will cache the result and return it on all subsequent
  seq calls."  
  [& body]
  (list 'new 'clojure.lang.LazySeq (list* '#^{:once true} fn* [] body)))    

(defn concat
  "Returns a lazy seq representing the concatenation of the elements in the supplied colls."
  ([] (lazy-seq nil))
  ([x] (lazy-seq x))
  ([x y]
     (lazy-seq
      (let [s (seq x)]
        (if s
          (cons (first s) (concat (rest s) y))
          y))))
  ([x y & zs]
     (let [cat (fn cat [xys zs]
                 (lazy-seq
                  (let [xys (seq xys)]
                    (if xys
                      (cons (first xys) (cat (rest xys) zs))
                      (when zs
                        (cat (first zs) (next zs)))))))]
           (cat (concat x y) zs))))

;;;;;;;;;;;;;;;;at this point all the support for syntax-quote exists;;;;;;;;;;;;;;;;;;;;;;


(defmacro delay
  "Takes a body of expressions and yields a Delay object that will
  invoke the body only the first time it is forced (with force), and
  will cache the result and return it on all subsequent force
  calls."  
  [& body]
    (list 'new 'clojure.lang.Delay (list* `#^{:once true} fn* [] body)))

(defn delay?
  "returns true if x is a Delay created with delay"
  [x] (instance? clojure.lang.Delay x))

(defn force
  "If x is a Delay, returns the (possibly cached) value of its expression, else returns x"
  [x] (. clojure.lang.Delay (force x)))

(defmacro if-not
  "Evaluates test. If logical false, evaluates and returns then expr, otherwise else expr, if supplied, else nil."
  ([test then] `(if-not ~test ~then nil))
  ([test then else]
   `(if (not ~test) ~then ~else)))

(defn =
  "Equality. Returns true if x equals y, false if not. Same as
  Java x.equals(y) except it also works for nil, and compares
  numbers and collections in a type-independent manner.  Clojure's immutable data
  structures define equals() (and thus =) as a value, not an identity,
  comparison."
  {:tag Boolean
   :inline (fn [x y] `(. clojure.lang.Util equiv ~x ~y))
   :inline-arities #{2}}
  ([x] true)
  ([x y] (clojure.lang.Util/equiv x y))
  ([x y & more]
   (if (= x y)
     (if (next more)
       (recur y (first more) (next more))
       (= y (first more)))
     false)))

(defn not=
  "Same as (not (= obj1 obj2))"
  {:tag Boolean}
  ([x] false)
  ([x y] (not (= x y)))
  ([x y & more]
   (not (apply = x y more))))



(defn compare
  "Comparator. Returns 0 if x equals y, -1 if x is logically 'less
  than' y, else 1. Same as Java x.compareTo(y) except it also works
  for nil, and compares numbers and collections in a type-independent
  manner. x must implement Comparable"
  {:tag Integer
   :inline (fn [x y] `(. clojure.lang.Util compare ~x ~y))}
  [x y] (. clojure.lang.Util (compare x y)))

(defmacro and
  "Evaluates exprs one at a time, from left to right. If a form
  returns logical false (nil or false), and returns that value and
  doesn't evaluate any of the other expressions, otherwise it returns
  the value of the last expr. (and) returns true."
  ([] true)
  ([x] x)
  ([x & next]
   `(let [and# ~x]
      (if and# (and ~@next) and#))))

(defmacro or
  "Evaluates exprs one at a time, from left to right. If a form
  returns a logical true value, or returns that value and doesn't
  evaluate any of the other expressions, otherwise it returns the
  value of the last expression. (or) returns nil."
  ([] nil)
  ([x] x)
  ([x & next]
      `(let [or# ~x]
         (if or# or# (or ~@next)))))

;;;;;;;;;;;;;;;;;;; sequence fns  ;;;;;;;;;;;;;;;;;;;;;;;
(defn reduce
  "f should be a function of 2 arguments. If val is not supplied,
  returns the result of applying f to the first 2 items in coll, then
  applying f to that result and the 3rd item, etc. If coll contains no
  items, f must accept no arguments as well, and reduce returns the
  result of calling f with no arguments.  If coll has only 1 item, it
  is returned and f is not called.  If val is supplied, returns the
  result of applying f to val and the first item in coll, then
  applying f to that result and the 2nd item, etc. If coll contains no
  items, returns val and f is not called."
  ([f coll]
   (let [s (seq coll)]
     (if s
       (if (instance? clojure.lang.IReduce s)
         (. #^clojure.lang.IReduce s (reduce f))
         (reduce f (first s) (next s)))
       (f))))
  ([f val coll]
     (let [s (seq coll)]
       (if (instance? clojure.lang.IReduce s)
         (. #^clojure.lang.IReduce s (reduce f val))
         ((fn [f val s]
            (if s
              (recur f (f val (first s)) (next s))
              val))
          f val s)))))

(defn reverse
  "Returns a seq of the items in coll in reverse order. Not lazy."
  [coll]
    (reduce conj () coll))

;;math stuff
(defn +
  "Returns the sum of nums. (+) returns 0."
  {:inline (fn [x y] `(. clojure.lang.Numbers (add ~x ~y)))
   :inline-arities #{2}}
  ([] 0)
  ([x] (cast Number x))
  ([x y] (. clojure.lang.Numbers (add x y)))
  ([x y & more]
   (reduce + (+ x y) more)))

(defn *
  "Returns the product of nums. (*) returns 1."
  {:inline (fn [x y] `(. clojure.lang.Numbers (multiply ~x ~y)))
   :inline-arities #{2}}
  ([] 1)
  ([x] (cast Number x))
  ([x y] (. clojure.lang.Numbers (multiply x y)))
  ([x y & more]
   (reduce * (* x y) more)))

(defn /
  "If no denominators are supplied, returns 1/numerator,
  else returns numerator divided by all of the denominators."
  {:inline (fn [x y] `(. clojure.lang.Numbers (divide ~x ~y)))
   :inline-arities #{2}}
  ([x] (/ 1 x))
  ([x y] (. clojure.lang.Numbers (divide x y)))
  ([x y & more]
   (reduce / (/ x y) more)))

(defn -
  "If no ys are supplied, returns the negation of x, else subtracts
  the ys from x and returns the result."
  {:inline (fn [& args] `(. clojure.lang.Numbers (minus ~@args)))
   :inline-arities #{1 2}}
  ([x] (. clojure.lang.Numbers (minus x)))
  ([x y] (. clojure.lang.Numbers (minus x y)))
  ([x y & more]
   (reduce - (- x y) more)))

(defn <
  "Returns non-nil if nums are in monotonically increasing order,
  otherwise false."
  {:inline (fn [x y] `(. clojure.lang.Numbers (lt ~x ~y)))
   :inline-arities #{2}}
  ([x] true)
  ([x y] (. clojure.lang.Numbers (lt x y)))
  ([x y & more]
   (if (< x y)
     (if (next more)
       (recur y (first more) (next more))
       (< y (first more)))
     false)))

(defn <=
  "Returns non-nil if nums are in monotonically non-decreasing order,
  otherwise false."
  {:inline (fn [x y] `(. clojure.lang.Numbers (lte ~x ~y)))
   :inline-arities #{2}}
  ([x] true)
  ([x y] (. clojure.lang.Numbers (lte x y)))
  ([x y & more]
   (if (<= x y)
     (if (next more)
       (recur y (first more) (next more))
       (<= y (first more)))
     false)))

(defn >
  "Returns non-nil if nums are in monotonically decreasing order,
  otherwise false."
  {:inline (fn [x y] `(. clojure.lang.Numbers (gt ~x ~y)))
   :inline-arities #{2}}
  ([x] true)
  ([x y] (. clojure.lang.Numbers (gt x y)))
  ([x y & more]
   (if (> x y)
     (if (next more)
       (recur y (first more) (next more))
       (> y (first more)))
     false)))

(defn >=
  "Returns non-nil if nums are in monotonically non-increasing order,
  otherwise false."
  {:inline (fn [x y] `(. clojure.lang.Numbers (gte ~x ~y)))
   :inline-arities #{2}}
  ([x] true)
  ([x y] (. clojure.lang.Numbers (gte x y)))
  ([x y & more]
   (if (>= x y)
     (if (next more)
       (recur y (first more) (next more))
       (>= y (first more)))
     false)))

(defn ==
  "Returns non-nil if nums all have the same value, otherwise false"
  {:inline (fn [x y] `(. clojure.lang.Numbers (equiv ~x ~y)))
   :inline-arities #{2}}
  ([x] true)
  ([x y] (. clojure.lang.Numbers (equiv x y)))
  ([x y & more]
   (if (== x y)
     (if (next more)
       (recur y (first more) (next more))
       (== y (first more)))
     false)))

(defn max
  "Returns the greatest of the nums."
  ([x] x)
  ([x y] (if (> x y) x y))
  ([x y & more]
   (reduce max (max x y) more)))

(defn min
  "Returns the least of the nums."
  ([x] x)
  ([x y] (if (< x y) x y))
  ([x y & more]
   (reduce min (min x y) more)))

(defn inc
  "Returns a number one greater than num."
  {:inline (fn [x] `(. clojure.lang.Numbers (inc ~x)))}
  [x] (. clojure.lang.Numbers (inc x)))

(defn dec
  "Returns a number one less than num."
  {:inline (fn [x] `(. clojure.lang.Numbers (dec ~x)))}
  [x] (. clojure.lang.Numbers (dec x)))

(defn unchecked-inc
  "Returns a number one greater than x, an int or long.
  Note - uses a primitive operator subject to overflow."
  {:inline (fn [x] `(. clojure.lang.Numbers (unchecked_inc ~x)))}
  [x] (. clojure.lang.Numbers (unchecked_inc x)))

(defn unchecked-dec
  "Returns a number one less than x, an int or long.
  Note - uses a primitive operator subject to overflow."
  {:inline (fn [x] `(. clojure.lang.Numbers (unchecked_dec ~x)))}
  [x] (. clojure.lang.Numbers (unchecked_dec x)))

(defn unchecked-negate
  "Returns the negation of x, an int or long.
  Note - uses a primitive operator subject to overflow."
  {:inline (fn [x] `(. clojure.lang.Numbers (unchecked_negate ~x)))}
  [x] (. clojure.lang.Numbers (unchecked_negate x)))

(defn unchecked-add
  "Returns the sum of x and y, both int or long.
  Note - uses a primitive operator subject to overflow."
  {:inline (fn [x y] `(. clojure.lang.Numbers (unchecked_add ~x ~y)))}
  [x y] (. clojure.lang.Numbers (unchecked_add x y)))

(defn unchecked-subtract
  "Returns the difference of x and y, both int or long.
  Note - uses a primitive operator subject to overflow."
  {:inline (fn [x y] `(. clojure.lang.Numbers (unchecked_subtract ~x ~y)))}
  [x y] (. clojure.lang.Numbers (unchecked_subtract x y)))

(defn unchecked-multiply
  "Returns the product of x and y, both int or long.
  Note - uses a primitive operator subject to overflow."
  {:inline (fn [x y] `(. clojure.lang.Numbers (unchecked_multiply ~x ~y)))}
  [x y] (. clojure.lang.Numbers (unchecked_multiply x y)))

(defn unchecked-divide
  "Returns the division of x by y, both int or long.
  Note - uses a primitive operator subject to truncation."
  {:inline (fn [x y] `(. clojure.lang.Numbers (unchecked_divide ~x ~y)))}
  [x y] (. clojure.lang.Numbers (unchecked_divide x y)))

(defn unchecked-remainder
  "Returns the remainder of division of x by y, both int or long.
  Note - uses a primitive operator subject to truncation."
  {:inline (fn [x y] `(. clojure.lang.Numbers (unchecked_remainder ~x ~y)))}
  [x y] (. clojure.lang.Numbers (unchecked_remainder x y)))

(defn pos?
  "Returns true if num is greater than zero, else false"
  {:tag Boolean
   :inline (fn [x] `(. clojure.lang.Numbers (isPos ~x)))}
  [x] (. clojure.lang.Numbers (isPos x)))

(defn neg?
  "Returns true if num is less than zero, else false"
  {:tag Boolean
   :inline (fn [x] `(. clojure.lang.Numbers (isNeg ~x)))}
  [x] (. clojure.lang.Numbers (isNeg x)))

(defn zero?
  "Returns true if num is zero, else false"
  {:tag Boolean
   :inline (fn [x] `(. clojure.lang.Numbers (isZero ~x)))}
  [x] (. clojure.lang.Numbers (isZero x)))

(defn quot
  "quot[ient] of dividing numerator by denominator."
  [num div]
    (. clojure.lang.Numbers (quotient num div)))

(defn rem
  "remainder of dividing numerator by denominator."
  [num div]
    (. clojure.lang.Numbers (remainder num div)))

(defn rationalize
  "returns the rational value of num"
  [num]
  (. clojure.lang.Numbers (rationalize num)))

;;Bit ops

(defn bit-not
  "Bitwise complement"
  {:inline (fn [x] `(. clojure.lang.Numbers (not ~x)))}
  [x] (. clojure.lang.Numbers not x))


(defn bit-and
  "Bitwise and"
   {:inline (fn [x y] `(. clojure.lang.Numbers (and ~x ~y)))}
  [x y] (. clojure.lang.Numbers and x y))

(defn bit-or
  "Bitwise or"
  {:inline (fn [x y] `(. clojure.lang.Numbers (or ~x ~y)))}
  [x y] (. clojure.lang.Numbers or x y))

(defn bit-xor
  "Bitwise exclusive or"
  {:inline (fn [x y] `(. clojure.lang.Numbers (xor ~x ~y)))}
  [x y] (. clojure.lang.Numbers xor x y))

(defn bit-and-not
  "Bitwise and with complement"
  [x y] (. clojure.lang.Numbers andNot x y))


(defn bit-clear
  "Clear bit at index n"
  [x n] (. clojure.lang.Numbers clearBit x n))

(defn bit-set
  "Set bit at index n"
  [x n] (. clojure.lang.Numbers setBit x n))

(defn bit-flip
  "Flip bit at index n"
  [x n] (. clojure.lang.Numbers flipBit x n))

(defn bit-test
  "Test bit at index n"
  [x n] (. clojure.lang.Numbers testBit x n))


(defn bit-shift-left
  "Bitwise shift left"
  [x n] (. clojure.lang.Numbers shiftLeft x n))

(defn bit-shift-right
  "Bitwise shift right"
  [x n] (. clojure.lang.Numbers shiftRight x n))

(defn even?
  "Returns true if n is even, throws an exception if n is not an integer"
  [n] (zero? (bit-and n 1)))

(defn odd?
  "Returns true if n is odd, throws an exception if n is not an integer"
  [n] (not (even? n)))


;;

(defn complement
  "Takes a fn f and returns a fn that takes the same arguments as f,
  has the same effects, if any, and returns the opposite truth value."
  [f] 
  (fn 
    ([] (not (f)))
    ([x] (not (f x)))
    ([x y] (not (f x y)))
    ([x y & zs] (not (apply f x y zs)))))

(defn constantly
  "Returns a function that takes any number of arguments and returns x."
  [x] (fn [& args] x))

(defn identity
  "Returns its argument."
  [x] x)

;;Collection stuff



(defn count
  "Returns the number of items in the collection. (count nil) returns
  0.  Also works on strings, arrays, and Java Collections and Maps"
  [coll] (. clojure.lang.RT (count coll)))

;;list stuff
(defn peek
  "For a list or queue, same as first, for a vector, same as, but much
  more efficient than, last. If the collection is empty, returns nil."
  [coll] (. clojure.lang.RT (peek coll)))

(defn pop
  "For a list or queue, returns a new list/queue without the first
  item, for a vector, returns a new vector without the last item. If
  the collection is empty, throws an exception.  Note - not the same
  as next/butlast."
  [coll] (. clojure.lang.RT (pop coll)))

(defn nth
  "Returns the value at the index. get returns nil if index out of
  bounds, nth throws an exception unless not-found is supplied.  nth
  also works for strings, Java arrays, regex Matchers and Lists, and,
  in O(n) time, for sequences."
  ([coll index] (. clojure.lang.RT (nth coll index)))
  ([coll index not-found] (. clojure.lang.RT (nth coll index not-found))))

;;map stuff

(defn contains?
  "Returns true if key is present in the given collection, otherwise
  returns false.  Note that for numerically indexed collections like
  vectors and Java arrays, this tests if the numeric key is within the
  range of indexes. 'contains?' operates constant or logarithmic time;
  it will not perform a linear search for a value.  See also 'some'."
  [coll key] (. clojure.lang.RT (contains coll key)))

(defn get
  "Returns the value mapped to key, not-found or nil if key not present."
  ([map key]
   (. clojure.lang.RT (get map key)))
  ([map key not-found]
   (. clojure.lang.RT (get map key not-found))))

(defn dissoc
  "dissoc[iate]. Returns a new map of the same (hashed/sorted) type,
  that does not contain a mapping for key(s)."
  ([map] map)
  ([map key]
   (. clojure.lang.RT (dissoc map key)))
  ([map key & ks]
   (let [ret (dissoc map key)]
     (if ks
       (recur ret (first ks) (next ks))
       ret))))

(defn disj
  "disj[oin]. Returns a new set of the same (hashed/sorted) type, that
  does not contain key(s)."
  ([set] set)
  ([#^clojure.lang.IPersistentSet set key]
   (. set (disjoin key)))
  ([set key & ks]
   (let [ret (disj set key)]
     (if ks
       (recur ret (first ks) (next ks))
       ret))))

(defn find
  "Returns the map entry for key, or nil if key not present."
  [map key] (. clojure.lang.RT (find map key)))

(defn select-keys
  "Returns a map containing only those entries in map whose key is in keys"
  [map keyseq]
    (loop [ret {} keys (seq keyseq)]
      (if keys
        (let [entry (. clojure.lang.RT (find map (first keys)))]
          (recur
           (if entry
             (conj ret entry)
             ret)
           (next keys)))
        ret)))

(defn keys
  "Returns a sequence of the map's keys."
  [map] (. clojure.lang.RT (keys map)))

(defn vals
  "Returns a sequence of the map's values."
  [map] (. clojure.lang.RT (vals map)))

(defn key
  "Returns the key of the map entry."
  [#^java.util.Map$Entry e]
    (. e (getKey)))

(defn val
  "Returns the value in the map entry."
  [#^java.util.Map$Entry e]
    (. e (getValue)))

(defn rseq
  "Returns, in constant time, a seq of the items in rev (which
  can be a vector or sorted-map), in reverse order. If rev is empty returns nil"
  [#^clojure.lang.Reversible rev]
    (. rev (rseq)))

(defn name
  "Returns the name String of a symbol or keyword."
  {:tag String}
  [#^clojure.lang.Named x]
    (. x (getName)))

(defn namespace
  "Returns the namespace String of a symbol or keyword, or nil if not present."
  {:tag String}
  [#^clojure.lang.Named x]
    (. x (getNamespace)))

(defmacro locking
  "Executes exprs in an implicit do, while holding the monitor of x.
  Will release the monitor of x in all circumstances."
  [x & body]
  `(let [lockee# ~x]
     (try
      (monitor-enter lockee#)
      ~@body
      (finally
       (monitor-exit lockee#)))))

(defmacro ..
  "form => fieldName-symbol or (instanceMethodName-symbol args*)

  Expands into a member access (.) of the first member on the first
  argument, followed by the next member on the result, etc. For
  instance:

  (.. System (getProperties) (get \"os.name\"))

  expands to:

  (. (. System (getProperties)) (get \"os.name\"))

  but is easier to write, read, and understand."
  ([x form] `(. ~x ~form))
  ([x form & more] `(.. (. ~x ~form) ~@more)))

(defmacro ->
  "Threads the expr through the forms. Inserts x as the
  second item in the first form, making a list of it if it is not a
  list already. If there are more forms, inserts the first form as the
  second item in second form, etc."
  ([x form] (if (seq? form)
              `(~(first form) ~x ~@(next form))
              (list form x)))
  ([x form & more] `(-> (-> ~x ~form) ~@more)))

;;multimethods
(def global-hierarchy)

(defmacro defmulti
  "Creates a new multimethod with the associated dispatch function.
  The docstring and attribute-map are optional.

  Options are key-value pairs and may be one of:
    :default    the default dispatch value, defaults to :default
    :hierarchy  the isa? hierarchy to use for dispatching
                defaults to the global hierarchy"
  {:arglists '([name docstring? attr-map? dispatch-fn & options])}
  [mm-name & options]
  (let [docstring   (if (string? (first options))
                      (first options)
                      nil)
        options     (if (string? (first options))
                      (next options)
                      options)
        m           (if (map? (first options))
                      (first options)
                      {})
        options     (if (map? (first options))
                      (next options)
                      options)
        dispatch-fn (first options)
        options     (next options)
        m           (assoc m :tag 'clojure.lang.MultiFn)
        m           (if docstring
                      (assoc m :doc docstring)
                      m)
        m           (if (meta mm-name)
                      (conj (meta mm-name) m)
                      m)]
    (when (= (count options) 1)
      (throw (Exception. "The syntax for defmulti has changed. Example: (defmulti name dispatch-fn :default dispatch-value)")))
    (let [options   (apply hash-map options)
          default   (get options :default :default)
          hierarchy (get options :hierarchy #'global-hierarchy)]
      `(def ~(with-meta mm-name m)
         (new clojure.lang.MultiFn ~(name mm-name) ~dispatch-fn ~default ~hierarchy)))))

(defmacro defmethod
  "Creates and installs a new method of multimethod associated with dispatch-value. "
  [multifn dispatch-val & fn-tail]
  `(. ~multifn addMethod ~dispatch-val (fn ~@fn-tail)))

(defn remove-method
  "Removes the method of multimethod associated	with dispatch-value."
 [#^clojure.lang.MultiFn multifn dispatch-val]
 (. multifn removeMethod dispatch-val))

(defn prefer-method
  "Causes the multimethod to prefer matches of dispatch-val-x over dispatch-val-y when there is a conflict"
  [#^clojure.lang.MultiFn multifn dispatch-val-x dispatch-val-y]
  (. multifn preferMethod dispatch-val-x dispatch-val-y))

(defn methods
  "Given a multimethod, returns a map of dispatch values -> dispatch fns"
  [#^clojure.lang.MultiFn multifn] (.getMethodTable multifn))

(defn get-method
  "Given a multimethod and a dispatch value, returns the dispatch fn
  that would apply to that value, or nil if none apply and no default"
  [#^clojure.lang.MultiFn multifn dispatch-val] (.getMethod multifn dispatch-val))

(defn prefers
  "Given a multimethod, returns a map of preferred value -> set of other values"
  [#^clojure.lang.MultiFn multifn] (.getPreferTable multifn))

;;;;;;;;; var stuff

(defmacro #^{:private true} assert-args [fnname & pairs]
  `(do (when-not ~(first pairs)
         (throw (IllegalArgumentException.
                  ~(str fnname " requires " (second pairs)))))
     ~(let [more (nnext pairs)]
        (when more
          (list* `assert-args fnname more)))))

(defmacro if-let
  "bindings => binding-form test

  If test is true, evaluates then with binding-form bound to the value of test, if not, yields else"
  ([bindings then]
   `(if-let ~bindings ~then nil))
  ([bindings then else & oldform]
   (assert-args if-let
     (and (vector? bindings) (nil? oldform)) "a vector for its binding"
     (= 2 (count bindings)) "exactly 2 forms in binding vector")
   (let [form (bindings 0) tst (bindings 1)]
     `(let [temp# ~tst]
        (if temp#
          (let [~form temp#]
            ~then)
          ~else)))))

(defmacro when-let
  "bindings => binding-form test

  When test is true, evaluates body with binding-form bound to the value of test"
  [bindings & body]
  (assert-args when-let
     (vector? bindings) "a vector for its binding"
     (= 2 (count bindings)) "exactly 2 forms in binding vector")
   (let [form (bindings 0) tst (bindings 1)]
    `(let [temp# ~tst]
       (when temp#
         (let [~form temp#]
           ~@body)))))

(defmacro binding
  "binding => var-symbol init-expr

  Creates new bindings for the (already-existing) vars, with the
  supplied initial values, executes the exprs in an implicit do, then
  re-establishes the bindings that existed before."
  [bindings & body]
    (assert-args binding
      (vector? bindings) "a vector for its binding"
      (even? (count bindings)) "an even number of forms in binding vector")
    (let [var-ize (fn [var-vals]
                    (loop [ret [] vvs (seq var-vals)]
                      (if vvs
                        (recur  (conj (conj ret `(var ~(first vvs))) (second vvs))
                                (next (next vvs)))
                        (seq ret))))]
      `(do
         (. clojure.lang.Var (pushThreadBindings (hash-map ~@(var-ize bindings))))
         (try
          ~@body
          (finally
           (. clojure.lang.Var (popThreadBindings)))))))

(defn find-var
  "Returns the global var named by the namespace-qualified symbol, or
  nil if no var with that name."
 [sym] (. clojure.lang.Var (find sym)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Refs ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defn #^{:private true}
  setup-reference [#^clojure.lang.ARef r options]
  (let [opts (apply hash-map options)]
    (when (:meta opts)
      (.resetMeta r (:meta opts)))
    (when (:validator opts)
      (.setValidator r (:validator opts)))
    r))

(defn agent
  "Creates and returns an agent with an initial value of state and
  zero or more options (in any order):

  :meta metadata-map

  :validator validate-fn

  If metadata-map is supplied, it will be come the metadata on the
  agent. validate-fn must be nil or a side-effect-free fn of one
  argument, which will be passed the intended new state on any state
  change. If the new state is unacceptable, the validate-fn should
  return false or throw an exception."
  ([state] (new clojure.lang.Agent state))
  ([state & options]
     (setup-reference (agent state) options)))

(defn send
  "Dispatch an action to an agent. Returns the agent immediately.
  Subsequently, in a thread from a thread pool, the state of the agent
  will be set to the value of:

  (apply action-fn state-of-agent args)"
  [#^clojure.lang.Agent a f & args]
    (. a (dispatch f args false)))

(defn send-off
  "Dispatch a potentially blocking action to an agent. Returns the
  agent immediately. Subsequently, in a separate thread, the state of
  the agent will be set to the value of:

  (apply action-fn state-of-agent args)"
  [#^clojure.lang.Agent a f & args]
    (. a (dispatch f args true)))

(defn release-pending-sends
  "Normally, actions sent directly or indirectly during another action
  are held until the action completes (changes the agent's
  state). This function can be used to dispatch any pending sent
  actions immediately. This has no impact on actions sent during a
  transaction, which are still held until commit. If no action is
  occurring, does nothing. Returns the number of actions dispatched."
  [] (clojure.lang.Agent/releasePendingSends))

(defn add-watch
  "Experimental.
  Adds a watch function to an agent/atom/var/ref reference. The watch
  fn must be a fn of 4 args: a key, the reference, its old-state, its
  new-state. Whenever the reference's state might have been changed,
  any registered watches will have their functions called. The watch fn
  will be called synchronously, on the agent's thread if an agent,
  before any pending sends if agent or ref. Note that an atom's or
  ref's state may have changed again prior to the fn call, so use
  old/new-state rather than derefing the reference. Note also that watch
  fns may be called from multiple threads simultaneously. Var watchers
  are triggered only by root binding changes, not thread-local
  set!s. Keys must be unique per reference, and can be used to remove
  the watch with remove-watch, but are otherwise considered opaque by
  the watch mechanism."
  [#^clojure.lang.IRef reference key fn] (.addWatch reference key fn))

(defn remove-watch
  "Experimental.
  Removes a watch (set by add-watch) from a reference"
  [#^clojure.lang.IRef reference key]
  (.removeWatch reference key))

(defn add-watcher
  "Experimental.
  Adds a watcher to an agent/atom/var/ref reference. The watcher must
  be an Agent, and the action a function of the agent's state and one
  additional arg, the reference. Whenever the reference's state
  changes, any registered watchers will have their actions
  sent. send-type must be one of :send or :send-off. The actions will
  be sent after the reference's state is changed. Var watchers are
  triggered only by root binding changes, not thread-local set!s"
  [#^clojure.lang.IRef reference send-type watcher-agent action-fn]
  (add-watch reference watcher-agent
    (fn [watcher-agent reference old-state new-state]
      (when-not (identical? old-state new-state)
        ((if (= send-type :send-off) send-off send)
         watcher-agent action-fn reference)))))

(defn remove-watcher
  "Experimental.
  Removes a watcher (set by add-watcher) from a reference"
  [reference watcher-agent]
  (remove-watch reference watcher-agent))

(defn agent-errors
  "Returns a sequence of the exceptions thrown during asynchronous
  actions of the agent."
  [#^clojure.lang.Agent a] (. a (getErrors)))

(defn clear-agent-errors
  "Clears any exceptions thrown during asynchronous actions of the
  agent, allowing subsequent actions to occur."
  [#^clojure.lang.Agent a] (. a (clearErrors)))

(defn shutdown-agents
  "Initiates a shutdown of the thread pools that back the agent
  system. Running actions will complete, but no new actions will be
  accepted"
  [] (. clojure.lang.Agent shutdown))

(defn ref
  "Creates and returns a Ref with an initial value of x and zero or
  more options (in any order):

  :meta metadata-map

  :validator validate-fn

  If metadata-map is supplied, it will be come the metadata on the
  ref. validate-fn must be nil or a side-effect-free fn of one
  argument, which will be passed the intended new state on any state
  change. If the new state is unacceptable, the validate-fn should
  return false or throw an exception. validate-fn will be called on
  transaction commit, when all refs have their final values."
  ([x] (new clojure.lang.Ref x))
  ([x & options] (setup-reference (ref x) options)))

(defn deref
  "Also reader macro: @ref/@agent/@var/@atom/@delay/@future. Within a transaction,
  returns the in-transaction-value of ref, else returns the
  most-recently-committed value of ref. When applied to a var, agent
  or atom, returns its current state. When applied to a delay, forces
  it if not already forced. When applied to a future, will block if
  computation not complete" 
  [#^clojure.lang.IDeref ref] (.deref ref))

(defn atom
  "Creates and returns an Atom with an initial value of x and zero or
  more options (in any order):

  :meta metadata-map

  :validator validate-fn

  If metadata-map is supplied, it will be come the metadata on the
  atom. validate-fn must be nil or a side-effect-free fn of one
  argument, which will be passed the intended new state on any state
  change. If the new state is unacceptable, the validate-fn should
  return false or throw an exception."
  ([x] (new clojure.lang.Atom x))
  ([x & options] (setup-reference (atom x) options)))

(defn swap!
  "Atomically swaps the value of atom to be:
  (apply f current-value-of-atom args). Note that f may be called
  multiple times, and thus should be free of side effects.  Returns
  the value that was swapped in."
  ([#^clojure.lang.Atom atom f] (.swap atom f))
  ([#^clojure.lang.Atom atom f x] (.swap atom f x))
  ([#^clojure.lang.Atom atom f x y] (.swap atom f x y))
  ([#^clojure.lang.Atom atom f x y & args] (.swap atom f x y args)))

(defn compare-and-set!
  "Atomically sets the value of atom to newval if and only if the
  current value of the atom is identical to oldval. Returns true if
  set happened, else false"
  [#^clojure.lang.Atom atom oldval newval] (.compareAndSet atom oldval newval))

(defn reset!
  "Sets the value of atom to newval without regard for the
  current value. Returns newval."
  [#^clojure.lang.Atom atom newval] (.reset atom newval))

(defn set-validator!
  "Sets the validator-fn for a var/ref/agent/atom. validator-fn must be nil or a
  side-effect-free fn of one argument, which will be passed the intended
  new state on any state change. If the new state is unacceptable, the
  validator-fn should return false or throw an exception. If the current state (root
  value if var) is not acceptable to the new validator, an exception
  will be thrown and the validator will not be changed."
  [#^clojure.lang.IRef iref validator-fn] (. iref (setValidator validator-fn)))

(defn get-validator
  "Gets the validator-fn for a var/ref/agent/atom."
 [#^clojure.lang.IRef iref] (. iref (getValidator)))

(defn alter-meta!
  "Atomically sets the metadata for a namespace/var/ref/agent/atom to be:

  (apply f its-current-meta args)

  f must be free of side-effects"
 [#^clojure.lang.IReference iref f & args] (.alterMeta iref f args))

(defn reset-meta!
  "Atomically resets the metadata for a namespace/var/ref/agent/atom"
 [#^clojure.lang.IReference iref metadata-map] (.resetMeta iref metadata-map))

(defn commute
  "Must be called in a transaction. Sets the in-transaction-value of
  ref to:

  (apply fun in-transaction-value-of-ref args)

  and returns the in-transaction-value of ref.

  At the commit point of the transaction, sets the value of ref to be:

  (apply fun most-recently-committed-value-of-ref args)

  Thus fun should be commutative, or, failing that, you must accept
  last-one-in-wins behavior.  commute allows for more concurrency than
  ref-set."

  [#^clojure.lang.Ref ref fun & args]
    (. ref (commute fun args)))

(defn alter
  "Must be called in a transaction. Sets the in-transaction-value of
  ref to:

  (apply fun in-transaction-value-of-ref args)

  and returns the in-transaction-value of ref."
  [#^clojure.lang.Ref ref fun & args]
    (. ref (alter fun args)))

(defn ref-set
  "Must be called in a transaction. Sets the value of ref.
  Returns val."
  [#^clojure.lang.Ref ref val]
    (. ref (set val)))

(defn ensure
  "Must be called in a transaction. Protects the ref from modification
  by other transactions.  Returns the in-transaction-value of
  ref. Allows for more concurrency than (ref-set ref @ref)"
  [#^clojure.lang.Ref ref]
    (. ref (touch))
    (. ref (deref)))

(defmacro sync
  "transaction-flags => TBD, pass nil for now

  Runs the exprs (in an implicit do) in a transaction that encompasses
  exprs and any nested calls.  Starts a transaction if none is already
  running on this thread. Any uncaught exception will abort the
  transaction and flow out of sync. The exprs may be run more than
  once, but any effects on Refs will be atomic."
  [flags-ignored-for-now & body]
  `(. clojure.lang.LockingTransaction
      (runInTransaction (fn [] ~@body))))


(defmacro io!
  "If an io! block occurs in a transaction, throws an
  IllegalStateException, else runs body in an implicit do. If the
  first expression in body is a literal string, will use that as the
  exception message."
  [& body]
  (let [message (when (string? (first body)) (first body))
        body (if message (next body) body)]
    `(if (clojure.lang.LockingTransaction/isRunning)
       (throw (new IllegalStateException ~(or message "I/O in transaction")))
       (do ~@body))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; fn stuff ;;;;;;;;;;;;;;;;


(defn comp
  "Takes a set of functions and returns a fn that is the composition
  of those fns.  The returned fn takes a variable number of args,
  applies the rightmost of fns to the args, the next
  fn (right-to-left) to the result, etc."
  [& fs]
    (let [fs (reverse fs)]
      (fn [& args]
        (loop [ret (apply (first fs) args) fs (next fs)]
          (if fs
            (recur ((first fs) ret) (next fs))
            ret)))))

(defn partial
  "Takes a function f and fewer than the normal arguments to f, and
  returns a fn that takes a variable number of additional args. When
  called, the returned function calls f with args + additional args."
  ([f arg1]
   (fn [& args] (apply f arg1 args)))
  ([f arg1 arg2]
   (fn [& args] (apply f arg1 arg2 args)))
  ([f arg1 arg2 arg3]
   (fn [& args] (apply f arg1 arg2 arg3 args)))
  ([f arg1 arg2 arg3 & more]
   (fn [& args] (apply f arg1 arg2 arg3 (concat more args)))))

;;;;;;;;;;;;;;;;;;; sequence fns  ;;;;;;;;;;;;;;;;;;;;;;;
(defn stream? 
  "Returns true if x is an instance of Stream"
  [x] (instance? clojure.lang.Stream x))


(defn sequence
  "Coerces coll to a (possibly empty) sequence, if it is not already
  one. Will not force a lazy seq. (sequence nil) yields ()"  
  [coll]
   (cond 
    (seq? coll) coll
    (stream? coll) (.sequence #^clojure.lang.Stream coll)
    :else (or (seq coll) ())))

(defn every?
  "Returns true if (pred x) is logical true for every x in coll, else
  false."
  {:tag Boolean}
  [pred coll]
    (if (seq coll)
      (and (pred (first coll))
           (recur pred (next coll)))
      true))

(def
 #^{:tag Boolean
    :doc "Returns false if (pred x) is logical true for every x in
  coll, else true."
    :arglists '([pred coll])}
 not-every? (comp not every?))

(defn some
  "Returns the first logical true value of (pred x) for any x in coll,
  else nil.  One common idiom is to use a set as pred, for example
  this will return true if :fred is in the sequence, otherwise nil:
  (some #{:fred} coll)"
  [pred coll]
    (when (seq coll)
      (or (pred (first coll)) (recur pred (next coll)))))

(def
 #^{:tag Boolean
    :doc "Returns false if (pred x) is logical true for any x in coll,
  else true."
    :arglists '([pred coll])}
 not-any? (comp not some))

(defn map
  "Returns a lazy sequence consisting of the result of applying f to the
  set of first items of each coll, followed by applying f to the set
  of second items in each coll, until any one of the colls is
  exhausted.  Any remaining items in other colls are ignored. Function
  f should accept number-of-colls arguments."
  ([f coll]
   (lazy-seq
    (when-let [s (seq coll)]
      (cons (f (first s)) (map f (rest s))))))
  ([f c1 c2]
   (lazy-seq
    (let [s1 (seq c1) s2 (seq c2)]
      (when (and s1 s2)
        (cons (f (first s1) (first s2))
              (map f (rest s1) (rest s2)))))))
  ([f c1 c2 c3]
   (lazy-seq
    (let [s1 (seq c1) s2 (seq c2) s3 (seq c3)]
      (when (and  s1 s2 s3)
        (cons (f (first s1) (first s2) (first s3))
              (map f (rest s1) (rest s2) (rest s3)))))))
  ([f c1 c2 c3 & colls]
   (let [step (fn step [cs]
                 (lazy-seq
                  (let [ss (map seq cs)]
                    (when (every? identity ss)
                      (cons (map first ss) (step (map rest ss)))))))]
     (map #(apply f %) (step (conj colls c3 c2 c1))))))

(defn mapcat
  "Returns the result of applying concat to the result of applying map
  to f and colls.  Thus function f should return a collection."
  [f & colls]
    (apply concat (apply map f colls)))

(defn filter
  "Returns a lazy sequence of the items in coll for which
  (pred item) returns true. pred must be free of side-effects."
  [pred coll]
  (let [step (fn [p c]
                 (when-let [s (seq c)]
                   (if (p (first s))
                     (cons (first s) (filter p (rest s)))
                     (recur p (rest s)))))]
    (lazy-seq (step pred coll))))


(defn remove
  "Returns a lazy sequence of the items in coll for which
  (pred item) returns false. pred must be free of side-effects."
  [pred coll]
  (filter (complement pred) coll))

(defn take
  "Returns a lazy sequence of the first n items in coll, or all items if
  there are fewer than n."
  [n coll]
  (lazy-seq
   (when (pos? n) 
     (when-let [s (seq coll)]
      (cons (first s) (take (dec n) (rest s)))))))

(defn take-while
  "Returns a lazy sequence of successive items from coll while
  (pred item) returns true. pred must be free of side-effects."
  [pred coll]
  (lazy-seq
   (when-let [s (seq coll)]
       (when (pred (first s))
         (cons (first s) (take-while pred (rest s)))))))

(defn drop
  "Returns a lazy sequence of all but the first n items in coll."
  [n coll]
  (let [step (fn [n coll]
               (let [s (seq coll)]
                 (if (and (pos? n) s)
                   (recur (dec n) (rest s))
                   s)))]
    (lazy-seq (step n coll))))

(defn drop-last
  "Return a lazy sequence of all but the last n (default 1) items in coll"
  ([s] (drop-last 1 s))
  ([n s] (map (fn [x _] x) s (drop n s))))

(defn drop-while
  "Returns a lazy sequence of the items in coll starting from the first
  item for which (pred item) returns nil."
  [pred coll]
  (let [step (fn [pred coll]
               (let [s (seq coll)]
                 (if (and s (pred (first s)))
                   (recur pred (rest s))
                   s)))]
    (lazy-seq (step pred coll))))

(defn cycle
  "Returns a lazy (infinite!) sequence of repetitions of the items in coll."  
  [coll] (lazy-seq 
          (when-let [s (seq coll)] 
              (concat s (cycle s)))))

(defn split-at
  "Returns a vector of [(take n coll) (drop n coll)]"
  [n coll]
    [(take n coll) (drop n coll)])

(defn split-with
  "Returns a vector of [(take-while pred coll) (drop-while pred coll)]"
  [pred coll]
    [(take-while pred coll) (drop-while pred coll)])

(defn repeat
  "Returns a lazy (infinite!, or length n if supplied) sequence of xs."
  ([x] (lazy-seq (cons x (repeat x))))
  ([n x] (take n (repeat x))))

(defn replicate
  "Returns a lazy seq of n xs."
  [n x] (take n (repeat x)))

(defn iterate
  "Returns a lazy sequence of x, (f x), (f (f x)) etc. f must be free of side-effects"
  [f x] (cons x (lazy-seq (iterate f (f x)))))

(defn range
  "Returns a lazy seq of nums from start (inclusive) to end
  (exclusive), by step, where start defaults to 0 and step to 1."
  ([end] (if (and (> end 0) (<= end (. Integer MAX_VALUE)))
           (new clojure.lang.Range 0 end)
           (take end (iterate inc 0))))
  ([start end] (if (and (< start end)
                        (>= start (. Integer MIN_VALUE))
                        (<= end (. Integer MAX_VALUE)))
                 (new clojure.lang.Range start end)
                 (take (- end start) (iterate inc start))))
  ([start end step]
   (take-while (partial (if (pos? step) > <) end) (iterate (partial + step) start))))

(defn merge
  "Returns a map that consists of the rest of the maps conj-ed onto
  the first.  If a key occurs in more than one map, the mapping from
  the latter (left-to-right) will be the mapping in the result."
  [& maps]
  (when (some identity maps)
    (reduce #(conj (or %1 {}) %2) maps)))

(defn merge-with
  "Returns a map that consists of the rest of the maps conj-ed onto
  the first.  If a key occurs in more than one map, the mapping(s)
  from the latter (left-to-right) will be combined with the mapping in
  the result by calling (f val-in-result val-in-latter)."
  [f & maps]
  (when (some identity maps)
    (let [merge-entry (fn [m e]
			(let [k (key e) v (val e)]
			  (if (contains? m k)
			    (assoc m k (f (m k) v))
			    (assoc m k v))))
          merge2 (fn [m1 m2]
		   (reduce merge-entry (or m1 {}) (seq m2)))]
      (reduce merge2 maps))))



(defn zipmap
  "Returns a map with the keys mapped to the corresponding vals."
  [keys vals]
    (loop [map {}
           ks (seq keys)
           vs (seq vals)]
      (if (and ks vs)
        (recur (assoc map (first ks) (first vs))
               (next ks)
               (next vs))
        map)))

(defn line-seq
  "Returns the lines of text from rdr as a lazy sequence of strings.
  rdr must implement java.io.BufferedReader."
  [#^java.io.BufferedReader rdr]
  (lazy-seq
   (let [line  (. rdr (readLine))]
     (when line
       (cons line (line-seq rdr))))))

(defn comparator
  "Returns an implementation of java.util.Comparator based upon pred."
  [pred]
    (fn [x y]
      (cond (pred x y) -1 (pred y x) 1 :else 0)))

(defn sort
  "Returns a sorted sequence of the items in coll. If no comparator is
  supplied, uses compare. comparator must
  implement java.util.Comparator."
  ([coll]
   (sort compare coll))
  ([#^java.util.Comparator comp coll]
   (if (seq coll)
     (let [a (to-array coll)]
       (. java.util.Arrays (sort a comp))
       (seq a))
     ())))

(defn sort-by
  "Returns a sorted sequence of the items in coll, where the sort
  order is determined by comparing (keyfn item).  If no comparator is
  supplied, uses compare. comparator must
  implement java.util.Comparator."
  ([keyfn coll]
   (sort-by keyfn compare coll))
  ([keyfn #^java.util.Comparator comp coll]
   (sort (fn [x y] (. comp (compare (keyfn x) (keyfn y)))) coll)))

(defn partition
  "Returns a lazy sequence of lists of n items each, at offsets step
  apart. If step is not supplied, defaults to n, i.e. the partitions
  do not overlap."
  ([n coll]
     (partition n n coll))
  ([n step coll]
   (lazy-seq
    (when-let [s (seq coll)]
      (let [p (take n s)]
        (when (= n (count p))
          (cons p (partition n step (drop step s)))))))))

;; evaluation

(defn eval
  "Evaluates the form data structure (not text!) and returns the result."
  [form] (. clojure.lang.Compiler (eval form)))

(defmacro doseq
  "Repeatedly executes body (presumably for side-effects) with
  bindings and filtering as provided by \"for\".  Does not retain
  the head of the sequence. Returns nil."
  [seq-exprs & body]
  (assert-args doseq
     (vector? seq-exprs) "a vector for its binding"
     (even? (count seq-exprs)) "an even number of forms in binding vector")
  (let [step (fn step [recform exprs]
               (if-not exprs
                 [true `(do ~@body)]
                 (let [k (first exprs)
                       v (second exprs)
                       seqsym (when-not (keyword? k) (gensym))
                       recform (if (keyword? k) recform `(recur (next ~seqsym)))
                       steppair (step recform (nnext exprs))
                       needrec (steppair 0)
                       subform (steppair 1)]
                   (cond
                     (= k :let) [needrec `(let ~v ~subform)]
                     (= k :while) [false `(when ~v
                                            ~subform
                                            ~@(when needrec [recform]))]
                     (= k :when) [false `(if ~v
                                           (do
                                             ~subform
                                             ~@(when needrec [recform]))
                                           ~recform)]
                     :else [true `(loop [~seqsym (seq ~v)]
                                    (when ~seqsym
                                      (let [~k (first ~seqsym)]
                                        ~subform
                                        ~@(when needrec [recform]))))]))))]
    (nth (step nil (seq seq-exprs)) 1)))

(defn dorun
  "When lazy sequences are produced via functions that have side
  effects, any effects other than those needed to produce the first
  element in the seq do not occur until the seq is consumed. dorun can
  be used to force any effects. Walks through the successive nexts of
  the seq, does not retain the head and returns nil."
  ([coll]
   (when (seq coll)
     (recur (next coll))))
  ([n coll]
   (when (and (seq coll) (pos? n))
     (recur (dec n) (next coll)))))

(defn doall
  "When lazy sequences are produced via functions that have side
  effects, any effects other than those needed to produce the first
  element in the seq do not occur until the seq is consumed. doall can
  be used to force any effects. Walks through the successive nexts of
  the seq, retains the head and returns it, thus causing the entire
  seq to reside in memory at one time."
  ([coll]
   (dorun coll)
   coll)
  ([n coll]
   (dorun n coll)
   coll))

(defn await
  "Blocks the current thread (indefinitely!) until all actions
  dispatched thus far, from this thread or agent, to the agent(s) have
  occurred."
  [& agents]
  (io! "await in transaction"
    (when *agent*
      (throw (new Exception "Can't await in agent action")))
    (let [latch (new java.util.concurrent.CountDownLatch (count agents))
          count-down (fn [agent] (. latch (countDown)) agent)]
      (doseq [agent agents]
        (send agent count-down))
      (. latch (await)))))

(defn await1 [#^clojure.lang.Agent a]
  (when (pos? (.getQueueCount a))
    (await a))
    a)

(defn await-for
  "Blocks the current thread until all actions dispatched thus
  far (from this thread or agent) to the agents have occurred, or the
  timeout (in milliseconds) has elapsed. Returns nil if returning due
  to timeout, non-nil otherwise."
  [timeout-ms & agents]
    (io! "await-for in transaction"
     (when *agent*
       (throw (new Exception "Can't await in agent action")))
     (let [latch (new java.util.concurrent.CountDownLatch (count agents))
           count-down (fn [agent] (. latch (countDown)) agent)]
       (doseq [agent agents]
           (send agent count-down))
       (. latch (await  timeout-ms (. java.util.concurrent.TimeUnit MILLISECONDS))))))

(defmacro dotimes
  "bindings => name n

  Repeatedly executes body (presumably for side-effects) with name
  bound to integers from 0 through n-1."
  [bindings & body]
  (assert-args dotimes
     (vector? bindings) "a vector for its binding"
     (= 2 (count bindings)) "exactly 2 forms in binding vector")
  (let [i (first bindings)
        n (second bindings)]
    `(let [n# (int ~n)]
       (loop [~i (int 0)]
         (when (< ~i n#)
           ~@body
           (recur (unchecked-inc ~i)))))))

(defn import
  "import-list => (package-symbol class-name-symbols*)

  For each name in class-name-symbols, adds a mapping from name to the
  class named by package.name to the current namespace. Use :import in the ns
  macro in preference to calling this directly."
  [& import-symbols-or-lists]
    (let [#^clojure.lang.Namespace ns *ns*]
      (doseq [spec import-symbols-or-lists]
        (if (symbol? spec)
          (let [n (name spec)
                dot (.lastIndexOf n (. clojure.lang.RT (intCast \.)))
                c (symbol (.substring n (inc dot)))]
            (. ns (importClass c (. clojure.lang.RT (classForName (name spec))))))
          (let [pkg (first spec)
                classes (next spec)]
            (doseq [c classes]
              (. ns (importClass c (. clojure.lang.RT (classForName (str pkg "." c)))))))))))


(defn into-array
  "Returns an array with components set to the values in aseq. The array's
  component type is type if provided, or the type of the first value in
  aseq if present, or Object. All values in aseq must be compatible with
  the component type. Class objects for the primitive types can be obtained
  using, e.g., Integer/TYPE."
  ([aseq]
     (clojure.lang.RT/seqToTypedArray (seq aseq)))
  ([type aseq]
     (clojure.lang.RT/seqToTypedArray type (seq aseq))))

(defn into
  "Returns a new coll consisting of to-coll with all of the items of
  from-coll conjoined."
  [to from]
    (let [ret to items (seq from)]
      (if items
        (recur (conj ret (first items)) (next items))
        ret)))

(defn #^{:private true}
  array [& items]
    (into-array items))

(defn #^Class class
  "Returns the Class of x"
  [#^Object x] (if (nil? x) x (. x (getClass))))

(defn type 
  "Returns the :type metadata of x, or its Class if none"
  [x]
  (or (:type (meta x)) (class x)))

(defn num
  "Coerce to Number"
  {:tag Number
   :inline (fn  [x] `(. clojure.lang.Numbers (num ~x)))}
  [x] (. clojure.lang.Numbers (num x)))

(defn int
  "Coerce to int"
  {:tag Integer
   :inline (fn  [x] `(. clojure.lang.RT (intCast ~x)))}
  [x] (. clojure.lang.RT (intCast x)))

(defn long
  "Coerce to long"
  {:tag Long
   :inline (fn  [x] `(. clojure.lang.RT (longCast ~x)))}
  [#^Number x] (. x (longValue)))

(defn float
  "Coerce to float"
  {:tag Float
   :inline (fn  [x] `(. clojure.lang.RT (floatCast ~x)))}
  [#^Number x] (. x (floatValue)))

(defn double
  "Coerce to double"
  {:tag Double
   :inline (fn  [x] `(. clojure.lang.RT (doubleCast ~x)))}
  [#^Number x] (. x (doubleValue)))

(defn short
  "Coerce to short"
  {:tag Short
   :inline (fn  [x] `(. clojure.lang.RT (shortCast ~x)))}
  [#^Number x] (. x (shortValue)))

(defn byte
  "Coerce to byte"
  {:tag Byte
   :inline (fn  [x] `(. clojure.lang.RT (byteCast ~x)))}
  [#^Number x] (. x (byteValue)))

(defn char
  "Coerce to char"
  {:tag Character
   :inline (fn  [x] `(. clojure.lang.RT (charCast ~x)))}
  [x] (. clojure.lang.RT (charCast x)))

(defn boolean
  "Coerce to boolean"
  {:tag Boolean
   :inline (fn  [x] `(. clojure.lang.RT (booleanCast ~x)))}
  [x] (if x true false))

(defn number?
  "Returns true if x is a Number"
  [x]
  (instance? Number x))

(defn integer?
  "Returns true if n is an integer"
  [n]
  (or (instance? Integer n)
      (instance? Long n)
      (instance? BigInteger n)
      (instance? Short n)
      (instance? Byte n)))

(defn mod
  "Modulus of num and div. Truncates toward negative infinity." 
  [num div] 
  (let [m (rem num div)] 
    (if (or (zero? m) (pos? (* num div))) 
      m 
      (+ m div))))

(defn ratio?
  "Returns true if n is a Ratio"
  [n] (instance? clojure.lang.Ratio n))

(defn decimal?
  "Returns true if n is a BigDecimal"
  [n] (instance? BigDecimal n))

(defn float?
  "Returns true if n is a floating point number"
  [n]
  (or (instance? Double n)
      (instance? Float n)))

(defn rational? [n]
  "Returns true if n is a rational number"
  (or (integer? n) (ratio? n) (decimal? n)))

(defn bigint
  "Coerce to BigInteger"
  {:tag BigInteger}
  [x] (cond
       (instance? BigInteger x) x
       (decimal? x) (.toBigInteger #^BigDecimal x)
       (number? x) (BigInteger/valueOf (long x))
       :else (BigInteger. x)))

(defn bigdec
  "Coerce to BigDecimal"
  {:tag BigDecimal}
  [x] (cond
       (decimal? x) x
       (float? x) (. BigDecimal valueOf (double x))
       (ratio? x) (/ (BigDecimal. (.numerator x)) (.denominator x))
       (instance? BigInteger x) (BigDecimal. #^BigInteger x)
       (number? x) (BigDecimal/valueOf (long x))
       :else (BigDecimal. x)))

(def #^{:private true} print-initialized false)

(defmulti print-method (fn [x writer] (type x)))
(defmulti print-dup (fn [x writer] (class x)))

(defn pr-on
  {:private true}
  [x w]
  (if *print-dup*
    (print-dup x w)
    (print-method x w))
  nil)

(defn pr
  "Prints the object(s) to the output stream that is the current value
  of *out*.  Prints the object(s), separated by spaces if there is
  more than one.  By default, pr and prn print in a way that objects
  can be read by the reader"
  ([] nil)
  ([x]
     (pr-on x *out*))
  ([x & more]
   (pr x)
   (. *out* (append \space))
   (apply pr more)))

(defn newline
  "Writes a newline to the output stream that is the current value of
  *out*"
  []
    (. *out* (append \newline))
    nil)

(defn flush
  "Flushes the output stream that is the current value of
  *out*"
  []
    (. *out* (flush))
    nil)

(defn prn
  "Same as pr followed by (newline). Observes *flush-on-newline*"
  [& more]
    (apply pr more)
    (newline)
    (when *flush-on-newline*
      (flush)))

(defn print
  "Prints the object(s) to the output stream that is the current value
  of *out*.  print and println produce output for human consumption."
  [& more]
    (binding [*print-readably* nil]
      (apply pr more)))

(defn println
  "Same as print followed by (newline)"
  [& more]
    (binding [*print-readably* nil]
      (apply prn more)))


(defn read
  "Reads the next object from stream, which must be an instance of
  java.io.PushbackReader or some derivee.  stream defaults to the
  current value of *in* ."
  ([]
   (read *in*))
  ([stream]
   (read stream true nil))
  ([stream eof-error? eof-value]
   (read stream eof-error? eof-value false))
  ([stream eof-error? eof-value recursive?]
   (. clojure.lang.LispReader (read stream (boolean eof-error?) eof-value recursive?))))

(defn read-line
  "Reads the next line from stream that is the current value of *in* ."
  []
  (if (instance? clojure.lang.LineNumberingPushbackReader *in*)
    (.readLine #^clojure.lang.LineNumberingPushbackReader *in*)
    (.readLine #^java.io.BufferedReader *in*)))

(defn read-string
  "Reads one object from the string s"
  [s] (clojure.lang.RT/readString s))

(defn subvec
  "Returns a persistent vector of the items in vector from
  start (inclusive) to end (exclusive).  If end is not supplied,
  defaults to (count vector). This operation is O(1) and very fast, as
  the resulting vector shares structure with the original and no
  trimming is done."
  ([v start]
   (subvec v start (count v)))
  ([v start end]
   (. clojure.lang.RT (subvec v start end))))

(defmacro with-open
  "bindings => [name init ...]

  Evaluates body in a try expression with names bound to the values
  of the inits, and a finally clause that calls (.close name) on each
  name in reverse order."
  [bindings & body]
  (assert-args with-open
     (vector? bindings) "a vector for its binding"
     (even? (count bindings)) "an even number of forms in binding vector")
  (cond
    (= (count bindings) 0) `(do ~@body)
    (symbol? (bindings 0)) `(let ~(subvec bindings 0 2)
                              (try
                                (with-open ~(subvec bindings 2) ~@body)
                                (finally
                                  (. ~(bindings 0) close))))
    :else (throw (IllegalArgumentException.
                   "with-open only allows Symbols in bindings"))))

(defmacro doto
  "Evaluates x then calls all of the methods and functions with the
  value of x supplied at the from of the given arguments.  The forms
  are evaluated in order.  Returns x.

  (doto (new java.util.HashMap) (.put \"a\" 1) (.put \"b\" 2))"
  [x & forms]
    (let [gx (gensym)]
      `(let [~gx ~x]
         ~@(map (fn [f]
                  (if (seq? f)
                    `(~(first f) ~gx ~@(next f))
                    `(~f ~gx)))
                forms)
         ~gx)))

(defmacro memfn
  "Expands into code that creates a fn that expects to be passed an
  object and any args and calls the named instance method on the
  object passing the args. Use when you want to treat a Java method as
  a first-class fn."
  [name & args]
  `(fn [target# ~@args]
     (. target# (~name ~@args))))

(defmacro time
  "Evaluates expr and prints the time it took.  Returns the value of
 expr."
  [expr]
  `(let [start# (. System (nanoTime))
         ret# ~expr]
     (prn (str "Elapsed time: " (/ (double (- (. System (nanoTime)) start#)) 1000000.0) " msecs"))
     ret#))



(import '(java.lang.reflect Array))

(defn alength
  "Returns the length of the Java array. Works on arrays of all
  types."
  {:inline (fn [a] `(. clojure.lang.RT (alength ~a)))}
  [array] (. clojure.lang.RT (alength array)))

(defn aclone
  "Returns a clone of the Java array. Works on arrays of known
  types."
  {:inline (fn [a] `(. clojure.lang.RT (aclone ~a)))}
  [array] (. clojure.lang.RT (aclone array)))

(defn aget
  "Returns the value at the index/indices. Works on Java arrays of all
  types."
  {:inline (fn [a i] `(. clojure.lang.RT (aget ~a ~i)))
   :inline-arities #{2}}
  ([array idx]
   (clojure.lang.Reflector/prepRet (. Array (get array idx))))
  ([array idx & idxs]
   (apply aget (aget array idx) idxs)))

(defn aset
  "Sets the value at the index/indices. Works on Java arrays of
  reference types. Returns val."
  {:inline (fn [a i v] `(. clojure.lang.RT (aset ~a ~i ~v)))
   :inline-arities #{3}}
  ([array idx val]
   (. Array (set array idx val))
   val)
  ([array idx idx2 & idxv]
   (apply aset (aget array idx) idx2 idxv)))

(defmacro
  #^{:private true}
  def-aset [name method coerce]
    `(defn ~name
       {:arglists '([~'array ~'idx ~'val] [~'array ~'idx ~'idx2 & ~'idxv])}
       ([array# idx# val#]
        (. Array (~method array# idx# (~coerce val#)))
        val#)
       ([array# idx# idx2# & idxv#]
        (apply ~name (aget array# idx#) idx2# idxv#))))

(def-aset
  #^{:doc "Sets the value at the index/indices. Works on arrays of int. Returns val."}
  aset-int setInt int)

(def-aset
  #^{:doc "Sets the value at the index/indices. Works on arrays of long. Returns val."}
  aset-long setLong long)

(def-aset
  #^{:doc "Sets the value at the index/indices. Works on arrays of boolean. Returns val."}
  aset-boolean setBoolean boolean)

(def-aset
  #^{:doc "Sets the value at the index/indices. Works on arrays of float. Returns val."}
  aset-float setFloat float)

(def-aset
  #^{:doc "Sets the value at the index/indices. Works on arrays of double. Returns val."}
  aset-double setDouble double)

(def-aset
  #^{:doc "Sets the value at the index/indices. Works on arrays of short. Returns val."}
  aset-short setShort short)

(def-aset
  #^{:doc "Sets the value at the index/indices. Works on arrays of byte. Returns val."}
  aset-byte setByte byte)

(def-aset
  #^{:doc "Sets the value at the index/indices. Works on arrays of char. Returns val."}
  aset-char setChar char)

(defn make-array
  "Creates and returns an array of instances of the specified class of
  the specified dimension(s).  Note that a class object is required.
  Class objects can be obtained by using their imported or
  fully-qualified name.  Class objects for the primitive types can be
  obtained using, e.g., Integer/TYPE."
  ([#^Class type len]
   (. Array (newInstance type (int len))))
  ([#^Class type dim & more-dims]
   (let [dims (cons dim more-dims)
         #^"[I" dimarray (make-array (. Integer TYPE)  (count dims))]
     (dotimes [i (alength dimarray)]
       (aset-int dimarray i (nth dims i)))
     (. Array (newInstance type dimarray)))))

(defn to-array-2d
  "Returns a (potentially-ragged) 2-dimensional array of Objects
  containing the contents of coll, which can be any Collection of any
  Collection."
  {:tag "[[Ljava.lang.Object;"}
  [#^java.util.Collection coll]
    (let [ret (make-array (. Class (forName "[Ljava.lang.Object;")) (. coll (size)))]
      (loop [i 0 xs (seq coll)]
        (when xs
          (aset ret i (to-array (first xs)))
          (recur (inc i) (next xs))))
      ret))

(defn macroexpand-1
  "If form represents a macro form, returns its expansion,
  else returns form."
  [form]
    (. clojure.lang.Compiler (macroexpand1 form)))

(defn macroexpand
  "Repeatedly calls macroexpand-1 on form until it no longer
  represents a macro form, then returns it.  Note neither
  macroexpand-1 nor macroexpand expand macros in subforms."
  [form]
    (let [ex (macroexpand-1 form)]
      (if (identical? ex form)
        form
        (macroexpand ex))))

(defn create-struct
  "Returns a structure basis object."
  [& keys]
    (. clojure.lang.PersistentStructMap (createSlotMap keys)))

(defmacro defstruct
  "Same as (def name (create-struct keys...))"
  [name & keys]
  `(def ~name (create-struct ~@keys)))

(defn struct-map
  "Returns a new structmap instance with the keys of the
  structure-basis. keyvals may contain all, some or none of the basis
  keys - where values are not supplied they will default to nil.
  keyvals can also contain keys not in the basis."
  [s & inits]
    (. clojure.lang.PersistentStructMap (create s inits)))

(defn struct
  "Returns a new structmap instance with the keys of the
  structure-basis. vals must be supplied for basis keys in order -
  where values are not supplied they will default to nil."
  [s & vals]
    (. clojure.lang.PersistentStructMap (construct s vals)))

(defn accessor
  "Returns a fn that, given an instance of a structmap with the basis,
  returns the value at the key.  The key must be in the basis. The
  returned function should be (slightly) more efficient than using
  get, but such use of accessors should be limited to known
  performance-critical areas."
  [s key]
    (. clojure.lang.PersistentStructMap (getAccessor s key)))

(defn load-reader
  "Sequentially read and evaluate the set of forms contained in the
  stream/file"
  [rdr] (. clojure.lang.Compiler (load rdr)))

(defn load-string
  "Sequentially read and evaluate the set of forms contained in the
  string"
  [s]
  (let [rdr (-> (java.io.StringReader. s)
                (clojure.lang.LineNumberingPushbackReader.))]
    (load-reader rdr)))

(defn set
  "Returns a set of the distinct elements of coll."
  [coll] (apply hash-set coll))

(defn #^{:private true}
  filter-key [keyfn pred amap]
    (loop [ret {} es (seq amap)]
      (if es
        (if (pred (keyfn (first es)))
          (recur (assoc ret (key (first es)) (val (first es))) (next es))
          (recur ret (next es)))
        ret)))

(defn find-ns
  "Returns the namespace named by the symbol or nil if it doesn't exist."
  [sym] (clojure.lang.Namespace/find sym))

(defn create-ns
  "Create a new namespace named by the symbol if one doesn't already
  exist, returns it or the already-existing namespace of the same
  name."
  [sym] (clojure.lang.Namespace/findOrCreate sym))

(defn remove-ns
  "Removes the namespace named by the symbol. Use with caution.
  Cannot be used to remove the clojure namespace."
  [sym] (clojure.lang.Namespace/remove sym))

(defn all-ns
  "Returns a sequence of all namespaces."
  [] (clojure.lang.Namespace/all))

(defn #^clojure.lang.Namespace the-ns
  "If passed a namespace, returns it. Else, when passed a symbol,
  returns the namespace named by it, throwing an exception if not
  found."
  [x]
  (if (instance? clojure.lang.Namespace x)
    x
    (or (find-ns x) (throw (Exception. (str "No namespace: " x " found"))))))

(defn ns-name
  "Returns the name of the namespace, a symbol."
  [ns]
  (.getName (the-ns ns)))

(defn ns-map
  "Returns a map of all the mappings for the namespace."
  [ns]
  (.getMappings (the-ns ns)))

(defn ns-unmap
  "Removes the mappings for the symbol from the namespace."
  [ns sym]
  (.unmap (the-ns ns) sym))

;(defn export [syms]
;  (doseq [sym syms]
;   (.. *ns* (intern sym) (setExported true))))

(defn ns-publics
  "Returns a map of the public intern mappings for the namespace."
  [ns]
  (let [ns (the-ns ns)]
    (filter-key val (fn [#^clojure.lang.Var v] (and (instance? clojure.lang.Var v)
                                 (= ns (.ns v))
                                 (.isPublic v)))
                (ns-map ns))))

(defn ns-imports
  "Returns a map of the import mappings for the namespace."
  [ns]
  (filter-key val (partial instance? Class) (ns-map ns)))

(defn refer
  "refers to all public vars of ns, subject to filters.
  filters can include at most one each of:

  :exclude list-of-symbols
  :only list-of-symbols
  :rename map-of-fromsymbol-tosymbol

  For each public interned var in the namespace named by the symbol,
  adds a mapping from the name of the var to the var to the current
  namespace.  Throws an exception if name is already mapped to
  something else in the current namespace. Filters can be used to
  select a subset, via inclusion or exclusion, or to provide a mapping
  to a symbol different from the var's name, in order to prevent
  clashes. Use :use in the ns macro in preference to calling this directly."
  [ns-sym & filters]
    (let [ns (or (find-ns ns-sym) (throw (new Exception (str "No namespace: " ns-sym))))
          fs (apply hash-map filters)
          nspublics (ns-publics ns)
          rename (or (:rename fs) {})
          exclude (set (:exclude fs))
          to-do (or (:only fs) (keys nspublics))]
      (doseq [sym to-do]
        (when-not (exclude sym)
          (let [v (nspublics sym)]
            (when-not v
              (throw (new java.lang.IllegalAccessError (str sym " is not public"))))
            (. *ns* (refer (or (rename sym) sym) v)))))))

(defn ns-refers
  "Returns a map of the refer mappings for the namespace."
  [ns]
  (let [ns (the-ns ns)]
    (filter-key val (fn [#^clojure.lang.Var v] (and (instance? clojure.lang.Var v)
                                 (not= ns (.ns v))))
                (ns-map ns))))

(defn ns-interns
  "Returns a map of the intern mappings for the namespace."
  [ns]
  (let [ns (the-ns ns)]
    (filter-key val (fn [#^clojure.lang.Var v] (and (instance? clojure.lang.Var v)
                                 (= ns (.ns v))))
                (ns-map ns))))

(defn alias
  "Add an alias in the current namespace to another
  namespace. Arguments are two symbols: the alias to be used, and
  the symbolic name of the target namespace. Use :as in the ns macro in preference
  to calling this directly."
  [alias namespace-sym]
  (.addAlias *ns* alias (find-ns namespace-sym)))

(defn ns-aliases
  "Returns a map of the aliases for the namespace."
  [ns]
  (.getAliases (the-ns ns)))

(defn ns-unalias
  "Removes the alias for the symbol from the namespace."
  [ns sym]
  (.removeAlias (the-ns ns) sym))

(defn take-nth
  "Returns a lazy seq of every nth item in coll."
  [n coll]
    (lazy-seq
     (when-let [s (seq coll)]
       (cons (first s) (take-nth n (drop n s))))))

(defn interleave
  "Returns a lazy seq of the first item in each coll, then the second
  etc."
  [& colls]
    (apply concat (apply map list colls)))

(defn var-get
  "Gets the value in the var object"
  [#^clojure.lang.Var x] (. x (get)))

(defn var-set
  "Sets the value in the var object to val. The var must be
 thread-locally bound."
  [#^clojure.lang.Var x val] (. x (set val)))

(defmacro with-local-vars
  "varbinding=> symbol init-expr

  Executes the exprs in a context in which the symbols are bound to
  vars with per-thread bindings to the init-exprs.  The symbols refer
  to the var objects themselves, and must be accessed with var-get and
  var-set"
  [name-vals-vec & body]
  (assert-args with-local-vars
     (vector? name-vals-vec) "a vector for its binding"
     (even? (count name-vals-vec)) "an even number of forms in binding vector")
  `(let [~@(interleave (take-nth 2 name-vals-vec)
                       (repeat '(. clojure.lang.Var (create))))]
     (. clojure.lang.Var (pushThreadBindings (hash-map ~@name-vals-vec)))
     (try
      ~@body
      (finally (. clojure.lang.Var (popThreadBindings))))))

(defn ns-resolve
  "Returns the var or Class to which a symbol will be resolved in the
  namespace, else nil.  Note that if the symbol is fully qualified,
  the var/Class to which it resolves need not be present in the
  namespace."
  [ns sym]
  (clojure.lang.Compiler/maybeResolveIn (the-ns ns) sym))

(defn resolve
  "same as (ns-resolve *ns* symbol)"
  [sym] (ns-resolve *ns* sym))

(defn array-map
  "Constructs an array-map."
  ([] (. clojure.lang.PersistentArrayMap EMPTY))
  ([& keyvals] (new clojure.lang.PersistentArrayMap (to-array keyvals))))

(defn nthnext
  "Returns the nth next of coll, (seq coll) when n is 0."
  [coll n]
    (loop [n n xs (seq coll)]
      (if (and xs (pos? n))
        (recur (dec n) (next xs))
        xs)))


;redefine let and loop  with destructuring
(defn destructure [bindings]
  (let [bmap (apply array-map bindings)
        pb (fn pb [bvec b v]
               (let [pvec
                     (fn [bvec b val]
                       (let [gvec (gensym "vec__")]
                         (loop [ret (-> bvec (conj gvec) (conj val))
                                n 0
                                bs b
                                seen-rest? false]
                           (if (seq bs)
                             (let [firstb (first bs)]
                               (cond
                                (= firstb '&) (recur (pb ret (second bs) (list `nthnext gvec n))
                                                     n
                                                     (nnext bs)
                                                     true)
                                (= firstb :as) (pb ret (second bs) gvec)
                                :else (if seen-rest?
                                        (throw (new Exception "Unsupported binding form, only :as can follow & parameter"))
                                        (recur (pb ret firstb  (list `nth gvec n nil))
                                               (inc n)
                                               (next bs)
                                               seen-rest?))))
                             ret))))
                     pmap
                     (fn [bvec b v]
                       (let [gmap (or (:as b) (gensym "map__"))
                             defaults (:or b)]
                         (loop [ret (-> bvec (conj gmap) (conj v))
                                bes (reduce
                                     (fn [bes entry]
                                       (reduce #(assoc %1 %2 ((val entry) %2))
                                               (dissoc bes (key entry))
                                               ((key entry) bes)))
                                     (dissoc b :as :or)
                                     {:keys #(keyword (str %)), :strs str, :syms #(list `quote %)})]
                           (if (seq bes)
                             (let [bb (key (first bes))
                                   bk (val (first bes))
                                   has-default (contains? defaults bb)]
                               (recur (pb ret bb (if has-default
                                                   (list `get gmap bk (defaults bb))
                                                   (list `get gmap bk)))
                                      (next bes)))
                             ret))))]
                 (cond
                  (symbol? b) (-> bvec (conj b) (conj v))
                  (vector? b) (pvec bvec b v)
                  (map? b) (pmap bvec b v)
                  :else (throw (new Exception (str "Unsupported binding form: " b))))))
        process-entry (fn [bvec b] (pb bvec (key b) (val b)))]
    (if (every? symbol? (keys bmap))
      bindings
      (reduce process-entry [] bmap))))

(defmacro let
  "Evaluates the exprs in a lexical context in which the symbols in
  the binding-forms are bound to their respective init-exprs or parts
  therein."
  [bindings & body]
  (assert-args let
     (vector? bindings) "a vector for its binding"
     (even? (count bindings)) "an even number of forms in binding vector")
  `(let* ~(destructure bindings) ~@body))

;redefine fn with destructuring
(defmacro fn
  "(fn name? [params* ] exprs*)
  (fn name? ([params* ] exprs*)+)

  params => positional-params* , or positional-params* & next-param
  positional-param => binding-form
  next-param => binding-form
  name => symbol

  Defines a function"
  [& sigs]
    (let [name (if (symbol? (first sigs)) (first sigs) nil)
          sigs (if name (next sigs) sigs)
          sigs (if (vector? (first sigs)) (list sigs) sigs)
          psig (fn [sig]
                 (let [[params & body] sig]
                   (if (every? symbol? params)
                     sig
                     (loop [params params
                            new-params []
                            lets []]
                       (if params
                         (if (symbol? (first params))
                           (recur (next params) (conj new-params (first params)) lets)
                           (let [gparam (gensym "p__")]
                             (recur (next params) (conj new-params gparam)
                                    (-> lets (conj (first params)) (conj gparam)))))
                         `(~new-params
                           (let ~lets
                             ~@body)))))))
          new-sigs (map psig sigs)]
      (with-meta
        (if name
          (list* 'fn* name new-sigs)
          (cons 'fn* new-sigs))
        *macro-meta*)))

(defmacro loop
  "Evaluates the exprs in a lexical context in which the symbols in
  the binding-forms are bound to their respective init-exprs or parts
  therein. Acts as a recur target."
  [bindings & body]
    (assert-args loop
      (vector? bindings) "a vector for its binding"
      (even? (count bindings)) "an even number of forms in binding vector")
    (let [db (destructure bindings)]
      (if (= db bindings)
        `(loop* ~bindings ~@body)
        (let [vs (take-nth 2 (drop 1 bindings))
              bs (take-nth 2 bindings)
              gs (map (fn [b] (if (symbol? b) b (gensym))) bs)
              bfs (reduce (fn [ret [b v g]]
                            (if (symbol? b)
                              (conj ret g v)
                              (conj ret g v b g)))
                          [] (map vector bs vs gs))]
          `(let ~bfs
             (loop* ~(vec (interleave gs gs))
               (let ~(vec (interleave bs gs))
                 ~@body)))))))

(defmacro when-first
  "bindings => x xs

  Same as (when (seq xs) (let [x (first xs)] body))"
  [bindings & body]
  (assert-args when-first
     (vector? bindings) "a vector for its binding"
     (= 2 (count bindings)) "exactly 2 forms in binding vector")
  (let [[x xs] bindings]
    `(when (seq ~xs)
       (let [~x (first ~xs)]
         ~@body))))

(defmacro lazy-cat
  "Expands to code which yields a lazy sequence of the concatenation
  of the supplied colls.  Each coll expr is not evaluated until it is
  needed. 

  (lazy-cat xs ys zs) === (concat (lazy-seq xs) (lazy-seq ys) (lazy-seq zs))" 
  [& colls]
  `(concat ~@(map #(list `lazy-seq %) colls)))

(defmacro for
  "List comprehension. Takes a vector of one or more
   binding-form/collection-expr pairs, each followed by zero or more
   modifiers, and yields a lazy sequence of evaluations of expr.
   Collections are iterated in a nested fashion, rightmost fastest,
   and nested coll-exprs can refer to bindings created in prior
   binding-forms.  Supported modifiers are: :let [binding-form expr ...],
   :while test, :when test.

  (take 100 (for [x (range 100000000) y (range 1000000) :while (< y x)]  [x y]))"
  [seq-exprs body-expr]
  (assert-args for
     (vector? seq-exprs) "a vector for its binding"
     (even? (count seq-exprs)) "an even number of forms in binding vector")
  (let [to-groups (fn [seq-exprs]
                    (reduce (fn [groups [k v]]
                              (if (keyword? k)
                                (conj (pop groups) (conj (peek groups) [k v]))
                                (conj groups [k v])))
                            [] (partition 2 seq-exprs)))
        err (fn [& msg] (throw (IllegalArgumentException. (apply str msg))))
        emit-bind (fn emit-bind [[[bind expr & mod-pairs]
                                  & [[_ next-expr] :as next-groups]]]
                    (let [giter (gensym "iter__")
                          gxs (gensym "s__")
                          do-mod (fn do-mod [[[k v :as pair] & etc]]
                                   (cond
                                     (= k :let) `(let ~v ~(do-mod etc))
                                     (= k :while) `(when ~v ~(do-mod etc))
                                     (= k :when) `(if ~v
                                                    ~(do-mod etc)
                                                    (recur (rest ~gxs)))
                                     (keyword? k) (err "Invalid 'for' keyword " k)
                                     next-groups
                                      `(let [iterys# ~(emit-bind next-groups)
                                             fs# (seq (iterys# ~next-expr))]
                                         (if fs#
                                           (concat fs# (~giter (rest ~gxs)))
                                           (recur (rest ~gxs))))
                                     :else `(cons ~body-expr
                                                  (~giter (rest ~gxs)))))]
                      `(fn ~giter [~gxs]
                         (lazy-seq
                           (loop [~gxs ~gxs]
                             (when-first [~bind ~gxs]
                               ~(do-mod mod-pairs)))))))]
    `(let [iter# ~(emit-bind (to-groups seq-exprs))]
        (iter# ~(second seq-exprs)))))

(defmacro comment
  "Ignores body, yields nil"
  [& body])

(defmacro with-out-str
  "Evaluates exprs in a context in which *out* is bound to a fresh
  StringWriter.  Returns the string created by any nested printing
  calls."
  [& body]
  `(let [s# (new java.io.StringWriter)]
     (binding [*out* s#]
       ~@body
       (str s#))))

(defmacro with-in-str
  "Evaluates body in a context in which *in* is bound to a fresh
  StringReader initialized with the string s."
  [s & body]
  `(with-open [s# (-> (java.io.StringReader. ~s) clojure.lang.LineNumberingPushbackReader.)]
     (binding [*in* s#]
       ~@body)))

(defn pr-str
  "pr to a string, returning it"
  {:tag String}
  [& xs]
    (with-out-str
     (apply pr xs)))

(defn prn-str
  "prn to a string, returning it"
  {:tag String}
  [& xs]
  (with-out-str
   (apply prn xs)))

(defn print-str
  "print to a string, returning it"
  {:tag String}
  [& xs]
    (with-out-str
     (apply print xs)))

(defn println-str
  "println to a string, returning it"
  {:tag String}
  [& xs]
    (with-out-str
     (apply println xs)))

(defmacro assert
  "Evaluates expr and throws an exception if it does not evaluate to
 logical true."
  [x]
  `(when-not ~x
     (throw (new Exception (str "Assert failed: " (pr-str '~x))))))

(defn test
  "test [v] finds fn at key :test in var metadata and calls it,
  presuming failure will throw exception"
  [v]
    (let [f (:test ^v)]
      (if f
        (do (f) :ok)
        :no-test)))

(defn re-pattern
  "Returns an instance of java.util.regex.Pattern, for use, e.g. in
  re-matcher."
  {:tag java.util.regex.Pattern}
  [s] (if (instance? java.util.regex.Pattern s)
        s
        (. java.util.regex.Pattern (compile s))))

(defn re-matcher
  "Returns an instance of java.util.regex.Matcher, for use, e.g. in
  re-find."
  {:tag java.util.regex.Matcher}
  [#^java.util.regex.Pattern re s]
    (. re (matcher s)))

(defn re-groups
  "Returns the groups from the most recent match/find. If there are no
  nested groups, returns a string of the entire match. If there are
  nested groups, returns a vector of the groups, the first element
  being the entire match."
  [#^java.util.regex.Matcher m]
    (let [gc  (. m (groupCount))]
      (if (zero? gc)
        (. m (group))
        (loop [ret [] c 0]
          (if (<= c gc)
            (recur (conj ret (. m (group c))) (inc c))
            ret)))))

(defn re-seq
  "Returns a lazy sequence of successive matches of pattern in string,
  using java.util.regex.Matcher.find(), each such match processed with
  re-groups."
  [#^java.util.regex.Pattern re s]
    (let [m (re-matcher re s)]
      ((fn step []
         (lazy-seq
          (when (. m (find))
            (cons (re-groups m) (step))))))))

(defn re-matches
  "Returns the match, if any, of string to pattern, using
  java.util.regex.Matcher.matches().  Uses re-groups to return the
  groups."
  [#^java.util.regex.Pattern re s]
    (let [m (re-matcher re s)]
      (when (. m (matches))
        (re-groups m))))


(defn re-find
  "Returns the next regex match, if any, of string to pattern, using
  java.util.regex.Matcher.find().  Uses re-groups to return the
  groups."
  ([#^java.util.regex.Matcher m]
   (when (. m (find))
     (re-groups m)))
  ([#^java.util.regex.Pattern re s]
   (let [m (re-matcher re s)]
     (re-find m))))

(defn rand
  "Returns a random floating point number between 0 (inclusive) and
  n (default 1) (exclusive)."
  ([] (. Math (random)))
  ([n] (* n (rand))))

(defn rand-int
  "Returns a random integer between 0 (inclusive) and n (exclusive)."
  [n] (int (rand n)))

(defmacro defn-
  "same as defn, yielding non-public def"
  [name & decls]
    (list* `defn (with-meta name (assoc (meta name) :private true)) decls))

(defn print-doc [v]
  (println "-------------------------")
  (println (str (ns-name (:ns ^v)) "/" (:name ^v)))
  (prn (:arglists ^v))
  (when (:macro ^v)
    (println "Macro"))
  (println " " (:doc ^v)))

(defn find-doc
  "Prints documentation for any var whose documentation or name
 contains a match for re-string-or-pattern"
  [re-string-or-pattern]
    (let [re  (re-pattern re-string-or-pattern)]
      (doseq [ns (all-ns)
              v (sort-by (comp :name meta) (vals (ns-interns ns)))
              :when (and (:doc ^v)
                         (or (re-find (re-matcher re (:doc ^v)))
                             (re-find (re-matcher re (str (:name ^v))))))]
               (print-doc v))))

(defn special-form-anchor
  "Returns the anchor tag on http://clojure.org/special_forms for the
  special form x, or nil"
  [x]
  (#{'. 'def 'do 'fn 'if 'let 'loop 'monitor-enter 'monitor-exit 'new
  'quote 'recur 'set! 'throw 'try 'var} x))

(defn syntax-symbol-anchor
  "Returns the anchor tag on http://clojure.org/special_forms for the
  special form that uses syntax symbol x, or nil"
  [x]
  ({'& 'fn 'catch 'try 'finally 'try} x))

(defn print-special-doc
  [name type anchor]
  (println "-------------------------")
  (println name)
  (println type)
  (println (str "  Please see http://clojure.org/special_forms#" anchor)))

(defn print-namespace-doc
  "Print the documentation string of a Namespace."
  [nspace]
  (println "-------------------------")
  (println (str (ns-name nspace)))
  (println " " (:doc ^nspace)))

(defmacro doc
  "Prints documentation for a var or special form given its name"
  [name]
  (cond
   (special-form-anchor `~name)
   `(print-special-doc '~name "Special Form" (special-form-anchor '~name))
   (syntax-symbol-anchor `~name)
   `(print-special-doc '~name "Syntax Symbol" (syntax-symbol-anchor '~name))
   :else
    (let [nspace (find-ns name)]
      (if nspace
        `(print-namespace-doc ~nspace)
        `(print-doc (var ~name))))))

 (defn tree-seq
  "Returns a lazy sequence of the nodes in a tree, via a depth-first walk.
   branch? must be a fn of one arg that returns true if passed a node
   that can have children (but may not).  children must be a fn of one
   arg that returns a sequence of the children. Will only be called on
   nodes for which branch? returns true. Root is the root node of the
  tree."  
   [branch? children root]
   (let [walk (fn walk [node]
                (lazy-seq
                 (cons node
                  (when (branch? node)
                    (mapcat walk (children node))))))]
     (walk root)))

(defn file-seq
  "A tree seq on java.io.Files"
  [dir]
    (tree-seq
     (fn [#^java.io.File f] (. f (isDirectory)))
     (fn [#^java.io.File d] (seq (. d (listFiles))))
     dir))

(defn xml-seq
  "A tree seq on the xml elements as per xml/parse"
  [root]
    (tree-seq
     (complement string?)
     (comp seq :content)
     root))

(defn special-symbol?
  "Returns true if s names a special form"
  [s]
    (contains? (. clojure.lang.Compiler specials) s))

(defn var?
  "Returns true if v is of type clojure.lang.Var"
  [v] (instance? clojure.lang.Var v))

(defn slurp
  "Reads the file named by f into a string and returns it."
  [#^String f]
  (with-open [r (new java.io.BufferedReader (new java.io.FileReader f))]
    (let [sb (new StringBuilder)]
      (loop [c (. r (read))]
        (if (neg? c)
          (str sb)
          (do
            (. sb (append (char c)))
            (recur (. r (read)))))))))

(defn subs
  "Returns the substring of s beginning at start inclusive, and ending
  at end (defaults to length of string), exclusive."
  ([#^String s start] (. s (substring start)))
  ([#^String s start end] (. s (substring start end))))

(defn max-key
  "Returns the x for which (k x), a number, is greatest."
  ([k x] x)
  ([k x y] (if (> (k x) (k y)) x y))
  ([k x y & more]
   (reduce #(max-key k %1 %2) (max-key k x y) more)))

(defn min-key
  "Returns the x for which (k x), a number, is least."
  ([k x] x)
  ([k x y] (if (< (k x) (k y)) x y))
  ([k x y & more]
   (reduce #(min-key k %1 %2) (min-key k x y) more)))

(defn distinct
  "Returns a lazy sequence of the elements of coll with duplicates removed"
  [coll]
    (let [step (fn step [xs seen]
                   (lazy-seq
                    ((fn [[f :as xs] seen]
                      (when-let [s (seq xs)]
                        (if (contains? seen f) 
                          (recur (rest s) seen)
                          (cons f (step (rest s) (conj seen f))))))
                     xs seen)))]
      (step coll #{})))



(defn replace
  "Given a map of replacement pairs and a vector/collection, returns a
  vector/seq with any elements = a key in smap replaced with the
  corresponding val in smap"
  [smap coll]
    (if (vector? coll)
      (reduce (fn [v i]
                (if-let [e (find smap (nth v i))]
                        (assoc v i (val e))
                        v))
              coll (range (count coll)))
      (map #(if-let [e (find smap %)] (val e) %) coll)))

(defmacro dosync
  "Runs the exprs (in an implicit do) in a transaction that encompasses
  exprs and any nested calls.  Starts a transaction if none is already
  running on this thread. Any uncaught exception will abort the
  transaction and flow out of dosync. The exprs may be run more than
  once, but any effects on Refs will be atomic."
  [& exprs]
  `(sync nil ~@exprs))

(defmacro with-precision
  "Sets the precision and rounding mode to be used for BigDecimal operations.

  Usage: (with-precision 10 (/ 1M 3))
  or:    (with-precision 10 :rounding HALF_DOWN (/ 1M 3))

  The rounding mode is one of CEILING, FLOOR, HALF_UP, HALF_DOWN,
  HALF_EVEN, UP, DOWN and UNNECESSARY; it defaults to HALF_UP."
  [precision & exprs]
    (let [[body rm] (if (= (first exprs) :rounding)
                      [(next (next exprs))
                       `((. java.math.RoundingMode ~(second exprs)))]
                      [exprs nil])]
      `(binding [*math-context* (java.math.MathContext. ~precision ~@rm)]
         ~@body)))

(defn bound-fn
  {:private true}
  [#^clojure.lang.Sorted sc test key]
  (fn [e]
    (test (.. sc comparator (compare (. sc entryKey e) key)) 0)))

(defn subseq
  "sc must be a sorted collection, test(s) one of <, <=, > or
  >=. Returns a seq of those entries with keys ek for
  which (test (.. sc comparator (compare ek key)) 0) is true"
  ([#^clojure.lang.Sorted sc test key]
   (let [include (bound-fn sc test key)]
     (if (#{> >=} test)
       (when-let [[e :as s] (. sc seqFrom key true)]
         (if (include e) s (next s)))
       (take-while include (. sc seq true)))))
  ([#^clojure.lang.Sorted sc start-test start-key end-test end-key]
   (when-let [[e :as s] (. sc seqFrom start-key true)]
     (take-while (bound-fn sc end-test end-key)
                 (if ((bound-fn sc start-test start-key) e) s (next s))))))

(defn rsubseq
  "sc must be a sorted collection, test(s) one of <, <=, > or
  >=. Returns a reverse seq of those entries with keys ek for
  which (test (.. sc comparator (compare ek key)) 0) is true"
  ([#^clojure.lang.Sorted sc test key]
   (let [include (bound-fn sc test key)]
     (if (#{< <=} test)
       (when-let [[e :as s] (. sc seqFrom key false)]
         (if (include e) s (next s)))
       (take-while include (. sc seq false)))))
  ([#^clojure.lang.Sorted sc start-test start-key end-test end-key]
   (when-let [[e :as s] (. sc seqFrom end-key false)]
     (take-while (bound-fn sc start-test start-key)
                 (if ((bound-fn sc end-test end-key) e) s (next s))))))

(defn repeatedly
  "Takes a function of no args, presumably with side effects, and returns an infinite
  lazy sequence of calls to it"
  [f] (lazy-seq (cons (f) (repeatedly f))))

(defn add-classpath
  "Adds the url (String or URL object) to the classpath per URLClassLoader.addURL"
  [url] (. clojure.lang.RT addURL url))



(defn hash
  "Returns the hash code of its argument"
  [x] (. clojure.lang.Util (hash x)))

(defn interpose
  "Returns a lazy seq of the elements of coll separated by sep"
  [sep coll] (drop 1 (interleave (repeat sep) coll)))

(defmacro definline
  "Experimental - like defmacro, except defines a named function whose
  body is the expansion, calls to which may be expanded inline as if
  it were a macro. Cannot be used with variadic (&) args." 
  [name & decl]
  (let [[pre-args [args expr]] (split-with (comp not vector?) decl)]
    `(do
       (defn ~name ~@pre-args ~args ~(apply (eval (list `fn args expr)) args))
       (alter-meta! (var ~name) assoc :inline (fn ~args ~expr))
       (var ~name))))

(defn empty
  "Returns an empty collection of the same category as coll, or nil"
  [coll]
  (when (instance? clojure.lang.IPersistentCollection coll)
    (.empty #^clojure.lang.IPersistentCollection coll)))

(defmacro amap
  "Maps an expression across an array a, using an index named idx, and
  return value named ret, initialized to a clone of a, then setting each element of
  ret to the evaluation of expr, returning the new array ret."
  [a idx ret expr]
  `(let [a# ~a
         ~ret (aclone a#)]
     (loop  [~idx (int 0)]
       (if (< ~idx  (alength a#))
         (do
           (aset ~ret ~idx ~expr)
           (recur (unchecked-inc ~idx)))
         ~ret))))

(defmacro areduce
  "Reduces an expression across an array a, using an index named idx,
  and return value named ret, initialized to init, setting ret to the evaluation of expr at
  each step, returning ret."
  [a idx ret init expr]
  `(let [a# ~a]
     (loop  [~idx (int 0) ~ret ~init]
       (if (< ~idx  (alength a#))
         (recur (unchecked-inc ~idx) ~expr)
         ~ret))))

(defn float-array
  "Creates an array of floats"
  {:inline (fn [& args] `(. clojure.lang.Numbers float_array ~@args))
   :inline-arities #{1 2}}
  ([size-or-seq] (. clojure.lang.Numbers float_array size-or-seq))
  ([size init-val-or-seq] (. clojure.lang.Numbers float_array size init-val-or-seq)))

(defn double-array
  "Creates an array of doubles"
  {:inline (fn [& args] `(. clojure.lang.Numbers double_array ~@args))
   :inline-arities #{1 2}}
  ([size-or-seq] (. clojure.lang.Numbers double_array size-or-seq))
  ([size init-val-or-seq] (. clojure.lang.Numbers double_array size init-val-or-seq)))

(defn int-array
  "Creates an array of ints"
  {:inline (fn [& args] `(. clojure.lang.Numbers int_array ~@args))
   :inline-arities #{1 2}}
  ([size-or-seq] (. clojure.lang.Numbers int_array size-or-seq))
  ([size init-val-or-seq] (. clojure.lang.Numbers int_array size init-val-or-seq)))

(defn long-array
  "Creates an array of ints"
  {:inline (fn [& args] `(. clojure.lang.Numbers long_array ~@args))
   :inline-arities #{1 2}}
  ([size-or-seq] (. clojure.lang.Numbers long_array size-or-seq))
  ([size init-val-or-seq] (. clojure.lang.Numbers long_array size init-val-or-seq)))

(definline floats
  "Casts to float[]"
  [xs] `(. clojure.lang.Numbers floats ~xs))

(definline ints
  "Casts to int[]"
  [xs] `(. clojure.lang.Numbers ints ~xs))

(definline doubles
  "Casts to double[]"
  [xs] `(. clojure.lang.Numbers doubles ~xs))

(definline longs
  "Casts to long[]"
  [xs] `(. clojure.lang.Numbers longs ~xs))

(import '(java.util.concurrent BlockingQueue LinkedBlockingQueue))

(defn seque
  "Creates a queued seq on another (presumably lazy) seq s. The queued
  seq will produce a concrete seq in the background, and can get up to
  n items ahead of the consumer. n-or-q can be an integer n buffer
  size, or an instance of java.util.concurrent BlockingQueue. Note
  that reading from a seque can block if the reader gets ahead of the
  producer."
  ([s] (seque 100 s))
  ([n-or-q s]
   (let [#^BlockingQueue q (if (instance? BlockingQueue n-or-q)
                             n-or-q
                             (LinkedBlockingQueue. (int n-or-q)))
         NIL (Object.) ;nil sentinel since LBQ doesn't support nils
         agt (agent (seq s))
         fill (fn [s]
                (try
                  (loop [[x & xs :as s] s]
                    (if s
                      (if (.offer q (if (nil? x) NIL x))
                        (recur xs)
                        s)
                      (.put q q))) ; q itself is eos sentinel
                  (catch Exception e
                    (.put q q)
                    (throw e))))
         drain (fn drain []
                 (lazy-seq
                  (let [x (.take q)]
                    (if (identical? x q) ;q itself is eos sentinel
                      (do @agt nil)  ;touch agent just to propagate errors
                      (do
                        (send-off agt fill)
                        (cons (if (identical? x NIL) nil x) (drain)))))))]
     (send-off agt fill)
     (drain))))

(defn class?
  "Returns true if x is an instance of Class"
  [x] (instance? Class x))

(defn alter-var-root
  "Atomically alters the root binding of var v by applying f to its
  current value plus any args"
  [#^clojure.lang.Var v f & args] (.alterRoot v f args))

(defn make-hierarchy
  "Creates a hierarchy object for use with derive, isa? etc."
  [] {:parents {} :descendants {} :ancestors {}})

(def #^{:private true}
     global-hierarchy (make-hierarchy))

(defn not-empty
  "If coll is empty, returns nil, else coll"
  [coll] (when (seq coll) coll))

(defn bases
  "Returns the immediate superclass and direct interfaces of c, if any"
  [#^Class c]
  (let [i (.getInterfaces c)
        s (.getSuperclass c)]
    (not-empty
     (if s (cons s i) i))))

(defn supers
  "Returns the immediate and indirect superclasses and interfaces of c, if any"
  [#^Class class]
  (loop [ret (set (bases class)) cs ret]
    (if (seq cs)
      (let [c (first cs) bs (bases c)]
        (recur (into ret bs) (into (disj cs c) bs)))
      (not-empty ret))))

(defn isa?
  "Returns true if (= child parent), or child is directly or indirectly derived from
  parent, either via a Java type inheritance relationship or a
  relationship established via derive. h must be a hierarchy obtained
  from make-hierarchy, if not supplied defaults to the global
  hierarchy"
  ([child parent] (isa? global-hierarchy child parent))
  ([h child parent]
   (or (= child parent)
       (and (class? parent) (class? child)
            (. #^Class parent isAssignableFrom child))
       (contains? ((:ancestors h) child) parent)
       (and (class? child) (some #(contains? ((:ancestors h) %) parent) (supers child)))
       (and (vector? parent) (vector? child)
            (= (count parent) (count child))
            (loop [ret true i 0]
              (if (or (not ret) (= i (count parent)))
                ret
                (recur (isa? h (child i) (parent i)) (inc i))))))))

(defn parents
  "Returns the immediate parents of tag, either via a Java type
  inheritance relationship or a relationship established via derive. h
  must be a hierarchy obtained from make-hierarchy, if not supplied
  defaults to the global hierarchy"
  ([tag] (parents global-hierarchy tag))
  ([h tag] (not-empty
            (let [tp (get (:parents h) tag)]
              (if (class? tag)
                (into (set (bases tag)) tp)
                tp)))))

(defn ancestors
  "Returns the immediate and indirect parents of tag, either via a Java type
  inheritance relationship or a relationship established via derive. h
  must be a hierarchy obtained from make-hierarchy, if not supplied
  defaults to the global hierarchy"
  ([tag] (ancestors global-hierarchy tag))
  ([h tag] (not-empty
            (let [ta (get (:ancestors h) tag)]
              (if (class? tag)
                (let [superclasses (set (supers tag))]
                  (reduce into superclasses
                    (cons ta
                          (map #(get (:ancestors h) %) superclasses))))
                ta)))))

(defn descendants
  "Returns the immediate and indirect children of tag, through a
  relationship established via derive. h must be a hierarchy obtained
  from make-hierarchy, if not supplied defaults to the global
  hierarchy. Note: does not work on Java type inheritance
  relationships."
  ([tag] (descendants global-hierarchy tag))
  ([h tag] (if (class? tag)
             (throw (java.lang.UnsupportedOperationException. "Can't get descendants of classes"))
             (not-empty (get (:descendants h) tag)))))

(defn derive
  "Establishes a parent/child relationship between parent and
  tag. Parent must be a namespace-qualified symbol or keyword and
  child can be either a namespace-qualified symbol or keyword or a
  class. h must be a hierarchy obtained from make-hierarchy, if not
  supplied defaults to, and modifies, the global hierarchy."
  ([tag parent]
   (assert (namespace parent))
   (assert (or (class? tag) (and (instance? clojure.lang.Named tag) (namespace tag))))

   (alter-var-root #'global-hierarchy derive tag parent) nil)
  ([h tag parent]
   (assert (not= tag parent))
   (assert (or (class? tag) (instance? clojure.lang.Named tag)))
   (assert (instance? clojure.lang.Named parent))

   (let [tp (:parents h)
         td (:descendants h)
         ta (:ancestors h)
         tf (fn [m source sources target targets]
              (reduce (fn [ret k]
                        (assoc ret k
                               (reduce conj (get targets k #{}) (cons target (targets target)))))
                      m (cons source (sources source))))]
     (or
      (when-not (contains? (tp tag) parent)
        (when (contains? (ta tag) parent)
          (throw (Exception. (print-str tag "already has" parent "as ancestor"))))
        (when (contains? (ta parent) tag)
          (throw (Exception. (print-str "Cyclic derivation:" parent "has" tag "as ancestor"))))
        {:parents (assoc (:parents h) tag (conj (get tp tag #{}) parent))
         :ancestors (tf (:ancestors h) tag td parent ta)
         :descendants (tf (:descendants h) parent ta tag td)})
      h))))

(defn underive
  "Removes a parent/child relationship between parent and
  tag. h must be a hierarchy obtained from make-hierarchy, if not
  supplied defaults to, and modifies, the global hierarchy."
  ([tag parent] (alter-var-root #'global-hierarchy underive tag parent) nil)
  ([h tag parent]
   (let [tp (:parents h)
         td (:descendants h)
         ta (:ancestors h)
         tf (fn [m source sources target targets]
              (reduce
               (fn [ret k]
                 (assoc ret k
                        (reduce disj (get targets k) (cons target (targets target)))))
               m (cons source (sources source))))]
     (if (contains? (tp tag) parent)
       {:parent (assoc (:parents h) tag (disj (get tp tag) parent))
        :ancestors (tf (:ancestors h) tag td parent ta)
        :descendants (tf (:descendants h) parent ta tag td)}
       h))))


(defn distinct?
  "Returns true if no two of the arguments are ="
  {:tag Boolean}
  ([x] true)
  ([x y] (not (= x y)))
  ([x y & more]
   (if (not= x y)
     (loop [s #{x y} [x & etc :as xs] more]
       (if xs
         (if (contains? s x)
           false
           (recur (conj s x) etc))
         true))
     false)))

(defn resultset-seq
  "Creates and returns a lazy sequence of structmaps corresponding to
  the rows in the java.sql.ResultSet rs"
  [#^java.sql.ResultSet rs]
    (let [rsmeta (. rs (getMetaData))
          idxs (range 1 (inc (. rsmeta (getColumnCount))))
          keys (map (comp keyword #(.toLowerCase #^String %))
                    (map (fn [i] (. rsmeta (getColumnLabel i))) idxs))
          check-keys
                (or (apply distinct? keys)
                    (throw (Exception. "ResultSet must have unique column labels")))
          row-struct (apply create-struct keys)
          row-values (fn [] (map (fn [#^Integer i] (. rs (getObject i))) idxs))
          rows (fn thisfn []
                   (lazy-seq
                    (when (. rs (next))
                      (cons (apply struct row-struct (row-values)) (thisfn)))))]
      (rows)))

(defn iterator-seq
  "Returns a seq on a java.util.Iterator. Note that most collections
  providing iterators implement Iterable and thus support seq directly."
  [iter]
  (clojure.lang.IteratorSeq/create iter))

(defn enumeration-seq
  "Returns a seq on a java.util.Enumeration"
  [e]
  (clojure.lang.EnumerationSeq/create e))

(defn format
  "Formats a string using java.lang.String.format, see java.util.Formatter for format
  string syntax"
  {:tag String}
  [fmt & args]
  (String/format fmt (to-array args)))

(defn printf
  "Prints formatted output, as per format"
  [fmt & args]
  (print (apply format fmt args)))

(def gen-class)

(defmacro ns
  "Sets *ns* to the namespace named by name (unevaluated), creating it
  if needed.  references can be zero or more of: (:refer-clojure ...)
  (:require ...) (:use ...) (:import ...) (:load ...) (:gen-class)
  with the syntax of refer-clojure/require/use/import/load/gen-class
  respectively, except the arguments are unevaluated and need not be
  quoted. (:gen-class ...), when supplied, defaults to :name
  corresponding to the ns name, :main true, :impl-ns same as ns, and
  :init-impl-ns true. All options of gen-class are
  supported. The :gen-class directive is ignored when not
  compiling. If :gen-class is not supplied, when compiled only an
  nsname__init.class will be generated. If :refer-clojure is not used, a
  default (refer 'clojure) is used.  Use of ns is preferred to
  individual calls to in-ns/require/use/import:

  (ns foo.bar
    (:refer-clojure :exclude [ancestors printf])
    (:require (clojure.contrib sql sql.tests))
    (:use (my.lib this that))
    (:import (java.util Date Timer Random)
              (java.sql Connection Statement)))"

  [name & references]
  (let [process-reference
        (fn [[kname & args]]
          `(~(symbol "clojure.core" (clojure.core/name kname))
             ~@(map #(list 'quote %) args)))
        docstring  (when (string? (first references)) (first references))
        references (if docstring (next references) references)
        name (if docstring
               (with-meta name (assoc (meta name)
                                      :doc docstring))
               name)
        gen-class-clause (first (filter #(= :gen-class (first %)) references))
        gen-class-call
          (when gen-class-clause
            (list* `gen-class :name (.replace (str name) \- \_) :impl-ns name :main true (next gen-class-clause)))
        references (remove #(= :gen-class (first %)) references)]
    `(do
       (clojure.core/in-ns '~name)
       ~@(when gen-class-call (list gen-class-call))
       ~@(when (and (not= name 'clojure.core) (not-any? #(= :refer-clojure (first %)) references))
           `((clojure.core/refer '~'clojure.core)))
       ~@(map process-reference references))))

(defmacro refer-clojure
  "Same as (refer 'clojure.core <filters>)"
  [& filters]
  `(clojure.core/refer '~'clojure.core ~@filters))

(defmacro defonce
  "defs name to have the root value of the expr iff the named var has no root value,
  else expr is unevaluated"
  [name expr]
  `(let [v# (def ~name)]
     (when-not (.hasRoot v#)
       (def ~name ~expr))))

;;;;;;;;;;; require/use/load, contributed by Stephen C. Gilardi ;;;;;;;;;;;;;;;;;;

(defonce
  #^{:private true
     :doc "A ref to a sorted set of symbols representing loaded libs"}
  *loaded-libs* (ref (sorted-set)))

(defonce
  #^{:private true
     :doc "the set of paths currently being loaded by this thread"}
  *pending-paths* #{})

(defonce
  #^{:private true :doc
     "True while a verbose load is pending"}
  *loading-verbosely* false)

(defn- throw-if
  "Throws an exception with a message if pred is true"
  [pred fmt & args]
  (when pred
    (let [#^String message (apply format fmt args)
          exception (Exception. message)
          raw-trace (.getStackTrace exception)
          boring? #(not= (.getMethodName #^StackTraceElement %) "doInvoke")
          trace (into-array (drop 2 (drop-while boring? raw-trace)))]
      (.setStackTrace exception trace)
      (throw exception))))

(defn- libspec?
  "Returns true if x is a libspec"
  [x]
  (or (symbol? x)
      (and (vector? x)
           (or
            (nil? (second x))
            (keyword? (second x))))))

(defn- prependss
  "Prepends a symbol or a seq to coll"
  [x coll]
  (if (symbol? x)
    (cons x coll)
    (concat x coll)))

(defn- root-resource
  "Returns the root directory path for a lib"
  {:tag String}
  [lib]
  (str \/
       (.. (name lib)
           (replace \- \_)
           (replace \. \/))))

(defn- root-directory
  "Returns the root resource path for a lib"
  [lib]
  (let [d (root-resource lib)]
    (subs d 0 (.lastIndexOf d "/"))))

(def load)

(defn- load-one
  "Loads a lib given its name. If need-ns, ensures that the associated
  namespace exists after loading. If require, records the load so any
  duplicate loads can be skipped."
  [lib need-ns require]
  (load (root-resource lib))
  (throw-if (and need-ns (not (find-ns lib)))
            "namespace '%s' not found after loading '%s'"
            lib (root-resource lib))
  (when require
    (dosync
     (commute *loaded-libs* conj lib))))

(defn- load-all
  "Loads a lib given its name and forces a load of any libs it directly or
  indirectly loads. If need-ns, ensures that the associated namespace
  exists after loading. If require, records the load so any duplicate loads
  can be skipped."
  [lib need-ns require]
  (dosync
   (commute *loaded-libs* #(reduce conj %1 %2)
            (binding [*loaded-libs* (ref (sorted-set))]
              (load-one lib need-ns require)
              @*loaded-libs*))))

(defn- load-lib
  "Loads a lib with options"
  [prefix lib & options]
  (throw-if (and prefix (pos? (.indexOf (name lib) (int \.))))
            "lib names inside prefix lists must not contain periods")
  (let [lib (if prefix (symbol (str prefix \. lib)) lib)
        opts (apply hash-map options)
        {:keys [as reload reload-all require use verbose]} opts
        loaded (contains? @*loaded-libs* lib)
        load (cond reload-all
                   load-all
                   (or reload (not require) (not loaded))
                   load-one)
        need-ns (or as use)
        filter-opts (select-keys opts '(:exclude :only :rename))]
    (binding [*loading-verbosely* (or *loading-verbosely* verbose)]
      (if load
        (load lib need-ns require)
        (throw-if (and need-ns (not (find-ns lib)))
                  "namespace '%s' not found" lib))
      (when (and need-ns *loading-verbosely*)
        (printf "(clojure.core/in-ns '%s)\n" (ns-name *ns*)))
      (when as
        (when *loading-verbosely*
          (printf "(clojure.core/alias '%s '%s)\n" as lib))
        (alias as lib))
      (when use
        (when *loading-verbosely*
          (printf "(clojure.core/refer '%s" lib)
          (doseq [opt filter-opts]
            (printf " %s '%s" (key opt) (print-str (val opt))))
          (printf ")\n"))
        (apply refer lib (mapcat seq filter-opts))))))

(defn- load-libs
  "Loads libs, interpreting libspecs, prefix lists, and flags for
  forwarding to load-lib"
  [& args]
  (let [flags (filter keyword? args)
        opts (interleave flags (repeat true))
        args (filter (complement keyword?) args)]
    (doseq [arg args]
      (if (libspec? arg)
        (apply load-lib nil (prependss arg opts))
        (let [[prefix & args] arg]
          (throw-if (nil? prefix) "prefix cannot be nil")
          (doseq [arg args]
            (apply load-lib prefix (prependss arg opts))))))))

;; Public

(defn require
  "Loads libs, skipping any that are already loaded. Each argument is
  either a libspec that identifies a lib, a prefix list that identifies
  multiple libs whose names share a common prefix, or a flag that modifies
  how all the identified libs are loaded. Use :require in the ns macro
  in preference to calling this directly.

  Libs

  A 'lib' is a named set of resources in classpath whose contents define a
  library of Clojure code. Lib names are symbols and each lib is associated
  with a Clojure namespace and a Java package that share its name. A lib's
  name also locates its root directory within classpath using Java's
  package name to classpath-relative path mapping. All resources in a lib
  should be contained in the directory structure under its root directory.
  All definitions a lib makes should be in its associated namespace.

  'require loads a lib by loading its root resource. The root resource path
  is derived from the root directory path by repeating its last component
  and appending '.clj'. For example, the lib 'x.y.z has root directory
  <classpath>/x/y/z; root resource <classpath>/x/y/z/z.clj. The root
  resource should contain code to create the lib's namespace and load any
  additional lib resources.

  Libspecs

  A libspec is a lib name or a vector containing a lib name followed by
  options expressed as sequential keywords and arguments.

  Recognized options: :as
  :as takes a symbol as its argument and makes that symbol an alias to the
    lib's namespace in the current namespace.

  Prefix Lists

  It's common for Clojure code to depend on several libs whose names have
  the same prefix. When specifying libs, prefix lists can be used to reduce
  repetition. A prefix list contains the shared prefix followed by libspecs
  with the shared prefix removed from the lib names. After removing the
  prefix, the names that remain must not contain any periods.

  Flags

  A flag is a keyword.
  Recognized flags: :reload, :reload-all, :verbose
  :reload forces loading of all the identified libs even if they are
    already loaded
  :reload-all implies :reload and also forces loading of all libs that the
    identified libs directly or indirectly load via require or use
  :verbose triggers printing information about each load, alias, and refer"

  [& args]
  (apply load-libs :require args))

(defn use
  "Like 'require, but also refers to each lib's namespace using
  clojure.core/refer. Use :use in the ns macro in preference to calling
  this directly.

  'use accepts additional options in libspecs: :exclude, :only, :rename.
  The arguments and semantics for :exclude, :only, and :rename are the same
  as those documented for clojure.core/refer."
  [& args] (apply load-libs :require :use args))

(defn loaded-libs
  "Returns a sorted set of symbols naming the currently loaded libs"
  [] @*loaded-libs*)

(defn load
  "Loads Clojure code from resources in classpath. A path is interpreted as
  classpath-relative if it begins with a slash or relative to the root
  directory for the current namespace otherwise."
  [& paths]
  (doseq [#^String path paths]
    (let [#^String path (if (.startsWith path "/")
                          path
                          (str (root-directory (ns-name *ns*)) \/ path))]
      (when *loading-verbosely*
        (printf "(clojure.core/load \"%s\")\n" path)
        (flush))
;      (throw-if (*pending-paths* path)
;                "cannot load '%s' again while it is loading"
;                path)
      (when-not (*pending-paths* path)
        (binding [*pending-paths* (conj *pending-paths* path)]
          (clojure.lang.RT/load  (.substring path 1)))))))

(defn compile
  "Compiles the namespace named by the symbol lib into a set of
  classfiles. The source for the lib must be in a proper
  classpath-relative directory. The output files will go into the
  directory specified by *compile-path*, and that directory too must
  be in the classpath."
  [lib]
  (binding [*compile-files* true]
    (load-one lib true true))
  lib)

;;;;;;;;;;;;; nested associative ops ;;;;;;;;;;;

(defn get-in
  "returns the value in a nested associative structure, where ks is a sequence of keys"
  [m ks]
  (reduce get m ks))

(defn assoc-in
  "Associates a value in a nested associative structure, where ks is a
  sequence of keys and v is the new value and returns a new nested structure.
  If any levels do not exist, hash-maps will be created."
  [m [k & ks] v]
  (if ks
    (assoc m k (assoc-in (get m k) ks v))
    (assoc m k v)))

(defn update-in
  "'Updates' a value in a nested associative structure, where ks is a
  sequence of keys and f is a function that will take the old value
  and any supplied args and return the new value, and returns a new
  nested structure.  If any levels do not exist, hash-maps will be
  created."
  ([m [k & ks] f & args]
   (if ks
     (assoc m k (apply update-in (get m k) ks f args))
     (assoc m k (apply f (get m k) args)))))


(defn empty?
  "Returns true if coll has no items - same as (not (seq coll)).
  Please use the idiom (seq x) rather than (not (empty? x))"
  [coll] (not (seq coll)))

(defn coll?
  "Returns true if x implements IPersistentCollection"
  [x] (instance? clojure.lang.IPersistentCollection x))

(defn list?
  "Returns true if x implements IPersistentList"
  [x] (instance? clojure.lang.IPersistentList x))

(defn set?
  "Returns true if x implements IPersistentSet"
  [x] (instance? clojure.lang.IPersistentSet x))

(defn ifn?
  "Returns true if x implements IFn. Note that many data structures
  (e.g. sets and maps) implement IFn"
  [x] (instance? clojure.lang.IFn x))

(defn fn?
  "Returns true if x implements Fn, i.e. is an object created via fn."
  [x] (instance? clojure.lang.Fn x))


(defn associative?
 "Returns true if coll implements Associative"
  [coll] (instance? clojure.lang.Associative coll))

(defn sequential?
 "Returns true if coll implements Sequential"
  [coll] (instance? clojure.lang.Sequential coll))

(defn sorted?
 "Returns true if coll implements Sorted"
  [coll] (instance? clojure.lang.Sorted coll))

(defn counted?
 "Returns true if coll implements count in constant time"
  [coll] (instance? clojure.lang.Counted coll))

(defn reversible?
 "Returns true if coll implements Reversible"
  [coll] (instance? clojure.lang.Reversible coll))

(def
 #^{:doc "bound in a repl thread to the most recent value printed"}
 *1)

(def
 #^{:doc "bound in a repl thread to the second most recent value printed"}
 *2)

(def
 #^{:doc "bound in a repl thread to the third most recent value printed"}
 *3)

(def
 #^{:doc "bound in a repl thread to the most recent exception caught by the repl"}
 *e)

(defmacro declare
  "defs the supplied var names with no bindings, useful for making forward declarations."
  [& names] `(do ~@(map #(list 'def %) names)))

(defn trampoline
  "trampoline can be used to convert algorithms requiring mutual
  recursion without stack consumption. Calls f with supplied args, if
  any. If f returns a fn, calls that fn with no arguments, and
  continues to repeat, until the return value is not a fn, then
  returns that non-fn value. Note that if you want to return a fn as a
  final value, you must wrap it in some data structure and unpack it
  after trampoline returns."
  ([f]
     (let [ret (f)]
       (if (fn? ret)
         (recur ret)
         ret)))
  ([f & args]
     (trampoline #(apply f args))))

(defn intern
  "Finds or creates a var named by the symbol name in the namespace
  ns (which can be a symbol or a namespace), setting its root binding
  to val if supplied. The namespace must exist. The var will adopt any
  metadata from the name symbol.  Returns the var."
  ([ns #^clojure.lang.Symbol name]
     (let [v (clojure.lang.Var/intern (the-ns ns) name)]
       (when ^name (.setMeta v ^name))
       v))
  ([ns name val]
     (let [v (clojure.lang.Var/intern (the-ns ns) name val)]
       (when ^name (.setMeta v ^name))
       v)))

(defmacro while
  "Repeatedly executes body while test expression is true. Presumes
  some side-effect will cause test to become false/nil. Returns nil"
  [test & body]
  `(loop []
     (when ~test
       ~@body
       (recur))))

(defn memoize
  "Returns a memoized version of a referentially transparent function. The
  memoized version of the function keeps a cache of the mapping from arguments
  to results and, when calls with the same arguments are repeated often, has
  higher performance at the expense of higher memory use."
  [f]
  (let [mem (atom {})]
    (fn [& args]
      (if-let [e (find @mem args)]
        (val e)
        (let [ret (apply f args)]
          (swap! mem assoc args ret)
          ret)))))

(defmacro condp
  "Takes a binary predicate, an expression, and a set of clauses.
  Each clause can take the form of either:

  test-expr result-expr

  test-expr :>> result-fn

  Note :>> is an ordinary keyword.

  For each clause, (pred test-expr expr) is evaluated. If it returns
  logical true, the clause is a match. If a binary clause matches, the
  result-expr is returned, if a ternary clause matches, its result-fn,
  which must be a unary function, is called with the result of the
  predicate as its argument, the result of that call being the return
  value of condp. A single default expression can follow the clauses,
  and its value will be returned if no clause matches. If no default
  expression is provided and no clause matches, an
  IllegalArgumentException is thrown."

  [pred expr & clauses]
  (let [gpred (gensym "pred__")
        gexpr (gensym "expr__")
        emit (fn emit [pred expr args]
               (let [[[a b c :as clause] more]
                       (split-at (if (= :>> (second args)) 3 2) args)
                       n (count clause)]
                 (cond
                  (= 0 n) `(throw (IllegalArgumentException. (str "No matching clause: " ~expr)))
                  (= 1 n) a
                  (= 2 n) `(if (~pred ~a ~expr)
                             ~b
                             ~(emit pred expr more))
                  :else `(if-let [p# (~pred ~a ~expr)]
                           (~c p#)
                           ~(emit pred expr more)))))
        gres (gensym "res__")]
    `(let [~gpred ~pred
           ~gexpr ~expr]
       ~(emit gpred gexpr clauses))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; var documentation ;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmacro add-doc {:private true} [name docstring]
  `(alter-meta! (var ~name)  assoc :doc ~docstring))

(add-doc *file*
  "The path of the file being evaluated, as a String.

  Evaluates to nil when there is no file, eg. in the REPL.")

(add-doc *command-line-args*
  "A sequence of the supplied command line arguments, or nil if
  none were supplied")

(add-doc *warn-on-reflection*
  "When set to true, the compiler will emit warnings when reflection is
  needed to resolve Java method calls or field accesses.

  Defaults to false.")

(add-doc *compile-path*
  "Specifies the directory where 'compile' will write out .class
  files. This directory must be in the classpath for 'compile' to
  work.

  Defaults to \"classes\"")

(add-doc *compile-files*
  "Set to true when compiling files, false otherwise.")

(add-doc *ns*
  "A clojure.lang.Namespace object representing the current namespace.")

(add-doc *in*
  "A java.io.Reader object representing standard input for read operations.

  Defaults to System/in, wrapped in a LineNumberingPushbackReader")

(add-doc *out*
  "A java.io.Writer object representing standard output for print operations.

  Defaults to System/out")

(add-doc *err*
  "A java.io.Writer object representing standard error for print operations.

  Defaults to System/err, wrapped in a PrintWriter")

(add-doc *flush-on-newline*
  "When set to true, output will be flushed whenever a newline is printed.

  Defaults to true.")

(add-doc *print-meta*
  "If set to logical true, when printing an object, its metadata will also
  be printed in a form that can be read back by the reader.

  Defaults to false.")

(add-doc *print-dup*
  "When set to logical true, objects will be printed in a way that preserves
  their type when read in later.

  Defaults to false.")

(add-doc *print-readably*
  "When set to logical false, strings and characters will be printed with
  non-alphanumeric characters converted to the appropriate escape sequences.

  Defaults to true")

(add-doc *read-eval*
  "When set to logical false, the EvalReader (#=(...)) is disabled in the 
  read/load in the thread-local binding.
  Example: (binding [*read-eval* false] (read-string \"#=(eval (def x 3))\"))

  Defaults to true")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; helper files ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(alter-meta! (find-ns 'clojure.core) assoc :doc "Fundamental library of the Clojure language")
(load "core_proxy")
(load "core_print")
(load "genclass")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; futures (needs proxy);;;;;;;;;;;;;;;;;;
(defn future-call 
  "Takes a function of no args and yields a future object that will
  invoke the function in another thread, and will cache the result and
  return it on all subsequent calls to deref/@. If the computation has
  not yet finished, calls to deref/@ will block."
  [#^Callable f]
  (let [fut (.submit clojure.lang.Agent/soloExecutor f)]
    (proxy [clojure.lang.IDeref java.util.concurrent.Future] []
      (deref [] (.get fut))
      (get ([] (.get fut))
           ([timeout unit] (.get fut timeout unit)))
      (isCancelled [] (.isCancelled fut))
      (isDone [] (.isDone fut))
      (cancel [interrupt?] (.cancel fut interrupt?)))))
  
(defmacro future
  "Takes a body of expressions and yields a future object that will
  invoke the body in another thread, and will cache the result and
  return it on all subsequent calls to deref/@. If the computation has
  not yet finished, calls to deref/@ will block."  
  [& body] `(future-call (fn [] ~@body)))

(defn pmap
  "Like map, except f is applied in parallel. Semi-lazy in that the
  parallel computation stays ahead of the consumption, but doesn't
  realize the entire result unless required. Only useful for
  computationally intensive functions where the time of f dominates
  the coordination overhead."
  ([f coll]
   (let [n (+ 2 (.. Runtime getRuntime availableProcessors))
         rets (map #(future (f %)) coll)
         step (fn step [[x & xs :as vs] fs]
                (lazy-seq
                 (if-let [s (seq fs)]
                   (cons (deref x) (step xs (rest s)))
                   (map deref vs))))]
     (step rets (drop n rets))))
  ([f coll & colls]
   (let [step (fn step [cs]
                (lazy-seq
                 (let [ss (map seq cs)]
                   (when (every? identity ss)
                     (cons (map first ss) (step (map rest ss)))))))]
     (pmap #(apply f %) (step (cons coll colls))))))

(defn pcalls
  "Executes the no-arg fns in parallel, returning a lazy sequence of
  their values" 
  [& fns] (pmap #(%) fns))

(defmacro pvalues
  "Returns a lazy sequence of the values of the exprs, which are
  evaluated in parallel" 
  [& exprs]
  `(pcalls ~@(map #(list `fn [] %) exprs)))

(defmacro letfn 
  "Takes a vector of function specs and a body, and generates a set of
  bindings of functions to their names. All of the names are available
  in all of the definitions of the functions, as well as the body.

  fnspec ==> (fname [params*] exprs) or (fname ([params*] exprs)+)" 
  [fnspecs & body] 
  `(letfn* ~(vec (interleave (map first fnspecs) 
                             (map #(cons `fn %) fnspecs)))
           ~@body))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; clojure version number ;;;;;;;;;;;;;;;;;;;;;;

(let [version-stream (.getResourceAsStream (clojure.lang.RT/baseLoader) 
                                           "clojure/version.properties")
      properties     (doto (new java.util.Properties) (.load version-stream))
      prop (fn [k] (.getProperty properties (str "clojure.version." k)))
      clojure-version {:major       (Integer/valueOf (prop "major"))
                       :minor       (Integer/valueOf (prop "minor"))
                       :incremental (Integer/valueOf (prop "incremental"))
                       :qualifier   (prop "qualifier")}]
  (def *clojure-version* 
    (if (not (= (prop "interim") "false"))
      (clojure.lang.RT/assoc clojure-version :interim true)
      clojure-version)))
      
(add-doc *clojure-version*
  "The version info for Clojure core, as a map containing :major :minor 
  :incremental and :qualifier keys. Feature releases may increment 
  :minor and/or :major, bugfix releases will increment :incremental. 
  Possible values of :qualifier include \"GA\", \"SNAPSHOT\", \"RC-x\" \"BETA-x\"")
      
(defn
  clojure-version 
  "Returns clojure version as a printable string."
  []
  (str (:major *clojure-version*)
       "."
       (:minor *clojure-version*)
       (when-let [i (:incremental *clojure-version*)]
         (str "." i))
       (when-let [q (:qualifier *clojure-version*)]
         (str "-" q))
       (when (:interim *clojure-version*)
         "-SNAPSHOT")))
;   Copyright (c) Rich Hickey. All rights reserved.
;   The use and distribution terms for this software are covered by the
;   Eclipse Public License 1.0 (http://opensource.org/licenses/eclipse-1.0.php)
;   which can be found in the file epl-v10.html at the root of this distribution.
;   By using this software in any fashion, you are agreeing to be bound by
;   the terms of this license.
;   You must not remove this notice, or any other, from this software.

(in-ns 'clojure.core)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; printing ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(import '(java.io Writer))

(def
 #^{:doc "*print-length* controls how many items of each collection the
  printer will print. If it is bound to logical false, there is no
  limit. Otherwise, it must be bound to an integer indicating the maximum
  number of items of each collection to print. If a collection contains
  more items, the printer will print items up to the limit followed by
  '...' to represent the remaining items. The root binding is nil
  indicating no limit."}
 *print-length* nil)

(def
 #^{:doc "*print-level* controls how many levels deep the printer will
  print nested objects. If it is bound to logical false, there is no
  limit. Otherwise, it must be bound to an integer indicating the maximum
  level to print. Each argument to print is at level 0; if an argument is a
  collection, its items are at level 1; and so on. If an object is a
  collection and is at a level greater than or equal to the value bound to
  *print-level*, the printer prints '#' to represent it. The root binding
  is nil indicating no limit."}
*print-level* nil)

(defn- print-sequential [#^String begin, print-one, #^String sep, #^String end, sequence, #^Writer w]
  (binding [*print-level* (and (not *print-dup*) *print-level* (dec *print-level*))]
    (if (and *print-level* (neg? *print-level*))
      (.write w "#")
      (do
        (.write w begin)
        (when-let [xs (seq sequence)]
          (if (and (not *print-dup*) *print-length*)
            (loop [[x & xs] xs
                   print-length *print-length*]
              (if (zero? print-length)
                (.write w "...")
                (do
                  (print-one x w)
                  (when xs
                    (.write w sep)
                    (recur xs (dec print-length))))))
            (loop [[x & xs] xs]
              (print-one x w)
              (when xs
                (.write w sep)
                (recur xs)))))
        (.write w end)))))

(defn- print-meta [o, #^Writer w]
  (when-let [m (meta o)]
    (when (and (pos? (count m))
               (or *print-dup*
                   (and *print-meta* *print-readably*)))
      (.write w "#^")
      (if (and (= (count m) 1) (:tag m))
          (pr-on (:tag m) w)
          (pr-on m w))
      (.write w " "))))

(defmethod print-method :default [o, #^Writer w]
  (print-method (vary-meta o #(dissoc % :type)) w))

(defmethod print-method nil [o, #^Writer w]
  (.write w "nil"))

(defmethod print-dup nil [o w] (print-method o w))

(defn print-ctor [o print-args #^Writer w]
  (.write w "#=(")
  (.write w (.getName #^Class (class o)))
  (.write w ". ")
  (print-args o w)
  (.write w ")"))

(defmethod print-method Object [o, #^Writer w]
  (.write w "#<")
  (.write w (.getSimpleName (class o)))
  (.write w " ")
  (.write w (str o))
  (.write w ">"))

(defmethod print-method clojure.lang.Keyword [o, #^Writer w]
  (.write w (str o)))

(defmethod print-dup clojure.lang.Keyword [o w] (print-method o w))

(defmethod print-method Number [o, #^Writer w]
  (.write w (str o)))

(defmethod print-dup Number [o, #^Writer w]
  (print-ctor o
              (fn [o w]
                  (print-dup (str o) w))
              w))

(defmethod print-dup clojure.lang.Fn [o, #^Writer w]
  (print-ctor o (fn [o w]) w))

(prefer-method print-dup clojure.lang.IPersistentCollection clojure.lang.Fn)
(prefer-method print-dup java.util.Map clojure.lang.Fn)
(prefer-method print-dup java.util.Collection clojure.lang.Fn)

(defmethod print-method Boolean [o, #^Writer w]
  (.write w (str o)))

(defmethod print-dup Boolean [o w] (print-method o w))

(defn print-simple [o, #^Writer w]
  (print-meta o w)
  (.write w (str o)))

(defmethod print-method clojure.lang.Symbol [o, #^Writer w]
  (print-simple o w))

(defmethod print-dup clojure.lang.Symbol [o w] (print-method o w))

(defmethod print-method clojure.lang.Var [o, #^Writer w]
  (print-simple o w))

(defmethod print-dup clojure.lang.Var [#^clojure.lang.Var o, #^Writer w]
  (.write w (str "#=(var " (.name (.ns o)) "/" (.sym o) ")")))

(defmethod print-method clojure.lang.ISeq [o, #^Writer w]
  (print-meta o w)
  (print-sequential "(" pr-on " " ")" o w))

(defmethod print-dup clojure.lang.ISeq [o w] (print-method o w))
(defmethod print-dup clojure.lang.IPersistentList [o w] (print-method o w))
(prefer-method print-method clojure.lang.IPersistentList clojure.lang.ISeq)
(prefer-method print-dup clojure.lang.IPersistentList clojure.lang.ISeq)
(prefer-method print-method clojure.lang.ISeq clojure.lang.IPersistentCollection)
(prefer-method print-dup clojure.lang.ISeq clojure.lang.IPersistentCollection)
(prefer-method print-method clojure.lang.ISeq java.util.Collection)
(prefer-method print-dup clojure.lang.ISeq java.util.Collection)

(defmethod print-method clojure.lang.IPersistentList [o, #^Writer w]
  (print-meta o w)
  (print-sequential "(" print-method " " ")" o w))


(defmethod print-dup java.util.Collection [o, #^Writer w]
 (print-ctor o #(print-sequential "[" print-dup " " "]" %1 %2) w))

(defmethod print-dup clojure.lang.IPersistentCollection [o, #^Writer w]
  (print-meta o w)
  (.write w "#=(")
  (.write w (.getName #^Class (class o)))
  (.write w "/create ")
  (print-sequential "[" print-dup " " "]" o w)
  (.write w ")"))

(prefer-method print-dup clojure.lang.IPersistentCollection java.util.Collection)

(def #^{:tag String 
        :doc "Returns escape string for char or nil if none"}
  char-escape-string
    {\newline "\\n"
     \tab  "\\t"
     \return "\\r"
     \" "\\\""
     \\  "\\\\"
     \formfeed "\\f"
     \backspace "\\b"})

(defmethod print-method String [#^String s, #^Writer w]
  (if (or *print-dup* *print-readably*)
    (do (.append w \")
      (dotimes [n (count s)]
        (let [c (.charAt s n)
              e (char-escape-string c)]
          (if e (.write w e) (.append w c))))
      (.append w \"))
    (.write w s))
  nil)

(defmethod print-dup String [s w] (print-method s w))

(defmethod print-method clojure.lang.IPersistentVector [v, #^Writer w]
  (print-meta v w)
  (print-sequential "[" pr-on " " "]" v w))

(defn- print-map [m print-one w]
  (print-sequential 
   "{"
   (fn [e  #^Writer w] 
     (do (print-one (key e) w) (.append w \space) (print-one (val e) w)))
   ", "
   "}"
   (seq m) w))

(defmethod print-method clojure.lang.IPersistentMap [m, #^Writer w]
  (print-meta m w)
  (print-map m pr-on w))

(defmethod print-dup java.util.Map [m, #^Writer w]
  (print-ctor m #(print-map (seq %1) print-dup %2) w))

(defmethod print-dup clojure.lang.IPersistentMap [m, #^Writer w]
  (print-meta m w)
  (.write w "#=(")
  (.write w (.getName (class m)))
  (.write w "/create ")
  (print-map m print-dup w)
  (.write w ")"))

(prefer-method print-dup clojure.lang.IPersistentCollection java.util.Map)

(defmethod print-method clojure.lang.IPersistentSet [s, #^Writer w]
  (print-meta s w)
  (print-sequential "#{" pr-on " " "}" (seq s) w))

(def #^{:tag String 
        :doc "Returns name string for char or nil if none"} 
 char-name-string
   {\newline "newline"
    \tab "tab"
    \space "space"
    \backspace "backspace"
    \formfeed "formfeed"
    \return "return"})

(defmethod print-method java.lang.Character [#^Character c, #^Writer w]
  (if (or *print-dup* *print-readably*)
    (do (.append w \\)
        (let [n (char-name-string c)]
          (if n (.write w n) (.append w c))))
    (.append w c))
  nil)

(defmethod print-dup java.lang.Character [c w] (print-method c w))
(defmethod print-dup java.lang.Integer [o w] (print-method o w))
(defmethod print-dup java.lang.Double [o w] (print-method o w))
(defmethod print-dup clojure.lang.Ratio [o w] (print-method o w))
(defmethod print-dup java.math.BigDecimal [o w] (print-method o w))
(defmethod print-dup clojure.lang.PersistentHashMap [o w] (print-method o w))
(defmethod print-dup clojure.lang.PersistentHashSet [o w] (print-method o w))
(defmethod print-dup clojure.lang.PersistentVector [o w] (print-method o w))
(defmethod print-dup clojure.lang.LazilyPersistentVector [o w] (print-method o w))

(def primitives-classnames
  {Float/TYPE "Float/TYPE"
   Integer/TYPE "Integer/TYPE"
   Long/TYPE "Long/TYPE"
   Boolean/TYPE "Boolean/TYPE"
   Character/TYPE "Character/TYPE"
   Double/TYPE "Double/TYPE"
   Byte/TYPE "Byte/TYPE"
   Short/TYPE "Short/TYPE"})

(defmethod print-method Class [#^Class c, #^Writer w]
  (.write w (.getName c)))

(defmethod print-dup Class [#^Class c, #^Writer w]
  (cond
    (.isPrimitive c) (do
                       (.write w "#=(identity ")
                       (.write w #^String (primitives-classnames c))
                       (.write w ")"))
    (.isArray c) (do
                   (.write w "#=(java.lang.Class/forName \"")
                   (.write w (.getName c))
                   (.write w "\")"))
    :else (do
            (.write w "#=")
            (.write w (.getName c)))))

(defmethod print-method java.math.BigDecimal [b, #^Writer w]
  (.write w (str b))
  (.write w "M"))

(defmethod print-method java.util.regex.Pattern [p #^Writer w]
  (.write w "#\"")
  (loop [[#^Character c & r :as s] (seq (.pattern #^java.util.regex.Pattern p))
         qmode false]
    (when s
      (cond
        (= c \\) (let [[#^Character c2 & r2] r]
                   (.append w \\)
                   (.append w c2)
                   (if qmode
                      (recur r2 (not= c2 \E))
                      (recur r2 (= c2 \Q))))
        (= c \") (do
                   (if qmode
                     (.write w "\\E\\\"\\Q")
                     (.write w "\\\""))
                   (recur r qmode))
        :else    (do
                   (.append w c)
                   (recur r qmode)))))
  (.append w \"))

(defmethod print-dup java.util.regex.Pattern [p #^Writer w] (print-method p w))

(defmethod print-dup clojure.lang.Namespace [#^clojure.lang.Namespace n #^Writer w]
  (.write w "#=(find-ns ")
  (print-dup (.name n) w)
  (.write w ")"))

(defmethod print-method clojure.lang.IDeref [o #^Writer w]
  (print-sequential (format "#<%s@%x: "
                            (.getSimpleName (class o))
                            (System/identityHashCode o))
                    pr-on, "", ">", (list @o), w))

(def #^{:private true} print-initialized true)
;   Copyright (c) Rich Hickey. All rights reserved.
;   The use and distribution terms for this software are covered by the
;   Eclipse Public License 1.0 (http://opensource.org/licenses/eclipse-1.0.php)
;   which can be found in the file epl-v10.html at the root of this distribution.
;   By using this software in any fashion, you are agreeing to be bound by
;   the terms of this license.
;   You must not remove this notice, or any other, from this software.

(in-ns 'clojure.core)

;;;;;;;;;;;;;;;;;;;;;;;;;;;; proxy ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(import
 '(clojure.asm ClassWriter ClassVisitor Opcodes Type) 
 '(java.lang.reflect Modifier Constructor)
 '(clojure.asm.commons Method GeneratorAdapter)
 '(clojure.lang IProxy Reflector DynamicClassLoader IPersistentMap PersistentHashMap RT))

(defn method-sig [#^java.lang.reflect.Method meth]
  [(. meth (getName)) (seq (. meth (getParameterTypes))) (. meth getReturnType)])

(defn- most-specific [rtypes]
  (or (some (fn [t] (when (every? #(isa? t %) rtypes) t)) rtypes)
    (throw (Exception. "Incompatible return types"))))

(defn- group-by-sig [coll]
 "takes a collection of [msig meth] and returns a seq of maps from return-types to meths."
  (vals (reduce (fn [m [msig meth]]
                  (let [rtype (peek msig)
                        argsig (pop msig)]
                    (assoc m argsig (assoc (m argsig {}) rtype meth))))
          {} coll)))

(defn proxy-name
 {:tag String} 
 [#^Class super interfaces]
  (apply str "clojure.proxy."
         (.getName super)
         (interleave (repeat "$")
                     (sort (map #(.getSimpleName #^Class %) interfaces)))))

(defn- generate-proxy [#^Class super interfaces]
  (let [cv (new ClassWriter (. ClassWriter COMPUTE_MAXS))
        cname (.replace (proxy-name super interfaces) \. \/) ;(str "clojure/lang/" (gensym "Proxy__"))
        ctype (. Type (getObjectType cname))
        iname (fn [#^Class c] (.. Type (getType c) (getInternalName)))
        fmap "__clojureFnMap"
        totype (fn [#^Class c] (. Type (getType c)))
        to-types (fn [cs] (if (pos? (count cs))
                            (into-array (map totype cs))
                            (make-array Type 0)))
        super-type #^Type (totype super)
        imap-type #^Type (totype IPersistentMap)
        ifn-type (totype clojure.lang.IFn)
        obj-type (totype Object)
        sym-type (totype clojure.lang.Symbol)
        rt-type  (totype clojure.lang.RT)
        ex-type  (totype java.lang.UnsupportedOperationException)
        gen-bridge 
        (fn [#^java.lang.reflect.Method meth #^java.lang.reflect.Method dest]
            (let [pclasses (. meth (getParameterTypes))
                  ptypes (to-types pclasses)
                  rtype #^Type (totype (. meth (getReturnType)))
                  m (new Method (. meth (getName)) rtype ptypes)
                  dtype (totype (.getDeclaringClass dest))
                  dm (new Method (. dest (getName)) (totype (. dest (getReturnType))) (to-types (. dest (getParameterTypes))))
                  gen (new GeneratorAdapter (bit-or (. Opcodes ACC_PUBLIC) (. Opcodes ACC_BRIDGE)) m nil nil cv)]
              (. gen (visitCode))
              (. gen (loadThis))
              (dotimes [i (count ptypes)]
                  (. gen (loadArg i)))
              (if (-> dest .getDeclaringClass .isInterface)
                (. gen (invokeInterface dtype dm))
                (. gen (invokeVirtual dtype dm)))
              (. gen (returnValue))
              (. gen (endMethod))))
        gen-method
        (fn [#^java.lang.reflect.Method meth else-gen]
            (let [pclasses (. meth (getParameterTypes))
                  ptypes (to-types pclasses)
                  rtype #^Type (totype (. meth (getReturnType)))
                  m (new Method (. meth (getName)) rtype ptypes)
                  gen (new GeneratorAdapter (. Opcodes ACC_PUBLIC) m nil nil cv)
                  else-label (. gen (newLabel))
                  end-label (. gen (newLabel))
                  decl-type (. Type (getType (. meth (getDeclaringClass))))]
              (. gen (visitCode))
              (if (> (count pclasses) 18)
                (else-gen gen m)
                (do
                  (. gen (loadThis))
                  (. gen (getField ctype fmap imap-type))
                  
                  (. gen (push (. meth (getName))))
                                        ;lookup fn in map
                  (. gen (invokeStatic rt-type (. Method (getMethod "Object get(Object, Object)"))))
                  (. gen (dup))
                  (. gen (ifNull else-label))
                                        ;if found
                  (.checkCast gen ifn-type)
                  (. gen (loadThis))
                                        ;box args
                  (dotimes [i (count ptypes)]
                      (. gen (loadArg i))
                    (. clojure.lang.Compiler$HostExpr (emitBoxReturn nil gen (nth pclasses i))))
                                        ;call fn
                  (. gen (invokeInterface ifn-type (new Method "invoke" obj-type 
                                                        (into-array (cons obj-type 
                                                                          (replicate (count ptypes) obj-type))))))
                                        ;unbox return
                  (. gen (unbox rtype))
                  (when (= (. rtype (getSort)) (. Type VOID))
                    (. gen (pop)))
                  (. gen (goTo end-label))
                  
                                        ;else call supplied alternative generator
                  (. gen (mark else-label))
                  (. gen (pop))
                  
                  (else-gen gen m)
                  
                  (. gen (mark end-label))))
              (. gen (returnValue))
              (. gen (endMethod))))]
    
                                        ;start class definition
    (. cv (visit (. Opcodes V1_5) (+ (. Opcodes ACC_PUBLIC) (. Opcodes ACC_SUPER))
                 cname nil (iname super) 
                 (into-array (map iname (cons IProxy interfaces)))))
                                        ;add field for fn mappings
    (. cv (visitField (+ (. Opcodes ACC_PRIVATE) (. Opcodes ACC_VOLATILE))
                      fmap (. imap-type (getDescriptor)) nil nil))          
                                        ;add ctors matching/calling super's
    (doseq [#^Constructor ctor (. super (getDeclaredConstructors))]
        (when-not (. Modifier (isPrivate (. ctor (getModifiers))))
          (let [ptypes (to-types (. ctor (getParameterTypes)))
                m (new Method "<init>" (. Type VOID_TYPE) ptypes)
                gen (new GeneratorAdapter (. Opcodes ACC_PUBLIC) m nil nil cv)]
            (. gen (visitCode))
                                        ;call super ctor
            (. gen (loadThis))
            (. gen (dup))
            (. gen (loadArgs))
            (. gen (invokeConstructor super-type m))
            
            (. gen (returnValue))
            (. gen (endMethod)))))
                                        ;add IProxy methods
    (let [m (. Method (getMethod "void __initClojureFnMappings(clojure.lang.IPersistentMap)"))
          gen (new GeneratorAdapter (. Opcodes ACC_PUBLIC) m nil nil cv)]
      (. gen (visitCode))
      (. gen (loadThis))
      (. gen (loadArgs))
      (. gen (putField ctype fmap imap-type))
      
      (. gen (returnValue))
      (. gen (endMethod)))
    (let [m (. Method (getMethod "void __updateClojureFnMappings(clojure.lang.IPersistentMap)"))
          gen (new GeneratorAdapter (. Opcodes ACC_PUBLIC) m nil nil cv)]
      (. gen (visitCode))
      (. gen (loadThis))
      (. gen (dup))
      (. gen (getField ctype fmap imap-type))
      (.checkCast gen (totype clojure.lang.IPersistentCollection))
      (. gen (loadArgs))
      (. gen (invokeInterface (totype clojure.lang.IPersistentCollection)
                              (. Method (getMethod "clojure.lang.IPersistentCollection cons(Object)"))))
      (. gen (checkCast imap-type))
      (. gen (putField ctype fmap imap-type))
      
      (. gen (returnValue))
      (. gen (endMethod)))
    (let [m (. Method (getMethod "clojure.lang.IPersistentMap __getClojureFnMappings()"))
          gen (new GeneratorAdapter (. Opcodes ACC_PUBLIC) m nil nil cv)]
      (. gen (visitCode))
      (. gen (loadThis))
      (. gen (getField ctype fmap imap-type))
      (. gen (returnValue))
      (. gen (endMethod)))
    
                                        ;calc set of supers' non-private instance methods
    (let [[mm considered]
            (loop [mm {} considered #{} c super]
              (if c
                (let [[mm considered]
                      (loop [mm mm 
                             considered considered 
                             meths (concat 
                                    (seq (. c (getDeclaredMethods)))
                                    (seq (. c (getMethods))))]
                        (if (seq meths)
                          (let [#^java.lang.reflect.Method meth (first meths)
                                mods (. meth (getModifiers))
                                mk (method-sig meth)]
                            (if (or (considered mk)
                                    (not (or (Modifier/isPublic mods) (Modifier/isProtected mods)))
                                    ;(. Modifier (isPrivate mods)) 
                                    (. Modifier (isStatic mods))
                                    (. Modifier (isFinal mods))
                                    (= "finalize" (.getName meth)))
                              (recur mm (conj considered mk) (next meths))
                              (recur (assoc mm mk meth) (conj considered mk) (next meths))))
                          [mm considered]))]
                  (recur mm considered (. c (getSuperclass))))
                [mm considered]))
          ifaces-meths (into {} 
                         (for [#^Class iface interfaces meth (. iface (getMethods))
                               :let [msig (method-sig meth)] :when (not (considered msig))]
                           {msig meth}))
          mgroups (group-by-sig (concat mm ifaces-meths))
          rtypes (map #(most-specific (keys %)) mgroups)
          mb (map #(vector (%1 %2) (vals (dissoc %1 %2))) mgroups rtypes)
          bridge? (reduce into #{} (map second mb))
          ifaces-meths (remove bridge? (vals ifaces-meths))
          mm (remove bridge? (vals mm))]
                                        ;add methods matching supers', if no mapping -> call super
      (doseq [[#^java.lang.reflect.Method dest bridges] mb
              #^java.lang.reflect.Method meth bridges]
          (gen-bridge meth dest))
      (doseq [#^java.lang.reflect.Method meth mm]
          (gen-method meth 
                      (fn [#^GeneratorAdapter gen #^Method m]
                          (. gen (loadThis))
                                        ;push args
                        (. gen (loadArgs))
                                        ;call super
                        (. gen (visitMethodInsn (. Opcodes INVOKESPECIAL) 
                                                (. super-type (getInternalName))
                                                (. m (getName))
                                                (. m (getDescriptor)))))))
      
                                        ;add methods matching interfaces', if no mapping -> throw
      (doseq [#^java.lang.reflect.Method meth ifaces-meths]
                (gen-method meth 
                            (fn [#^GeneratorAdapter gen #^Method m]
                                (. gen (throwException ex-type (. m (getName))))))))
    
                                        ;finish class def
    (. cv (visitEnd))
    [cname (. cv toByteArray)]))

(defn- get-super-and-interfaces [bases]
  (if (. #^Class (first bases) (isInterface))
    [Object bases]
    [(first bases) (next bases)]))

(defn get-proxy-class 
  "Takes an optional single class followed by zero or more
  interfaces. If not supplied class defaults to Object.  Creates an
  returns an instance of a proxy class derived from the supplied
  classes. The resulting value is cached and used for any subsequent
  requests for the same class set. Returns a Class object."  
  [& bases]
    (let [[super interfaces] (get-super-and-interfaces bases)
          pname (proxy-name super interfaces)]
      (or (RT/loadClassForName pname)
          (let [[cname bytecode] (generate-proxy super interfaces)]
            (. (RT/getRootClassLoader) (defineClass pname bytecode))))))

(defn construct-proxy
  "Takes a proxy class and any arguments for its superclass ctor and
  creates and returns an instance of the proxy."  
  [c & ctor-args]
    (. Reflector (invokeConstructor c (to-array ctor-args))))

(defn init-proxy
  "Takes a proxy instance and a map of strings (which must
  correspond to methods of the proxy superclass/superinterfaces) to
  fns (which must take arguments matching the corresponding method,
  plus an additional (explicit) first arg corresponding to this, and
  sets the proxy's fn map."
  [#^IProxy proxy mappings]
    (. proxy (__initClojureFnMappings mappings)))

(defn update-proxy
  "Takes a proxy instance and a map of strings (which must
  correspond to methods of the proxy superclass/superinterfaces) to
  fns (which must take arguments matching the corresponding method,
  plus an additional (explicit) first arg corresponding to this, and
  updates (via assoc) the proxy's fn map. nil can be passed instead of
  a fn, in which case the corresponding method will revert to the
  default behavior. Note that this function can be used to update the
  behavior of an existing instance without changing its identity."
  [#^IProxy proxy mappings]
    (. proxy (__updateClojureFnMappings mappings)))

(defn proxy-mappings
  "Takes a proxy instance and returns the proxy's fn map."
  [#^IProxy proxy]
    (. proxy (__getClojureFnMappings)))

(defmacro proxy
  "class-and-interfaces - a vector of class names

  args - a (possibly empty) vector of arguments to the superclass
  constructor.

  f => (name [params*] body) or
  (name ([params*] body) ([params+] body) ...)

  Expands to code which creates a instance of a proxy class that
  implements the named class/interface(s) by calling the supplied
  fns. A single class, if provided, must be first. If not provided it
  defaults to Object.

  The interfaces names must be valid interface types. If a method fn
  is not provided for a class method, the superclass methd will be
  called. If a method fn is not provided for an interface method, an
  UnsupportedOperationException will be thrown should it be
  called. Method fns are closures and can capture the environment in
  which proxy is called. Each method fn takes an additional implicit
  first arg, which is bound to 'this. Note that while method fns can
  be provided to override protected methods, they have no other access
  to protected members, nor to super, as these capabilities cannot be
  proxied."
  [class-and-interfaces args & fs]
   (let [bases (map #(or (resolve %) (throw (Exception. (str "Can't resolve: " %)))) 
                    class-and-interfaces)
         [super interfaces] (get-super-and-interfaces bases)
         compile-effect (when *compile-files*
                          (let [[cname bytecode] (generate-proxy super interfaces)]
                            (clojure.lang.Compiler/writeClassFile cname bytecode)))
         pc-effect (apply get-proxy-class bases)
         pname (proxy-name super interfaces)]
     `(let [;pc# (get-proxy-class ~@class-and-interfaces)
            p# (new ~(symbol pname) ~@args)] ;(construct-proxy pc# ~@args)]   
        (init-proxy p#
         ~(loop [fmap {} fs fs]
            (if fs
              (let [[sym & meths] (first fs)
                    meths (if (vector? (first meths))
                            (list meths)
                            meths)
                    meths (map (fn [[params & body]]
                                   (cons (apply vector 'this params) body))
                               meths)]
                (if-not (contains? fmap (name sym))		  
                (recur (assoc fmap (name sym) (cons `fn meths)) (next fs))
		           (throw (IllegalArgumentException.
			              (str "Method '" (name sym) "' redefined")))))
              fmap)))
        p#)))

(defn proxy-call-with-super [call this meth]
 (let [m (proxy-mappings this)]
    (update-proxy this (assoc m meth nil))
    (let [ret (call)]
      (update-proxy this m)
      ret)))

(defmacro proxy-super 
  "Use to call a superclass method in the body of a proxy method. 
  Note, expansion captures 'this"
  [meth & args]
 `(proxy-call-with-super (fn [] (. ~'this ~meth ~@args))  ~'this ~(name meth)))

(defn bean
  "Takes a Java object and returns a read-only implementation of the
  map abstraction based upon its JavaBean properties."
  [#^Object x]
  (let [c (. x (getClass))
	pmap (reduce (fn [m #^java.beans.PropertyDescriptor pd]
			 (let [name (. pd (getName))
			       method (. pd (getReadMethod))]
			   (if (and method (zero? (alength (. method (getParameterTypes)))))
			     (assoc m (keyword name) (fn [] (clojure.lang.Reflector/prepRet (. method (invoke x nil)))))
			     m)))
		     {}
		     (seq (.. java.beans.Introspector
			      (getBeanInfo c)
			      (getPropertyDescriptors))))
	v (fn [k] ((pmap k)))
        snapshot (fn []
                   (reduce (fn [m e]
                             (assoc m (key e) ((val e))))
                           {} (seq pmap)))]
    (proxy [clojure.lang.APersistentMap]
           []
      (containsKey [k] (contains? pmap k))
      (entryAt [k] (when (contains? pmap k) (new clojure.lang.MapEntry k (v k))))
      (valAt ([k] (v k))
	     ([k default] (if (contains? pmap k) (v k) default)))
      (cons [m] (conj (snapshot) m))
      (count [] (count pmap))
      (assoc [k v] (assoc (snapshot) k v))
      (without [k] (dissoc (snapshot) k))
      (seq [] ((fn thisfn [plseq]
		  (lazy-seq
                   (when-let [pseq (seq plseq)]
                     (cons (new clojure.lang.MapEntry (first pseq) (v (first pseq)))
                           (thisfn (rest pseq)))))) (keys pmap))))))



;   Copyright (c) Rich Hickey. All rights reserved.
;   The use and distribution terms for this software are covered by the
;   Eclipse Public License 1.0 (http://opensource.org/licenses/eclipse-1.0.php)
;   which can be found in the file epl-v10.html at the root of this distribution.
;   By using this software in any fashion, you are agreeing to be bound by
;   the terms of this license.
;   You must not remove this notice, or any other, from this software.

(in-ns 'clojure.core)

(import '(java.lang.reflect Modifier Constructor)
        '(clojure.asm ClassWriter ClassVisitor Opcodes Type)
        '(clojure.asm.commons Method GeneratorAdapter)
        '(clojure.lang IPersistentMap))

;(defn method-sig [#^java.lang.reflect.Method meth]
;  [(. meth (getName)) (seq (. meth (getParameterTypes)))])

(defn- non-private-methods [#^Class c]
  (loop [mm {}
         considered #{}
         c c]
    (if c
      (let [[mm considered]
            (loop [mm mm
                   considered considered
                   meths (seq (concat
                                (seq (. c (getDeclaredMethods)))
                                (seq (. c (getMethods)))))]
              (if meths
                (let [#^java.lang.reflect.Method meth (first meths)
                      mods (. meth (getModifiers))
                      mk (method-sig meth)]
                  (if (or (considered mk)
                          (not (or (Modifier/isPublic mods) (Modifier/isProtected mods)))
                          ;(. Modifier (isPrivate mods))
                          (. Modifier (isStatic mods))
                          (. Modifier (isFinal mods))
                          (= "finalize" (.getName meth)))
                    (recur mm (conj considered mk) (next meths))
                    (recur (assoc mm mk meth) (conj considered mk) (next meths))))
                [mm considered]))]
        (recur mm considered (. c (getSuperclass))))
      mm)))

(defn- ctor-sigs [#^Class super]
  (for [#^Constructor ctor (. super (getDeclaredConstructors))
        :when (not (. Modifier (isPrivate (. ctor (getModifiers)))))]
    (apply vector (. ctor (getParameterTypes)))))

(defn- escape-class-name [#^Class c]
  (.. (.getSimpleName c) 
      (replace "[]" "<>")))

(defn- overload-name [mname pclasses]
  (if (seq pclasses)
    (apply str mname (interleave (repeat \-) 
                                 (map escape-class-name pclasses)))
    (str mname "-void")))

(defn- #^java.lang.reflect.Field find-field [#^Class c f]
  (let [start-class c]
    (loop [c c]
      (if (= c Object)
        (throw (new Exception (str "field, " f ", not defined in class, " start-class ", or its ancestors")))
        (let [dflds (.getDeclaredFields c)
              rfld (first (filter #(= f (.getName #^java.lang.reflect.Field %)) dflds))]
          (or rfld (recur (.getSuperclass c))))))))

;(distinct (map first(keys (mapcat non-private-methods [Object IPersistentMap]))))

(def #^{:private true} prim->class
     {'int Integer/TYPE
      'long Long/TYPE
      'float Float/TYPE
      'double Double/TYPE
      'void Void/TYPE
      'short Short/TYPE
      'boolean Boolean/TYPE
      'byte Byte/TYPE
      'char Character/TYPE})

(defn- #^Class the-class [x] 
  (cond 
   (class? x) x
   (contains? prim->class x) (prim->class x)
   :else (let [strx (str x)]
           (clojure.lang.RT/classForName 
            (if (some #{\.} strx)
              strx
              (str "java.lang." strx))))))

(defn- generate-class [options-map]
  (let [default-options {:prefix "-" :load-impl-ns true :impl-ns (ns-name *ns*)}
        {:keys [name extends implements constructors methods main factory state init exposes 
                exposes-methods prefix load-impl-ns impl-ns post-init]} 
          (merge default-options options-map)
        name (str name)
        super (if extends (the-class extends) Object)
        interfaces (map the-class implements)
        supers (cons super interfaces)
        ctor-sig-map (or constructors (zipmap (ctor-sigs super) (ctor-sigs super)))
        cv (new ClassWriter (. ClassWriter COMPUTE_MAXS))
        cname (. name (replace "." "/"))
        pkg-name name
        impl-pkg-name (str impl-ns)
        impl-cname (.. impl-pkg-name (replace "." "/") (replace \- \_))
        ctype (. Type (getObjectType cname))
        iname (fn [#^Class c] (.. Type (getType c) (getInternalName)))
        totype (fn [#^Class c] (. Type (getType c)))
        to-types (fn [cs] (if (pos? (count cs))
                            (into-array (map totype cs))
                            (make-array Type 0)))
        obj-type #^Type (totype Object)
        arg-types (fn [n] (if (pos? n)
                            (into-array (replicate n obj-type))
                            (make-array Type 0)))
        super-type #^Type (totype super)
        init-name (str init)
        post-init-name (str post-init)
        factory-name (str factory)
        state-name (str state)
        main-name "main"
        var-name (fn [s] (str s "__var"))
        class-type  (totype Class)
        rt-type  (totype clojure.lang.RT)
        var-type #^Type (totype clojure.lang.Var)
        ifn-type (totype clojure.lang.IFn)
        iseq-type (totype clojure.lang.ISeq)
        ex-type  (totype java.lang.UnsupportedOperationException)
        all-sigs (distinct (concat (map #(let[[m p] (key %)] {m [p]}) (mapcat non-private-methods supers))
                                   (map (fn [[m p]] {(str m) [p]}) methods)))
        sigs-by-name (apply merge-with concat {} all-sigs)
        overloads (into {} (filter (fn [[m s]] (next s)) sigs-by-name))
        var-fields (concat (when init [init-name]) 
                           (when post-init [post-init-name])
                           (when main [main-name])
                           ;(when exposes-methods (map str (vals exposes-methods)))
                           (distinct (concat (keys sigs-by-name)
                                             (mapcat (fn [[m s]] (map #(overload-name m (map the-class %)) s)) overloads)
                                             (mapcat (comp (partial map str) vals val) exposes))))
        emit-get-var (fn [#^GeneratorAdapter gen v]
                       (let [false-label (. gen newLabel)
                             end-label (. gen newLabel)]
                         (. gen getStatic ctype (var-name v) var-type)
                         (. gen dup)
                         (. gen invokeVirtual var-type (. Method (getMethod "boolean isBound()")))
                         (. gen ifZCmp (. GeneratorAdapter EQ) false-label)
                         (. gen invokeVirtual var-type (. Method (getMethod "Object get()")))
                         (. gen goTo end-label)
                         (. gen mark false-label)
                         (. gen pop)
                         (. gen visitInsn (. Opcodes ACONST_NULL))
                         (. gen mark end-label)))
        emit-unsupported (fn [#^GeneratorAdapter gen #^Method m]
                           (. gen (throwException ex-type (str (. m (getName)) " ("
                                                               impl-pkg-name "/" prefix (.getName m)
                                                               " not defined?)"))))
        emit-forwarding-method
        (fn [mname pclasses rclass as-static else-gen]
          (let [pclasses (map the-class pclasses)
                rclass (the-class rclass)
                ptypes (to-types pclasses)
                rtype #^Type (totype rclass)
                m (new Method mname rtype ptypes)
                is-overload (seq (overloads mname))
                gen (new GeneratorAdapter (+ (. Opcodes ACC_PUBLIC) (if as-static (. Opcodes ACC_STATIC) 0)) 
                         m nil nil cv)
                found-label (. gen (newLabel))
                else-label (. gen (newLabel))
                end-label (. gen (newLabel))]
            (. gen (visitCode))
            (if (> (count pclasses) 18)
              (else-gen gen m)
              (do
                (when is-overload
                  (emit-get-var gen (overload-name mname pclasses))
                  (. gen (dup))
                  (. gen (ifNonNull found-label))
                  (. gen (pop)))
                (emit-get-var gen mname)
                (. gen (dup))
                (. gen (ifNull else-label))
                (when is-overload
                  (. gen (mark found-label)))
                                        ;if found
                (.checkCast gen ifn-type)
                (when-not as-static
                  (. gen (loadThis)))
                                        ;box args
                (dotimes [i (count ptypes)]
                  (. gen (loadArg i))
                  (. clojure.lang.Compiler$HostExpr (emitBoxReturn nil gen (nth pclasses i))))
                                        ;call fn
                (. gen (invokeInterface ifn-type (new Method "invoke" obj-type 
                                                      (to-types (replicate (+ (count ptypes)
                                                                              (if as-static 0 1)) 
                                                                           Object)))))
                                        ;(into-array (cons obj-type 
                                        ;                 (replicate (count ptypes) obj-type))))))
                                        ;unbox return
                (. gen (unbox rtype))
                (when (= (. rtype (getSort)) (. Type VOID))
                  (. gen (pop)))
                (. gen (goTo end-label))
                
                                        ;else call supplied alternative generator
                (. gen (mark else-label))
                (. gen (pop))
                
                (else-gen gen m)
            
                (. gen (mark end-label))))
            (. gen (returnValue))
            (. gen (endMethod))))
        ]
                                        ;start class definition
    (. cv (visit (. Opcodes V1_5) (+ (. Opcodes ACC_PUBLIC) (. Opcodes ACC_SUPER))
                 cname nil (iname super)
                 (when-let [ifc (seq interfaces)]
                   (into-array (map iname ifc)))))
    
                                        ;static fields for vars
    (doseq [v var-fields]
      (. cv (visitField (+ (. Opcodes ACC_PRIVATE) (. Opcodes ACC_FINAL) (. Opcodes ACC_STATIC))
                        (var-name v) 
                        (. var-type getDescriptor)
                        nil nil)))
    
                                        ;instance field for state
    (when state
      (. cv (visitField (+ (. Opcodes ACC_PUBLIC) (. Opcodes ACC_FINAL))
                        state-name 
                        (. obj-type getDescriptor)
                        nil nil)))
    
                                        ;static init to set up var fields and load init
    (let [gen (new GeneratorAdapter (+ (. Opcodes ACC_PUBLIC) (. Opcodes ACC_STATIC)) 
                   (. Method getMethod "void <clinit> ()")
                   nil nil cv)]
      (. gen (visitCode))
      (doseq [v var-fields]
        (. gen push impl-pkg-name)
        (. gen push (str prefix v))
        (. gen (invokeStatic var-type (. Method (getMethod "clojure.lang.Var internPrivate(String,String)"))))
        (. gen putStatic ctype (var-name v) var-type))
      
      (when load-impl-ns
        (. gen push "clojure.core")
        (. gen push "load")
        (. gen (invokeStatic rt-type (. Method (getMethod "clojure.lang.Var var(String,String)"))))
        (. gen push (str "/" impl-cname))
        (. gen (invokeInterface ifn-type (new Method "invoke" obj-type (to-types [Object]))))
;        (. gen push (str (.replace impl-pkg-name \- \_) "__init"))
;        (. gen (invokeStatic class-type (. Method (getMethod "Class forName(String)"))))
        (. gen pop))

      (. gen (returnValue))
      (. gen (endMethod)))
    
                                        ;ctors
    (doseq [[pclasses super-pclasses] ctor-sig-map]
      (let [pclasses (map the-class pclasses)
            super-pclasses (map the-class super-pclasses)
            ptypes (to-types pclasses)
            super-ptypes (to-types super-pclasses)
            m (new Method "<init>" (. Type VOID_TYPE) ptypes)
            super-m (new Method "<init>" (. Type VOID_TYPE) super-ptypes)
            gen (new GeneratorAdapter (. Opcodes ACC_PUBLIC) m nil nil cv)
            no-init-label (. gen newLabel)
            end-label (. gen newLabel)
            no-post-init-label (. gen newLabel)
            end-post-init-label (. gen newLabel)
            nth-method (. Method (getMethod "Object nth(Object,int)"))
            local (. gen newLocal obj-type)]
        (. gen (visitCode))
        
        (if init
          (do
            (emit-get-var gen init-name)
            (. gen dup)
            (. gen ifNull no-init-label)
            (.checkCast gen ifn-type)
                                        ;box init args
            (dotimes [i (count pclasses)]
              (. gen (loadArg i))
              (. clojure.lang.Compiler$HostExpr (emitBoxReturn nil gen (nth pclasses i))))
                                        ;call init fn
            (. gen (invokeInterface ifn-type (new Method "invoke" obj-type 
                                                  (arg-types (count ptypes)))))
                                        ;expecting [[super-ctor-args] state] returned
            (. gen dup)
            (. gen push 0)
            (. gen (invokeStatic rt-type nth-method))
            (. gen storeLocal local)
            
            (. gen (loadThis))
            (. gen dupX1)
            (dotimes [i (count super-pclasses)]
              (. gen loadLocal local)
              (. gen push i)
              (. gen (invokeStatic rt-type nth-method))
              (. clojure.lang.Compiler$HostExpr (emitUnboxArg nil gen (nth super-pclasses i))))
            (. gen (invokeConstructor super-type super-m))
            
            (if state
              (do
                (. gen push 1)
                (. gen (invokeStatic rt-type nth-method))
                (. gen (putField ctype state-name obj-type)))
              (. gen pop))
            
            (. gen goTo end-label)
                                        ;no init found
            (. gen mark no-init-label)
            (. gen (throwException ex-type (str impl-pkg-name "/" prefix init-name " not defined")))
            (. gen mark end-label))
          (if (= pclasses super-pclasses)
            (do
              (. gen (loadThis))
              (. gen (loadArgs))
              (. gen (invokeConstructor super-type super-m)))
            (throw (new Exception ":init not specified, but ctor and super ctor args differ"))))

        (when post-init
          (emit-get-var gen post-init-name)
          (. gen dup)
          (. gen ifNull no-post-init-label)
          (.checkCast gen ifn-type)
          (. gen (loadThis))
                                       ;box init args
          (dotimes [i (count pclasses)]
            (. gen (loadArg i))
            (. clojure.lang.Compiler$HostExpr (emitBoxReturn nil gen (nth pclasses i))))
                                       ;call init fn
          (. gen (invokeInterface ifn-type (new Method "invoke" obj-type 
                                                (arg-types (inc (count ptypes))))))
          (. gen pop)
          (. gen goTo end-post-init-label)
                                       ;no init found
          (. gen mark no-post-init-label)
          (. gen (throwException ex-type (str impl-pkg-name "/" prefix post-init-name " not defined")))
          (. gen mark end-post-init-label))

        (. gen (returnValue))
        (. gen (endMethod))
                                        ;factory
        (when factory
          (let [fm (new Method factory-name ctype ptypes)
                gen (new GeneratorAdapter (+ (. Opcodes ACC_PUBLIC) (. Opcodes ACC_STATIC)) 
                         fm nil nil cv)]
            (. gen (visitCode))
            (. gen newInstance ctype)
            (. gen dup)
            (. gen (loadArgs))
            (. gen (invokeConstructor ctype m))            
            (. gen (returnValue))
            (. gen (endMethod))))))
    
                                        ;add methods matching supers', if no fn -> call super
    (let [mm (non-private-methods super)]
      (doseq [#^java.lang.reflect.Method meth (vals mm)]
             (emit-forwarding-method (.getName meth) (.getParameterTypes meth) (.getReturnType meth) false
                                     (fn [#^GeneratorAdapter gen #^Method m]
                                       (. gen (loadThis))
                                        ;push args
                                       (. gen (loadArgs))
                                        ;call super
                                       (. gen (visitMethodInsn (. Opcodes INVOKESPECIAL) 
                                                               (. super-type (getInternalName))
                                                               (. m (getName))
                                                               (. m (getDescriptor)))))))
                                        ;add methods matching interfaces', if no fn -> throw
      (reduce (fn [mm #^java.lang.reflect.Method meth]
                (if (contains? mm (method-sig meth))
                  mm
                  (do
                    (emit-forwarding-method (.getName meth) (.getParameterTypes meth) (.getReturnType meth) false
                                            emit-unsupported)
                    (assoc mm (method-sig meth) meth))))
              mm (mapcat #(.getMethods #^Class %) interfaces))
                                        ;extra methods
       (doseq [[mname pclasses rclass :as msig] methods]
         (emit-forwarding-method (str mname) pclasses rclass (:static ^msig)
                                 emit-unsupported))
                                        ;expose specified overridden superclass methods
       (doseq [[local-mname #^java.lang.reflect.Method m] (reduce (fn [ms [[name _ _] m]]
                              (if (contains? exposes-methods (symbol name))
                                (conj ms [((symbol name) exposes-methods) m])
                                ms)) [] (seq mm))]
         (let [ptypes (to-types (.getParameterTypes m))
               rtype (totype (.getReturnType m))
               exposer-m (new Method (str local-mname) rtype ptypes)
               target-m (new Method (.getName m) rtype ptypes)
               gen (new GeneratorAdapter (. Opcodes ACC_PUBLIC) exposer-m nil nil cv)]
           (. gen (loadThis))
           (. gen (loadArgs))
           (. gen (visitMethodInsn (. Opcodes INVOKESPECIAL) 
                                   (. super-type (getInternalName))
                                   (. target-m (getName))
                                   (. target-m (getDescriptor))))
           (. gen (returnValue))
           (. gen (endMethod)))))
                                        ;main
    (when main
      (let [m (. Method getMethod "void main (String[])")
            gen (new GeneratorAdapter (+ (. Opcodes ACC_PUBLIC) (. Opcodes ACC_STATIC)) 
                     m nil nil cv)
            no-main-label (. gen newLabel)
            end-label (. gen newLabel)]
        (. gen (visitCode))

        (emit-get-var gen main-name)
        (. gen dup)
        (. gen ifNull no-main-label)
        (.checkCast gen ifn-type)
        (. gen loadArgs)
        (. gen (invokeStatic rt-type (. Method (getMethod "clojure.lang.ISeq seq(Object)"))))
        (. gen (invokeInterface ifn-type (new Method "applyTo" obj-type 
                                              (into-array [iseq-type]))))
        (. gen pop)
        (. gen goTo end-label)
                                        ;no main found
        (. gen mark no-main-label)
        (. gen (throwException ex-type (str impl-pkg-name "/" prefix main-name " not defined")))
        (. gen mark end-label)
        (. gen (returnValue))
        (. gen (endMethod))))
                                        ;field exposers
    (doseq [[f {getter :get setter :set}] exposes]
      (let [fld (find-field super (str f))
            ftype (totype (.getType fld))
            static? (Modifier/isStatic (.getModifiers fld))
            acc (+ Opcodes/ACC_PUBLIC (if static? Opcodes/ACC_STATIC 0))]
        (when getter
          (let [m (new Method (str getter) ftype (to-types []))
                gen (new GeneratorAdapter acc m nil nil cv)]
            (. gen (visitCode))
            (if static?
              (. gen getStatic ctype (str f) ftype)
              (do
                (. gen loadThis)
                (. gen getField ctype (str f) ftype)))
            (. gen (returnValue))
            (. gen (endMethod))))
        (when setter
          (let [m (new Method (str setter) Type/VOID_TYPE (into-array [ftype]))
                gen (new GeneratorAdapter acc m nil nil cv)]
            (. gen (visitCode))
            (if static?
              (do
                (. gen loadArgs)
                (. gen putStatic ctype (str f) ftype))
              (do
                (. gen loadThis)
                (. gen loadArgs)
                (. gen putField ctype (str f) ftype)))
            (. gen (returnValue))
            (. gen (endMethod))))))
                                        ;finish class def
    (. cv (visitEnd))
    [cname (. cv (toByteArray))]))

(defmacro gen-class 
  "When compiling, generates compiled bytecode for a class with the
  given package-qualified :name (which, as all names in these
  parameters, can be a string or symbol), and writes the .class file
  to the *compile-path* directory.  When not compiling, does
  nothing. The gen-class construct contains no implementation, as the
  implementation will be dynamically sought by the generated class in
  functions in an implementing Clojure namespace. Given a generated
  class org.mydomain.MyClass with a method named mymethod, gen-class
  will generate an implementation that looks for a function named by 
  (str prefix mymethod) (default prefix: \"-\") in a
  Clojure namespace specified by :impl-ns
  (defaults to the current namespace). All inherited methods,
  generated methods, and init and main functions (see :methods, :init,
  and :main below) will be found similarly prefixed. By default, the
  static initializer for the generated class will attempt to load the
  Clojure support code for the class as a resource from the classpath,
  e.g. in the example case, ``org/mydomain/MyClass__init.class``. This
  behavior can be controlled by :load-impl-ns

  Note that methods with a maximum of 18 parameters are supported.

  In all subsequent sections taking types, the primitive types can be
  referred to by their Java names (int, float etc), and classes in the
  java.lang package can be used without a package qualifier. All other
  classes must be fully qualified.

  Options should be a set of key/value pairs, all except for :name are optional:

  :name aname

  The package-qualified name of the class to be generated

  :extends aclass

  Specifies the superclass, the non-private methods of which will be
  overridden by the class. If not provided, defaults to Object.

  :implements [interface ...]

  One or more interfaces, the methods of which will be implemented by the class.

  :init name

  If supplied, names a function that will be called with the arguments
  to the constructor. Must return [ [superclass-constructor-args] state] 
  If not supplied, the constructor args are passed directly to
  the superclass constructor and the state will be nil

  :constructors {[param-types] [super-param-types], ...}

  By default, constructors are created for the generated class which
  match the signature(s) of the constructors for the superclass. This
  parameter may be used to explicitly specify constructors, each entry
  providing a mapping from a constructor signature to a superclass
  constructor signature. When you supply this, you must supply an :init
  specifier. 

  :post-init name

  If supplied, names a function that will be called with the object as
  the first argument, followed by the arguments to the constructor.
  It will be called every time an object of this class is created,
  immediately after all the inherited constructors have completed.
  It's return value is ignored.

  :methods [ [name [param-types] return-type], ...]

  The generated class automatically defines all of the non-private
  methods of its superclasses/interfaces. This parameter can be used
  to specify the signatures of additional methods of the generated
  class. Static methods can be specified with #^{:static true} in the
  signature's metadata. Do not repeat superclass/interface signatures
  here.

  :main boolean

  If supplied and true, a static public main function will be generated. It will
  pass each string of the String[] argument as a separate argument to
  a function called (str prefix main).

  :factory name

  If supplied, a (set of) public static factory function(s) will be
  created with the given name, and the same signature(s) as the
  constructor(s).
  
  :state name

  If supplied, a public final instance field with the given name will be
  created. You must supply an :init function in order to provide a
  value for the state. Note that, though final, the state can be a ref
  or agent, supporting the creation of Java objects with transactional
  or asynchronous mutation semantics.

  :exposes {protected-field-name {:get name :set name}, ...}

  Since the implementations of the methods of the generated class
  occur in Clojure functions, they have no access to the inherited
  protected fields of the superclass. This parameter can be used to
  generate public getter/setter methods exposing the protected field(s)
  for use in the implementation.

  :exposes-methods {super-method-name exposed-name, ...}

  It is sometimes necessary to call the superclass' implementation of an
  overridden method.  Those methods may be exposed and referred in 
  the new method implementation by a local name.

  :prefix string

  Default: \"-\" Methods called e.g. Foo will be looked up in vars called
  prefixFoo in the implementing ns.

  :impl-ns name

  Default: the name of the current ns. Implementations of methods will be looked up in this namespace.

  :load-impl-ns boolean

  Default: true. Causes the static initializer for the generated class
  to reference the load code for the implementing namespace. Should be
  true when implementing-ns is the default, false if you intend to
  load the code via some other method."
  
  [& options]
    (when *compile-files*
      (let [options-map (apply hash-map options)
            [cname bytecode] (generate-class options-map)]
        (clojure.lang.Compiler/writeClassFile cname bytecode))))

;;;;;;;;;;;;;;;;;;;; gen-interface ;;;;;;;;;;;;;;;;;;;;;;
;; based on original contribution by Chris Houser

(defn- #^Type asm-type
  "Returns an asm Type object for c, which may be a primitive class
  (such as Integer/TYPE), any other class (such as Double), or a
  fully-qualified class name given as a string or symbol
  (such as 'java.lang.String)"
  [c]
  (if (or (instance? Class c) (prim->class c))
    (Type/getType (the-class c))
    (let [strx (str c)]
      (Type/getObjectType 
       (.replace (if (some #{\.} strx)
                   strx
                   (str "java.lang." strx)) 
                 "." "/")))))

(defn- generate-interface
  [{:keys [name extends methods]}]
  (let [iname (.replace (str name) "." "/")
        cv (ClassWriter. ClassWriter/COMPUTE_MAXS)]
    (. cv visit Opcodes/V1_5 (+ Opcodes/ACC_PUBLIC 
                                Opcodes/ACC_ABSTRACT
                                Opcodes/ACC_INTERFACE)
       iname nil "java/lang/Object"
       (when (seq extends)
         (into-array (map #(.getInternalName (asm-type %)) extends))))
    (doseq [[mname pclasses rclass] methods]
      (. cv visitMethod (+ Opcodes/ACC_PUBLIC Opcodes/ACC_ABSTRACT)
         (str mname)
         (Type/getMethodDescriptor (asm-type rclass) 
                                   (if pclasses
                                     (into-array Type (map asm-type pclasses))
                                     (make-array Type 0)))
         nil nil))
    (. cv visitEnd)
    [iname (. cv toByteArray)]))

(defmacro gen-interface
  "When compiling, generates compiled bytecode for an interface with
  the given package-qualified :name (which, as all names in these
  parameters, can be a string or symbol), and writes the .class file
  to the *compile-path* directory.  When not compiling, does nothing.
 
  In all subsequent sections taking types, the primitive types can be
  referred to by their Java names (int, float etc), and classes in the
  java.lang package can be used without a package qualifier. All other
  classes must be fully qualified.
 
  Options should be a set of key/value pairs, all except for :name are
  optional:

  :name aname

  The package-qualified name of the class to be generated

  :extends [interface ...]

  One or more interfaces, which will be extended by this interface.

  :methods [ [name [param-types] return-type], ...]

  This parameter is used to specify the signatures of the methods of
  the generated interface.  Do not repeat superinterface signatures
  here."

  [& options]
  (when *compile-files*
    (let [options-map (apply hash-map options)
          [cname bytecode] (generate-interface options-map)]
      (clojure.lang.Compiler/writeClassFile cname bytecode)))) 

(comment

(defn gen-and-load-class 
  "Generates and immediately loads the bytecode for the specified
  class. Note that a class generated this way can be loaded only once
  - the JVM supports only one class with a given name per
  classloader. Subsequent to generation you can import it into any
  desired namespaces just like any other class. See gen-class for a
  description of the options."

  [& options]
  (let [options-map (apply hash-map options)
        [cname bytecode] (generate-class options-map)]
    (.. (clojure.lang.RT/getRootClassLoader) (defineClass cname bytecode))))

)
;   Copyright (c) Rich Hickey. All rights reserved.
;   The use and distribution terms for this software are covered by the
;   Eclipse Public License 1.0 (http://opensource.org/licenses/eclipse-1.0.php)
;   which can be found in the file epl-v10.html at the root of this distribution.
;   By using this software in any fashion, you are agreeing to be bound by
;   the terms of this license.
;   You must not remove this notice, or any other, from this software.

(ns clojure.inspector
    (:import
     (java.awt BorderLayout)
     (java.awt.event ActionEvent ActionListener)
     (javax.swing.tree TreeModel)
     (javax.swing.table TableModel AbstractTableModel)
     (javax.swing JPanel JTree JTable JScrollPane JFrame JToolBar JButton SwingUtilities)))

(defn atom? [x]
  (not (coll? x)))

(defn collection-tag [x]
  (cond 
   (instance? java.util.Map$Entry x) :entry
   (instance? java.util.Map x) :map
   (sequential? x) :seq
   :else :atom))

(defmulti is-leaf collection-tag)
(defmulti get-child (fn [parent index] (collection-tag parent)))
(defmulti get-child-count collection-tag)

(defmethod is-leaf :default [node]
  (atom? node))
(defmethod get-child :default [parent index]
  (nth parent index))
(defmethod get-child-count :default [parent]
  (count parent))

(defmethod is-leaf :entry [e]
  (is-leaf (val e)))
(defmethod get-child :entry [e index]
  (get-child (val e) index))
(defmethod get-child-count :entry [e]
  (count (val e)))

(defmethod is-leaf :map [m]
  false)
(defmethod get-child :map [m index]
  (nth (seq m) index))

(defn tree-model [data]
  (proxy [TreeModel] []
    (getRoot [] data)
    (addTreeModelListener [treeModelListener])
    (getChild [parent index]
      (get-child parent index))
    (getChildCount [parent]
       (get-child-count parent))
    (isLeaf [node]
      (is-leaf node))
    (valueForPathChanged [path newValue])
    (getIndexOfChild [parent child]
      -1)
    (removeTreeModelListener [treeModelListener])))


(defn old-table-model [data]
  (let [row1 (first data)
	colcnt (count row1)
	cnt (count data)
	vals (if (map? row1) vals identity)]
    (proxy [TableModel] []
      (addTableModelListener [tableModelListener])
      (getColumnClass [columnIndex] Object)
      (getColumnCount [] colcnt)
      (getColumnName [columnIndex]
	(if (map? row1)
	  (name (nth (keys row1) columnIndex))
	  (str columnIndex)))
      (getRowCount [] cnt)
      (getValueAt [rowIndex columnIndex]
	(nth (vals (nth data rowIndex)) columnIndex))
      (isCellEditable [rowIndex columnIndex] false)
      (removeTableModelListener [tableModelListener]))))
      
(defn inspect-tree 
  "creates a graphical (Swing) inspector on the supplied hierarchical data"
  [data]
  (doto (JFrame. "Clojure Inspector")
    (.add (JScrollPane. (JTree. (tree-model data))))
    (.setSize 400 600)
    (.setVisible true)))

(defn inspect-table 
  "creates a graphical (Swing) inspector on the supplied regular
  data, which must be a sequential data structure of data structures
  of equal length"
    [data]
  (doto (JFrame. "Clojure Inspector")
    (.add (JScrollPane. (JTable. (old-table-model data))))
    (.setSize 400 600)
    (.setVisible true)))


(defmulti list-provider class)

(defmethod list-provider :default [x]
  {:nrows 1 :get-value (fn [i] x) :get-label (fn [i] (.getName (class x)))})

(defmethod list-provider java.util.List [c]
  (let [v (if (vector? c) c (vec c))]
    {:nrows (count v) 
     :get-value (fn [i] (v i)) 
     :get-label (fn [i] i)}))

(defmethod list-provider java.util.Map [c]
  (let [v (vec (sort (map (fn [[k v]] (vector k v)) c)))]
    {:nrows (count v) 
     :get-value (fn [i] ((v i) 1)) 
     :get-label (fn [i] ((v i) 0))}))

(defn list-model [provider]
  (let [{:keys [nrows get-value get-label]} provider]
    (proxy [AbstractTableModel] []
      (getColumnCount [] 2)
      (getRowCount [] nrows)
      (getValueAt [rowIndex columnIndex]
        (cond 
         (= 0 columnIndex) (get-label rowIndex)
         (= 1 columnIndex) (print-str (get-value rowIndex)))))))

(defmulti table-model class)

(defmethod table-model :default [x]
  (proxy [AbstractTableModel] []
    (getColumnCount [] 2)
    (getRowCount [] 1)
    (getValueAt [rowIndex columnIndex]
      (if (zero? columnIndex)
        (class x)
        x))))

;(defn make-inspector [x]
;  (agent {:frame frame :data x :parent nil :index 0}))


(defn inspect
  "creates a graphical (Swing) inspector on the supplied object"
  [x]
  (doto (JFrame. "Clojure Inspector")
    (.add
      (doto (JPanel. (BorderLayout.))
        (.add (doto (JToolBar.)
                (.add (JButton. "Back"))
                (.addSeparator)
                (.add (JButton. "List"))
                (.add (JButton. "Table"))
                (.add (JButton. "Bean"))
                (.add (JButton. "Line"))
                (.add (JButton. "Bar"))
                (.addSeparator)
                (.add (JButton. "Prev"))
                (.add (JButton. "Next")))
              BorderLayout/NORTH)
        (.add
          (JScrollPane. 
            (doto (JTable. (list-model (list-provider x)))
              (.setAutoResizeMode JTable/AUTO_RESIZE_LAST_COLUMN)))
          BorderLayout/CENTER)))
    (.setSize 400 400)
    (.setVisible true)))


(comment

(load-file "src/inspector.clj")
(refer 'inspector)
(inspect-tree {:a 1 :b 2 :c [1 2 3 {:d 4 :e 5 :f [6 7 8]}]})
(inspect-table [[1 2 3][4 5 6][7 8 9][10 11 12]])

)
;; Copyright (c) Rich Hickey All rights reserved. The use and
;; distribution terms for this software are covered by the Eclipse Public
;; License 1.0 (http://opensource.org/licenses/eclipse-1.0.php) which can be found
;; in the file epl-v10.html at the root of this distribution. By using this
;; software in any fashion, you are agreeing to be bound by the terms of
;; this license. You must not remove this notice, or any other, from this
;; software.

;; Originally contributed by Stephen C. Gilardi

(ns clojure.main
  (:import (clojure.lang Compiler Compiler$CompilerException
                         LineNumberingPushbackReader RT)))

(declare main)

(defmacro with-bindings
  "Executes body in the context of thread-local bindings for several vars
  that often need to be set!: *ns* *warn-on-reflection* *print-meta*
  *print-length* *print-level* *compile-path* *command-line-args* *1
  *2 *3 *e"
  [& body]
  `(binding [*ns* *ns*
             *warn-on-reflection* *warn-on-reflection*
             *print-meta* *print-meta*
             *print-length* *print-length*
             *print-level* *print-level*
             *compile-path* (System/getProperty "clojure.compile.path" "classes")
             *command-line-args* *command-line-args*
             *1 nil
             *2 nil
             *3 nil
             *e nil]
     ~@body))

(defn repl-prompt
  "Default :prompt hook for repl"
  []
  (printf "%s=> " (ns-name *ns*)))

(defn skip-if-eol
  "If the next character on stream s is a newline, skips it, otherwise
  leaves the stream untouched. Returns :line-start, :stream-end, or :body
  to indicate the relative location of the next character on s. The stream
  must either be an instance of LineNumberingPushbackReader or duplicate
  its behavior of both supporting .unread and collapsing all of CR, LF, and
  CRLF to a single \\newline."
  [s]
  (let [c (.read s)]
    (cond
     (= c (int \newline)) :line-start
     (= c -1) :stream-end
     :else (do (.unread s c) :body))))

(defn skip-whitespace
  "Skips whitespace characters on stream s. Returns :line-start, :stream-end,
  or :body to indicate the relative location of the next character on s.
  Interprets comma as whitespace and semicolon as comment to end of line.
  Does not interpret #! as comment to end of line because only one
  character of lookahead is available. The stream must either be an
  instance of LineNumberingPushbackReader or duplicate its behavior of both
  supporting .unread and collapsing all of CR, LF, and CRLF to a single
  \\newline."
  [s]
  (loop [c (.read s)]
    (cond
     (= c (int \newline)) :line-start
     (= c -1) :stream-end
     (= c (int \;)) (do (.readLine s) :line-start)
     (or (Character/isWhitespace c) (= c (int \,))) (recur (.read s))
     :else (do (.unread s c) :body))))

(defn repl-read
  "Default :read hook for repl. Reads from *in* which must either be an
  instance of LineNumberingPushbackReader or duplicate its behavior of both
  supporting .unread and collapsing all of CR, LF, and CRLF into a single
  \\newline. repl-read:
    - skips whitespace, then
      - returns request-prompt on start of line, or
      - returns request-exit on end of stream, or
      - reads an object from the input stream, then
        - skips the next input character if it's end of line, then
        - returns the object."
  [request-prompt request-exit]
  (or ({:line-start request-prompt :stream-end request-exit}
       (skip-whitespace *in*))
      (let [input (read)]
        (skip-if-eol *in*)
        input)))

(defn- root-cause
  "Returns the initial cause of an exception or error by peeling off all of
  its wrappers"
  [throwable]
  (loop [cause throwable]
    (if-let [cause (.getCause cause)]
      (recur cause)
      cause)))

(defn repl-exception
  "Returns CompilerExceptions in tact, but only the root cause of other
  throwables"
  [throwable]
  (if (instance? Compiler$CompilerException throwable)
    throwable
    (root-cause throwable)))

(defn repl-caught
  "Default :caught hook for repl"
  [e]
  (.println *err* (repl-exception e)))

(defn repl
  "Generic, reusable, read-eval-print loop. By default, reads from *in*,
  writes to *out*, and prints exception summaries to *err*. If you use the
  default :read hook, *in* must either be an instance of
  LineNumberingPushbackReader or duplicate its behavior of both supporting
  .unread and collapsing CR, LF, and CRLF into a single \\newline. Options
  are sequential keyword-value pairs. Available options and their defaults:

     - :init, function of no arguments, initialization hook called with
       bindings for set!-able vars in place.
       default: #()

     - :need-prompt, function of no arguments, called before each
       read-eval-print except the first, the user will be prompted if it
       returns true.
       default: (if (instance? LineNumberingPushbackReader *in*)
                  #(.atLineStart *in*)
                  #(identity true))

     - :prompt, function of no arguments, prompts for more input.
       default: repl-prompt

     - :flush, function of no arguments, flushes output
       default: flush

     - :read, function of two arguments, reads from *in*:
         - returns its first argument to request a fresh prompt
           - depending on need-prompt, this may cause the repl to prompt
             before reading again
         - returns its second argument to request an exit from the repl
         - else returns the next object read from the input stream
       default: repl-read

     - :eval, funtion of one argument, returns the evaluation of its
       argument
       default: eval

     - :print, function of one argument, prints its argument to the output
       default: prn

     - :caught, function of one argument, a throwable, called when
       read, eval, or print throws an exception or error
       default: repl-caught"
  [& options]
  (let [{:keys [init need-prompt prompt flush read eval print caught]
         :or {init        #()
              need-prompt (if (instance? LineNumberingPushbackReader *in*)
                            #(.atLineStart *in*)
                            #(identity true))
              prompt      repl-prompt
              flush       flush
              read        repl-read
              eval        eval
              print       prn
              caught      repl-caught}}
        (apply hash-map options)
        request-prompt (Object.)
        request-exit (Object.)
        read-eval-print
        (fn []
          (try
           (let [input (read request-prompt request-exit)]
             (or (#{request-prompt request-exit} input)
                 (let [value (eval input)]
                   (print value)
                   (set! *3 *2)
                   (set! *2 *1)
                   (set! *1 value))))
           (catch Throwable e
             (caught e)
             (set! *e e))))]
    (with-bindings
     (try
      (init)
      (catch Throwable e
        (caught e)
        (set! *e e)))
     (prompt)
     (flush)
     (loop []
       (when-not (= (read-eval-print) request-exit)
         (when (need-prompt)
           (prompt)
           (flush))
         (recur))))))

(defn load-script
  "Loads Clojure source from a file or resource given its path. Paths
  beginning with @ or @/ are considered relative to classpath."
  [path]
  (if (.startsWith path "@")
    (RT/loadResourceScript
     (.substring path (if (.startsWith path "@/") 2 1)))
    (Compiler/loadFile path)))

(defn- init-opt
  "Load a script"
  [path]
  (load-script path))

(defn- eval-opt
  "Evals expressions in str, prints each non-nil result using prn"
  [str]
  (let [eof (Object.)]
    (with-in-str str
      (loop [input (read *in* false eof)]
        (when-not (= input eof)
          (let [value (eval input)]
            (when-not (nil? value)
              (prn value))
            (recur (read *in* false eof))))))))

(defn- init-dispatch
  "Returns the handler associated with an init opt"
  [opt]
  ({"-i"     init-opt
    "--init" init-opt
    "-e"     eval-opt
    "--eval" eval-opt} opt))

(defn- initialize
  "Common initialize routine for repl, script, and null opts"
  [args inits]
  (in-ns 'user)
  (set! *command-line-args* args)
  (doseq [[opt arg] inits]
    ((init-dispatch opt) arg)))

(defn- repl-opt
  "Start a repl with args and inits. Print greeting if no eval options were
  present"
  [[_ & args] inits]
  (when-not (some #(= eval-opt (init-dispatch (first %))) inits)
    (println "Clojure" (clojure-version)))
  (repl :init #(initialize args inits))
  (prn)
  (System/exit 0))

(defn- script-opt
  "Run a script from a file, resource, or standard in with args and inits"
  [[path & args] inits]
  (with-bindings
    (initialize args inits)
    (if (= path "-")
      (load-reader *in*)
      (load-script path))))

(defn- null-opt
  "No repl or script opt present, just bind args and run inits"
  [args inits]
  (with-bindings
    (initialize args inits)))

(defn- help-opt
  "Print help text for main"
  [_ _]
  (println (:doc (meta (var main)))))

(defn- main-dispatch
  "Returns the handler associated with a main option"
  [opt]
  (or
   ({"-r"     repl-opt
     "--repl" repl-opt
     nil      null-opt
     "-h"     help-opt
     "--help" help-opt
     "-?"     help-opt} opt)
   script-opt))

(defn- legacy-repl
  "Called by the clojure.lang.Repl.main stub to run a repl with args
  specified the old way"
  [args]
  (let [[inits [sep & args]] (split-with (complement #{"--"}) args)]
    (repl-opt (concat ["-r"] args) (map vector (repeat "-i") inits))))

(defn- legacy-script
  "Called by the clojure.lang.Script.main stub to run a script with args
  specified the old way"
  [args]
  (let [[inits [sep & args]] (split-with (complement #{"--"}) args)]
    (null-opt args (map vector (repeat "-i") inits))))

(defn main
  "Usage: java -cp clojure.jar clojure.main [init-opt*] [main-opt] [arg*]

  With no options or args, runs an interactive Read-Eval-Print Loop

  init options:
    -i, --init path   Load a file or resource
    -e, --eval string Evaluate expressions in string; print non-nil values

  main options:
    -r, --repl        Run a repl
    path              Run a script from from a file or resource
    -                 Run a script from standard input
    -h, -?, --help    Print this help message and exit

  operation:

    - Establishes thread-local bindings for commonly set!-able vars
    - Enters the user namespace
    - Binds *command-line-args* to a seq of strings containing command line
      args that appear after any main option
    - Runs all init options in order
    - Runs a repl or script if requested

  The init options may be repeated and mixed freely, but must appear before
  any main option. The appearance of any eval option before running a repl
  suppresses the usual repl greeting message: \"Clojure ~(clojure-version)\".

  Paths may be absolute or relative in the filesystem or relative to
  classpath. Classpath-relative paths have prefix of @ or @/"
  [& args]
  (try
   (if args
     (loop [[opt arg & more :as args] args inits []]
       (if (init-dispatch opt)
         (recur more (conj inits [opt arg]))
         ((main-dispatch opt) args inits)))
     (repl-opt nil nil))
   (finally 
     (flush))))

;   Copyright (c) Rich Hickey. All rights reserved.
;   The use and distribution terms for this software are covered by the
;   Eclipse Public License 1.0 (http://opensource.org/licenses/eclipse-1.0.php)
;   which can be found in the file epl-v10.html at the root of this distribution.
;   By using this software in any fashion, you are agreeing to be bound by
;   the terms of this license.
;   You must not remove this notice, or any other, from this software.

(ns clojure.parallel)
(alias 'parallel 'clojure.parallel)

(comment "
The parallel library wraps the ForkJoin library scheduled for inclusion in JDK 7:

http://gee.cs.oswego.edu/dl/concurrency-interest/index.html

You'll need jsr166y.jar in your classpath in order to use this
library.  The basic idea is that Clojure collections, and most
efficiently vectors, can be turned into parallel arrays for use by
this library with the function par, although most of the functions
take collections and will call par if needed, so normally you will
only need to call par explicitly in order to attach bound/filter/map
ops. Parallel arrays support the attachment of bounds, filters and
mapping functions prior to realization/calculation, which happens as
the result of any of several operations on the
array (pvec/psort/pfilter-nils/pfilter-dupes). Rather than perform
composite operations in steps, as would normally be done with
sequences, maps and filters are instead attached and thus composed by
providing ops to par. Note that there is an order sensitivity to the
attachments - bounds precede filters precede mappings.  All operations
then happen in parallel, using multiple threads and a sophisticated
work-stealing system supported by fork-join, either when the array is
realized, or to perform aggregate operations like preduce/pmin/pmax
etc. A parallel array can be realized into a Clojure vector using
pvec.
")

(import '(jsr166y.forkjoin ParallelArray ParallelArrayWithBounds ParallelArrayWithFilter 
                           ParallelArrayWithMapping 
                           Ops$Op Ops$BinaryOp Ops$Reducer Ops$Predicate Ops$BinaryPredicate 
                           Ops$IntAndObjectPredicate Ops$IntAndObjectToObject))

(defn- op [f]
  (proxy [Ops$Op] []
    (op [x] (f x))))

(defn- binary-op [f]
  (proxy [Ops$BinaryOp] []
    (op [x y] (f x y))))

(defn- int-and-object-to-object [f]
  (proxy [Ops$IntAndObjectToObject] []
    (op [i x] (f x i))))

(defn- reducer [f]
  (proxy [Ops$Reducer] []
    (op [x y] (f x y))))

(defn- predicate [f]
  (proxy [Ops$Predicate] []
    (op [x] (boolean (f x)))))

(defn- binary-predicate [f]
  (proxy [Ops$BinaryPredicate] []
    (op [x y] (boolean (f x y)))))

(defn- int-and-object-predicate [f]
  (proxy [Ops$IntAndObjectPredicate] []
    (op [i x] (boolean (f x i)))))

(defn par
  "Creates a parallel array from coll. ops, if supplied, perform
  on-the-fly filtering or transformations during parallel realization
  or calculation. ops form a chain, and bounds must precede filters,
  must precede maps. ops must be a set of keyword value pairs of the
  following forms:

     :bound [start end] 

  Only elements from start (inclusive) to end (exclusive) will be
  processed when the array is realized.

     :filter pred 

  Filter preds remove elements from processing when the array is realized. pred
  must be a function of one argument whose return will be processed
  via boolean.

     :filter-index pred2 

  pred2 must be a function of two arguments, which will be an element
  of the collection and the corresponding index, whose return will be
  processed via boolean.

     :filter-with [pred2 coll2] 

  pred2 must be a function of two arguments, which will be
  corresponding elements of the 2 collections.

     :map f 

  Map fns will be used to transform elements when the array is
  realized. f must be a function of one argument.

     :map-index f2 

  f2 must be a function of two arguments, which will be an element of
  the collection and the corresponding index.

     :map-with [f2 coll2]

  f2 must be a function of two arguments, which will be corresponding
  elements of the 2 collections."

  ([coll] 
     (if (instance? ParallelArrayWithMapping coll)
       coll
       (. ParallelArray createUsingHandoff  
        (to-array coll) 
        (. ParallelArray defaultExecutor))))
  ([coll & ops]
     (reduce (fn [pa [op args]] 
                 (cond
                  (= op :bound) (. pa withBounds (args 0) (args 1))
                  (= op :filter) (. pa withFilter (predicate args))
                  (= op :filter-with) (. pa withFilter (binary-predicate (args 0)) (par (args 1)))
                  (= op :filter-index) (. pa withIndexedFilter (int-and-object-predicate args))
                  (= op :map) (. pa withMapping (parallel/op args))
                  (= op :map-with) (. pa withMapping (binary-op (args 0)) (par (args 1)))
                  (= op :map-index) (. pa withIndexedMapping (int-and-object-to-object args))
                  :else (throw (Exception. (str "Unsupported par op: " op)))))
             (par coll) 
             (partition 2 ops))))

;;;;;;;;;;;;;;;;;;;;; aggregate operations ;;;;;;;;;;;;;;;;;;;;;;
(defn pany
  "Returns some (random) element of the coll if it satisfies the bound/filter/map"
  [coll] 
  (. (par coll) any))

(defn pmax
  "Returns the maximum element, presuming Comparable elements, unless
  a Comparator comp is supplied"
  ([coll] (. (par coll) max))
  ([coll comp] (. (par coll) max comp)))

(defn pmin
  "Returns the minimum element, presuming Comparable elements, unless
  a Comparator comp is supplied"
  ([coll] (. (par coll) min))
  ([coll comp] (. (par coll) min comp)))

(defn- summary-map [s]
  {:min (.min s) :max (.max s) :size (.size s) :min-index (.indexOfMin s) :max-index (.indexOfMax s)})

(defn psummary 
  "Returns a map of summary statistics (min. max, size, min-index, max-index, 
  presuming Comparable elements, unless a Comparator comp is supplied"
  ([coll] (summary-map (. (par coll) summary)))
  ([coll comp] (summary-map (. (par coll) summary comp))))

(defn preduce 
  "Returns the reduction of the realized elements of coll
  using function f. Note f will not necessarily be called
  consecutively, and so must be commutative. Also note that 
  (f base an-element) might be performed many times, i.e. base is not
  an initial value as with sequential reduce."
  [f base coll]
  (. (par coll) (reduce (reducer f) base)))

;;;;;;;;;;;;;;;;;;;;; collection-producing operations ;;;;;;;;;;;;;;;;;;;;;;

(defn- pa-to-vec [pa]
  (vec (. pa getArray)))

(defn- pall
  "Realizes a copy of the coll as a parallel array, with any bounds/filters/maps applied"
  [coll]
  (if (instance? ParallelArrayWithMapping coll)
    (. coll all)
    (par coll)))

(defn pvec 
  "Returns the realized contents of the parallel array pa as a Clojure vector"
  [pa] (pa-to-vec (pall pa)))

(defn pdistinct
  "Returns a parallel array of the distinct elements of coll"
  [coll]
  (pa-to-vec (. (pall coll) allUniqueElements)))

;this doesn't work, passes null to reducer?
(defn- pcumulate [coll f init]
  (.. (pall coll) (precumulate (reducer f) init)))

(defn psort 
  "Returns a new vector consisting of the realized items in coll, sorted, 
  presuming Comparable elements, unless a Comparator comp is supplied"
  ([coll] (pa-to-vec (. (pall coll) sort)))
  ([coll comp] (pa-to-vec (. (pall coll) sort comp))))

(defn pfilter-nils
  "Returns a vector containing the non-nil (realized) elements of coll"
  [coll]
  (pa-to-vec (. (pall coll) removeNulls)))

(defn pfilter-dupes 
  "Returns a vector containing the (realized) elements of coll, 
  without any consecutive duplicates"
  [coll]
  (pa-to-vec (. (pall coll) removeConsecutiveDuplicates)))


(comment
(load-file "src/parallel.clj")
(refer 'parallel)
(pdistinct [1 2 3 2 1])
;(pcumulate [1 2 3 2 1] + 0) ;broken, not exposed
(def a (make-array Object 1000000))
(dotimes i (count a)
  (aset a i (rand-int i)))
(time (reduce + 0 a))
(time (preduce + 0 a))
(time (count (distinct a)))
(time (count (pdistinct a)))

(preduce + 0 [1 2 3 2 1])
(preduce + 0 (psort a))
(pvec (par [11 2 3 2] :filter-index (fn [x i] (> i x))))
(pvec (par [11 2 3 2] :filter-with [(fn [x y] (> y x)) [110 2 33 2]]))

(psummary ;or pvec/pmax etc
 (par [11 2 3 2] 
      :filter-with [(fn [x y] (> y x)) 
                    [110 2 33 2]]
      :map #(* % 2)))

(preduce + 0
  (par [11 2 3 2] 
       :filter-with [< [110 2 33 2]]))

(time (reduce + 0 (map #(* % %) (range 1000000))))
(time (preduce + 0 (par (range 1000000) :map-index *)))
(def v (range 1000000))
(time (preduce + 0 (par v :map-index *)))
(time (preduce + 0 (par v :map  #(* % %))))
(time (reduce + 0 (map #(* % %) v)))
);   Copyright (c) Rich Hickey. All rights reserved.
;   The use and distribution terms for this software are covered by the
;   Eclipse Public License 1.0 (http://opensource.org/licenses/eclipse-1.0.php)
;   which can be found in the file epl-v10.html at the root of this distribution.
;   By using this software in any fashion, you are agreeing to be bound by
;   the terms of this license.
;   You must not remove this notice, or any other, from this software.

(ns clojure.set)

(defn- bubble-max-key [k coll]
  "Move a maximal element of coll according to fn k (which returns a number) 
   to the front of coll."
  (let [max (apply max-key k coll)]
    (cons max (remove #(identical? max %) coll))))

(defn union
  "Return a set that is the union of the input sets"
  ([] #{})
  ([s1] s1)
  ([s1 s2]
     (if (< (count s1) (count s2))
       (reduce conj s2 s1)
       (reduce conj s1 s2)))
  ([s1 s2 & sets]
     (let [bubbled-sets (bubble-max-key count (conj sets s2 s1))]
       (reduce into (first bubbled-sets) (rest bubbled-sets)))))

(defn intersection
  "Return a set that is the intersection of the input sets"
  ([s1] s1)
  ([s1 s2]
     (if (< (count s2) (count s1))
       (recur s2 s1)
       (reduce (fn [result item]
                   (if (contains? s2 item)
		     result
                     (disj result item)))
	       s1 s1)))
  ([s1 s2 & sets] 
     (let [bubbled-sets (bubble-max-key #(- (count %)) (conj sets s2 s1))]
       (reduce intersection (first bubbled-sets) (rest bubbled-sets)))))

(defn difference
  "Return a set that is the first set without elements of the remaining sets"
  ([s1] s1)
  ([s1 s2] 
     (if (< (count s1) (count s2))
       (reduce (fn [result item] 
                   (if (contains? s2 item) 
                     (disj result item) 
                     result))
               s1 s1)
       (reduce disj s1 s2)))
  ([s1 s2 & sets] 
     (reduce difference s1 (conj sets s2))))


(defn select
  "Returns a set of the elements for which pred is true"
  [pred xset]
    (reduce (fn [s k] (if (pred k) s (disj s k)))
            xset xset))

(defn project
  "Returns a rel of the elements of xrel with only the keys in ks"
  [xrel ks]
    (set (map #(select-keys % ks) xrel)))

(defn rename-keys
  "Returns the map with the keys in kmap renamed to the vals in kmap"
  [map kmap]
    (reduce 
     (fn [m [old new]]
       (if (not= old new)
         (-> m (assoc new (m old)) (dissoc old))
         m)) 
     map kmap))

(defn rename
  "Returns a rel of the maps in xrel with the keys in kmap renamed to the vals in kmap"
  [xrel kmap]
    (set (map #(rename-keys % kmap) xrel)))

(defn index
  "Returns a map of the distinct values of ks in the xrel mapped to a
  set of the maps in xrel with the corresponding values of ks."
  [xrel ks]
    (reduce
     (fn [m x]
       (let [ik (select-keys x ks)]
         (assoc m ik (conj (get m ik #{}) x))))
     {} xrel))
   
(defn map-invert
  "Returns the map with the vals mapped to the keys."
  [m] (reduce (fn [m [k v]] (assoc m v k)) {} m))

(defn join
  "When passed 2 rels, returns the rel corresponding to the natural
  join. When passed an additional keymap, joins on the corresponding
  keys."
  ([xrel yrel] ;natural join
   (if (and (seq xrel) (seq yrel))
     (let [ks (intersection (set (keys (first xrel))) (set (keys (first yrel))))
           [r s] (if (<= (count xrel) (count yrel))
                   [xrel yrel]
                   [yrel xrel])
           idx (index r ks)]
       (reduce (fn [ret x]
                 (let [found (idx (select-keys x ks))]
                   (if found
                     (reduce #(conj %1 (merge %2 x)) ret found)
                     ret)))
               #{} s))
     #{}))
  ([xrel yrel km] ;arbitrary key mapping
   (let [[r s k] (if (<= (count xrel) (count yrel))
                   [xrel yrel (map-invert km)]
                   [yrel xrel km])
         idx (index r (vals k))]
     (reduce (fn [ret x]
               (let [found (idx (rename-keys (select-keys x (keys k)) k))]
                 (if found
                   (reduce #(conj %1 (merge %2 x)) ret found)
                   ret)))
             #{} s))))

(comment
(refer 'set)
(def xs #{{:a 11 :b 1 :c 1 :d 4}
         {:a 2 :b 12 :c 2 :d 6}
         {:a 3 :b 3 :c 3 :d 8 :f 42}})

(def ys #{{:a 11 :b 11 :c 11 :e 5}
         {:a 12 :b 11 :c 12 :e 3}
         {:a 3 :b 3 :c 3 :e 7 }})

(join xs ys)
(join xs (rename ys {:b :yb :c :yc}) {:a :a})

(union #{:a :b :c} #{:c :d :e })
(difference #{:a :b :c} #{:c :d :e})
(intersection #{:a :b :c} #{:c :d :e})

(index ys [:b])
)

;   Copyright (c) Rich Hickey. All rights reserved.
;   The use and distribution terms for this software are covered by the
;   Eclipse Public License 1.0 (http://opensource.org/licenses/eclipse-1.0.php)
;   which can be found in the file epl-v10.html at the root of this distribution.
;   By using this software in any fashion, you are agreeing to be bound by
;   the terms of this license.
;   You must not remove this notice, or any other, from this software.

(ns clojure.xml
    (:import (org.xml.sax ContentHandler Attributes SAXException)
             (javax.xml.parsers SAXParser SAXParserFactory)))

(def *stack*)
(def *current*)
(def *state*) ; :element :chars :between
(def *sb*)

(defstruct element :tag :attrs :content)

(def tag (accessor element :tag))
(def attrs (accessor element :attrs))
(def content (accessor element :content))

(def content-handler
  (let [push-content (fn [e c]
                       (assoc e :content (conj (or (:content e) []) c)))
        push-chars (fn []
                     (when (and (= *state* :chars)
                                (some (complement #(. Character (isWhitespace %))) (str *sb*)))
                       (set! *current* (push-content *current* (str *sb*)))))]
    (new clojure.lang.XMLHandler
         (proxy [ContentHandler] []
           (startElement [uri local-name q-name #^Attributes atts]
             (let [attrs (fn [ret i]
                           (if (neg? i)
                             ret
                             (recur (assoc ret 
                                           (. clojure.lang.Keyword (intern (symbol (. atts (getQName i)))))
                                           (. atts (getValue i)))
                                    (dec i))))
                   e (struct element 
                             (. clojure.lang.Keyword (intern (symbol q-name)))
                             (when (pos? (. atts (getLength)))
                               (attrs {} (dec (. atts (getLength))))))]
               (push-chars)
               (set! *stack* (conj *stack* *current*))
               (set! *current* e)
               (set! *state* :element))
             nil)
           (endElement [uri local-name q-name]
             (push-chars)
             (set! *current* (push-content (peek *stack*) *current*))
             (set! *stack* (pop *stack*))
             (set! *state* :between)
             nil)
           (characters [ch start length]
             (when-not (= *state* :chars)
               (set! *sb* (new StringBuilder)))
             (let [#^StringBuilder sb *sb*]
               (. sb (append ch start length))
               (set! *state* :chars))
             nil)
           (setDocumentLocator [locator])
           (startDocument [])
           (endDocument [])
           (startPrefixMapping [prefix uri])
           (endPrefixMapping [prefix])
           (ignorableWhitespace [ch start length])
           (processingInstruction [target data])
           (skippedEntity [name])
           ))))

(defn startparse-sax [s ch]
  (.. SAXParserFactory (newInstance) (newSAXParser) (parse s ch)))

(defn parse
  "Parses and loads the source s, which can be a File, InputStream or
  String naming a URI. Returns a tree of the xml/element struct-map,
  which has the keys :tag, :attrs, and :content. and accessor fns tag,
  attrs, and content. Other parsers can be supplied by passing
  startparse, a fn taking a source and a ContentHandler and returning
  a parser"
  ([s] (parse s startparse-sax))
  ([s startparse]
    (binding [*stack* nil
              *current* (struct element)
              *state* :between
              *sb* nil]
      (startparse s content-handler)
      ((:content *current*) 0)))) 

(defn emit-element [e]
  (if (instance? String e)
    (println e)
    (do
      (print (str "<" (name (:tag e))))
      (when (:attrs e)
	(doseq [attr (:attrs e)]
	  (print (str " " (name (key attr)) "='" (val attr)"'"))))
      (if (:content e)
	(do
	  (println ">")
	  (doseq [c (:content e)]
	    (emit-element c))
	  (println (str "</" (name (:tag e)) ">")))
	(println "/>")))))

(defn emit [x]
  (println "<?xml version='1.0' encoding='UTF-8'?>")
  (emit-element x))

;(export '(tag attrs content parse element emit emit-element))

;(load-file "/Users/rich/dev/clojure/src/xml.clj")
;(def x (xml/parse "http://arstechnica.com/journals.rssx"))
;   Copyright (c) Rich Hickey. All rights reserved.
;   The use and distribution terms for this software are covered by the
;   Eclipse Public License 1.0 (http://opensource.org/licenses/eclipse-1.0.php)
;   which can be found in the file epl-v10.html at the root of this distribution.
;   By using this software in any fashion, you are agreeing to be bound by
;   the terms of this license.
;   You must not remove this notice, or any other, from this software.

;functional hierarchical zipper, with navigation, editing and enumeration
;see Huet

(ns clojure.zip
    (:refer-clojure :exclude (replace remove next)))

(defn zipper
  "Creates a new zipper structure. 

  branch? is a fn that, given a node, returns true if can have
  children, even if it currently doesn't.

  children is a fn that, given a branch node, returns a seq of its
  children.

  make-node is a fn that, given an existing node and a seq of
  children, returns a new branch node with the supplied children.
  root is the root node."  
  [branch? children make-node root]
    #^{:zip/branch? branch? :zip/children children :zip/make-node make-node} 
    [root nil])

(defn seq-zip
  "Returns a zipper for nested sequences, given a root sequence"
  [root]
    (zipper seq? identity (fn [node children] children) root))

(defn vector-zip
  "Returns a zipper for nested vectors, given a root vector"
  [root]
    (zipper vector? seq (fn [node children] (apply vector children)) root))

(defn xml-zip
  "Returns a zipper for xml elements (as from xml/parse),
  given a root element"
  [root]
    (zipper (complement string?) 
            (comp seq :content)
            (fn [node children]
              (assoc node :content (and children (apply vector children))))
            root))

(defn node
  "Returns the node at loc"
  [loc] (loc 0))

(defn branch?
  "Returns true if the node at loc is a branch"
  [loc]
    ((:zip/branch? ^loc) (node loc)))

(defn children
  "Returns a seq of the children of node at loc, which must be a branch"
  [loc]
    ((:zip/children ^loc) (node loc)))

(defn make-node
  "Returns a new branch node, given an existing node and new
  children. The loc is only used to supply the constructor."
  [loc node children]
    ((:zip/make-node ^loc) node children))

(defn path
  "Returns a seq of nodes leading to this loc"
  [loc]
    (:pnodes (loc 1)))

(defn lefts
  "Returns a seq of the left siblings of this loc"
  [loc]
    (seq (:l (loc 1))))

(defn rights
  "Returns a seq of the right siblings of this loc"
  [loc]
    (:r (loc 1)))


(defn down
  "Returns the loc of the leftmost child of the node at this loc, or
  nil if no children"
  [loc]
    (let [[node path] loc
          [c & cnext :as cs] (children loc)]
      (when cs
        (with-meta [c {:l [] 
                       :pnodes (if path (conj (:pnodes path) node) [node]) 
                       :ppath path 
                       :r cnext}] ^loc))))

(defn up
  "Returns the loc of the parent of the node at this loc, or nil if at
  the top"
  [loc]
    (let [[node {l :l, ppath :ppath, pnodes :pnodes r :r, changed? :changed?, :as path}] loc]
      (when pnodes
        (let [pnode (peek pnodes)]
          (with-meta (if changed?
                       [(make-node loc pnode (concat l (cons node r))) 
                        (and ppath (assoc ppath :changed? true))]
                       [pnode ppath])
                     ^loc)))))

(defn root
  "zips all the way up and returns the root node, reflecting any
 changes."
  [loc]
    (if (= :end (loc 1))
      (node loc)
      (let [p (up loc)]
        (if p
          (recur p)
          (node loc)))))

(defn right
  "Returns the loc of the right sibling of the node at this loc, or nil"
  [loc]
    (let [[node {l :l  [r & rnext :as rs] :r :as path}] loc]
      (when (and path rs)
        (with-meta [r (assoc path :l (conj l node) :r rnext)] ^loc))))

(defn rightmost
  "Returns the loc of the rightmost sibling of the node at this loc, or self"
  [loc]
    (let [[node {l :l r :r :as path}] loc]
      (if (and path r)
        (with-meta [(last r) (assoc path :l (apply conj l node (butlast r)) :r nil)] ^loc)
        loc)))

(defn left
  "Returns the loc of the left sibling of the node at this loc, or nil"
  [loc]
    (let [[node {l :l r :r :as path}] loc]
      (when (and path (seq l))
        (with-meta [(peek l) (assoc path :l (pop l) :r (cons node r))] ^loc))))

(defn leftmost
  "Returns the loc of the leftmost sibling of the node at this loc, or self"
  [loc]
    (let [[node {l :l r :r :as path}] loc]
      (if (and path (seq l))
        (with-meta [(first l) (assoc path :l [] :r (concat (rest l) [node] r))] ^loc)
        loc)))

(defn insert-left
  "Inserts the item as the left sibling of the node at this loc,
 without moving"
  [loc item]
    (let [[node {l :l :as path}] loc]
      (if (nil? path)
        (throw (new Exception "Insert at top"))
        (with-meta [node (assoc path :l (conj l item) :changed? true)] ^loc))))

(defn insert-right
  "Inserts the item as the right sibling of the node at this loc,
  without moving"
  [loc item]
    (let [[node {r :r :as path}] loc]
      (if (nil? path)
        (throw (new Exception "Insert at top"))
        (with-meta [node (assoc path :r (cons item r) :changed? true)] ^loc))))

(defn replace
  "Replaces the node at this loc, without moving"
  [loc node]
    (let [[_ path] loc]
      (with-meta [node (assoc path :changed? true)] ^loc)))

(defn edit
  "Replaces the node at this loc with the value of (f node args)"
  [loc f & args]
    (replace loc (apply f (node loc) args)))

(defn insert-child
  "Inserts the item as the leftmost child of the node at this loc,
  without moving"
  [loc item]
    (replace loc (make-node loc (node loc) (cons item (children loc)))))

(defn append-child
  "Inserts the item as the rightmost child of the node at this loc,
  without moving"
  [loc item]
    (replace loc (make-node loc (node loc) (concat (children loc) [item]))))

(defn next
  "Moves to the next loc in the hierarchy, depth-first. When reaching
  the end, returns a distinguished loc detectable via end?. If already
  at the end, stays there."
  [loc]
    (if (= :end (loc 1))
      loc
      (or 
       (and (branch? loc) (down loc))
       (right loc)
       (loop [p loc]
         (if (up p)
           (or (right (up p)) (recur (up p)))
           [(node p) :end])))))

(defn prev
  "Moves to the previous loc in the hierarchy, depth-first. If already
  at the root, returns nil."
  [loc]
    (if-let [lloc (left loc)]
      (loop [loc lloc]
        (if-let [child (and (branch? loc) (down loc))]
          (recur (rightmost child))
          loc))
      (up loc)))

(defn end?
  "Returns true if loc represents the end of a depth-first walk"
  [loc]
    (= :end (loc 1)))

(defn remove
  "Removes the node at loc, returning the loc that would have preceded
  it in a depth-first walk."
  [loc]
    (let [[node {l :l, ppath :ppath, pnodes :pnodes, rs :r, :as path}] loc]
      (if (nil? path)
        (throw (new Exception "Remove at top"))
        (if (pos? (count l))
          (loop [loc (with-meta [(peek l) (assoc path :l (pop l) :changed? true)] ^loc)]
            (if-let [child (and (branch? loc) (down loc))]
              (recur (rightmost child))
              loc))
          (with-meta [(make-node loc (peek pnodes) rs) 
                      (and ppath (assoc ppath :changed? true))]
                     ^loc)))))
  
(comment

(load-file "/Users/rich/dev/clojure/src/zip.clj")
(refer 'zip)
(def data '[[a * b] + [c * d]])
(def dz (vector-zip data))

(right (down (right (right (down dz)))))
(lefts (right (down (right (right (down dz))))))
(rights (right (down (right (right (down dz))))))
(up (up (right (down (right (right (down dz)))))))
(path (right (down (right (right (down dz))))))

(-> dz down right right down right)
(-> dz down right right down right (replace '/) root)
(-> dz next next (edit str) next next next (replace '/) root)
(-> dz next next next next next next next next next remove root)
(-> dz next next next next next next next next next remove (insert-right 'e) root)
(-> dz next next next next next next next next next remove up (append-child 'e) root)

(end? (-> dz next next next next next next next next next remove next))

(-> dz next remove next remove root)

(loop [loc dz]
  (if (end? loc)
    (root loc)
    (recur (next (if (= '* (node loc)) 
                   (replace loc '/)
                   loc)))))

(loop [loc dz]
  (if (end? loc)
    (root loc)
    (recur (next (if (= '* (node loc)) 
                   (remove loc)
                   loc)))))
)
