#lang racket

(define (inc n)
  (+ n 1))

;;; ordered elements
(define (make-elem pri val)
  (cons pri val))

(define (elem-priority x)
  (car x))

(define (elem-val x)
  (cdr x))

;;; leftist heaps (after Okasaki)

;; data representation
(define leaf 'leaf)

(define (leaf? h) (eq? 'leaf h))

(define (hnode? h)
  (and (list? h)
       (= 5 (length h))
       (eq? (car h) 'hnode)
       (natural? (caddr h))))

;; {'hnode, {prior, val}, rank, L, R}

(define (make-node elem heap-a heap-b)
  (if (>= (rank heap-a) (rank heap-b))
      (list 'hnode elem (inc (rank heap-b)) heap-a heap-b)
      (list 'hnode elem (inc (rank heap-a)) heap-b heap-a)
  )
)

(define (node-elem h)
  (second h))

(define (node-left h)
  (fourth h))

(define (node-right h)
  (fifth h))

(define (hord? p h)
  (or (leaf? h)
      (<= p (elem-priority (node-elem h)))))

(define (heap? h)
  (or (leaf? h)
      (and (hnode? h)
           (heap? (node-left h))
           (heap? (node-right h))
           (<= (rank (node-right h))
               (rank (node-left h)))
           (= (rank h) (inc (rank (node-right h))))
           (hord? (elem-priority (node-elem h))
                  (node-left h))
           (hord? (elem-priority (node-elem h))
                  (node-right h)))))

(define (rank h)
  (if (leaf? h)
      0
      (third h)))

;; operations

(define empty-heap leaf)

(define (heap-empty? h)
  (leaf? h))

(define (heap-insert elt heap)
  (heap-merge heap (make-node elt leaf leaf)))

(define (heap-min heap)
  (node-elem heap))

(define (heap-pop heap)
  (heap-merge (node-left heap) (node-right heap)))

(define (heap-merge h1 h2)
  (cond
    [(leaf? h1) h2]
    [(leaf? h2) h1]
    [else {let* ([hp (if [< (elem-priority (heap-min h1)) (elem-priority (heap-min h2))]
                         (cons h1 h2)
                         (cons h2 h1))]
                 [e (heap-min (car hp))]
                 [hl (node-left (car hp))]
                 [hr (node-right (car hp))]
                 [h (cdr hp)])
                (make-node e hl (heap-merge h hr))
            }]))


;;; heapsort. sorts a list of numbers.
(define (heapsort xs)
  (define (popAll h)
    (if (heap-empty? h)
        null
        (cons (elem-val (heap-min h)) (popAll (heap-pop h)))))
  (let ((h (foldl (lambda (x h)
                    (heap-insert (make-elem x x) h))
            empty-heap xs)))
    (popAll h)))

;;; check that a list is sorted (useful for longish lists)
(define (sorted? xs)
  (cond [(null? xs)              true]
        [(null? (cdr xs))        true]
        [(<= (car xs) (cadr xs)) (sorted? (cdr xs))]
        [else                    false]))

;;; generate a list of random numbers of a given length
(define (randlist len max)
  (define (aux len lst)
    (if (= len 0)
        lst
        (aux (- len 1) (cons (random max) lst))))
  (aux len null))

(display "TESTS:\n")
(display "test empty: ") (sorted? (heapsort '()))
(display "test one elem:") (sorted? (heapsort '(2)))
(display "test random short 1:") (sorted? (heapsort (randlist 10 5)))
(display "test random short 2:") (sorted? (heapsort (randlist 10 50)))
(display "test random long 1:") (sorted? (heapsort (randlist 100 1000)))
(display "test random long 2:") (sorted? (heapsort (randlist 10000 500000)))