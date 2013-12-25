name "observed"
#version "0.1.1"
version "master"

dependency "ruby"
dependency "rubygems"
#dependency "bundler"
dependency "rsync"

source :git => "https://github.com/gree/observed.git"

relative_path "observed"

build do
  gem "install bundler --no-rdoc --no-ri -v 1.3.0"
  bundle "install --path=#{install_dir}/embedded/service/gem"
  command "mkdir -p #{install_dir}/embedded/service/observed"
  command "#{install_dir}/embedded/bin/rsync -a --delete --exclude=.git/*** --exclude=.gitignore ./ #{install_dir}/embedded/service/observed/"
end
