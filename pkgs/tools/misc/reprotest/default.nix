{ lib, stdenv, fetchgit, python3Packages,
  diffoscope,
  libfaketime, disorderfs,
  coreutils, utillinux, bash,
  docutils, help2man,
}:

python3Packages.buildPythonApplication rec {
  name = "reprotest-${version}";
  version = "0.7.8";

  src = fetchgit {
    url    = "https://anonscm.debian.org/git/reproducible/reprotest.git";
    rev    = "refs/tags/${version}";
    sha256 = "1g67r7srb551hqwpn5gmx1si7j190zb46gh56x3amljq1h3lalir";
  };

  patches = [
    ./0001-Do-not-record-system-architecture.patch
    ./0002-Default-to-system-interface-nix-no-use-of-dpkg.patch
  ];


  postPatch = ''
    # When generating manpage, use the installed version
    substituteInPlace doc/Makefile --replace "../bin" "$out/bin"
  '';

  propagatedBuildInputs = [
    python3Packages.rstr
    python3Packages.libarchive-c
    python3Packages.python_magic
    diffoscope
    # run-time dependencies
    libfaketime
    disorderfs
    coreutils
    bash
    utillinux
  ];

  nativeBuildInputs = [ docutils help2man ];

  postFixup = ''
    wrapPythonProgramsIn "$out/lib/${python3Packages.python.libPrefix}/site-packages/reprotest/virt" "$out $pythonPath"
  '';

  postInstall = ''
    make -C doc
    mkdir -p $out/share/man/man1
    cp doc/reprotest.1 $out/share/man/man1/reprotest.1
  '';

  meta = with stdenv.lib; {
    description = "Build software and check it for reproducibility";
    longDescription = ''
     reprotest builds the same source code twice in different environments, and
     then checks the binaries produced by each build for differences. If any
     are found, then diffoscope (or if unavailable then diff) is used to
     display them in detail for later analysis.

     It supports different types of environment such as a "null" environment
     (i.e.  doing the builds directly in /tmp) or various other virtual
     servers, for example schroot, ssh, qemu, and several others.

     reprotest is developed as part of the “reproducible builds” Debian project.
    '';
    homepage    = https://wiki.debian.org/ReproducibleBuilds;
    license     = licenses.gpl3Plus;
    platforms   = platforms.linux;
  };
}
