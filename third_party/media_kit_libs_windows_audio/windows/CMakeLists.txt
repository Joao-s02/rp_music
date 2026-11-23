# This file is a part of media_kit (https://github.com/media-kit/media-kit).
#
# Copyright © 2021 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
# All rights reserved.
# Use of this source code is governed by MIT license that can be found in the LICENSE file.

cmake_minimum_required(VERSION 3.14)

# This option is read by the other packages which are part of package:media_kit.
option(MEDIA_KIT_LIBS_AVAILABLE "package:media_kit libraries are available." ON)

set(PROJECT_NAME "media_kit_libs_windows_audio")
project(${PROJECT_NAME} LANGUAGES CXX)

# Pin the archive and the installed DLL to the reviewed Immuch360 release.
if(NOT CMAKE_SIZEOF_VOID_P EQUAL 8 OR CMAKE_GENERATOR_PLATFORM MATCHES "[Aa][Rr][Mm]")
  message(FATAL_ERROR "RP Music bundles libmpv for Windows x64.")
endif()
set(LIBMPV_RELEASE "libmpv-windows-20261110-1")
set(LIBMPV "mpv-dev-x86_64-20261110-git-0b7ed67.7z")
set(LIBMPV_SHA256 "f97a1e31c697ad4f4eb15c51d2d451154268c31a39dae1085418debc2e918da4")
set(LIBMPV_DLL_SHA256 "3f026a3263ecb31fd6b0297a865cd68cb65420bd40e338bb487df0e356e1ed8a")
set(LIBMPV_ARCHIVE "${CMAKE_BINARY_DIR}/${LIBMPV}")
set(LIBMPV_SRC "${CMAKE_BINARY_DIR}/${LIBMPV_RELEASE}")

if(DEFINED ENV{RP_MUSIC_LIBMPV_ARCHIVE})
  set(LIBMPV_ARCHIVE "$ENV{RP_MUSIC_LIBMPV_ARCHIVE}")
elseif(NOT EXISTS "${LIBMPV_ARCHIVE}")
  file(DOWNLOAD
    "https://github.com/immuch360/libmpv-builds/releases/download/${LIBMPV_RELEASE}/${LIBMPV}"
    "${LIBMPV_ARCHIVE}.download"
    EXPECTED_HASH "SHA256=${LIBMPV_SHA256}" TLS_VERIFY ON)
  file(RENAME "${LIBMPV_ARCHIVE}.download" "${LIBMPV_ARCHIVE}")
endif()
file(SHA256 "${LIBMPV_ARCHIVE}" archive_hash)
if(NOT archive_hash STREQUAL LIBMPV_SHA256)
  message(FATAL_ERROR "Unexpected libmpv archive SHA-256: ${LIBMPV_ARCHIVE}")
endif()

file(MAKE_DIRECTORY "${LIBMPV_SRC}")
execute_process(
  COMMAND "${CMAKE_COMMAND}" -E tar xf "${LIBMPV_ARCHIVE}"
  WORKING_DIRECTORY "${LIBMPV_SRC}"
  RESULT_VARIABLE result)
if(NOT result STREQUAL "0")
  message(FATAL_ERROR "Could not extract ${LIBMPV_ARCHIVE}: ${result}")
endif()
file(SHA256 "${LIBMPV_SRC}/libmpv-2.dll" dll_hash)
if(NOT dll_hash STREQUAL LIBMPV_DLL_SHA256)
  message(FATAL_ERROR "Unexpected SHA-256 for the extracted libmpv DLL.")
endif()

set(RP_MUSIC_LIBMPV_DIR "${LIBMPV_SRC}" PARENT_SCOPE)

set(PLUGIN_NAME "media_kit_libs_windows_audio_plugin")

add_library(
  ${PLUGIN_NAME} SHARED
  "include/media_kit_libs_windows_audio/media_kit_libs_windows_audio_plugin_c_api.h"
  "media_kit_libs_windows_audio_plugin_c_api.cpp"
)

apply_standard_settings(${PLUGIN_NAME})

set_target_properties(
  ${PLUGIN_NAME}
  PROPERTIES
  CXX_VISIBILITY_PRESET
  hidden
)
target_compile_definitions(
  ${PLUGIN_NAME}
  PRIVATE
  FLUTTER_PLUGIN_IMPL
)

target_include_directories(
  ${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
)
target_link_libraries(
  ${PLUGIN_NAME}
  PRIVATE
  flutter
  flutter_wrapper_plugin
)

set(
  media_kit_libs_windows_audio_bundled_libraries
  "${LIBMPV_SRC}/libmpv-2.dll"
  PARENT_SCOPE
)
