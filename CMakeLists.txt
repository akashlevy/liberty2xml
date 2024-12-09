cmake_minimum_required(VERSION 3.10)
project(liberty2xml)

# Find Flex and Bison
find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

# Define the input files
set(FLEX_INPUT ${CMAKE_SOURCE_DIR}/liberty2xml.ll)
set(BISON_INPUT ${CMAKE_SOURCE_DIR}/liberty2xml.yy)

# Define the output files
set(FLEX_OUTPUT ${CMAKE_BINARY_DIR}/liberty2xml.lex.cpp)
set(BISON_OUTPUT ${CMAKE_BINARY_DIR}/liberty2xml.tab.cpp)
set(BISON_HEADER ${CMAKE_BINARY_DIR}/liberty2xml.tab.hpp)

# Generate the Flex and Bison files
FLEX_TARGET(Lexer ${FLEX_INPUT} ${FLEX_OUTPUT})
BISON_TARGET(Parser ${BISON_INPUT} ${BISON_OUTPUT} DEFINES_FILE ${BISON_HEADER})

# Add the generated files to the project
ADD_FLEX_BISON_DEPENDENCY(Lexer Parser)

# Add the executable
add_executable(liberty2xml ${FLEX_OUTPUT} ${BISON_OUTPUT})

# Include the directory where Bison generated header is located
target_include_directories(liberty2xml PRIVATE ${CMAKE_BINARY_DIR})
