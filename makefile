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

FILEPFX = icwe_rmc
CLEANOBJS = $(FILEPFX).pdf
WATCHOBJECT = src/org/$(FILEPFX).org
WATCHTARGET = $(FILEPFX).pdf

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


############################
#
# Local targets
#
############################


$(BUILDIR)/$(FILEPFX).tex: src/org/$(FILEPFX).org $(BUILDIR)/.f
	emacs -u "zaccaria" --batch --eval '(load user-init-file)' $< -f org-beamer-export-to-latex
	mv src/org/$(FILEPFX).tex $@


$(BUILDIR)/$(FILEPFX).pdf: $(BUILDIR)/$(FILEPFX).tex
	mkdir -p $(BUILDIR)/images
	cp src/org/images/* $(BUILDIR)/images
	cd $(BUILDIR) && xelatex --shell-escape $(FILEPFX).tex | egrep "arning|rror|ages"
	cd $(BUILDIR) && xelatex --shell-escape $(FILEPFX).tex | egrep "arning|rror|ages"
	cd $(BUILDIR) && xelatex --shell-escape $(FILEPFX).tex | egrep "arning|rror|ages"

$(FILEPFX).pdf: $(BUILDIR)/$(FILEPFX).pdf
	cp $< $@

edit:
	open -a "Skim" $(FILEPFX).pdf
	make watch

all: $(FILEPFX).pdf
