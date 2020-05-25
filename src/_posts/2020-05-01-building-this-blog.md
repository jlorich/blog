---
layout: post
title:  Building this blog
date:   2020-05-01
image: /images/2020-05-22-build.jpg
categories: azure devops published
---

A large part of my career at Microsoft has been about helping people find effective solutions to their challenges. As many businesses have fairly uncommon challenges that means there often are fairly niche/unique solutions, however given enough time I often run across common patterns so I've been meaning to find a good place to document them — hence the creation of this site.

I'm not one to half-ass a technology related project, especially one that takes up my free time, so in the process of putting this site together I've made an effort to make this the most robust static blog site possible.

---

## Components

There are a lot of different pieces to what I've built beyond just the site content, here's a breakdown of everything I put together:

#### The site itself

As I just wanted a static blog site, I've chosen to use [Jekyll](https://jekyllrb.com/). Jekyll is an extremely well supported Ruby-based static blog site generator.  I've used it in the past for a number of projects and it's rock solid.  It lets me write posts in [markdown](https://daringfireball.net/projects/markdown/syntax), or in this specific use case a variant of it called [kramdown](https://kramdown.gettalong.org/), provide some HTML/CSS templating, and spit out everything combined together.

#### Tools for developing the blog

Now, I don't want to install Ruby.  I'm a Linux guy, but I do most of my development on Windows and Ruby on Windows honestly isn't a great experience.  The [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl) is amazing and generally my go-to choice, but I've been trying hard to force myself to containerize *everything* I can to provide as much flexibility as possible — plus managing Ruby versions is annoying on Linux too.

Because of all this I've decided to go with a DevContainer approach.  In the repo for this site I've included a `Dockerfile` that includes stages for both *building* the site in CI AND *developing* on the project itself.  I'm leveraging [Visual Studio Code Remote - Containers](https://code.visualstudio.com/docs/remote/containers) to launch my development environment *inside* the provided container, so all my dependencies are brought along with the project.  Simple open the repo folder in VS Code and it will prompt to build and open the project inside the dev container.  This should be 100% consistent across ANY machine.

#### Linux containers on Windows?

As I mentioned, I'm on Windows most of the time.  Windows containers historically don't play the nicest with Windows and require standing up a fairly heavy VM to get them running.  However with the advent of WSL version 2 Docker Desktop for Windows can now run containers *inside* the native Windows Linux environment without a need for a VM.  This is called the [Docker Desktop WSL 2 backend](https://docs.docker.com/docker-for-windows/wsl/).  It's provided for an incredibly speedy and smooth experience.

#### Infrastructure

Even a static site needs to live somewhere.  Naturally, I'm going to deploy on Azure - and as it's all static **Azure Storage** makes the most sense.  Azure Storage supports [static website hosting](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-static-website) out of the box, and even custom domain SSL if you [front it with Azure CDN](https://docs.microsoft.com/en-us/azure/storage/blobs/static-website-content-delivery-network).  This is a ultra-low-cost option that will provide incredibly robust performance around the world.  I'm even using Azure Key Vault to store the certificates for my domain and Azure DNS to correctly route my resources.

#### Infrastructure as Code

So how do I stand it all up? Well, to take a spin on the DevOps mantra "friends don't let friends right-click publish" I'm going to say "friends don't let friends create production resources in the Azure portal".  All the infrastrutre defitions for this site lives as code in the repo right alongside the source.  I'm using [Terraform](https://www.terraform.io/) to provision every single thing needed for this site in a flexible manner that can be applied in multiple environments for staging/testing purposes.  I'm even leveraging the [ACME provider](https://www.terraform.io/docs/providers/acme/index.html) pointing at [Let's Encrypt](https://letsencrypt.org/) to generate new TLS certificates on each deployment if needed.

```hcl
resource "azurerm_storage_account" "default" {
  name                      = local.storage_account_name
  resource_group_name       = azurerm_resource_group.default.name
  location                  = azurerm_resource_group.default.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  static_website {
    index_document = "index.html"
    error_404_document = "404.html"
  }
}
```

#### CI/CD

An overly-engineered static blog site certainly wouldn't be complete without a CI/CD pipeline, so I've also built [Azure Pipelines YAML Templates](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/templates?view=azure-devops) for building the site (using the provided Dockerfile), using Terraform to create/update the infrastructure, and then to deploy out to the releveant Azure resources.  To make changes I simple commit and push markdown updates and everything is taken care of for me.

---

## But, why?

Really I wanted to build this to show a robust development experience from soup to nuts.  In a single repo all the tools for developers, operations, and more are tied together and provide a robust and consistent experience.  Also the fact that the end product of all this is actually just a bunch of html/css files is pretty comical to me.  I could have just used something like Squarespace and been done ages ago, but where's the fun in that?!
