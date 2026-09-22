ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
XNU_SOURCE ?= $(abspath $(ROOT)/../xnu)
BUILD_DIR ?= $(ROOT)/build/ctfconvert
PREFIX ?= /usr/local
PKG_CONFIG ?= pkg-config

CPPFLAGS += \
	-D_GNU_SOURCE \
	-D__APPLE__ \
	-DDTRACE_PORTABLE_HOST \
	-include $(ROOT)/compat/portable_host.h \
	-I$(ROOT)/compat/opensolaris/sys \
	-I$(ROOT)/compat/opensolaris \
	-I$(ROOT)/include \
	-I$(ROOT)/lib/libelf \
	-I$(ROOT)/lib/libdwarf \
	-I$(ROOT)/lib/libdwarf/cmplrs \
	-I$(ROOT)/lib/libctf/common \
	-I$(ROOT)/tools/ctfconvert \
	-idirafter $(XNU_SOURCE)/EXTERNAL_HEADERS \
	-idirafter $(XNU_SOURCE)/bsd \
	-idirafter $(XNU_SOURCE)/osfmk \
	-idirafter $(XNU_SOURCE)/libkern \
	$(ZLIB_CFLAGS)
CFLAGS ?= -O2 -g
CFLAGS += -std=gnu11 -pthread
CXXFLAGS ?= -O2 -g
CXXFLAGS += -std=gnu++17 -pthread -U__APPLE__ -include $(ROOT)/compat/opensolaris/darwin_shim.h
ZLIB_CFLAGS := $(shell $(PKG_CONFIG) --cflags zlib)
ZLIB_LIBS := $(shell $(PKG_CONFIG) --libs zlib)
LDLIBS += $(ZLIB_LIBS) -pthread

CTF_COMMON_C_SOURCES := \
	tools/ctfconvert/tdata.c \
	tools/ctfconvert/output.c \
	tools/ctfconvert/fifo.c \
	tools/ctfconvert/list.c \
	tools/ctfconvert/hash.c \
	tools/ctfconvert/memory.c \
	tools/ctfconvert/barrier.c \
	tools/ctfconvert/traverse.c \
	tools/ctfconvert/iidesc.c \
	tools/ctfconvert/ctf.c \
	tools/ctfconvert/input.c \
	tools/ctfconvert/array.c \
	tools/ctfconvert/symbol.c \
	tools/ctfconvert/util.c \
	tools/ctfconvert/merge.c \
	tools/ctfconvert/stack.c \
	tools/ctfconvert/dwarf.c \
	compat/opensolaris/darwin_shim.c

CTFCONVERT_C_SOURCES := tools/ctfconvert/ctfconvert.c
CTFMERGE_C_SOURCES := \
	tools/ctfconvert/ctfmerge.c \
	tools/ctfconvert/utils.c

CTF_CXX_SOURCES := \
	tools/ctfconvert/atom.cpp \
	tools/ctfconvert/strtab.cpp \
	tools/ctfconvert/alist.cpp

ELF_SOURCES := \
	lib/libelf/clscook_ELF64.c \
	lib/libelf/clscook.c \
	lib/libelf/cntl.c \
	lib/libelf/cook.c \
	lib/libelf/data.c \
	lib/libelf/gelf.c \
	lib/libelf/getehdr.c \
	lib/libelf/getident.c \
	lib/libelf/getscn.c \
	lib/libelf/getshdr.c \
	lib/libelf/input.c \
	lib/libelf/kind.c \
	lib/libelf/ndxscn.c \
	lib/libelf/nextscn.c \
	lib/libelf/strptr.c \
	lib/libelf/xlate.c \
	lib/libelf/begin.c \
	lib/libelf/end.c \
	lib/libelf/error.c \
	lib/libelf/getdata.c \
	lib/libelf/getshstrndx.c \
	lib/libelf/xlate64.c

DWARF_SOURCES := \
	lib/libdwarf/dwarf_abbrev.c \
	lib/libdwarf/dwarf_addr_finder.c \
	lib/libdwarf/dwarf_alloc.c \
	lib/libdwarf/dwarf_arange.c \
	lib/libdwarf/dwarf_die_deliv.c \
	lib/libdwarf/dwarf_error.c \
	lib/libdwarf/dwarf_form.c \
	lib/libdwarf/dwarf_frame.c \
	lib/libdwarf/dwarf_frame2.c \
	lib/libdwarf/dwarf_frame3.c \
	lib/libdwarf/dwarf_funcs.c \
	lib/libdwarf/dwarf_global.c \
	lib/libdwarf/dwarf_init_finish.c \
	lib/libdwarf/dwarf_leb.c \
	lib/libdwarf/dwarf_line.c \
	lib/libdwarf/dwarf_line2.c \
	lib/libdwarf/dwarf_loc.c \
	lib/libdwarf/dwarf_macro.c \
	lib/libdwarf/dwarf_print_lines.c \
	lib/libdwarf/dwarf_pubtypes.c \
	lib/libdwarf/dwarf_query.c \
	lib/libdwarf/dwarf_sort_line.c \
	lib/libdwarf/dwarf_string.c \
	lib/libdwarf/dwarf_types.c \
	lib/libdwarf/dwarf_util.c \
	lib/libdwarf/dwarf_vars.c \
	lib/libdwarf/dwarf_weaks.c

COMMON_C_SOURCES := $(CTF_COMMON_C_SOURCES) $(ELF_SOURCES) $(DWARF_SOURCES)
COMMON_OBJECTS := $(addprefix $(BUILD_DIR)/,$(COMMON_C_SOURCES:.c=.o) $(CTF_CXX_SOURCES:.cpp=.o))
CTFCONVERT_OBJECTS := $(COMMON_OBJECTS) $(addprefix $(BUILD_DIR)/,$(CTFCONVERT_C_SOURCES:.c=.o))
CTFMERGE_OBJECTS := $(COMMON_OBJECTS) $(addprefix $(BUILD_DIR)/,$(CTFMERGE_C_SOURCES:.c=.o))
CTFCONVERT := $(BUILD_DIR)/ctfconvert
CTFMERGE := $(BUILD_DIR)/ctfmerge

.PHONY: all clean install
all: $(CTFCONVERT) $(CTFMERGE)

$(CTFCONVERT): $(CTFCONVERT_OBJECTS)
	@mkdir -p $(@D)
	$(CXX) $(LDFLAGS) -o $@ $(CTFCONVERT_OBJECTS) $(LDLIBS)

$(CTFMERGE): $(CTFMERGE_OBJECTS)
	@mkdir -p $(@D)
	$(CXX) $(LDFLAGS) -o $@ $(CTFMERGE_OBJECTS) $(LDLIBS)

$(BUILD_DIR)/%.o: $(ROOT)/%.c
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/%.o: $(ROOT)/%.cpp
	@mkdir -p $(@D)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c -o $@ $<

install: $(CTFCONVERT) $(CTFMERGE)
	install -Dm755 $(CTFCONVERT) $(DESTDIR)$(PREFIX)/bin/ctfconvert
	install -Dm755 $(CTFMERGE) $(DESTDIR)$(PREFIX)/bin/ctfmerge

clean:
	rm -rf $(BUILD_DIR)
