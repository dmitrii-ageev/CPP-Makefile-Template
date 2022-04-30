# C++ Makefile Template
A Generic Makefile Template for C++ Projects

## Description

### Features:
* Automatically traverses and lists all (code files in) sub-directories, or you manually add;
* Automatically generates and processes dependencies;
* Automatically formats code syntax, runs static code analysis and unit tests;
* With examples in-file, and flags for high performance with small size of binary;

### Usage:
1. Copy the `Makefile` file to your program source code directory.
2. Run `make install-requirements` to get software required for the Makefile.
3. Type `make` to start building your program.

### Make Target:
The Makefile provides the following targets to make:
```Shell
   make all                  # compile and link
   make format               # format C++ code
   make check                # run syntax/code check
   make debug                # build a debug release with maximum verbosity
   make test                 # run unit tests
   make coverage             # create a test coverage report
   make release              # build an application release
   make archive              # create a source code release
   make install-requirements # installs all Makefile requirements
   make clean                # clean objects and the executable file
   make help                 # get the usage of the makefile
```

## Author
  Dmitrii Ageev <d.ageev@gmail.com>
  
