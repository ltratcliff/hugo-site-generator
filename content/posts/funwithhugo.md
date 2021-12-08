---
title: "Fun With Hugo"
date: 2021-11-06T13:40:19-04:00
draft: false
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

---

## Quickstart
The Official docs: [here](https://gohugo.io/getting-started/quick-start/) help get you setup with installation, and a new project

namely
1. `yum|apt|brew intall hugo`
2. `hugo new site sitename`
   1. Theme installation: 
      1. `git init` 
      2. `git submodule add https://github.com/theNewDynamic/gohugo-theme-ananke.git themes/ananke`
3. `hugo new posts/postname.md`

---

## Themes
So. Many. Options.

[Themes](https://themes.gohugo.io)

The quickstart recommends ananke, and that's what I stuck with. If you go through the youtube
link above, Mike uses his own theme to help explain some hugo concepts (list pages, single pages, etc.)

---

## Developement

The easiest way to see your changes in real time is to use:

```bash
hugo -D serve
```

This will open a socket on [http://localhost:1313](http://localhost:1313)

 > Changes made to the source code will reflect in real time (without the need to refresh)

---

## Archetypes

Archtypes are great for automating the front-matter (top metadata on posts above the ---)
I created one archtype to auto populate author, toc and tags for posts

This is created by creating a .md file in the archetypes dir with a name matching the folder used in new posts
ie: `archetypes -> posts.md` will match any new post created by `hugo new posts/whatever.md`

![](/images/fun_with_hugo/archetypes.png)

This make ensure all new posts created with `hugo new posts/article.md` will have that front-matter

---

## Content

This directory contains other directories and markdown files for content

![](/images/fun_with_hugo/content-tree.png)

---

## Layouts (aka Templates)

These HTML templates make it easy to inject reusable html (think style, header, footer, etc.) 
 into single pages and lists as well as static HTML (and go templating) into individual .md files

Let's consider this directory structure:

![](/images/fun_with_hugo/layout_tree.png)

### Partials

Partials will take an entire html block and insert into a template (or shortcode, etc.).
The `tag-cloud.html` partial above looks like this:

```html
<script>
  let tagArray = new Array();
  {{ range $key, $value := .Site.Data.mytechs.techs }}
	tagArray.push([{{ $key }}, {{ $value }}])
  {{ end }}
</script>
<script src="/js/wordcloud2.js"></script>

<div id="tag-wrapper" style="width: 100%; height: 400px;"></div>
<script>
    WordCloud(document.querySelector("#tag-wrapper"), {
        list: tagArray,
	drawOutOfBounds: false,
        shrinkToFit: true,
    });
</script>
```

This can then be used in a template via (like in the `tech.html` shortcode we will look at shortly):
```go
{{ partial "tag-cloud.html" . }}
```

### Shortcodes

Shortcodes are similar. They are used as a way to insert go logic into a markdown file:

A simple example from the docs (`year.html`):

```go
{{ now.Format "2006" }}
```

Used in your markdown post via:
```
{{</* year */>}}
```

Will interpolate to the current year.

You can also use variables defined in your front-matter like so:

Front-Matter example:
```yam
---
title: "Fun With Hugo"
var: "test"
array: [1,2,3,4,5]
---
```

Shortcode ex:
```
{{</* param "var" */>}}
{{</* param "Title" */>}}
{{</* param "array" */>}}
```
Output:

{{<param "var" >}}
{{<param "Title" >}}
{{<param "array" >}}

Here's some more examples using slices, ranges, etc.

The shortcode `rangeshortcode.html` contains this html/go:

```go
<h3>Shuffled</h3>
{{ (seq 1 5) | shuffle }}

{{ $array := (seq 1 5) }}
{{ $list := slice "one" "two" "three" }}

<h4>Range over array</h4>
{{ range $array }}
 {{ . }}
{{ end }}

<h4>Range with index</h4>
{{ range $elem_index, $elem_val := $array }}
 <p>
 {{ $elem_index }} - {{ $elem_val }}
 </p>
{{ end }}

<h4>Slice</h4>
{{ $list }}

<h4>Range Slice</h4>
{{ range $list }}
  {{ . }}
{{ end }}
```
When used with:
```
{{</* rangeshortcode */>}}
```

Will produce the following content in the post:

{{< rangeshortcode >}}

---

## Public

The public directory contains all of the files needed for your static site. These can placed in your httpd/nginx/etc. directory for serving.

These files are built using:
```bash
hugo
# or to build draft posts
hugo -D
```

---

## Static

Static contains objects contained on your pages (ie: images, css, etc.)

When placing images, javascript, etc. You can reference in your markdown/html like so.

For a dir structure like this:

![](/images/fun_with_hugo/static-tree.png)


Image example in markdown:

```md
![](/images/fun_with_hugo/content-tree.png)
```

Javascript example in partial html:

```html
<script src="/js/wordcloud2.js"></script>

<div id="tag-wrapper" style="width: 100%; height: 400px;"></div>
<script>
    WordCloud(document.querySelector("#tag-wrapper"), {
        list: tagArray,
        drawOutOfBounds: false,
        shrinkToFit: true,
    });
</script>
```

---

## Data

Data contains yaml, json, toml files that can be referenced in other templates.

For example, with this dir structure and yaml content:

![](/images/fun_with_hugo/data-tree.png)

This can be referenced like so:

```html {linenos=true,hl_lines=[3,6]}
<script>
  let tagArray = new Array();
  {{ range $key, $value := .Site.Data.mytechs.techs }}
	tagArray.push([{{ $key }}, {{ $value }}])
  {{ end }}
  console.log(tagArray)
</script>
```

Which will produce the following in the browser console:

![](/images/fun_with_hugo/webconsole.png)
