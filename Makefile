#-----------------------------------------------------------------------

CXX             := g++
LD              := g++

AR               = ar
ARFLAGS          = rcs

WARNINGS        := -Wall -Wextra \
                   -Warray-bounds \
                   -Weffc++ \
                   -Wno-parentheses \
                   -Wpedantic \
                   -Wwrite-strings

PROJECT_DIR     := $(shell pwd)/native-app
OUTPUT_DIR      := $(shell pwd)/out

EXEC_NAME        = main
EXEC_FILE       := $(OUTPUT_DIR)/bin/$(EXEC_NAME)
FLAGS           := -std=c++11 $(WARNINGS)
CXXFLAGS        := $(FLAGS)
LDFLAGS         := $(FLAGS)
INC             := -I $(PROJECT_DIR)/inc
SRC             := $(wildcard $(PROJECT_DIR)/src/*.cc)
OBJ             := $(SRC:$(PROJECT_DIR)/src/%.cc=$(OUTPUT_DIR)/obj/%.o)

TEST_EXEC_NAME   = test
TEST_EXEC_FILE  := $(OUTPUT_DIR)/bin/$(TEST_EXEC_NAME)
FLAGS_TEST      := $(FLAGS)
CXXFLAGS_TEST   := $(CXXFLAGS)
LDFLAGS_TEST    := $(LDFLAGS)
INC_TEST        := $(INC) -I $(PROJECT_DIR)/inc
SRC_TEST        := $(wildcard $(PROJECT_DIR)/tst/*.cc)
OBJ_TEST        := $(filter-out $(OUTPUT_DIR)/obj/main.o, $(OBJ)) $(SRC_TEST:$(PROJECT_DIR)/tst/%.cc=$(OUTPUT_DIR)/obj/%.o)

DIR_GUARD		 = mkdir -pv $(@D)

.SUFFIXES:

#-----------------------------------------------------------------------
#   Rules
#-----------------------------------------------------------------------

.PHONY: all
all: shared_library static_library main test_exe

main: $(EXEC_FILE)
$(EXEC_FILE): $(OBJ)
	@$(DIR_GUARD)
	@$(LD) $(LDFLAGS_TEST) $^ -Wl,-L build/resolvedDep/libmathy/lib -lmathy -o $@ && echo "[OK]: $@"
	@$@

static_library: $(OUTPUT_DIR)/lib/libmathy.a
$(OUTPUT_DIR)/lib/libmathy.a: $(OUTPUT_DIR)/obj/mathy.o
	@$(DIR_GUARD)
	@$(AR) $(ARFLAGS) $@ $^ && echo "[OK]: $@"

shared_library: $(OUTPUT_DIR)/lib/libmathy.so
$(OUTPUT_DIR)/lib/libmathy.so: $(OUTPUT_DIR)/obj/mathy.o
	@$(DIR_GUARD)
	@$(CXX) $(LDFLAGS) -shared -o $@ $^ && echo "[OK]: $@"

.PHONY: test
test: test_exe
	$(TEST_EXEC_FILE)
	@$(TEST_EXEC_FILE) -o out/bin/results_junit.xml --durations yes --reporter junit

test_exe: $(TEST_EXEC_FILE)
$(TEST_EXEC_FILE): $(OBJ_TEST)
	@$(DIR_GUARD)
	@$(LD) $(LDFLAGS_TEST) $^ -o $@ && echo "[OK]: $@"

$(OUTPUT_DIR)/obj/%.o: $(PROJECT_DIR)/src/%.cc
	@$(DIR_GUARD)
	@$(CXX) $(CXXFLAGS) -c $< $(INC) -o $@ && echo "[OK]: $@"

$(OUTPUT_DIR)/obj/%.o: $(PROJECT_DIR)/tst/%.cc
	@$(DIR_GUARD)
	@$(CXX) $(CXXFLAGS_TEST) -c $< $(INC_TEST) -o $@ && echo "[OK]: $@"

.PHONY: clean, clear
clean clear:
	@rm -fv $(OUTPUT_DIR)/bin/* && echo "[Clean]: $(OUTPUT_DIR)/bin/"
	@rm -fv $(OUTPUT_DIR)/lib/* && echo "[Clean]: $(OUTPUT_DIR)/lib/"
	@rm -fv $(OUTPUT_DIR)/obj/* && echo "[Clean]: $(OUTPUT_DIR)/obj/"

.PHONY: archive, zip
archive zip:
	@zip -x $(OUTPUT_DIR)/bin/* $(OUTPUT_DIR)/obj/* $(OUTPUT_DIR)/lib/* -q -r $(OUTPUT_DIR)/bin/$(EXEC)-$(shell date '+%F').zip . && echo "[OK]: $(OUTPUT_DIR)/bin/$(EXEC)-$(shell date '+%F').zip"
