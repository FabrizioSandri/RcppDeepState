# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.10

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/akhila/deepstate

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/akhila/deepstate/build

# Include any dependencies generated for this target.
include examples/CMakeFiles/EnsembledCrash.dir/depend.make

# Include the progress variables for this target.
include examples/CMakeFiles/EnsembledCrash.dir/progress.make

# Include the compile flags for this target's objects.
include examples/CMakeFiles/EnsembledCrash.dir/flags.make

examples/CMakeFiles/EnsembledCrash.dir/EnsembledCrash.cpp.o: examples/CMakeFiles/EnsembledCrash.dir/flags.make
examples/CMakeFiles/EnsembledCrash.dir/EnsembledCrash.cpp.o: ../examples/EnsembledCrash.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/akhila/deepstate/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object examples/CMakeFiles/EnsembledCrash.dir/EnsembledCrash.cpp.o"
	cd /home/akhila/deepstate/build/examples && /usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/EnsembledCrash.dir/EnsembledCrash.cpp.o -c /home/akhila/deepstate/examples/EnsembledCrash.cpp

examples/CMakeFiles/EnsembledCrash.dir/EnsembledCrash.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/EnsembledCrash.dir/EnsembledCrash.cpp.i"
	cd /home/akhila/deepstate/build/examples && /usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /home/akhila/deepstate/examples/EnsembledCrash.cpp > CMakeFiles/EnsembledCrash.dir/EnsembledCrash.cpp.i

examples/CMakeFiles/EnsembledCrash.dir/EnsembledCrash.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/EnsembledCrash.dir/EnsembledCrash.cpp.s"
	cd /home/akhila/deepstate/build/examples && /usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /home/akhila/deepstate/examples/EnsembledCrash.cpp -o CMakeFiles/EnsembledCrash.dir/EnsembledCrash.cpp.s

examples/CMakeFiles/EnsembledCrash.dir/EnsembledCrash.cpp.o.requires:

.PHONY : examples/CMakeFiles/EnsembledCrash.dir/EnsembledCrash.cpp.o.requires

examples/CMakeFiles/EnsembledCrash.dir/EnsembledCrash.cpp.o.provides: examples/CMakeFiles/EnsembledCrash.dir/EnsembledCrash.cpp.o.requires
	$(MAKE) -f examples/CMakeFiles/EnsembledCrash.dir/build.make examples/CMakeFiles/EnsembledCrash.dir/EnsembledCrash.cpp.o.provides.build
.PHONY : examples/CMakeFiles/EnsembledCrash.dir/EnsembledCrash.cpp.o.provides

examples/CMakeFiles/EnsembledCrash.dir/EnsembledCrash.cpp.o.provides.build: examples/CMakeFiles/EnsembledCrash.dir/EnsembledCrash.cpp.o


# Object files for target EnsembledCrash
EnsembledCrash_OBJECTS = \
"CMakeFiles/EnsembledCrash.dir/EnsembledCrash.cpp.o"

# External object files for target EnsembledCrash
EnsembledCrash_EXTERNAL_OBJECTS =

examples/EnsembledCrash: examples/CMakeFiles/EnsembledCrash.dir/EnsembledCrash.cpp.o
examples/EnsembledCrash: examples/CMakeFiles/EnsembledCrash.dir/build.make
examples/EnsembledCrash: libdeepstate.a
examples/EnsembledCrash: examples/CMakeFiles/EnsembledCrash.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/akhila/deepstate/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable EnsembledCrash"
	cd /home/akhila/deepstate/build/examples && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/EnsembledCrash.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
examples/CMakeFiles/EnsembledCrash.dir/build: examples/EnsembledCrash

.PHONY : examples/CMakeFiles/EnsembledCrash.dir/build

examples/CMakeFiles/EnsembledCrash.dir/requires: examples/CMakeFiles/EnsembledCrash.dir/EnsembledCrash.cpp.o.requires

.PHONY : examples/CMakeFiles/EnsembledCrash.dir/requires

examples/CMakeFiles/EnsembledCrash.dir/clean:
	cd /home/akhila/deepstate/build/examples && $(CMAKE_COMMAND) -P CMakeFiles/EnsembledCrash.dir/cmake_clean.cmake
.PHONY : examples/CMakeFiles/EnsembledCrash.dir/clean

examples/CMakeFiles/EnsembledCrash.dir/depend:
	cd /home/akhila/deepstate/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/akhila/deepstate /home/akhila/deepstate/examples /home/akhila/deepstate/build /home/akhila/deepstate/build/examples /home/akhila/deepstate/build/examples/CMakeFiles/EnsembledCrash.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : examples/CMakeFiles/EnsembledCrash.dir/depend
