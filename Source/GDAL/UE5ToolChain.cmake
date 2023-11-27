# UE_ROOT may for example be "/home/juzzuj/code/prereq/UnrealEngine5.3". Note: no trailing slash!
if("${UE_ROOT}" STREQUAL "")
    set(UE_ROOT "$ENV{UE_ROOT}")
endif()
  
if("${UE_ROOT}" STREQUAL "")
    message(FATAL_ERROR "UE_ROOT has not been set.")
endif()

set(ue_libcxx_dir "${UE_ROOT}/Engine/Source/ThirdParty/Unix/LibCxx")
set(ue_compiler_subdir "Engine/Extras/ThirdPartyNotUE/SDKs/HostLinux/Linux_x64")
# set(ue_compiler_name "v21_clang-15.0.1-centos7") # UE5.2. Varies with UE version.
set(ue_compiler_name "v22_clang-16.0.6-centos7") # UE5.3. Varies with UE version.
set(ue_compiler_dir "${UE_ROOT}/${ue_compiler_subdir}/${ue_compiler_name}/x86_64-unknown-linux-gnu")

set(CMAKE_SYSROOT "${ue_compiler_dir}")
set(CMAKE_C_COMPILER "${ue_compiler_dir}/bin/clang" CACHE STRING "The C compiler to use.")
set(CMAKE_CXX_COMPILER "${ue_compiler_dir}/bin/clang++" CACHE STRING "The C++ compiler to use.")

add_link_options("-fuse-ld=lld")  # make Clang use the LLVM linker lld.

# Add compiler flags to use the standard library header files shipped with Unreal Engine.
set(ue_compiler_flags "-nostdinc++ -I${ue_libcxx_dir}/include -I${ue_libcxx_dir}/include/c++/v1")  # add -v here to print a list of include paths during compilation (debugging output)
# add_compile_options("$<$<COMPILE_LANGUAGE:CXX>:${ue_compiler_flags}>")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${ue_compiler_flags}")

set(ue_linker_flags "-nodefaultlibs -lc++ -lc++abi -L${ue_libcxx_dir}/lib/Unix/x86_64-unknown-linux-gnu/")
if(NOT CMAKE_SHARED_LINKER_FLAGS MATCHES "${ue_libcxx_dir}")
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${ue_linker_flags}" CACHE INTERNAL "")
endif()

set(CMAKE_C_STANDARD_LIBRARIES "-lm -lc -lgcc_s -lgcc" CACHE INTERNAL "")
set(CMAKE_CXX_STANDARD_LIBRARIES "${ue_libcxx_dir}/lib/Unix/x86_64-unknown-linux-gnu/libc++.a ${ue_libcxx_dir}/lib/Unix/x86_64-unknown-linux-gnu/libc++abi.a -lm -lc -lgcc_s -lgcc -lpthread" CACHE INTERNAL "")

# this is a bit of a messy thing. but for a good reason. Up until (and including) -lpthread,
# this is needed to compile GDAL. The following nghttp2 include and library path are
# necessary for libcurl (which depends on nghttp2) and on which GDAL depends. 
# So the linker needs this. And it needs to be late in the link command. I found no
# other way of doing this.
set(CMAKE_CXX_STANDARD_LIBRARIES "${CMAKE_CXX_STANDARD_LIBRARIES} -I${UE_ROOT}/Engine/Source/ThirdParty/nghttp2/1.47.0/include -L${UE_ROOT}/Engine/Source/ThirdParty/nghttp2/1.47.0/lib/Unix/x86_64-unknown-linux-gnu/Release -lnghttp2")

# lets CMake detect pthread
set(CMAKE_REQUIRED_LIBRARIES ${ue_libcxx_dir}/lib/Unix/x86_64-unknown-linux-gnu/libc++.a ${ue_libcxx_dir}/lib/Unix/x86_64-unknown-linux-gnu/libc++abi.a -lm -lc -lgcc_s -lgcc -lpthread)

set(CMAKE_SIZEOF_VOID_P 8 CACHE INTERNAL "")

set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
