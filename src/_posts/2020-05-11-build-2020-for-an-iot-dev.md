---
layout: post
title:  "Microsoft Build 2020 - Sessions for an IoT Developer"
date:   2020-05-22
image: /images/2020-05-22-build.jpg
categories: learning azure iot build published
---

This year, for the first time ever, [Microsoft Build](https://mybuild.microsoft.com/) was offered as a 100% digital event —  live streaming a concurrent multitude of developer-focused broadcasts for 48 hours straight.  If you've never experienced Build before, it's the premier Microsoft developer conference, offering product updates, roadmaps, guidance, customer solutions, and more.  All in all more than 600 sessions were recorded and published, covering nearly every topic that a developer levearging Microsoft tools would want to hear.

Since digging through the vast session catalog can be time a daunting experience, I'd love to share my short list of sessions geared towards those developing IoT solutions in Azure:

## [1. Microsoft IoT Vision and Roadmap](https://mybuild.microsoft.com/sessions/64bae920-be29-4f08-8c95-f46893519695)

*Speaker: Sam George - Corporate Vice President, Azure Iot*

Of all the IoT sessions to watch, this is the most important. In this talk Sam George, Microsoft Corporate Vice President of Azure IoT, gives an update on the current and future state of Azure IoT.  This talk includes awesome customer use cases, the IoT response to Covid-19, new product annoucements (including Azure RTOS General Availability and the upcoming Azure Digital Twins v2 public preview), roadmap discussion and more.  It's a _must see_.


## [2. Azure Digital Twins: Powering the Next Generation of IoT](https://mybuild.microsoft.com/sessions/236599ae-ebe0-4b34-bfd9-4a3558e72bc6)

*Speaker: Christian Schormann - Partner Group Program Manager, Azure IoT*

As far as new products go, this is the big one.  Azure Digital Twins is set to bring new horizions in spacial intelligence — letting you create and interact with comprehensive models of physical and virtual environments though a higly performant, scalable, and flexible architecture that natively integrates with the Azure IoT Services.  If you're building or managing devices at scale, especially if they live in complex physical environments, this is not a session you want to miss.

## [3. Make your IoT data useful with an end-to-end analytics platform, Azure Time Series Insights](https://mybuild.microsoft.com/sessions/1ef69f98-aedb-4644-aa1e-c2f6239c73e5)

*Speakers:*
 - *Deepak Palled - Program Manager, Azure IoT Analytics*
 - *Diego Viso - Principal PM Manager, Azure IoT*


Azure Time Series Insights (TSI) is the premier way to slice and dice through incredible amounts of live streaming time series data.  It's a Software as a Service analytics tool that can bring both tools for exploring the data as well as ways to surface up the charts and insights into your own applications.  This session covers what new features are coming to TSI and how people are using it to be successful.

## [4. Building a DevOps Culture in a Remote World](https://mybuild.microsoft.com/sessions/540c76f7-0f1b-4df5-b253-b9820fb18bf5)

*Speaker: Emily Freeman - Principal Cloud Advocate, Modern Operations Advocay Manager*

Though not strictly an IoT session, this one sits high on my list because it's an *EVERYONE* session.  Emily has a long history of providing some of the most poignant insights into organizational culture, including quite literally writing *the* book on the subject ([DevOps for Dummies](https://www.amazon.com/DevOps-Dummies-Computer-Tech/dp/1119552222), seriously, go buy it - I think it's the best single resource on tech culture and productivity out there).  This talk is particularly home-hitting in the current situation we're in globally and everyone should give it a watch.

## [5. Building scalable and secure applications with Azure Cosmos DB](https://mybuild.microsoft.com/sessions/9c8fa83f-5c1b-4f61-a6fd-5362656eec84)

*Speakers:*
 - *Deborah Chen - Program Manager II, Cosmos DB*
 - *Diego Viso - Senior Program Manager, Cosmos DB*

 Cosmos is the ultimate cloud-scale database, with essentially infinite throughput capabilities.  For any large scale IoT solution it's an absolutely critical part of data storage and analysis and should be something ever IoT developer is familiar with.  In this session you'll hear updates on Cosmos DB as well as topics on how to build and secure applications powered by it.


## [6. DevOps with Azure, GitHub, and Azure DevOps](https://mybuild.microsoft.com/sessions/3c5b0106-66e9-49d7-a1ee-80f0b3765455)

*Speakers:*

- *Martin Woodward - Director, Developer Relations, GitHub*
- *Shanku Niyogi - Head of Product, GitHub*

In my experience working in the IoT world, the robutness around process for developing and deploying applications often lags behind those in the cloud-native application space, even though it's as imporatant or more.  With every IoT firmware or edge release there's the possibility of introducing problems into millions of devices.  Being able to have a robust and well-tested DevOps process is so incredible important, and this talk covers the future of DevOps with Azure, Azure DevOps, and Github.

## [7. SQL Server on Linux and containers for developers](https://mybuild.microsoft.com/sessions/15345d1a-f4bf-419b-8a3d-f6b3dbfc384d)

*Speaker: Bob Ward - Principal Architect, Microsoft*

The world is generating data at an unimaginably fast and ever-increasing rate.  As we gather more and more data, the concept of Data Gravit becomes incredibly important.  We need to perform analytics closer and closer to where the data is generated. In the IoT world this means storaing and processing data on the [Edge](https://docs.microsoft.com/en-us/azure/iot-edge/about-iot-edge).  This session covers SQL Server runnign on Linux and Containers, a critical component in any robust edge IoT deployment.

## [8. Azure Arc and Kubernetes: a Developer Story](https://mybuild.microsoft.com/sessions/42d3ed24-6773-45c8-82bd-6dec4a583c89)

If you haven't paid attention to [Azure ARC](https://azure.microsoft.com/en-us/services/azure-arc/) + [Kubernetes](https://kubernetes.io/) yet, you should start.  Kubernetes is the worlds most popular container orchestration system, and the platform of choice for running not only highly-available cloud services, but also Edge deployments.  Azure IoT Edge is designed to run workloads right on Kubernetes (including simple and easy to install distros like [microk8s](https://MicroK8s.io/) and [K3s](https://k3s.io/)), and ARC provides a universal governance and management plane for Kubernetes.  Together this means we can securely install, configure, and managed thousands of edge deployments from machine to workload in a secure, automated, and scalable manner.  Tune in to this session to hear updates and use cases for ARC+K8S.

## [9. The Journey to One .NET - Live](https://mybuild.microsoft.com/sessions/dc9d0a63-4a90-48bc-925f-6847745eba7b)

*Speakers:*
 - *Scott Hanselman - Partner Program Manager*
 - *Scott Hunter - Director Program Management, .NET*

Choosing an appropriate language and framework for your IoT platform is critical.  Certainly in small embedded devices C and C++ will be the language of choice, but as devices get more and more powerful there's no reason to constrain ourselves to low-level languages, and taking advantage of cutting-edge language such as C#/.NET can bring incredible* developer productivity. This talk covers the future of .NET, including the journey to a single unified platform for all devices and operatingsystems (no more Core vs Framework) with .NET 5.  Being able to leverage a unified language and framework on both devices and the cloud is a wonderful experience and truly brings the best IoT developer experience you cna have.

## [10. The new Windows command-line: Windows Terminal and WSL 2](https://mybuild.microsoft.com/sessions/7cd2db9e-72ea-4f18-9d83-7ff7ea03afe0)

My experience as a developer on Windows took a 180 in 2016 with the release of the original Windows Subsystem for Linux - a way of running Linux *right inside* Windows.  Since then my use of Windows tools for development have scaled back to the point where I have *ZERO* developer tools on Windows other than [Docker](https://www.docker.com/) (which runs containers in WSL) and [Visual Studio Code](https://code.visualstudio.com/), and rely solely on WSL and containers for everything.  This talk covers the release of WSL2 and the new [Windows Terminal](https://github.com/microsoft/terminal), bringing an unbelivably wonderful experience to developers building for any platform.  In the IoT space easy access to Linux is a must, and this provides a completely seamless toolchain for every developers needs.