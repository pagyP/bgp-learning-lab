# Azure BGP Lab: Student Guide

## Lab Overview

You will deploy two Ubuntu VMs in separate Azure VNets, peer the VNets, and manually install and configure FRRouting (FRR) to establish BGP peering between the VMs.

---

## 1. Depoy Infrastructure and Connect to Your VMs

- Deploy BGP-Lab.tf using Terraform, there are some variables you will need to set before deployment: subscription_id and a password for your VMs
- Use Bastion (if deployed) to SSH to the VMs
- Or the serial console
  

---

## 2. Install FRRouting (FRR) on each VM

```bash
sudo apt update
#sudo apt install -y frr frr-pythontools
curl -s https://deb.frrouting.org/frr/keys.gpg | sudo tee /usr/share/keyrings/frrouting.gpg > /dev/null
FRRVER="frr-stable"
echo deb '[signed-by=/usr/share/keyrings/frrouting.gpg]' https://deb.frrouting.org/frr $(lsb_release -s -c) $FRRVER | sudo tee -a /etc/apt/sources.list.d/frr.list
sudo apt update && sudo apt install -y frr frr-pythontools
```

```bash
sudo sed -i 's/bgpd=no/bgpd=yes/' /etc/frr/daemons
sudo systemctl restart frr
sudo systemctl status frr
```

## 2. Prepare Your VM for Routing

- Enable IP forwarding (so your VM can route packets):

  ```bash
  sudo sysctl -w net.ipv4.ip_forward=1
  echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
  sudo sysctl -p
  ```

## 3. Configure BGP

- Edit the BGP config file:
  ```bash
  sudo nano /etc/frr/frr.conf
  ```
- Example for VM1 (ASN 65001, neighbor 10.2.0.4):
  ```
  router bgp 65001
   bgp router-id 10.1.0.4
   no bgp ebgp-requires-policy
   neighbor 10.2.0.4 remote-as 65002
   network 10.1.0.0/24
  ```
- Example for VM2 (ASN 65002, neighbor 10.1.0.4):
  ```
  router bgp 65002
   bgp router-id 10.2.0.4
   no bgp ebgp-requires-policy
   neighbor 10.1.0.4 remote-as 65001
   network 10.2.0.0/24
  ```
- Restart FRR after editing:
  ```bash
  sudo systemctl restart frr
  ```

---

## 3a. Alternative: Configure BGP Using vtysh Console

- Instead of editing `/etc/frr/frr.conf`, you can use the FRR CLI for live configuration:
  ```bash
  sudo vtysh
  ```
- Enter configuration mode and type commands interactively:
  ```
  configure terminal
  router bgp 65001
   bgp router-id 10.1.0.4
   no bgp ebgp-requires-policy
   neighbor 10.2.0.4 remote-as 65002
   network 10.1.0.0/24
  end
  write memory
  ```
- The example above is for VM1; adjust accordingly for VM2.
- Changes take effect immediately and are saved with `write memory`.
- Try both methods (editing the config file and using `vtysh`) and compare the experience.

Hint - Commands in frr can be completed using tab completion or shortened using abbreviations, for example configure terminal can be entered as conf t.

Question: What do you think no bgp ebgp-requires-policy does?
Questions: Which method do you prefer and why?  Any drawbacks to either method?

---

## 4. Verify BGP Peering

- Use the FRR CLI:
  ```bash
  sudo vtysh -c 'show ip bgp summary'
  sudo vtysh -c 'show ip bgp'
  ```
  Or use the interactive vtysh shell:
  ```bash
  sudo vtysh
  show ip bgp summary
  show ip bgp
  ```
- You should see your neighbor and exchanged routes, do you?  If not think about the fact that BGP peering requires TCP connectivity on port 179.  And as we are running frr on Linux we need to think about whether frr itself knows how to route to the neighbor IP address.  .

Hint - maybe a static route to your BGP neigbors IP address is needed?

---

## 5. Exercises

### Exercise 1: Establish BGP Peering

- Re-Confirm both routers show each other as BGP neighbors using `show ip bgp summary`.
- If peering is not establish, check configuration and troubleshoot.

### Exercise 2: Advertise a New Network Using a loopback address

- On VM1, create a loopback interface:
 ```bash
  sudo ip addr add 192.168.1.1/32 dev lo
  ```
- Add the loopback address to your BGP config:
  ```
  network 192.168.1.1/32
  ```

- On each VM, create a loopback interface:
 ```bash
  sudo ip addr add 192.168.2.2/32 dev lo
  ```
- Add the loopback address to your BGP config:
 ```
  network 192.168.2.2/32

  ```
- You can either add the loopback network via editing `/etc/frr/frr.conf` or using `vtysh` as shown earlier.
- Restart FRR and verify the new route is advertised and received by the neighbor.  You do not need to restart FRR if you use vtysh to add the network.
- Try using different loopback addresses on each VM.

### Exercise 3: Change ASN and Observe Effects

- Change the ASN in one router’s config so it does not match the neighbor’s expected remote-as.
- Restart FRR and observe that peering fails.
- Restore the correct ASN and confirm peering is re-established.

- How do you think you change the remote-as?  if editing frr.conf do you need to restart frr?  If using vtysh how would you do it?

Hint - The word 'no' before a command in frr means to remove that command from the configuration.

### Exercise 4: Add a Third Router (Optional)

- Deploy a third VM in a new VNet and peer the VNet with the others.
- Install FRR and configure BGP with a unique ASN.
- Establish peering with one or both existing routers.
- Observe how routes are exchanged in a multi-router topology.

### Exercise 5: Implement Route Filtering

- Remove `no bgp ebgp-requires-policy` from your BGP configuration to enable outbound policy enforcement.
- Add a prefix-list or route-map to filter which networks are advertised or accepted.
- Example: Only advertise `10.1.0.0/24` and block others.
- Observe how filtering changes the routing table on the neighbor.

Example config snippet:

```
router bgp 65001
 bgp router-id 10.1.0.4
 neighbor 10.2.0.4 remote-as 65002
 network 10.1.0.0/24
 neighbor 10.2.0.4 route-map OUTBOUND out
!
route-map OUTBOUND permit 10
 match ip address prefix-list MYNETS
!
prefix-list MYNETS seq 5 permit 10.1.0.0/24
```

### Exercise 6: Simulate a Link Failure

- Temporarily shut down the BGP process on one VM (`sudo systemctl stop frr`).
- Observe how the neighbor detects the session loss and withdraws routes.
- Restart FRR and confirm recovery.

### Exercise 7: Explore BGP Path Selection

- Advertise the same network from both routers (e.g., both advertise `10.99.99.0/24`).
- Observe which path is chosen and why (based on BGP attributes).
- Can you make one path more preferred by adjusting attributes like local preference or AS path?

### Exercise 8: View and Interpret BGP Messages

- Use FRR logs and `show ip bgp` commands to see BGP updates, withdrawals, and state changes.


### Exercise 9: Hub-and-Spoke VNet Peering

- Deploy additional VNets in Azure and peer them to the VNet containing your Ubuntu VM (the "hub").
- On each spoke VM, configure BGP to peer with the hub VM.
- Advertise unique prefixes from each spoke and verify they are learned by the hub and other spokes (if transit is enabled).
- If you use route-maps or prefix-lists, update them to permit the new prefixes from spokes and the hub.
- Discuss how this topology maps to real-world cloud and enterprise networks.

Feel free to experiment further—change router-ids, add more networks, or try advanced BGP features!

---

## Troubleshooting

- Check FRR status: `sudo systemctl status frr`
- Check logs: `sudo journalctl -u frr`
- Ensure firewall rules allow BGP (TCP/179) between VMs.

---

Happy learning!
