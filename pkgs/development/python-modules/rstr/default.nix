{ stdenv, fetchPypi, buildPythonPackage, pytest, pytestcov, tox }:

buildPythonPackage rec {
  pname = "rstr";
  version = "2.2.6";

  buildInputs = [ pytest pytestcov tox ];

  checkPhase = ''
    touch tox.ini
    tox
  '';

  src = fetchPypi {
    inherit pname version;
    sha256 = "197dw8mbq0pjjz1l6h1ksi62vgn7x55d373ch74y06744qiq5sjx";
  };

  meta = with stdenv.lib; {
    homepage = https://github.com/nir0s/distro;
    description = "Random Strings in Python";
    license = licenses.bsd3;
  };
}
