#
# Help!!
#
# Here are the available commands:
#
#   make watch ; # recompiles on change

############################
#
# Setting up variables 
#
############################

VPATH = src/esercizi
INTERMEDIATEDIRS = figures
CLEANOBJS = book.pdf
WATCHOBJECT = src/org/book.org
WATCHTARGET = book.pdf

############################
#
# Should not modify the following variables
#
############################

BUILDIR ?= build
PROCREGEXP ?=
WATCHOBJECT ?=
WATCHTARGET ?=

#.SILENT:
#.IGNORE:


.DEFAULT_GOAL := all

# Used to create a directory as a prerequisite of a file
.SECONDEXPANSION:

mirrorinto		= $(patsubst %, $1/%, $2)
collapseinto	= $(patsubst %, $1/%, $(notdir $2))

# Used to create a directory as a prerequisite of a file
%/.f:
	mkdir -p $(dir $@)
	touch $@

clean:
	rm -rf $(BUILDIR) $(CLEANOBJS)


.phony: watch
watch:
	watchman $(WATCHOBJECT) "make $(WATCHTARGET)" &


.PHONY: show-procs
show-procs:
	@echo 'Processes in PROCREGEXP = $(PROCREGEXP), WATCHOBJECT = $(WATCHOBJECT)'
	@echo ' '
	$(if $(PROCREGEXP),  pgrep -l -f $(PROCREGEXP), @echo "PROCREGEXP not set")
	$(if $(WATCHOBJECT), pgrep -l -f ".*watchman.*$(WATCHOBJECT)", @echo "WATCHOBJECT not set")

.PHONY: kill-procs
kill-procs:
	@make show-procs
	$(if $(PROCREGEXP),  pkill -9 -f $(PROCREGEXP), @echo "PROCREGEXP not set")
	$(if $(WATCHOBJECT), pkill -9 -f ".*watchman.*$(WATCHOBJECT)", @echo "WATCHOBJECT not set")

show: show-procs

stop: kill-procs

######################
#
# Common build targets
#
######################

$(BUILDIR)/%.xelatex.pdf: %.xelatex.tex $(BUILDIR)/.f
	xelatex $<
	xelatex $<
	mv $*.xelatex.pdf $(BUILDIR)
	rm -f $*.xelatex.aux $*.xelatex.log



############################
#
# Local targets
#
############################

tmplts	= $(wildcard src/templates/*.tex)


$(BUILDIR)/%.md: %.md $$(@D)/.f
	exemd $< -p > $@

$(BUILDIR)/container.tex: src/org/book.org $(BUILDIR)/.f
	emacs --batch --eval '(progn (find-file "$<") (setq org-confirm-babel-evaluate nil) (org-latex-export-to-latex nil nil nil t nil))'
	mv src/org/book.tex $@


$(BUILDIR)/frontpage.tex: src/frontpage.md
	pandoc $< -t latex > $@

$(BUILDIR)/book.pdf: $(BUILDIR)/container.tex $(BUILDIR)/frontpage.tex $(tmplts)
	mkdir -p $(BUILDIR)/figures
	mkdir -p $(BUILDIR)/images
	cp src/images/*.pdf $(BUILDIR)/images
	cp $(tmplts) $(BUILDIR)
	cd $(BUILDIR) && xelatex --shell-escape book.tex | egrep "arning|rror|ages"
	cd $(BUILDIR) && xelatex --shell-escape book.tex | egrep "arning|rror|ages"
	cd $(BUILDIR) && xelatex --shell-escape book.tex | egrep "arning|rror|ages"

book.pdf: $(BUILDIR)/book.pdf
	cp $< $@

edit:
	open -a "Skim" book.pdf
	make watch

all: book.pdf
