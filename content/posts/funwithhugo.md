---
title: "Fun With Hugo"
date: 2021-11-06T13:40:19-04:00
draft: true
author: "Tom Ratcliff"
toc: true
tags: ["golang", "hugo"]
categories: ["golang"]
var: "test"
array: [1,2,3,4,5]
---

I've been digging the Hugo static website generator. 
Getting up and running quickly using github.io pages and  Hugo was 
breeze. Here's a few things I've learned over the last 2-3 days playing with Hugo

## Recommendations
This youtube playlist by giraffe academy was a great start. 
Shout out to Mike Dane for making this content

{{< youtube qtIqKaDlqXo>}}

## Quickstart
The Official docs: [here](https://gohugo.io/getting-started/quick-start/) help get you setup with installation, and a new project

namely
1. `yum|apt|brew intall hugo`
2. `hugo new site sitename`
   1. Theme installation: 
      1. `git init` 
      2. `git submodule add https://github.com/theNewDynamic/gohugo-theme-ananke.git themes/ananke`
3. `hugo new posts/postname.md`

## Themes
So. Many. Options.

[Themes](https://themes.gohugo.io)

The quickstart recommends ananke, and that's what I stuck with. If you go through the youtube
link above, Mike uses his own theme to help explain some hugo concepts (list pages, single pages, etc.)

## Archetypes

## Content

## Layouts (aka Templates)

### Partials

### Shortcodes

## Public

## Static

## Data

{{<param "var" >}}
{{<param "Title" >}}
{{<param "array" >}}

{{< year >}}

{{< rangeshortcode >}}

[comment]: <> ({{ range := .Params.array }})

[comment]: <> ( {{ . }})

[comment]: <> ({{ end }})

[comment]: <> ({{ range $elem_index, $elem_val := $array }})

[comment]: <> ( {{ $elem_index }} - {{ $elem_val }})

[comment]: <> ({{ end }})

