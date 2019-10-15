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
    DEVNUL := NUL
    WHICH := where
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
    DEVNUL := /dev/null
    WHICH := which
    SEP=/
endif

RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(RUN_ARGS):;@:)

# Recursive wildcard 
rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))
MAKEFILE_LIST=Makefile
THIS_FILE := $(lastword $(MAKEFILE_LIST))
# ENVIRONMENT Setting
GHDL_IMAGE=ghdl/ext:latest
MERMAID_IMAGE=mikoto2000/mermaid.cli
DOCKER_ENV = true
CMD_ARGUMENTS ?= $(cmd)
STARTUP_SCRIPT ?= $(startup)
TB_OPTION= --assert-level=error
####
FLAGS=--warn-error 
PACKAGES = ./utils_pkg  ./utils_pkg_body  ./cache_pkg ./cache_pkg_body ./cache_test_pkg ./cache_test_pkg_body
MODULES?= $(filter-out  $(PACKAGES),$(patsubst %.vhd,%, $(call rwildcard,./,*.vhd)) )
TEMP ?= 
ANALYZE_TARGETS?=$(addsuffix .vhd, $(subst ./,,${PACKAGES}))$(SPACE) $(addsuffix .vhd, $(subst ./,,${MODULES}))$(SPACE) $(addsuffix _behaviour.vhdl, $(subst ./,,${MODULES})) 
SKIP_TESTS=bram_tb cpu_gen_tb direct_mapped_cache_controller_tb cpu_gen_tb clock_gen_tb
STOP_TEST_TIME_FLAG= --stop-time=50us
TESTS=$(addsuffix _tb.vhdl, $(subst ./,,${MODULES}))
ifeq ($(DOCKER_ENV),true)
    ifeq ($(shell ${WHICH} docker 2>${DEVNUL}),)
        $(error "docker is not in your system PATH. Please install docker to continue or set DOCKER_ENV = false in make file ")
    endif
    DOCKER_IMAGE ?= $(docker_image)
    DOCKER_CONTAINER_NAME ?=$(container_name)
    DOCKER_CONTAINER_MOUNT_POINT?=$(mount_point)
    ifneq ($(DOCKER_CONTAINER_NAME),)
        CONTAINER_RUNNING := $(shell docker inspect -f '{{.State.Running}}' ${DOCKER_CONTAINER_NAME})
    endif
    ifneq ($(DOCKER_CONTAINER_NAME),)
        DOCKER_IMAGE_EXISTS := $(shell docker images -q ${DOCKER_IMAGE} 2> /dev/null)
    endif
else
    ifeq ($(shell ${WHICH} ghdl 2>${DEVNUL}),)
        $(error "ghdl is not in your system PATH. Please install ghdl to continue or set DOCKER_ENV = true in make file and use docker build pipeline ")
    endif
endif


.PHONY: all shell clean build analyze module cache_files mermaid
.SILENT: all shell clean build analyze module cache_files mermaid

# ex : make cmd="ls -lah"
shell:
ifneq ($(DOCKER_ENV),)
ifeq ($(DOCKER_ENV),true)
    ifeq ($(DOCKER_IMAGE_EXISTS),)
	- @docker pull ${DOCKER_IMAGE}
    endif
    ifneq ($(CONTAINER_RUNNING),true)
	- @docker run --entrypoint "/bin/bash" -v ${CURDIR}:${DOCKER_CONTAINER_MOUNT_POINT} --name ${DOCKER_CONTAINER_NAME} --rm -d -i -t ${DOCKER_IMAGE} -c tail -f /dev/null
    ifneq ($(STARTUP_SCRIPT),)
	- @docker exec  --workdir ${DOCKER_CONTAINER_MOUNT_POINT} ${DOCKER_CONTAINER_NAME} /bin/bash -c "${STARTUP_SCRIPT}"
    endif
    endif
endif
endif
ifneq ($(CMD_ARGUMENTS),)
    ifeq ($(DOCKER_ENV),true)
        ifneq ($(DOCKER_ENV),)
	- @docker exec  --workdir ${DOCKER_CONTAINER_MOUNT_POINT} ${DOCKER_CONTAINER_NAME} /bin/bash -c "$(CMD_ARGUMENTS)"
        endif
    else
	- @/bin/bash -c "$(CMD_ARGUMENTS)"
    endif
endif


test: 
	- $(CLEAR) 
	- @echo$(SPACE)  ${PACKAGES}
	- @echo$(SPACE) 
analyze: clean
	- $(MKDIR) test_results
	- $(MKDIR) imem
    ifeq ($(DOCKER_ENV),true)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="ghdl -i --workdir=./ *.vhd *.vhdl" container_name="ghdl_container" startup="/opt/ghdl/install_vsix.sh"   mount_point="/mnt/project"
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="ghdl -a --ieee=synopsys --std=00 $(FLAGS) $(ANALYZE_TARGETS)" docker_image="${GHDL_IMAGE}" container_name="ghdl_container" startup="/opt/ghdl/install_vsix.sh"   mount_point="/mnt/project"
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="ghdl -a --ieee=synopsys --std=00 $(FLAGS) $(TESTS)" docker_image="${GHDL_IMAGE}" container_name="ghdl_container" startup="/opt/ghdl/install_vsix.sh"   mount_point="/mnt/project"
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="ghdl -m --ieee=synopsys --std=00 --workdir=./ cache_files_generator" docker_image="${GHDL_IMAGE}" container_name="ghdl_container" startup="/opt/ghdl/install_vsix.sh"   mount_point="/mnt/project"
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="ghdl -r -g -O3 --ieee=synopsys --std=00 cache_files_generator -gTag_Filename=./imem/tag -gData_Filename=./imem/data" docker_image="${GHDL_IMAGE}" container_name="ghdl_container" startup="/opt/ghdl/install_vsix.sh"   mount_point="/mnt/project"
    else
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="ghdl -i --workdir=./ *.vhd *.vhdl"
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="ghdl -a --ieee=synopsys --std=00 $(FLAGS) $(ANALYZE_TARGETS)" 
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="ghdl -a --ieee=synopsys --std=00 $(FLAGS) $(TESTS)"
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="ghdl -m --ieee=synopsys --std=00 --workdir=./ cache_files_generator"
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="ghdl -r -g -O3 --ieee=synopsys --std=00 cache_files_generator -gTag_Filename=./imem/tag -gData_Filename=./imem/data"
    endif
module : 
	- $(CLEAR) 
	- $(TOUCH) $(addsuffix .vhd,$(RUN_ARGS))
	- $(TOUCH) $(addsuffix _tb.vhdl,$(RUN_ARGS))
	- $(TOUCH) $(addsuffix _behaviour.vhdl,$(RUN_ARGS))


build:  analyze
	- $(CLEAR)
    ifeq ($(DOCKER_ENV),true)
	- $(info Building in Docker Container)
	for target in $(filter-out $(SKIP_TESTS),$(subst ./,, $(addsuffix _tb, ${MODULES}))); do \
			$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="ghdl -e --ieee=synopsys $(FLAGS) $$target" docker_image="${GHDL_IMAGE}" container_name="ghdl_container" startup="/opt/ghdl/install_vsix.sh"   mount_point="/mnt/project" && \
			$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="ghdl -r --ieee=synopsys  $(FLAGS) $$target ${STOP_TEST_TIME_FLAG}" docker_image="${GHDL_IMAGE}" container_name="ghdl_container" startup="/opt/ghdl/install_vsix.sh"   mount_point="/mnt/project"; \
	done
    else
	- $(info Building in local environment)
	for target in $(filter-out $(SKIP_TESTS),$(subst ./,, $(addsuffix _tb, ${MODULES}))); do \
			$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="ghdl -e --ieee=synopsys $(FLAGS) $$target" && \
			$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="ghdl -r --ieee=synopsys $(FLAGS) $$target ${STOP_TEST_TIME_FLAG}"; \
	done
    endif


clean:
    ifeq ($(DOCKER_ENV),true)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="ghdl --clean --workdir=./" docker_image="${GHDL_IMAGE}" container_name="ghdl_container" startup="/opt/ghdl/install_vsix.sh"   mount_point="/mnt/project"
    else
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="ghdl --clean --workdir=./"
    endif
	- $(RM) work-obj93.cf *.o
	- $(RM) test_results
	- $(RM) imem
MERMAID_FILES?=$(patsubst %.mmd,%,$(subst fixtures/mermaid/,, $(call rwildcard,fixtures/mermaid/,*.mmd)))

mermaid:  clean
	- $(CLEAR)
	- $(MKDIR) fixtures/mermaid
    ifeq ($(DOCKER_ENV),true)
	for target in $(MERMAID_FILES); do \
			$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="mmdc -p /opt/local/mermaid.cli/puppeteer-config.json -i fixtures/mermaid/$$target.mmd -o fixtures/mermaid/$$target.png" docker_image="${MERMAID_IMAGE}" container_name="mermaid_ghdl" mount_point="/home/node/data" ; \
	done
    else
    ifeq ($(shell ${WHICH} mmdc 2>${DEVNUL}),)
        $(error "mmdc (mermaid compiler) is not in your system PATH. Please run `make dep` to install dependancy ")
    endif
	for target in $(MERMAID_FILES); do \
			$(MAKE) --no-print-directory -f $(THIS_FILE) shell cmd="mmdc -i fixtures/mermaid/$$target.mmd -o fixtures/mermaid/$$target.png"; \
	done
    endif