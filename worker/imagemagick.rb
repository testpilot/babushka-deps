dep 'imagemagick.managed' do
  installs { via :apt, 'libmagickwand-dev', 'imagemagick' }
  provides %w[compare animate convert composite conjure import identify stream display montage mogrify]
end
