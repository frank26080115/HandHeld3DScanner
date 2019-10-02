cmake_minimum_required(VERSION 2.8)

project(rs-pointcloud-recorder)

# set path
set(SOURCE_BASE ${PROJECT_SOURCE_DIR}/)

if(NOT INSTALL_PREFIX)
    add_definitions( -DINSTALL_PREFIX="${CMAKE_INSTALL_PREFIX}" )
endif()

if(NOT CMAKE_INSTALL_BINDIR)
    set(CMAKE_INSTALL_BINDIR /usr/local/bin)
endif()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -Wall -fmessage-length=0 --std=c++11 -fPIC -std=c++0x -fexceptions -frtti -ffunction-sections -fdata-sections -latomic")

include_directories(
    ${PROJECT_SOURCE_DIR}/inc
    /usr/include
)

link_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    /usr/lib
    /usr/local/lib
)

set(SOURCES
    src/rs_pointcloud_recorder.cpp
)

add_executable(${PROJECT_NAME} ${SOURCES})

set(LIBRARIES_TO_LINK
    realsense2
    GL
    GLU
    glfw
)

target_link_libraries(${PROJECT_NAME} ${LIBRARIES_TO_LINK})

set_property(TARGET rs-pointcloud-recorder PROPERTY CXX_STANDARD 11)

install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})