# OS specific part
# -----------------
ifeq ($(OS),Windows_NT)
    CLEAR = cls
    LS = dir
    TOUCH =>>
    RM = del /F /Q
    CPF = copy /y
    RMDIR = -RMDIR /S /Q
    MKDIR = -mkdir
    CMDSEP = &
    ERRIGNORE = 2>NUL || (exit 0)
    SEP=\\
else
    CLEAR = clear
    LS = ls
    TOUCH = touch
    CPF = cp -f
    RM = rm -rf
    RMDIR = rm -rf
    CMDSEP = ;
    MKDIR = mkdir -p
    ERRIGNORE = 2>/dev/null
    SEP=/
endif

MAKEFILE_LIST=Makefile
CMD_ARGUMENTS ?= $(cmd)

THIS_FILE := $(lastword $(MAKEFILE_LIST))

# ENVIRONMENT Setting
DOCKER_ENV = true
DOCKER_IMAGE=ghdl/ext:latest
DOCKER_IMAGE_EXISTS := $(shell docker images -q ${DOCKER_IMAGE} 2> /dev/null)
CONTAINER_RUNNING := $(shell docker inspect -f '{{.State.Running}}' ghdl-ls)
TB_OPTION=--assert-level=error
####
FLAGS=--warn-error --work=work


VHDS=$(addsuffix .vhd, ${MODULES})
TESTS=$(addsuffix _test, ${MODULES})
VHDLS=$(addsuffix .vhdl, $(TESTS))
PACKAGES = cache_primitives.vhd utils.vhd utils_body.vhd
MODULES= mux2 mux8 cache_decoder cache_controller
.PHONY: all shell clean pre-build build
# ex : make cmd="ghdl -a --std=00 --warn-error --work=work  mux2.vhd"
# ghdl -a --std=00 --warn-error --work=work mux2.vhd
shell:
ifeq ($(DOCKER_ENV),true)
    ifeq ($(DOCKER_IMAGE_EXISTS),)
	- @docker pull ${DOCKER_IMAGE}
    endif
    ifneq ($(CONTAINER_RUNNING),true)
	- @docker run -v ${CURDIR}:/mnt/project --name ghdl-ls --rm -d -i -t ${DOCKER_IMAGE} /bin/bash -c "/opt/ghdl/install_vsix.sh && tail -f /dev/null"
	- $(CLEAR)
    endif
endif
ifneq ($(CMD_ARGUMENTS),)
    ifeq ($(DOCKER_ENV),true)
	- @docker exec --workdir /mnt/project ghdl-ls /bin/bash -c "$(CMD_ARGUMENTS)"
    else
	- @/bin/bash -c "$(CMD_ARGUMENTS)"
    endif
endif

clean:
	- $(CLEAR)
	- $(RM) work-obj93.cf *.o *.vcd

pre-build: clean
	- $(CLEAR)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="ghdl -a --std=00 $(FLAGS) ${PACKAGES} $(VHDS)"
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="ghdl -a --std=00 $(FLAGS) $(VHDLS)"

build: pre-build
	- $(CLEAR)
	for target in $(TESTS); do \
 			$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="ghdl -e $(FLAGS) $$target" && \
			$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="ghdl -r $(FLAGS) $$target --stop-time=3us"; \
	done
    