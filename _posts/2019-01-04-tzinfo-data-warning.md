---
layout: post
title:  "Silencing tzinfo-data Bundler warnings"
date:   2019-01-04 14:24:37 -0800
---
If you've ever created a new [Rails](https://rubyonrails.org/) app and then ran `bundle install` on a Unix-like system, you've probably seen this warning:
>The dependency tzinfo-data (>= 0) will be unused by any of the platforms Bundler is installing for. Bundler is installing for ruby but the dependency is only for x86-mingw32, x86-mswin32, x64-mingw32, java. To add those platforms to the bundle, run bundle lock --add-platform mingw, mswin, x64_mingw, jruby.

This is a classic example of a noisy warning.

Bundler is trying to be helpful and telling you that you have a gem in your Gemfile that it's not going to install because it's marked as only being for certain platforms.

Usually, this is a good thing: it can be [confusing](https://github.com/bundler/bundler/pull/5003) if Bundler skips gems listed in your Gemfile without telling you why.

In this case, it's not so helpful.

Rails includes this gem because it needs to be able to do timezone conversions and the library it uses ([tzinfo](https://tzinfo.github.io/)) depends on having timezone definitions available.

On Unix-like systems, these are usually provided by the system itself so the tzinfo gem will just use those.
Windows, however, does not provide these definitions so the tzinfo-data gem needs to be included to provide them instead.

If you're using a Unix-like system, you can safely ignore these warnings but since they happen every time you run `bundle install`, they can get very annoying and it's useful to know how to turn them off.

## How to silence these warnings

Fortunately, Bundler (versions >= 1.17.0) has an [option](https://bundler.io/v1.17/bundle_config.html) `disable_platform_warnings` for silencing these warnings.

You can set it for a specific app by running:

```bash
bundle config --local disable_platform_warnings true
```
Every developer has to do this individually since Rails git ignores the `.bundle` directory where this config is stored (which is [intentional](https://stackoverflow.com/questions/6963496/why-does-rails-ignore-bundle-by-default) since most of the options used for configuring Bundler have to do with the local system e.g. gem installation options specific to a machine).

If you leave off the `--local` option, the warnings will be silenced globally for the current machine, regardless of which project you're in.

This is preferable to [other ways](https://github.com/tzinfo/tzinfo-data/issues/12#issuecomment-279554001) to avoid seeing this warning since it keeps the app working in Windows and doesn't install unneeded dependencies on non-Windows systems.
