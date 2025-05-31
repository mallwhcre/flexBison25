cmake_minimum_required(VERSION 3.16)
project(FlexBison25 C)

find_package(BISON 2.3 REQUIRED)
find_package(FLEX 2.6 REQUIRED)

set(SRC_DIR ${CMAKE_SOURCE_DIR}/src)

bison_target(Parser ${SRC_DIR}/parser.y ${CMAKE_BINARY_DIR}/parser.c DEFINES_FILE ${CMAKE_BINARY_DIR}/parser.h)
flex_target(Lexer ${SRC_DIR}/lexer.l ${CMAKE_BINARY_DIR}/lexer.c)
add_flex_bison_dependency(Lexer Parser)

include_directories(${SRC_DIR})
include_directories(${CMAKE_BINARY_DIR})

add_executable(myhtml
    ${BISON_Parser_OUTPUTS}
    ${FLEX_Lexer_OUTPUTS}
    ${SRC_DIR}/main.c
    ${SRC_DIR}/checks.c
)

add_library(checks STATIC ${SRC_DIR}/checks.c)
target_link_libraries(myhtml checks)
