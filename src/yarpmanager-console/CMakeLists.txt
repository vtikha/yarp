# Copyright (C) 2006-2020 Istituto Italiano di Tecnologia (IIT)
# All rights reserved.
#
# This software may be modified and distributed under the terms of the
# BSD-3-Clause license. See the accompanying LICENSE file for details.

if(YARP_COMPILE_yarpmanager-console)
  add_executable(yarpmanager-console)

  set(yarpmanager_console_SRCS yarpmanager.cpp
                               ymanager.cpp)
  set(yarpmanager_console_HDRS ymanager.h)


  target_sources(yarpmanager-console PRIVATE ${yarpmanager_console_SRCS}
                                             ${yarpmanager_console_HDRS})

  target_link_libraries(yarpmanager-console PRIVATE YARP::YARP_init
                                                    YARP::YARP_os
                                                    YARP::YARP_manager)

  if(MSVC)
    target_include_directories(yarpmanager-console SYSTEM PRIVATE ${dirent_INCLUDE_DIRS})
  endif()

  if(YARP_HAS_Libedit)
    target_compile_definitions(yarpmanager-console PRIVATE YARP_HAS_Libedit)
    target_link_libraries(yarpmanager-console PRIVATE Libedit::libedit)
  endif()

  install(TARGETS yarpmanager-console
          COMPONENT utilities
          DESTINATION ${CMAKE_INSTALL_BINDIR})

  set_property(TARGET yarpmanager-console PROPERTY FOLDER "Command Line Tools")
endif()
