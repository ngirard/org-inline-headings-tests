# Run
#   make apply_patch
#   make check

EMACS       ?= emacs24-nox
EMACSFLAGS   = --batch -Q
PWD=$(shell pwd)
ORGDIR=org-mode
PATCH=$(PWD)/0001-export-removes-INLINE-heading-and-promotes-subtree.patch
TEST_BRANCH=test_inline_heading
TESTS        = $(filter-out %-pkg.el, $(wildcard test/*.el))




$(ORGDIR) :
	git clone git://orgmode.org/org-mode.git

$(TEST_BRANCH): $(ORGDIR)
	cd $(ORGDIR); \
	branch=$$(git rev-parse --abbrev-ref HEAD); \
	[ "$$branch" = "$(TEST_BRANCH)" ] || git co -b $@	


.PHONY: apply_patch
apply_patch: $(TEST_BRANCH)  $(PATCH)
	cd $(ORGDIR); \
	git am $(PATCH)


.PHONY: check
check : 
	$(EMACS) $(EMACSFLAGS)  \
	-L $(ORGDIR)/lib -L $(ORGDIR)/testing \
	-l org-test \
	$(patsubst %,-l % , $(TESTS))\
	-f ert-run-tests-batch-and-exit
