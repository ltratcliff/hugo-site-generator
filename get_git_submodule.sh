#!/bin/bash
git submodule update --init --recursive
git submodule update --recursive --remote
# update ./themes/ananke/layouts/partials/social-share.html
# from {{ with .Site.Social.twitter }} to {{ with .Site.Params.Social.twitter }}
