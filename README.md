# Home Lab
I run a home lab to self-host a handful of services. My goal in doing this is to own my data and pick up some basic IT/Networking/Ops experience. My home lab all lives in one network. It spans several devices and services. This document outlines things at a high-level. Deeper in this repo you'll find configuration for different services.

# Network
## Devices
1. Verizon FiOS ONT - This is the WAN network ingress/egress
2. Gigabit wired router - I use a mikrotik router.
3. Switch - This is also a mikrotik.
4. Wireless AP x2 - I run two ubiquiti gigabit wireless access points on different sides of my house. There's a masonry column in the middle of my house that forms a wifi shadow if I only run one access point. I run one on each side of it for better coverage. Both emit the same SSID but on different channels.
5. Uninterruptible power supply - Items 1-4 all run on this. They run over a mixture of power cords and PoE. There's enough in the battery for several hours of power loss.
6. Wireless Router - I use a mikrotik router as a wireless bridge to some additional devices where it's a pain to run a wire. This runs in pseudo-bridge mode and I'm still experimenting with it.

# Devices
## Low-power server
This is the heart of my home lab setup. I have a Orange Pi 5 Plus running [Armbian](https://www.armbian.com/). It is low power so I am content leaving it running 24/7. This is also on the UPS run so it won't be interrupted by intermittent power losses.

I run a number of services on this machine:
1. [Portainer](https://www.portainer.io/) is a web ui and management system for docker-based containerized workloads. I use it to orchestrate most of the following services.
2. [Pi Hole](https://pi-hole.net/) is a dns server that swallows requests to known ad networks, making it serve as a network-wide adblocker. Internally I use static IPs and dns. This makes for easy setup of custom dns records.
3. [Photoprism](https://www.photoprism.app/) is a server that catalogs images. There a few services under its umbrella, including a WebDAV server where you can sync files to/from your devices, workers that index and run machine learning algorithms against your photos, and a webapp to actually view the images.
  - I use [Photosync](https://www.photosync-app.com/home) on both android and ios to push my photos from mobile devices. This works like a cheapo version of cloud consumer photo syncing.
  - I wrote my own public photo-sharing capabilities into [my personal website](https://github.com/gabrielmiller/gabrielmiller.org) a few years ago. Photoprism has since added their own capabilities, but I still kind of prefer the way I went about it.
4. [Home Assistant](https://www.home-assistant.io/) is a service that records and serves metrics on devices. I use it to record power usage of my devices. I use several plugs that utilize [esphome](https://github.com/esphome/esphome) firmware so that I have greater control of the data being collected by these devices.

## High-power AI server
In June 2025 a text to speech(TTS) AI model named [chatterbox](https://github.com/resemble-ai/chatterbox) was released. I stumbled upon a project that packaged it in a docker compose file alongside a webserver. After a little tinkering I had my own server running and I quickly found myself getting a kick out of generating ai voice material. Soon after I built a new machine with dedicated hardware to run it.

1. [Chatterbox-TTS](https://github.com/devnen/Chatterbox-TTS-Server) is the original repo for this project. I made my own alterations to it, which I intend to codify as a fork. I'll update this with a link to that when I get there.

# Future plans
- Currently I run the chatterbox tts webserver on the public internet from my house at a cheapo domain using a cert from letsencrypt. It's just secured with basic auth. I only leave it running when in use or when I'm at friends and plan to use it there. I have a few plans for this:
    - Put it behind a reverse proxy so that the proxy is responsible for tls termination and authentication
    - Create a separate service, also behind a reverse proxy, that allows for remotely starting the machine and service.
    - Similarly, create a service that automatically powers off the high-power servrt after a period of inactivity so that it isn't needlessly consuming electricity. It would be convenient to have a cron system where you book a certain amount of time to keep it awake and then have it otherwise keep it turned off. _As far as I've been able to tell this seems to be complicated by my current network topology, and wake on lan doesn't consistently work because this server runs on a flaky wireless bridge._
- I don't have a great backup solution for my photos. I currently make a couple copies every december 31 on various hard drives and I also burn a blue ray disc with that year's worth of photos. I intend to set up a cron to regularly sync these files to a service like S3 to have more peace of mind.
- It would also be nice to hook up more automation between photoprism and my personal photo sharing site so as to not have to manually do a number of steps to deploy new content.