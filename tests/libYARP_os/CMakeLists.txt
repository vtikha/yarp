# Copyright (C) 2006-2020 Istituto Italiano di Tecnologia (IIT)
# All rights reserved.
#
# This software may be modified and distributed under the terms of the
# BSD-3-Clause license. See the accompanying LICENSE file for details.

add_executable(harness_os)

target_sources(harness_os PRIVATE BinPortableTest.cpp
                                  BottleTest.cpp
                                  ContactTest.cpp
                                  ElectionTest.cpp
                                  EventTest.cpp
                                  LogStreamTest.cpp
                                  LogTest.cpp
                                  MessageStackTest.cpp
                                  NetTypeTest.cpp
                                  NetworkTest.cpp
                                  NodeTest.cpp
                                  PeriodicThreadTest.cpp
                                  PortablePairTest.cpp
                                  PortReaderBufferTest.cpp
                                  PortTest.cpp
                                  PropertyTest.cpp
                                  PublisherTest.cpp
                                  ResourceFinderTest.cpp
                                  RFModuleTest.cpp
                                  RouteTest.cpp
                                  SemaphoreTest.cpp
                                  StampTest.cpp
                                  StringInputStreamTest.cpp
                                  StringOutputStreamTest.cpp
                                  SystemInfoTest.cpp
                                  TerminatorTest.cpp
                                  ThreadTest.cpp
                                  TimerTest.cpp
                                  TimeTest.cpp
                                  ValueTest.cpp
                                  VocabTest.cpp)

target_include_directories(harness_os PRIVATE ${hmac_INCLUDE_DIRS})

target_link_libraries(harness_os PRIVATE YARP_harness
                                         YARP::YARP_os
                                         YARP::YARP_sig
                                         YARP::YARP_dev
                                         YARP::YARP_companion)

if(YARP_HAS_ACE)
  target_compile_definitions(harness_os PRIVATE YARP_HAS_ACE)
  target_link_libraries(harness_os PRIVATE ACE::ACE_INLINE)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  target_link_libraries(harness_os PRIVATE pthread)
endif()

set_property(TARGET harness_os PROPERTY FOLDER "Test")

yarp_parse_and_add_catch_tests(harness_os)


add_executable(print_value_table)
target_sources(print_value_table PRIVATE print_value_table.cpp)
target_link_libraries(print_value_table PRIVATE YARP::YARP_os)
set_property(TARGET print_value_table PROPERTY FOLDER "Test")
