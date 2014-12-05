require 'formula'

class OpenmpRt < Formula
  url "https://www.openmprtl.org/sites/default/files/libomp_20140926_oss.tgz"
  sha1 "488ff3874eb5c971523534cb3c987bfb5ce3addb"
  homepage 'https://www.openmprtl.org'

  def install
    ENV.append "CFLAGS", "-Wno-error=unused-command-line-argument-hard-error-in-future"
    ENV.append "CXFLAGS", "-Wno-error=unused-command-line-argument-hard-error-in-future"

    args = [
        "compiler=#{ENV.compiler}", "Wno-error=unused-command-line-argument-hard-error-in-future"
    ]

    system "make", *args
    include.install Dir["tmp/*rel*/*.h"]
    include.install Dir["tmp/*rel*/*.f"]
    include.install Dir["tmp/*rel*/*.f90"]
    lib.install Dir["tmp/*rel*/*.dylib"]
  end

  def patches
    if MacOS.version >= :mavericks && ENV.compiler == :clang
        DATA
    end
  end

end

__END__
diff --git a/cmake/Intel/CFlags.cmake b/cmake/Intel/CFlags.cmake
index d2a528a..fdce2d2 100644
--- a/cmake/Intel/CFlags.cmake
+++ b/cmake/Intel/CFlags.cmake
@@ -151,7 +151,6 @@ function(append_compiler_specific_linker_flags input_ld_flags input_ld_flags_lib
             append_linker_flags("-def:${def_file}")
         endif()
     elseif(${MAC})
-        append_linker_flags("-no-intel-extensions")
         if(NOT ${STUBS_LIBRARY})
             append_linker_flags_library("-pthread") # link in pthread library
             append_linker_flags_library("-ldl") # link in libdl (dynamic loader library)
diff --git a/src/makefile.mk b/src/makefile.mk
index 083252a..6731a9d 100644
--- a/src/makefile.mk
+++ b/src/makefile.mk
@@ -432,9 +432,6 @@ ifeq "$(os)" "lrb"
   ifeq "$(ld)" "$(c)"
     ld-flags += -Wl,--warn-shared-textrel
     ld-flags += -Wl,--version-script=$(src_dir)exports_so.txt
-    ld-flags += -static-intel
-    # Don't link libcilk*.
-    ld-flags += -no-intel-extensions
     # Discard unneeded dependencies.
     ld-flags += -Wl,--as-needed
 #    ld-flags += -nodefaultlibs
@@ -1184,7 +1181,7 @@ ifeq "$(mac_os_new)" "1"
 else
     iomp$(obj) : $(lib_obj_files) external-symbols.lst external-objects.lst .rebuild
 	    $(target)
-	    $(c) -r -nostartfiles -static-intel  -no-intel-extensions \
+	    $(c) -r -nostartfiles \
 		-Wl,-unexported_symbols_list,external-symbols.lst \
 		-Wl,-non_global_symbols_strip_list,external-symbols.lst \
 		-filelist external-objects.lst \
