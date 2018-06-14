cmake_minimum_required(VERSION 3.2)

macro(wut_enable_newlib target)
   set_property(TARGET ${target} APPEND_STRING PROPERTY
      LINK_FLAGS  " -Wl,--whole-archive -lwutnewlib -Wl,--no-whole-archive")
endmacro(wut_enable_newlib)

macro(wut_default_malloc target)
   set_property(TARGET ${target} APPEND_STRING PROPERTY
      LINK_FLAGS  " -Wl,--whole-archive -lwutmalloc -Wl,--no-whole-archive")
endmacro(wut_default_malloc)

macro(wut_enable_devoptab target)
   set_property(TARGET ${target} APPEND_STRING PROPERTY
      LINK_FLAGS  " -Wl,--whole-archive -lwutdevoptab -Wl,--no-whole-archive")
endmacro(wut_enable_devoptab)

macro(wut_enable_stdcpp target)
   target_link_libraries(${target}
      stdc++)

   set_property(TARGET ${target} APPEND_STRING PROPERTY
      COMPILE_FLAGS "-std=c++17")

   set_property(TARGET ${target} APPEND_STRING PROPERTY
      LINK_FLAGS " -Wl,--whole-archive -lwutstdc++ -Wl,--no-whole-archive")
endmacro(wut_enable_stdcpp)

macro(wut_add_exports target exports_file)
   set(RPL_EXPORTS_FILE ${exports_file})
   if(NOT IS_ABSOLUTE ${exports_file})
      set(RPL_EXPORTS_FILE "${CMAKE_CURRENT_SOURCE_DIR}/${exports_file}")
   endif()

   set(RPL_EXPORT_GEN_OUTPUT ${target}_exports.s)

   add_custom_command(
      OUTPUT ${RPL_EXPORT_GEN_OUTPUT}
      COMMAND ${WUT_RPLEXPORTGEN} ${RPL_EXPORTS_FILE} ${RPL_EXPORT_GEN_OUTPUT}
      DEPENDS ${RPL_EXPORTS_FILE})
   target_sources(${target} PRIVATE ${RPL_EXPORT_GEN_OUTPUT})

   set_source_files_properties(${RPL_EXPORT_GEN_OUTPUT} PROPERTIES LANGUAGE C)
endmacro(wut_add_exports)

function(wut_create_rpl target source)
   set(RPL_OPTIONS IS_RPX)
   set(RPL_SINGLE_ARGS "")
   set(RPL_MULTI_ARGS "")
   cmake_parse_arguments(RPL "${RPL_OPTIONS}" "${RPL_SINGLE_ARGS}" "${RPL_MULTI_ARGS}" "${ARGN}")

   if(RPL_IS_RPX)
      target_link_libraries(${source}
         wutcrt)
   else()
      set(ELF2RPL_FLAGS ${ELF2RPL_FLAGS} --rpl)
      target_link_libraries(${source}
         wutcrtrpl)
   endif()

   target_link_libraries(${source}
      coreinit)

   add_custom_target(${target} ALL
      COMMAND ${WUT_ELF2RPL} ${ELF2RPL_FLAGS} ${source} ${target}
      DEPENDS ${source}
      COMMENT "Converting to RPX ${target}")

   add_dependencies(${target} ${source})
endfunction()

function(wut_create_rpx)
   wut_create_rpl(${ARGV} IS_RPX)
endfunction()
