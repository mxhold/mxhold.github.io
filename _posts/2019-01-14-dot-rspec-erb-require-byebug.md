---
layout: post
title:  "Use ERB in your .rspec file to skip requiring byebug on CI"
date:   2019-01-14 14:24:37 -0800
---
You might already be using RSpec's `.rspec` file to [avoid](https://makandracards.com/makandra/36897-stop-writing-require-spec_helper-in-every-spec) having to add the `require 'spec_helper'` line at the top of all your spec files.

But did you know that RSpec supports [ERB in the `.rspec` file](https://relishapp.com/rspec/rspec-core/v/2-0/docs/configuration/read-command-line-configuration-options-from-files#using-erb-in-.rspec)?

Which means you can make your `.rspec` file this:
```
--require spec_helper
<%= "--require byebug" unless ENV["CI"] %>
```
in order to:

- always load [byebug](https://github.com/deivid-rodriguez/byebug) when running tests on your local machine so you don't have to add `require 'byebug'` every time you need to start a debugger with `byebug` 
- skip loading `byebug` during your [Continuous Integration](https://en.wikipedia.org/wiki/Continuous_integration) (CI) builds (assuming your CI server sets the `CI` environment variable like Travis CI [does](https://docs.travis-ci.com/user/environment-variables/#default-environment-variables))
- fail your CI builds fast whenever you accidentally leave in a call to `byebug` (instead of hanging waiting for input until eventually timing out)
