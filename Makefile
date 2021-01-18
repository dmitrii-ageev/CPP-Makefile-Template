#Makefile for a C++ application
#Created by Dmitrii Ageev 29.10.2020


CXX           := g++
LD            := g++
CPPCHECK      := cppcheck
ASTYLE        := astyle


EXEC          := app
FLAGS         := -std=c++11 -O3 -Wall
CXXFLAGS      := $(FLAGS)
LDFLAGS       := $(FLAGS)
INC           := -I inc
LIB           := -L lib
SRC           := $(wildcard src/*.cpp)
OBJ           := $(SRC:src/%.cpp=tmp/%.o)

EXEC_TEST     := test
FLAGS_TEST    := $(FLAGS)
CXXFLAGS_TEST := $(FLAGS)
LDFLAGS_TEST  := $(LDFLAGS)
INC_TEST      := $(INC) -I ~/include
SRC_TEST      := $(wildcard tst/*.cpp)
OBJ_TEST      := $(filter-out tmp/main.o, $(OBJ)) $(SRC_TEST:tst/%.cpp=tmp/%.o)

GCOV_CXXFLAGS := -fprofile-use -fprofile-arcs -ftest-coverage -fprofile-generate
GCOV_LDFLAGS  := -lgcov --coverage

.DEFAULT_GOAL := all

.SUFFIXES:


# --------------------------------------------------------------

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# --------------------------------------------------------------

.PHONY: install-requirements
install-requirements: ## Install the Makefile dependencies
	@sudo apt-get install -y g++ lcov binutils astyle cppcheck libboost-test1.71-dev zip tar
	@mkdir -m 0700 -p inc lib out src tmp tst
	@umask 077 && touch src/main.cpp tst/$(EXEC).input tst/unittest.cpp

# --------------------------------------------------------------

.PHONY: all
all: ## Build the application and its libraries
all: out/$(EXEC)

out/$(EXEC): $(OBJ)
ifeq ($(DEBUG),yes)
	@echo
	@echo Running \"$(LD) $(LIB) $(LDFLAGS) $^ -o $@\"
endif
	@$(LD) $(LIB) $(LDFLAGS) $^ -o $@ && echo "[OK]  $@"

# --------------------------------------------------------------

.PHONY: debug
debug: ## Create a debug build
debug: CXXFLAGS      += -DDEBUG -g
debug: CXXFLAGS      += -Werror -Wextra -Wwrite-strings -Wno-parentheses
debug: CXXFLAGS      += -Wpedantic -Warray-bounds -Weffc++
debug: INC_TEST      += -I ~/include
debug: LDFLAGS_TEST  += -L ~/lib -lboost_unit_test_framework
debug: format
debug: check
debug: clean all
debug:
	@echo
	@out/$(EXEC)

# --------------------------------------------------------------

.PHONY: coverage
coverage: ## Run a code coverage test
coverage: CXXFLAGS      += -DDEBUG -g
coverage: CXXFLAGS      += -Werror -Wextra -Wwrite-strings -Wno-parentheses
coverage: CXXFLAGS      += -Wpedantic -Warray-bounds -Weffc++
coverage: CXXFLAGS      += $(GCOV_CXXFLAGS)
coverage: LDFLAGS       += $(GCOV_LDFLAGS)
coverage: INC_TEST      += -I ~/include
coverage: CXXFLAGS_TEST += $(GCOV_CXXFLAGS)
coverage: LDFLAGS_TEST  += -L ~/lib -lboost_unit_test_framework
coverage: LDFLAGS_TEST  += $(GCOV_LDFLAGS)
coverage: clean
coverage: all
coverage:
	@cat tst/${EXEC}.input | out/$(EXEC) 2>/dev/null >/dev/null && echo "[OK]  Application test run"
	@gcov -o tmp inc/*.hpp src/*.cpp 2>/dev/null >/dev/null && echo "[OK]  Code coverage gathering"
	@lcov -c -d . --output-file out/$(EXEC).info 2>/dev/null >/dev/null && echo "[OK]  Prettify statistics"
	@genhtml out/$(EXEC).info --output-directory out 2>/dev/null >/dev/null && echo "[OK]  Generate HTML report"

# --------------------------------------------------------------

.PHONY: release
release: ## Build a software release
release: CXXFLAGS    := -std=c++11 -Os -s -DNDEBUG
release: CXXFLAGS    += -ffunction-sections -fdata-sections -Wl,--gc-sections
release: clean all
release:
	@strip -s -R .comment -R .gnu.version. --strip-unneeded out/$(EXEC) && echo "[OK]  $@"
	@mv -f out/$(EXEC) out/$(shell date '+%F')-release

# --------------------------------------------------------------

.PHONY: test
test: ## Run a unit test
test: inc/*hpp tst/*.cpp
test: out/$(EXEC_TEST)
test: LDFLAGS_TEST  += -L ~/lib -lboost_unit_test_framework

out/$(EXEC_TEST): $(OBJ_TEST)
ifeq ($(DEBUG),yes)
	@echo
	@echo Running \"$(LD) $(LDFLAGS_TEST) $^ -o $@\"
endif
	@$(LD) $(LDFLAGS_TEST) $^ -o $@ && echo "[OK]  $@"

ifeq ($(DEBUG),yes)
	@echo
	@echo Running \"out/$(EXEC_TEST) --log_level=all --report_level=short\"
	@out/$(EXEC_TEST) --log_level=all --report_level=short && echo "[CK]  $@"
else
	@out/$(EXEC_TEST) --log_level=nothing --report_level=no && echo "[CK]  $@"
endif

# --------------------------------------------------------------

format: ## Do code formatting
format: src/*.cpp inc/*.hpp tst/*.cpp
ifeq ($(DEBUG),yes)
	@echo
	@echo Running \"$(ASTYLE) --quiet --style=allman --indent=spaces=4 --suffix=none $^\"
endif
	@$(ASTYLE) --quiet --style=allman --indent=spaces=4 --suffix=none $^ && echo "[OK]  $@"

# --------------------------------------------------------------

check: ## Run a syntax/code check
check: src/*.cpp inc/*.hpp
ifeq ($(DEBUG),yes)
	@echo
	@echo Running \"$(CPPCHECK) --quiet $^\"
endif
	@$(CPPCHECK) --quiet $^ && echo "[OK]  $@"

# --------------------------------------------------------------

tmp/%.o: src/%.cpp inc/*.hpp
ifeq ($(DEBUG),yes)
	@echo
	@echo Running \"$(CXX) $(CXXFLAGS) -c $< $(INC) -o $@\"
endif
	@$(CXX) $(CXXFLAGS) -c $< $(INC) -o $@ && echo "[OK]  $@"

tmp/%.o: tst/%.cpp inc/*.hpp
ifeq ($(DEBUG),yes)
	@echo
	@echo Running \"$(CXX) $(CXXFLAGS_TEST) -c $< $(INC_TEST) -o $@\"
endif
	@$(CXX) $(CXXFLAGS_TEST) -c $< $(INC_TEST) -o $@ && echo "[OK]  $@"

# --------------------------------------------------------------

.PHONY: clean
clean: ## Clean temporary files
	@/bin/rm --one-file-system -fr out/* && echo "[CL]  out/"
	@/bin/rm --one-file-system -fr tmp/* && echo "[CL]  tmp/"

# --------------------------------------------------------------

.PHONY: zip
zip:
zip:
	@zip -x out/* tmp/* lib/* -q -r out/$(EXEC)-$(shell date '+%F').zip . \
	&& echo "[OK]  out/$(EXEC)-$(shell date '+%F').zip"

.PHONY: tar
tar:
tar:
	@tar -czf out/$(EXEC)-$(shell date '+%F').tar.gz --exclude=lib --exclude=tmp --exclude=out . \
	&& echo "[OK]  out/$(EXEC)-$(shell date '+%F').tar.gz"

.PHONY: archive
archive: ## Create a distribution archive
archive: zip tar

# --------------------------------------------------------------

