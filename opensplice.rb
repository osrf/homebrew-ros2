require "formula"

class Opensplice < Formula
  homepage "http://www.prismtech.com/opensplice"
  url "https://github.com/osrf/opensplice/archive/6.3.3-1.tar.gz"
  sha1 "85fe898165c2c859f7def999ab1a36ca00501a2c"

  depends_on "cmake" => :build
  depends_on "gawk"

  def patches
    if ! build.head?
      DATA
    end
  end

  bottle do
    root_url 'http://download.ros.org/bottles'
    cellar :any
    sha1 "088bd8fe15ddfcf6437eb6b25fd38e4b01b21b3d" => :mavericks
  end

  head 'https://github.com/osrf/opensplice', :using => :git

  def install
    ENV.deparallelize
    ENV.no_optimization
    mkdir "build_cmake" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    system "idlpp", "-h"
  end
end
__END__
diff --git a/src/api/dcps/isocpp/include/dds/core/detail/ref_traits.hpp b/src/api/dcps/isocpp/include/dds/core/detail/ref_traits.hpp
index 280a0fd..213cfcd 100644
--- a/src/api/dcps/isocpp/include/dds/core/detail/ref_traits.hpp
+++ b/src/api/dcps/isocpp/include/dds/core/detail/ref_traits.hpp
@@ -22,6 +22,7 @@
 #include <dds/core/Exception.hpp>

 /* Compiling explicitly w/ C++ 11 support */
+#define OSPL_USE_CXX11 1
 #if defined(OSPL_USE_CXX11)
 #  include <memory>
 #  include <type_traits>
diff --git a/CMakeLists.txt b/CMakeLists.txt
index df3a78e..683238a 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -3,20 +3,24 @@ cmake_minimum_required(VERSION 2.8)
 project(opensplice)

 # To build, run our bash wrapper script
+if(NOT DEFINED OSPL_BUILD_CONFIG)
+  set(OSPL_BUILD_CONFIG x86_64.linux2.6-release)
+endif()
 add_custom_target(build ALL
-                  COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/minimal_build.sh x86_64.linux2.6-release
+                  COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/minimal_build.sh ${OSPL_BUILD_CONFIG}
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

 # To install, cherry-pick some stuff
-install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/install/minimal/lib/
+message("Installing to ${CMAKE_INSTALL_PREFIX}")
+install(DIRECTORY install/minimal/lib/
         DESTINATION lib)
-install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/install/minimal/include/
+install(DIRECTORY install/minimal/include/
         DESTINATION include)
-install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/install/minimal/etc/
+install(DIRECTORY install/minimal/etc/
         DESTINATION etc)
-install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/install/minimal/bin/
+install(DIRECTORY install/minimal/bin/
         DESTINATION bin)
-install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/install/minimal/share/
+install(DIRECTORY install/minimal/share/
         DESTINATION share)

 # Set up CPack to produce a source tarball.
diff --git a/minimal_build.sh b/minimal_build.sh
index 1cb4064..388b068 100755
--- a/minimal_build.sh
+++ b/minimal_build.sh
@@ -11,7 +11,7 @@ make install
 set -x
 rm -rf install/minimal
 mkdir -p install/minimal
-cp -a install/HDE/*/lib install/minimal
+cp -aRL lib/* install/minimal/lib
 mkdir -p install/minimal/include
 cp -a install/HDE/*/include install/minimal/include/opensplice
 mkdir -p install/minimal/etc
diff --git a/bin/configure_functions b/bin/configure_functions
index d591abf..72407c3 100644
--- a/bin/configure_functions
+++ b/bin/configure_functions
@@ -452,9 +452,9 @@ get_abstraction_header_dirs ()
     SPLICE_REAL_TARGET=$SPLICE_TARGET
     set_var SPLICE_TARGET $SPLICE_HOST
     # ... to read the OS abstration headers for the host 'target'
-    set_var OSPL_HOST_HEADERS `make --no-print-directory get_target_os_header_dir`
+    set_var OSPL_HOST_HEADERS `make get_target_os_header_dir`
     # ... then set SPLICE_TARGET correctly & repeat
     set_var SPLICE_TARGET $SPLICE_REAL_TARGET
-    set_var OSPL_TARGET_HEADERS `make --no-print-directory get_target_os_header_dir`
+    set_var OSPL_TARGET_HEADERS `make get_target_os_header_dir`
     popd > /dev/null
 }
diff --git a/bin/sppodl b/bin/sppodl
index 3858e4b..d5fb3bb 100755
--- a/bin/sppodl
+++ b/bin/sppodl
@@ -22,7 +22,7 @@ else
     -m) odlpp_options="$odlpp_options $1";;
     -*) options="$options $1";;
     *)
-       cpp $options $1 $1.$$.odl
+       cpp $options $1 > $1.$$.odl
        $WINCMD odlpp $odlpp_options $1.$$.odl
        rm -f $1.$$.odl
     ;;
