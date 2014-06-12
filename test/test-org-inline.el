(require 'ert)

(require 'org)
(require 'ox)
(require 'ox-org)
(require 'org-test)

(defun org-test-default-backend ()
  "Return a default export back-end.
This back-end simply returns parsed data as Org syntax."
  (org-export-create-backend
   :transcoders (let (transcode-table)
		  (dolist (type (append org-element-all-elements
					org-element-all-objects)
				transcode-table)
		    (push
		     (cons type
			   (lambda (obj contents info)
			     (funcall
			      (intern (format "org-element-%s-interpreter"
					      type))
			      obj contents)))
		     transcode-table)))))


(ert-deftest test-org-inline--heading-is-ignored ()
  (should
    (equal
     (concat "* B" "\n")
     (org-test-with-temp-text
      "* A :inline:
* B"
      (beginning-of-buffer)
      (org-export-as (org-test-default-backend))))))



(ert-deftest test-org-inline---body-is-inlined ()
  (should
    (equal
     (concat "Body of A
* B" "\n")
     (org-test-with-temp-text
      "* A :inline:
Body of A
* B"
      (beginning-of-buffer)
      (org-export-as (org-test-default-backend))))))


(ert-deftest test-org-inline---no-properties ()
  (should
   (equal
    (concat "Body of A
* B" "\n")
    (org-test-with-temp-text
	"* A :inline:
:PROPERTIES:
:prop: value
:END:
Body of A
* B"
      (beginning-of-buffer)
      (org-export-as (org-test-default-backend))))))

(provide 'test-org-inline)
