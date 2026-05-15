# Home Lab
I run a home lab to self-host a handful of services. My goal in doing this is to own my data and pick up some basic IT/Networking/Ops experience. My home lab lives on a single network. It spans several devices and services. This document outlines things at a high-level. Deeper in this repo you'll find configuration for the network, machines, and services.

# Network
## Devices
1. Verizon FiOS ONT - This is the WAN network ingress/egress
2. Gigabit wired router - I use a gigabit wired router. It's a mikrotik RB760iGS.
3. Switch x2 - I have two gigabit wired switches. These are both mikrotik rb260gs units.
4. Wireless AP x2 - I run two ubiquiti gigabit wireless access points on different sides of my house. There's a masonry column in the middle of my house that forms a wifi shadow if I only run one access point. I run one on each side of it for better coverage. Both emit the same SSID but on different channels.
5. Uninterruptible power supply x2 - All noted equipment resides on UPS runs, through a mixture of power cords and PoE. There's enough in the batteries for several hours of power loss.

# Devices
## Low-power server
This is the heart of my home lab setup. I have a Orange Pi 5 Plus running linux. The hardware is low power so I am content leaving it running 24/7. This is also on one of the UPS runs so it won't be interrupted by intermittent power losses.

I opted to install a [UEFI](https://github.com/edk2-porting/edk2-rk3588) on the system in order to be able to run a generic ARM mainline linux. Kernel 6.15 is when most of the necessary drivers for the orange pi 5 plus became available. You can read details about that [here](https://gitlab.collabora.com/hardware-enablement/rockchip-3588/notes-for-rockchip-3588/-/blob/main/mainline-status.md). That limits your OS options unless you're willing to build your own kernel, which I am not. I decided to run fedora and plan to eventually use debian when kernel 6.15 is in it. A useful reference for initially configuring the hardware can be read [here](https://interfacinglinux.com/2025/08/25/edk2-uefi-for-the-rock-5-itx/).

I run a number of services on this machine:
1. [Portainer](https://www.portainer.io/) is a web ui and management system for docker-based containerized workloads. I use it to orchestrate most of the following services. I'm happy with it for my workloads. You can point it at compose files in web-hosted git repositories or directly provide compose files via its web ui.
2. [Pi Hole](https://pi-hole.net/) is a dns server that swallows requests to known ad networks, making it serve as a network-wide adblocker. Internally I use static IPs and dns. This makes for easy setup of custom dns records.
3. [Photoprism](https://www.photoprism.app/) is a server that catalogs images. There a few services under its umbrella, including a WebDAV server where you can sync files to/from your devices, workers that index and run machine learning algorithms against your photos, and a webapp to actually view the images.
    - I use [Photosync](https://www.photosync-app.com/home) on both android and ios to push my photos from mobile devices. This works like a cheapo version of cloud consumer photo syncing.
    - I wrote my own public photo-sharing capabilities into [my personal website](https://github.com/gabrielmiller/gabrielmiller.org) a few years ago. Photoprism has since added their own capabilities, but I still kind of prefer the way I went about it.
4. [Home Assistant](https://www.home-assistant.io/) is a service that records and serves metrics on devices. I use it to record power usage of my devices. I use several plugs that utilize [esphome](https://github.com/esphome/esphome) firmware so that I have greater control of the data being collected by these devices.
5. A reverse proxy to serve a private website. I'm running caddy toso that it auto-renews TLS certificates.
6. A web-application to remotely start and stop the machine and service for the website noted in item 5.

## GPU server
In June 2025 a text to speech(TTS) AI model named [chatterbox](https://github.com/resemble-ai/chatterbox) was released. I stumbled upon a project that packaged it in a docker compose file alongside a webserver. After a little tinkering I had my own server running and I quickly found myself getting a kick out of generating ai voice material. Soon after I built a new machine with dedicated hardware to run it.

1. [Chatterbox-TTS](https://github.com/devnen/Chatterbox-TTS-Server) is the original repo for this project. I made a couple little alterations to it for convenience, in the various branches in [my fork here](https://github.com/gabrielmiller/Chatterbox-TTS-Server).

# Future plans
- Add a more robust way to manage when the GPU server should be turned on and off. Right now I have to remember to turn it off when I'm done using it.
- I don't have a great backup solution for my photos. I currently make a couple copies every december 31 on various hard drives and I also burn a blue ray disc with that year's worth of photos. I intend to set up a cron to regularly sync these files to a service like S3 to have more peace of mind.
- It would also be nice to hook up more automation between photoprism and my personal photo sharing site so as to not have to manually do a number of steps to deploy new content.
- Further automate container orchestration with portainer. There's [a terraform provider for it](https://registry.terraform.io/providers/portainer/portainer/latest/docs), which I could use to reduce manual configuration steps whenever I next make changes to my network topology or devices.