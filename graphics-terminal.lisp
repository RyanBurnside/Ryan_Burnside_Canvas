;;;; Ryan Burnside 2013 graphics terminal.
;;;; Special thanks to edgar-rft of LispForum (http://www.lispforum.com)


;;; TODO this may not be possible but is very imporant
;; try to get some imput from piped thigns
;(loop
;   for line = (read-line)
;   for n = 0 then (1+ n)
;   while line do (format t "~a ~a~%" n line))
;
;(princ "Got here!")
;


;;; TODO change this when packaged and finished
(load "ltk.fasl")
(in-package :ltk)

;;; Some global parameters
(defparameter *pen-color* "#ffffff")
(defparameter *brush-color* "#aaaaaa")
(defparameter *canvas-color* "#000000")
(defparameter *pen-width* 1)

;; This function toggles using the brush to fill shapes (boolean)
(defparameter *use-brush* 1)

;;; Make a lookup table binding LTK shape commands to function symbols
(defparameter *shape-lookup*
  '((#\P . set-pen-color)
    (#\B . set-brush-color)
    (#\U . set-use-brush)
    (#\W . set-pen-width)
    (#\C . set-canvas-color)
    (#\l . create-line)
    (#\r . create-rectangle-cords)
    (#\t . create-polygon)
    (#\p . create-polygon)
    (#\o . create-oval-cords)))

;;; Functions for simple state setting
(defun set-pen-color (col)
  (setf *pen-color* col))

(defun set-brush-color (col)
  (setf *brush-color* col))

(defun set-canvas-color (col canvas)
  (configure canvas :background col))

(defun set-pen-width (width)
  (setf *pen-width* width))

(defun set-use-brush (zero-or-one)
  (if (= zero-or-one 0)
      (setf *use-brush* nil)
      (setf *use-brush* t)))

;;; Special shape generating functions
(defun create-oval-cords (canvas cords)
  "Substitute function, takes a cords list"
  (apply #'make-oval canvas cords))

(defun create-rectangle-cords (canvas cords)
  "Substitute function, takes a cords list"
  (apply #'make-rectangle canvas cords))

(defun make-color (RGB-list)
  "Returns a hex color string given 3 parameters 0-255 per channel in a list"
  (format nil "#~{~2,'0X~2,'0X~2,'0X~}" RGB-list))

;;; Parser section
(defun tokenize-string (string)
  "Returns a list of items delimited by #\Space"
  (loop for start = 0 then (1+ finish)
        for finish = (position #\Space string :start start)
        collecting (subseq string start finish)
        until (null finish)))

(defun parse-line (line canvas-object)
   "Parses the line, maps the first letter to a drawing funciton,
     turns the args into a list, passes as list to drawing function"
  (let* ((str (string-trim " " line))
         (begin (aref str 0))
         (args (mapcar #'parse-integer (subseq (tokenize-string str) 1))))

    ;; If this is just a state change command exit now that it ran
    (when (equal begin #\C)
      (funcall (cdr (assoc begin *shape-lookup*))
               (make-color args) canvas-object)
      (return-from parse-line t))

    ;; Canvas color and Use brush variables
    (when (or (equal begin #\W) (equal begin #\U))
      (funcall (cdr (assoc begin *shape-lookup*)) (car args))
      (return-from parse-line t))

    ;; Pen and Brush color setting
    (when (or (equal begin #\P) (equal begin #\B))
      (funcall (cdr (assoc begin *shape-lookup*)) (make-color args))
      (return-from parse-line t))

    (let ((l (funcall (cdr (assoc begin *shape-lookup*)) canvas-object args)))
      (itemconfigure canvas-object l :fill (if *use-brush* *brush-color* ""))
      (if (not (equal begin #\l)) ; Lines don't get outline attribute
          (itemconfigure canvas-object l :outline *pen-color*))
      (itemconfigure canvas-object l :width *pen-width*))))

;;; Menu bar command section
(defun load-file-shapes (canvas)
  "Open a file and parse out the shapes, adding them to the global canvas"
  (with-open-file (stream (get-open-file))
    (do ((line (read-line stream nil)
               (read-line stream nil)))
        ((null line))
      (parse-line line canvas))))

(defun show-help ()
  (message-box "Build 0.5"
	       "Ryan Burnside's Canvas"
	       "ok"
	       "info"))

(defun user-set-canvas-color (canvas)
  "Ask the user for the canvas color"
  (let ((color (choose-color :title "Choose color" :initialcolor "#FFFFFF")))
    (if (not (equal color ""))
	(configure canvas :background color))))

(defun main-function ()
  (with-ltk ()
    (let* ((frame (make-instance 'frame))
           (sc (make-instance 'scrolled-canvas))
           (canvas (canvas sc))
           (m (make-menubar))
	   (mfile (make-menu m "File"))
           (medit (make-menu m "Edit"))
	   (mhelp (make-menu m "Help")))
      (make-menubutton mfile "Load File" (lambda () (load-file-shapes canvas)))
      (make-menubutton mfile "Export Canvas" (lambda () (get-save-file)))
      (make-menubutton medit "Clear Canvas" (lambda () (clear canvas)))
      (make-menubutton mfile "Quit" (lambda () (setf *exit-mainloop* t)))
      (make-menubutton mhelp "About" (lambda () (show-help)))
      (make-menubutton medit "Set Canvas Color" 
		       (lambda () (user-set-canvas-color canvas)))
      (set-geometry *tk* 800 600 0 0)
      (wm-title *tk* "Ryan Burnside's Canvas")
      (pack frame :side :bottom)
      (pack sc :expand 1 :fill :both)
      (scrollregion canvas 0 0 800 600)
      (configure frame :relief :sunken))))

;Start program
;;; TODO see if possible to run a LOGO like command parser within this
(main-function)
