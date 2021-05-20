cmake_minimum_required(VERSION 3.17)
project(AS2)

set(CMAKE_CXX_STANDARD 20)

include_directories(instantclient_19_8/sdk/include/)
link_directories(instantclient_19_8/)
add_executable(AS2 main.cpp env.h)
target_link_libraries(AS2 libclntsh.dylib.19.1 libocci.dylib)