require "formula"

class Opensplice < Formula
  homepage "http://www.prismtech.com/opensplice"
  url "https://github.com/osrf/opensplice/releases/download/6.3.3-1/opensplice.tar.gz"
  version "6.3.3-1"
  sha1 "8fcfd2e03169aeb461e9bbe54fee1528feed8265"

  depends_on "cmake" => :build
  depends_on "gawk"

  def patches
    if MacOS.version >= :mavericks
      DATA
    end
  end

  bottle do
    root_url 'https://github.com/osrf/opensplice/releases/download/6.3.3-1'
    cellar :any
    revision 1
    sha1 "84aab9ca20dccb786f4d9cc0030547e7b25f67c1" => :mavericks
    sha1 "99bdb8890854eec049bf7ad0dc358777eca93d1c" => :mountain_lion
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
index 280a0fd..a93828c 100644
--- a/src/api/dcps/isocpp/include/dds/core/detail/ref_traits.hpp
+++ b/src/api/dcps/isocpp/include/dds/core/detail/ref_traits.hpp
@@ -21,6 +21,7 @@
 #include <dds/core/types.hpp>
 #include <dds/core/Exception.hpp>
 
+#define OSPL_USE_CXX11 1
 /* Compiling explicitly w/ C++ 11 support */
 #if defined(OSPL_USE_CXX11)
 #  include <memory>
