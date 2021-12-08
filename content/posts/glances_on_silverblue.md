---
title: "Glances on SilverBlue after an update"
date: 2021-11-11T19:08:27-05:00
draft: false
author: "Tom Ratcliff"
toc: true
tags: ["glances", "python", "silverblue"]
categories: ["fedora", "silverblue"]
---


Just updated from silverblue 34 to 35 with:

```bash
rpm-ostree rebase fedora:fedora/35/x86_64/silverblue
```

The update went very smooth, however there were a few minor caveats.

1. My Fedora 34 toolbox was inop
 1. Had to add/update to a fedora 35 container
 1. created ansible script to make migration easier

```yaml
---
- hosts: localhost
  become: true
  gather_facts: false
  vars_files:
    - software.yml
  tasks:
    - name: Install software
      dnf:
        name: "{{ software }}"
        state: latest
```
software.yml:
```yaml
software:
  - zsh
  - vim
  - tmux
  - golang
  - java-latest-openjdk
  - java-latest-openjdk-devel
  - nodejs
  - kubernetes-client
  - helm
  - sqlite
  - lsd
  - rsync
  - jq
  - ImageMagick
```

2) Random tools no logoner worked (ie: glances).

![](https://imgur.com/B7IoVKr.png)

End Result:
![](https://imgur.com/bue8k3F.png)
