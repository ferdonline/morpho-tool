


list(APPEND SRC_EXPORTER "morpho_tool.cpp" )

include_directories( ${CMAKE_CURRENT_SOURCE_DIR}/../morpho )


add_executable(morpho-tool ${SRC_EXPORTER} ${SRC_MESHER} ${MORPHO_HEADERS_BITS} ${MORPHO_HEADERS})


target_link_libraries(morpho-tool
                                ${CMAKE_THREAD_LIBS_INIT}
                                ${HDF5_C_LIBRARIES}  ${Boost_FILESYSTEM_LIBRARIES}
                                ${Boost_SYSTEM_LIBRARIES} ${Boost_PROGRAM_OPTIONS_LIBRARIES}
                                ## additional dependencies required for CGAL
                                ${Boost_THREAD_LIBRARIES}

                                morpho
                                morpho_io
                                ${MORPHO_MESHER_TARGET}
                             )



install(TARGETS morpho-tool RUNTIME DESTINATION ${BIN_INSTALL_DIR})



