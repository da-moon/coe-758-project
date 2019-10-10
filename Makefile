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
# ENVIRONMENT Setting
REMOTE_ENV = false
DOCKER_IMAGE=ghdl/ext:latest
ifeq ($(REMOTE_ENV),true)
    GHDLC = ghdl
else
    GHDLC = ghdl
endif

FLAGS=--warn-error --work=work 
TB_OPTION=--assert-level=error
####
VHDS=$(addsuffix .vhd, ${MODULES})
TESTS=$(addsuffix _test, ${MODULES})
VHDLS=$(addsuffix .vhdl, $(TESTS))
PACKAGES = cache_primitives.vhd utils.vhd utils_body.vhd
MODULES= mux2 mux8 cache_decoder cache_controller
.PHONY: all test dep clean pre-build build

dep:
	- $(CLEAR)
ifeq ($(REMOTE_ENV),true)
	- sudo apt update
	- sudo apt install -y ghdl
	- /bin/bash -c "./setup/dep.sh"
else
	- docker pull ${DOCKER_IMAGE}
	- docker run --name ghdl-ls -i ghdl/ext:latest bash -c "/opt/ghdl/install_vsix.sh"
endif
clean:
	- $(CLEAR)
	- $(RM) work-obj93.cf *.o *.vcd

pre-build: clean
	- $(CLEAR)
	- $(GHDLC) -a --std=00 $(FLAGS) ${PACKAGES} $(VHDS) 
	- $(GHDLC) -a --std=00 $(FLAGS) $(VHDLS) 

build: pre-build
	for target in $(TESTS); do \
			$(GHDLC) -e $(FLAGS) $$target && \
			$(GHDLC) -r $(FLAGS) $$target --stop-time=3us; \
	done


test: 
	- $(CLEAR)
	- $(CLEAR)
