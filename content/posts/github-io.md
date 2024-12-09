---
title: "Free Web Hosting with GitHub Pages"
date: 2021-12-06T20:48:44-05:00
draft: false
author: "Tom Ratcliff"
toc: true
summary: Host your site for free using github pages
tags: ["github", "website"]
categories: ["github"]
---
## Github.io
Sign up and create a github.io repo/page here: [github.io](https://pages.github.com/)

## Custom Domain
Purchase a custom domain. I chose google domains [Google Domains](https://domains.google.com)

Once purchased we need to setup DNS

### Google Domains DNS
We need to create an A record to point our new domain to the github.io IPs

To get the github.io IPs we can use nslookup

```bash
nslookup ltratcliff.github.io
```
![Imgur](https://i.imgur.com/zG8Bwdc.png)

There's a handful of IP addresses here, but we are not concerned with the IPV6 ones (2606:50c0:etc.)

Make note of the 185.* address and we can input those in our google domain admin console

![Imgur](https://i.imgur.com/dB0bvSf.png)

We also need to create a CNAME for our new google domain to point to our github.io page

![Imgur](https://i.imgur.com/xIgDIi8.png)

## Github.io Custom Domain Settings

In yout github.com repo for your github.io page, you need to add you new custom domain in settings.

Details here: [Add custom Domain](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site)

To confirm dns records are configured correctly, we can use the `dig` command to verify

```bash
dig www.ltratcliff.com
```

![Imgur](https://i.imgur.com/Rzo4H9g.png)

## Content

In the example for github.io they have you push a simple hello world index.html. I prefer Hugo and their hello world, so we'll be going that route. 

For some basics on getting up and running in Hugo
 - [My Hugo Post] (https://ltratcliff.com/posts/funwithhugo/)
 - [Hugo official get started] (https://gohugo.io/getting-started/quick-start/)

Once you have a basic page, push up to a new repo in github:

1. create repo at [github.com](https://gohugo.io/getting-started/quick-start/)

   ![Imgur](https://i.imgur.com/zDlxWXZ.png)

1. Add your new hugo dir to this repo
    ```bash
    git init
    git add .
    git commit -m "init commit"
    git remote add origin (link from step 1)
    git push origin main
    ```

We're now ready to setup a ci/cd pipeline to build our hugo static site on a `git push` and then deploy those artifacts to our github.io repo (updating our webpage)

## CI/CD

Ideas weened from these pages (with some alteration for break/fixes)
 - [Ruddra.com](https://ruddra.com/hugo-deploy-static-page-using-github-actions/)
 - [whoami-shubham](https://github.com/whoami-shubham/whoami-shubham.github.io/blob/code/content/posts/Deploy-Hugo-static-site-using-Github-Actions.md)

 There's three steps:

1. Create a GitHub token here: [GitHub Token](https://github.com/settings/tokens/new)
1. Add this token to your hugo repo secrets
1. Create a GitHub action (like a gitlab ci/cd pipeline)

Step 1: navigate to the above token request page. Ensure you select the repo option and your expiration duration.

Make sure to record this token somewhere, as once you leave the page you cannot display it again.

Step 2: On your hugo repo page, navigate to settings via the gear icon

![Imgur](https://i.imgur.com/s1M14T5.png)

Once there, select "Secrets -> Actions"

![Imgur](https://i.imgur.com/INHN7Sb.png)

Click the "New repository secret" on the top right.
Enter "TOKEN" for the name and paste the token acquired from step 1. Save

Step 3: create this directory structure and file your hugo dir

```bash
mkdir -p .github/workflows/
touch .github/workflows/main.yml
```

The contents for main.yml should be (fill out the \<FILLMEIN\>):

```yaml
name: CI
on: push
jobs:
  deploy:
    runs-on: ubuntu-18.04
    steps:
      - name: Git checkout
        uses: actions/checkout@v2

      #(Optional) If you have the theme added as submodule and Update theme step(next step) is not working then delete themes directory
      #- name: Clone theme
      #  run: git submodule add --depth=1 https://github.com/theNewDynamic/gohugo-theme-ananke.git themes/ananke 

      - name: Update theme
        # (Optional)If you have the theme added as submodule, you can pull it and use the most updated version
        run: git submodule update --init --recursive

      - name: Setup hugo
        uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: "0.91.2"
          extended: true

      - name: Build
        # remove --minify tag if you do not need it
        # docs: https://gohugo.io/hugo-pipes/minification/
        run: HUGO_ENV=production hugo 

      - name: Deploy
        uses: peaceiris/actions-gh-pages@v3
        with:
          personal_token: ${{ secrets.TOKEN }}
          external_repository: <FILLEMEIN>
          publish_dir: ./public
          #   keep_files: true
          user_name: <FILLMEIN>
          user_email: <FILLMEIN>
          publish_branch: main
          cname: <FILLMEIN>
```

Now for the fun part! Push to github and watch github workflows build the code and then deploy to your webpage

```bash
git add .github
git commit -m "ci/cd"
git push origin main
```

On your GitHub Hugo repo navigate to the "Actions" page
![Imgur](https://i.imgur.com/s1M14T5.png)

Here you should see the Workflow build and deploy (you can see a few of me failed attempts 😛 - Hopefully you see a green checkmark)

![Imgur](https://i.imgur.com/fhOWlDR.png)




## Next Steps
Start adding content! In a future post I'm going to show to how to host a local nginx instance via docker/podman and configure your google domain to his this site dyamically via dynamic dns, ddclient and podman, letsencrypt, etc. This is a nice setup to host a one-off site or link to a download, etc.
