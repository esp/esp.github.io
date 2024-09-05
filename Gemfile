source "https://rubygems.org"

gem "minimal-mistakes-jekyll", "~> 4.26.2"

# HACK to workaround
# GitHub Metadata: Error processing value 'repo_pages_info':
# Liquid Exception: uninitialized constant Faraday::Error::ConnectionFailed Did you mean? Faraday::ConnectionFailed in /_layouts/default.html
# https://stackoverflow.com/questions/59558141/jekyll-minimal-mistakes-theme-throwing-uninitialized-constant-faradayerrorc
# gem 'faraday', '0.17.3'

gem 'github-pages', group: :jekyll_plugins

# After updating ot jekyll 4.2.2 I was getting the error reported here:
# https://github.com/jekyll/jekyll/issues/8523
# Fix is to add webrick
gem "webrick", "~> 1.8"
