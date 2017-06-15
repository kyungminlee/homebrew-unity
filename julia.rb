class Julia < Formula
  desc "High-level dynamic programming language"
  homepage "http://julialang.org"
  url "https://github.com/JuliaLang/julia/releases/download/v0.5.1/julia-0.5.1-full.tar.gz"
  sha256 "533b6427a1b01bd38ea0601f58a32d15bf403f491b8415e9ce4305b8bc83bb21"

  depends_on :fortran => :build
  depends_on :perl => ["5.3", :build]
  depends_on :python

  depends_on "gpatch" => :build
  depends_on "patchelf" => :build

  depends_on "curl"
  depends_on "pcre2"
  depends_on "gmp"
  depends_on "fftw"
  depends_on "mpfr"
  depends_on "libgit2"
  depends_on "mbedtls"
  depends_on "openssl"
  depends_on "kyungminlee/harmony/mkl"

  env :super

  def install
    Pathname("Make.user").write <<-EOS.undent
    USE_INTEL_MKL=1
    MKLROOT=#{Formula["mkl"].opt_prefix}
    USE_SYSTEM_FFTW=1
    USE_SYSTEM_GMP=1
    USE_SYSTEM_PCRE=1
    USE_SYSTEM_MPFR=1
    USE_SYSTEM_LIBGIT2=1
    prefix=#{prefix}
    EOS

    mkdir_p "#{buildpath}/usr/lib"
    # Sneak in the fftw libraries, as julia doesn't know how to load dylibs from any place other than
    # julia's usr/lib directory and system default paths yet; the build process fixes that after the
    # install step, but the bootstrapping process requires the use of the fftw libraries before then
    ["", "f", "_threads", "f_threads"].each do |ext|
      ln_s "#{Formula["fftw"].lib}/libfftw3#{ext}.so", "#{buildpath}/usr/lib/"
    end
    # Do the same for openblas, pcre, mpfr, and gmp
    ln_s "#{Formula["pcre2"].lib}/libpcre2-8.so", "#{buildpath}/usr/lib/"
    ln_s "#{Formula["mpfr"].lib}/libmpfr.so", "#{buildpath}/usr/lib/"
    ln_s "#{Formula["gmp"].lib}/libgmp.so", "#{buildpath}/usr/lib/"

    system "make", "-C", "deps"
    system "make"

    ["", "f", "_threads", "f_threads"].each do |ext|
      rm "#{buildpath}/usr/lib/libfftw3#{ext}.so"
    end
    rm "#{buildpath}/usr/lib/libpcre2-8.so"
    rm "#{buildpath}/usr/lib/libmpfr.so"
    rm "#{buildpath}/usr/lib/libgmp.so"

    system "make", "install"
    
    # fix arpack's rpath
    # TODO: find out why superenv fails to set rpath for arpack
    system "chmod", "u+w", "#{lib}/julia/libarpack.so.2.0.0"
    system "patchelf", "--set-rpath", "#{HOMEBREW_PREFIX}/lib:$ORIGIN", "#{lib}/julia/libarpack.so.2.0.0"
    system "chmod", "u-w", "#{lib}/julia/libarpack.so.2.0.0"
  end

  test do
    # test sparse and dense 
    Pathname("test.jl").write <<-EOS.undent
    denseMatrix = [1.0 2.0; 2.0 -1.0]
    sparseMatrix = sparse([1,1,2,2], [1,2,1,2], [1.0,2.0,2.0,-1.0])
    println(eig(denseMatrix))
    println(eigs(sparseMatrix))
    EOS
    system "julia", "test.jl"
  end
end
