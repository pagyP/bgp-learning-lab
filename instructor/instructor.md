---
marp: true
---

# Introduction to BGP

---

## What is BGP?

- Border Gateway Protocol (BGP) is the protocol that makes the Internet work.
- Exchanges routing information between autonomous systems (ASNs).
- Used by ISPs, data centers, and large enterprises.

---

## Why Learn BGP?

- BGP is the backbone of global Internet routing.
- Essential for troubleshooting, design, and security.
- Valuable for cloud, networking, and security careers.

---

## Key Concepts

- **Autonomous System (ASN)**
- **BGP Peering**
- **Prefix**
- **Path Selection**

---

## BGP in the Cloud

- Used for hybrid connectivity, multi-cloud, advanced routing.
- Azure supports BGP with VPN gateways and ExpressRoute.
- Simulate BGP in Azure using Linux VMs and FRRouting.

---

## Lab Overview

- Deploy Ubuntu VMs in Azure, each in its own VNet.
- Peer VNets to simulate separate networks.
- Install and configure FRRouting (FRR) for BGP peering.
- Advertise networks, exchange routes, experiment with BGP features.

---

## What You'll Learn

- Configure BGP on Linux routers
- How BGP peering works
- Advertise and filter routes
- BGP path selection
- Build scalable topologies

---

## Session Flow

1. Kickoff & Concepts
2. Lab Deployment
3. Hands-on BGP Configuration
4. Exercises & Exploration
5. Wrap-up & Q&A

---

## Interactive: Quick Quiz

- Why does BGP use TCP?
- What happens if two routers have different ASNs?
- How does BGP prevent routing loops?
- How can you control which routes are advertised or accepted?

---

## Interactive: Hands-On Challenge

- Try to break BGP peering by changing ASN or router-id.
- Advertise a new network and see if it appears on the neighbor.
- Implement a route-map to filter routes.

---

## Let's Get Started!

- Open Azure portal and SSH client.
- Follow the student guide.
- Ask questions and experiment—BGP is best learned hands-on!

---

_Prepared for Azure BGP Lab – Instructor Edition_
