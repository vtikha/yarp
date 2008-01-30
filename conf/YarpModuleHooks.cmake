
#########################################################################
##
## Yet Another Device Compiling Monster
##   --paulfitz
##
#########################################################################


IF (NOT COMPILE_DEVICE_LIBRARY)


MACRO(ADD_LIBRARY LIBNAME)
  IF (YARPY_DEVICES)

    # no longer control compilation at the library level
    #SET(MYNAME "${DEVICE_PREFIX}${LIBNAME}")
    #SET(ENABLE_${MYNAME} TRUE CACHE BOOL "Enable/disable compilation of ${MYNAME}")
    #SET(YARPY_DEV_ACTIVE ENABLE_${MYNAME})

    IF (YARPY_DEV_ACTIVE)
      SET(YARPY_ACTIVE TRUE)
      IF (MERGE_DEVICE_LIBS)
        # this library is not actually needed
        #_ADD_LIBRARY(${MYNAME} ${YARPY_LIB_FLAG} ${ARGN} ${YARPY_DEV_SRC_LIST})
        FOREACH(SRC ${ARGN})
          GET_SOURCE_FILE_PROPERTY(SRC2 ${SRC} LOCATION)
          SET(YARPY_SRC_LIST ${YARPY_SRC_LIST} ${SRC2})
        ENDFOREACH(SRC ${ARGN})
        SET(YARPY_SRC_LIST ${YARPY_SRC_LIST} ${YARPY_DEV_SRC_LIST})
      ELSE (MERGE_DEVICE_LIBS)
        _ADD_LIBRARY(${MYNAME} ${ARGN} ${YARPY_DEV_SRC_LIST})
        SET(YARPY_SRC_LIST)
      ENDIF (MERGE_DEVICE_LIBS)
      SET(YARPY_LIB_LIST ${MYNAME} ${YARPY_LIB_LIST})
    ELSE (YARPY_DEV_ACTIVE)
        SET(YARPY_SRC_LIST)
        SET(YARPY_DEV_LIST)
    ENDIF (YARPY_DEV_ACTIVE)
    SET(YARPY_DEV_SRC_LIST)
  ELSE (YARPY_DEVICES)
    # pass on call without looking at it
    _ADD_LIBRARY(${LIBNAME} ${ARGN})
  ENDIF (YARPY_DEVICES)
ENDMACRO(ADD_LIBRARY LIBNAME)

MACRO(SET_TARGET_PROPERTIES LIBNAME)
  IF (YARPY_DEVICES)
    SET(MYNAME "${DEVICE_PREFIX}${LIBNAME}")
    ###MESSAGE(STATUS "setting properties for ${MYNAME}: ${ARGN}")
    _SET_TARGET_PROPERTIES(${MYNAME} ${ARGN})
  ELSE (YARPY_DEVICES)
    # pass on call without looking at it
    _SET_TARGET_PROPERTIES(${LIBNAME} ${ARGN})
  ENDIF (YARPY_DEVICES)
ENDMACRO(SET_TARGET_PROPERTIES LIBNAME)

MACRO(ADD_EXECUTABLE EXENAME)
  IF (YARPY_DEVICES)
    MESSAGE(STATUS "ignoring executable ${EXENAME}: ${ARGN}")
    #_ADD_EXECUTABLE(${EXENAME} ${YARPY_LIB_FLAG} ${ARGN})
  ELSE (YARPY_DEVICES)
    # pass on call without looking at it
    _ADD_EXECUTABLE(${EXENAME} ${ARGN})
  ENDIF (YARPY_DEVICES)
ENDMACRO(ADD_EXECUTABLE EXENAME)

IF (MERGE_DEVICE_LIBS)
  MACRO(ADD_DEFINITIONS)
    MESSAGE(STATUS "adding definitions: ${ARGN}")
    _ADD_DEFINITIONS(${ARGN})
    SET(YARPY_DEF_LIST ${YARPY_DEF_LIST} ${ARGN})
  ENDMACRO(ADD_DEFINITIONS)
ENDIF (MERGE_DEVICE_LIBS)

MACRO(LINK_LIBRARIES)
  IF (YARPY_DEVICES)
    ###MESSAGE(STATUS "adding libraries: ${ARGN}")
    _LINK_LIBRARIES(${ARGN})
    SET(YARPY_XLIB_LIST ${YARPY_XLIB_LIST} ${ARGN})
  ELSE (YARPY_DEVICES)
    # pass on call without looking at it
    _LINK_LIBRARIES(${ARGN})
  ENDIF (YARPY_DEVICES)
ENDMACRO(LINK_LIBRARIES)

MACRO(FIND_PACKAGE pkg)
  IF (YARPY_DEVICES)
    IF (NOT "${pkg}" STREQUAL "YARP")
      _FIND_PACKAGE(${pkg} ${ARGN})
    ELSE (NOT "${pkg}" STREQUAL "YARP")
       IF (COMPILING_ALL_YARP)
    	 INCLUDE_DIRECTORIES(${YARP_OS_INC} ${YARP_sig_INC} ${YARP_dev_INC})
         #LINK_LIBRARIES(YARP_dev ${YARP_EXTMOD_TARGETS} ${YARP_dev_EXT_LIBS} YARP_sig YARP_OS)
	 #MESSAGE(STATUS "YARP_LIBRARIES are ${YARP_LIBRARIES}")
	 LINK_LIBRARIES(${YARP_LIBRARIES})
	 SET(YARP_FOUND TRUE)
       ELSE (COMPILING_ALL_YARP)
 	 _FIND_PACKAGE(${pkg} ${ARGN})
       ENDIF (COMPILING_ALL_YARP)
    ENDIF (NOT "${pkg}" STREQUAL "YARP")
  ELSE (YARPY_DEVICES)
    # pass on call without looking at it
    _FIND_PACKAGE(${pkg} ${ARGN})
  ENDIF (YARPY_DEVICES)
ENDMACRO(FIND_PACKAGE)

MACRO(ADD_SUBDIRECTORY SUBDIR)
  IF (YARPY_DEVICES)
    _ADD_SUBDIRECTORY(${SUBDIR} ${ARGN})
    GET_DIRECTORY_PROPERTY(LIBS DIRECTORY ${SUBDIR} DEFINITION YARPY_LIB_LIST)
    GET_DIRECTORY_PROPERTY(XLIBS DIRECTORY ${SUBDIR} DEFINITION YARPY_XLIB_LIST)
    GET_DIRECTORY_PROPERTY(SRCS DIRECTORY ${SUBDIR} DEFINITION YARPY_SRC_LIST)
    GET_DIRECTORY_PROPERTY(INCS DIRECTORY ${SUBDIR} INCLUDE_DIRECTORIES)
    GET_DIRECTORY_PROPERTY(INCS2 DIRECTORY ${SUBDIR} DEFINITION YARPY_INC_LIST)
    IF (INCS2)
      SET(INCS ${INCS2})
    ENDIF (INCS2)
    GET_DIRECTORY_PROPERTY(LNKS DIRECTORY ${SUBDIR} LINK_DIRECTORIES)
    GET_DIRECTORY_PROPERTY(LNKS2 DIRECTORY ${SUBDIR} DEFINITION YARPY_LNK_LIST)
    IF (LNKS2)
      SET(LNKS ${LNKS2})
    ENDIF (LNKS2)
    GET_DIRECTORY_PROPERTY(DEFS DIRECTORY ${SUBDIR} DEFINITION YARPY_DEF_LIST)
    GET_DIRECTORY_PROPERTY(DEVS DIRECTORY ${SUBDIR} DEFINITION YARPY_DEV_LIST)
    GET_DIRECTORY_PROPERTY(ACTS DIRECTORY ${SUBDIR} DEFINITION YARPY_ACTIVE)
    IF (ACTS)
      SET(YARPY_LIB_LIST0 ${YARPY_LIB_LIST0} ${LIBS})
      SET(YARPY_XLIB_LIST0 ${YARPY_XLIB_LIST0} ${XLIBS})
      SET(YARPY_SRC_LIST0 ${YARPY_SRC_LIST0} ${SRCS})
      SET(YARPY_INC_LIST0 ${YARPY_INC_LIST0} ${INCS})
      SET(YARPY_LNK_LIST0 ${YARPY_LNK_LIST0} ${LNKS})
      SET(YARPY_DEF_LIST0 ${YARPY_DEF_LIST0} ${DEFS})
    ENDIF (ACTS)
    SET(YARPY_DEV_LIST0 ${YARPY_DEV_LIST0} ${DEVS})

  ELSE (YARPY_DEVICES)
    # pass on call without looking at it
    _ADD_SUBDIRECTORY(${SUBDIR} ${ARGN})
  ENDIF (YARPY_DEVICES)
ENDMACRO(ADD_SUBDIRECTORY SUBDIR)

MACRO(YARP_PREPARE_DEVICES)
  SET(YARP_CODE_PRE)
  SET(YARP_CODE_POST)
  FOREACH(dev ${YARPY_DEV_LIST0})
    SET(YARP_CODE_PRE "${YARP_CODE_PRE}\nextern void add_${dev}();")
    SET(YARP_CODE_POST "${YARP_CODE_POST}\n    add_${dev}();")
  ENDFOREACH(dev ${YARPY_DEV_LIST0})
  SET(YARP_LIB_NAME ${YARPY_DEV_LIB_NAME})
  CONFIGURE_FILE(${YARP_MODULE_PATH}/yarpdev_lib.cpp.in
     ${YARPY_DEV_GEN}/add_${YARP_LIB_NAME}_devices.cpp @ONLY  IMMEDIATE)
  CONFIGURE_FILE(${YARP_MODULE_PATH}/yarpdev_lib.h.in
     ${CMAKE_BINARY_DIR}/add_${YARP_LIB_NAME}_devices.h @ONLY  IMMEDIATE)

 SET(YARPY_DEV_LIBRARIES)
 IF (MERGE_DEVICE_LIBS)
  #MESSAGE(STATUS "Aggregate library:")
  #MESSAGE(STATUS "INCLUDE_DIRECTORIES  ${YARPY_INC_LIST0}")
  #MESSAGE(STATUS "LINK_DIRECTORIES  ${YARPY_LNK_LIST0}")
  #MESSAGE(STATUS "_ADD_DEFINITIONS  ${YARPY_DEF_LIST0}")
  #MESSAGE(STATUS "_LINK_LIBRARIES  ${YARPY_XLIB_LIST0}")
  INCLUDE_DIRECTORIES(${YARPY_INC_LIST0})
  LINK_DIRECTORIES(${YARPY_LNK_LIST0})
  _ADD_DEFINITIONS(${YARPY_DEF_LIST0})
  _LINK_LIBRARIES(${YARPY_XLIB_LIST0})
  ###MESSAGE(STATUS "adding --> ${YARPY_XLIB_LIST0}")
  _ADD_LIBRARY(${YARPY_DEV_LIB_NAME} ${YARPY_SRC_LIST0} ${YARPY_DEV_GEN}/add_${YARPY_DEV_LIB_NAME}_devices.cpp)
   SET(YARPY_DEV_LIBRARIES ${YARPY_DEV_LIB_NAME} ${YARPY_XLIB_LIST0})
 ELSE (MERGE_DEVICE_LIBS)
   _ADD_LIBRARY(${YARPY_DEV_LIB_NAME} ${YARPY_DEV_GEN}/add_${YARPY_DEV_LIB_NAME}_devices.cpp)
   SET(YARPY_DEV_LIBRARIES ${YARPY_DEV_LIB_NAME} ${YARPY_XLIB_LIST0})
   FOREACH(LIB ${YARPY_LIB_LIST0})
     ###MESSAGE(STATUS "adding --> ${LIB}")
     TARGET_LINK_LIBRARIES(${YARPY_DEV_LIB_NAME} ${LIB})
     SET(YARPY_DEV_LIBRARIES ${YARPY_DEV_LIBRARIES} ${YARPY_DEV_LIB_NAME} ${YARPY_XLIB_LIST0})
   ENDFOREACH(LIB ${YARPY_LIB_LIST0})
 ENDIF (MERGE_DEVICE_LIBS)
 GET_TARGET_PROPERTY(YARP_DEV_LIB_LOCATION ${YARPY_DEV_LIB_NAME} LOCATION)
 GET_FILENAME_COMPONENT(YARP_DEV_LIB_DIR ${YARP_DEV_LIB_LOCATION} PATH)

 IF (COMPILING_ALL_YARP)
    #TARGET_LINK_LIBRARIES(${YARPY_DEV_LIB_NAME}dev ${YARP_EXTMOD_TARGETS} ${YARP_dev_EXT_LIBS} YARP_sig YARP_OS)
 ELSE (COMPILING_ALL_YARP)
    CONFIGURE_FILE(${YARP_MODULE_PATH}/yarpdev_lib_main.cpp.in
        ${YARPY_DEV_GEN}/yarpdev_${YARPY_DEV_LIB_NAME}.cpp @ONLY  IMMEDIATE)
    _ADD_EXECUTABLE(${YARPY_DEV_LIB_NAME}dev ${YARPY_DEV_GEN}/yarpdev_${YARPY_DEV_LIB_NAME}.cpp)
    TARGET_LINK_LIBRARIES(${YARPY_DEV_LIB_NAME}dev ${YARPY_DEV_LIB_NAME})
 ENDIF (COMPILING_ALL_YARP)

 # --> switched from CMAKE_CURRENT_BINARY_DIR to CMAKE_BINARY_DIR
# SET(YARPY_DEV_DIR ${CMAKE_CURRENT_BINARY_DIR})
# SET(YARPY_OUT_DIR ${CMAKE_CURRENT_BINARY_DIR})
 SET(YARPY_DEV_DIR ${CMAKE_BINARY_DIR})
 SET(YARPY_OUT_DIR ${CMAKE_BINARY_DIR})
 CONFIGURE_FILE(${YARP_MODULE_PATH}/DEVICEConfig.cmake.in
     ${CMAKE_BINARY_DIR}/${YARPY_DEV_LIB_NAME}Config.cmake @ONLY  IMMEDIATE)
 EXPORT_LIBRARY_DEPENDENCIES(${CMAKE_BINARY_DIR}/${YARPY_DEV_LIB_NAME}Dependencies.cmake)

  #SET(@YARPY_DEV_LIB_NAME@_LIB_DEPENDS "general;@YARPY_DEV_LIB_NAME@;${@YARPY_DEV_LIB_NAME@_LIB_DEPENDS}")



ENDMACRO(YARP_PREPARE_DEVICES)


MACRO(END_DEVICE_LIBRARY devname)
  IF ("${devname}" STREQUAL "${YARPY_MASTER_DEVICE}")
    #MESSAGE(STATUS "working with ${YARPY_DEV_LIST0}")
    #MESSAGE(STATUS "working with ${YARPY_SRC_LIST0}")
    #MESSAGE(STATUS "working with ${YARPY_INC_LIST0}")
    YARP_PREPARE_DEVICES()
    SET(YARPY_DEVICES FALSE)
  ELSE ("${devname}" STREQUAL "${YARPY_MASTER_DEVICE}")

    # we may be a nested subdirectory
    SET(YARPY_LIB_LIST ${YARPY_LIB_LIST0})
    SET(YARPY_XLIB_LIST ${YARPY_XLIB_LIST0})
    SET(YARPY_SRC_LIST ${YARPY_SRC_LIST0})
    SET(YARPY_INC_LIST ${YARPY_INC_LIST0})
    SET(YARPY_LNK_LIST ${YARPY_LNK_LIST0})
    SET(YARPY_DEF_LIST ${YARPY_DEF_LIST0})
    SET(YARPY_DEV_LIST ${YARPY_DEV_LIST0})
    SET(YARPY_ACTIVE TRUE)

    #MESSAGE(STATUS "passing back ${YARPY_DEV_LIST}")
    #MESSAGE(STATUS "passing back ${YARPY_SRC_LIST}")
    #MESSAGE(STATUS "passing back ${YARPY_INC_LIST}")
  ENDIF ("${devname}" STREQUAL "${YARPY_MASTER_DEVICE}")
ENDMACRO(END_DEVICE_LIBRARY devname)


ENDIF(NOT COMPILE_DEVICE_LIBRARY)

