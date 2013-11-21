
name "observed"
maintainer "KUOKA Yusuke"
homepage "https://github.com/gree/observed"

replaces        "observed"
install_path    "/opt/observed"
build_version   Omnibus::BuildVersion.new.semver
build_iteration 1

# creates required build directories
dependency "preparation"

dependency "observed"

# version manifest file
dependency "version-manifest"

exclude "\.git*"
exclude "bundler\/git"
