---
layout: post
title:  Building this blog
date:   2020-05-01
categories: azure devops published
---

A large part of my career at Microsoft has been about helping people find effective solutions to their challenges. As many businesses have fairly uncommon challenges that means there often are fairly niche/unique solutions, however given enough time I often run across common patterns so I've been meaning to find a good place to document them — hence the creation of this site.

I'm not one to half-ass a technology related project, especially one that takes up my free time, so in the process of putting this site together I've made an effort to make this the most robust static blog site possible.

You can find the entirety of the source for this site [on github](https://github.com/jlorich/blog).  Please feel free to copy the site setup, configuration, dev tools, or CI/CD pipelines for yourself

---

## Development

#### Jekyll

As I just wanted a static blog site, I've chosen to use [Jekyll](https://jekyllrb.com/). Jekyll is an extremely well supported Ruby-based static site generator.  I've used it in the past for a number of projects and it's rock solid.  It lets me write posts in [markdown](https://daringfireball.net/projects/markdown/syntax), or in this specific use case a variant of it called [kramdown](https://kramdown.gettalong.org/), provide some HTML/CSS templating, and spit out everything combined together.  Code snippets even have syntax highlighting powered by [rouge](https://github.com/rouge-ruby/rouge), a syntax-highlighting gem written in pure Ruby.

#### Development container

Now, I don't want to install Ruby.  I'm a Linux guy, but I do most of my development on Windows and Ruby on Windows honestly isn't a great experience.  The [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl) is amazing and generally my go-to choice, but I've been trying hard to force myself to containerize *everything* I can to provide as much flexibility as possible — plus managing Ruby versions is annoying on Linux too.

Because of all this I've decided to go with a devcontainer approach.  In the repo for this site I've included a `Dockerfile` that includes stages for both *building* the site in CI AND *developing* on the project itself.  I'm leveraging [Visual Studio Code Remote - Containers](https://code.visualstudio.com/docs/remote/containers) to launch my development environment *inside* the provided container, so all my dependencies are brought along with the project.  Simple open the repo folder in VS Code and it will prompt to build and open the project inside the dev container.  This should be 100% consistent across ANY machine.

Here's a sample devcontainer.json file used for configuring the development environment.  You can view the current version on GitHub [here](https://github.com/jlorich/blog/blob/master/.devcontainer/devcontainer.json).

```js
{
	"name": "Blog",
	"dockerFile": "../Dockerfile",
	"context": "..",
	"build": {
		"target": "dev"
	},

	"mounts": [
		"source=/var/run/docker.sock,target=/var/run/docker.sock,type=bind",
		"source=${localEnv:HOME}${localEnv:USERPROFILE}/.git,target=/home/vscode/.config/git,type=bind",
	],

	"workspaceFolder": "/workspaces/blog",

	// Set *default* container specific settings.json values on container create.
	"settings": { 
		"terminal.integrated.shell.linux": "/bin/bash"
	},

	// Add the IDs of extensions you want installed when the container is created.
	"extensions": [
		"ms-azuretools.vscode-docker",
		"ms-azuretools.vscode-azureterraform",
		"mauve.terraform",
		"redhat.vscode-yaml"
	],

	// jekyll will serve on 4000
	"forwardPorts": [4000]
}
```

#### Containers on Windows?

As I mentioned, I'm on Windows most of the time.  Windows containers historically don't play the nicest with Windows and require standing up a fairly heavy VM to get them running.  However, with the advent of WSL version 2, Docker Desktop for Windows can now run containers *inside* a native Linux environment without a need for a creating a VM.  This is called the [Docker Desktop WSL 2 backend](https://docs.docker.com/docker-for-windows/wsl/) and it's allowed for an incredibly speedy and smooth experience.

## Infrastructure

#### It's just file storage!

Even a static site needs to live somewhere.  Naturally, I'm going to deploy on Azure - and as it's all static **Azure Storage** makes the most sense.  Azure Storage supports [static website hosting](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-static-website) out of the box, and even custom domain SSL if you [front it with Azure CDN](https://docs.microsoft.com/en-us/azure/storage/blobs/static-website-content-delivery-network).  This is an ultra-low-cost option that will provide incredibly robust performance around the world.  I'm even using Azure Key Vault to store the certificates for my domain and Azure DNS to correctly route my resources.

#### Let's Encrypt

It's 2020 and every site should be able to be access with HTTPS/TSL, bar none. It's not just a security thing, it's a _privacy_ thing.  

#### Infrastructure as Code

So how do I stand it all up? Well, to take a spin on the popular DevOps mantra "friends don't let friends right-click publish" I'm going to go ahead and say:

>Friends don't let friends create production resources by hand

All the infrastructure defitions for this site live as code in the repo right alongside the rest of the source.  I'm using [Terraform](https://www.terraform.io/) to provision every single thing needed for this site in a flexible manner that can be applied in multiple environments for staging/testing purposes.

For example, here's a the Terraform resource that stands up the storage account that backs this whole site:

```hcl
resource "azurerm_storage_account" "default" {
  name                      = local.storage_account_name
  resource_group_name       = azurerm_resource_group.default.name
  location                  = azurerm_resource_group.default.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  static_website {
    index_document = "index.html"
    error_404_document = "404.html"
  }
}
```

I'm even leveraging the [ACME provider](https://www.terraform.io/docs/providers/acme/index.html) pointing at [Let's Encrypt](https://letsencrypt.org/) to generate new TLS certificates on each deployment if needed!

## Process and deployments

#### Continuous integration and deployment

An overly-engineered static blog site certainly wouldn't be complete without a CI/CD pipeline, so I've also built [Azure Pipelines YAML Templates](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/templates?view=azure-devops) for building the site (using the provided Dockerfile), using Terraform to create/update the infrastructure, and then to deploy out to the releveant Azure resources.  To make changes I simple commit and push markdown updates and everything is taken care of for me.

Here's a quick snippet from the `build.yml` template you can find on [GitHub](https://github.com/jlorich/blog/blob/master/templates/build.yml)

```yaml
- task: AzureCLI@2
  inputs:
    displayName: Compile Blog
    azureSubscription: {%raw%} ${{ parameters.azureSubscription }} {%endraw%}
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      ...
      docker run \
          --mount type=bind,source=$(Build.ArtifactStagingDirectory),target=/workspaces/blog/src/_site \
          builder      
      ...
```

---

## But... why?

I wanted to build this in a way that shows a robust development experience from soup to nuts.  In a single repo all the tools for developers, operations, and more are tied together and provide a robust and consistent experience deployed in a completely automated fashion.  Also, the fact that the end product of all this together is just a bunch of html/css is pretty comical to me.  I could have just used something like Squarespace and been done ages ago, but where's the fun in that?!
