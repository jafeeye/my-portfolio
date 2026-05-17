---
title: Nutanix
date: 2026-02-18
toc: true
---
## 前言

可針對不同計畫進升級相關元件
![](Pasted%20image%2020260510210903.png)


## 實作


```
## Session1 
When configuring Application Discovery, the system requires connecting to the cloud exchanging API Key/ID with Prism Central.
What is the purpose of this requirement?
It establishes the connection to a Nutanix provided SaaS-like service.
It allows Prism Central to send Nutanix Pulse gathered data to Nutanix Central.
It is required to verify Nutanix Cloud Manager licenses availability through the portal.
It connects to Nutanix Security Central Portal.
Ans A

In which scenario would an administrator want to use IP Address Management (IPAM) for workloads when configuring a Virtual Network for Guest VM Interfaces?
To assign IP addresses statically to VMs.
To assign IP addresses automatically to VMs by using an external DHCP server.
To avoid assigning IP address to VMs.
To assign IP addresses automatically to VMs by using cluster-controlled DHCP.
Ans D

An administrator responsible for a two-node environment has been tasked with creating a new storage container. The new container will have linked clones.
What space saving technology can be used for this container?
Advertised Capacity
Erasure Coding
Deduplication
Compression
Ans D

In Prism Element, which color should the disk status indicator be when removing a disk in Prism Element prior to physically removing the disk?
Green
Grey
Red
Amber
Ans C

What is the protocol used by LCM to perform BMC and BIOS updates?
Blowfish
Glassfish
Catfish
Redfish
Ans D

An administrator has been tasked with creating the first Replication Factor 1 (RF1) storage container in a cluster.
The storage container must meet these requirements:
- The container must have an advertised capacity of 100 GiB.
- The container must have deduplication disabled.
- The container must have erasure coding disabled.
- The container will be named TestData.
What step should the administrator complete first?
In Prism Central, select the Enable Replication Factor 1 checkbox.
In Prism Element, select the Enable Replication Factor 1 checkbox.
In Prism Element, create an RF1 storage container.
In Prism Central, create a storage container.
Ans B

An administrator placed a node in maintenance mode before removing it from the current cluster. The administrator noticed most VMs migrated to other hosts, while others powered off.Which configuration may explain why some VMs were powered off?
A node crashed during operations.
VMs are configured with vGPU.
VMs are associated with an RF1 storage container.
Cluster has insufficient resources to migrate all VMs.
Ans C

Which VM type is able to automatically migrate when the host on which it resides is placed into maintenance mode?
Highly Available VM
CPU Passthrough VM
PCI Passthrough VM
RF1 VM
Ans A

An administrator wants to put a host into maintenance mode for firmware upgrades. There are several VMs running on this host that have pass-through enabled and may block the attempt to enter maintenance mode.
Which action can the administrator perform to complete the upgrades?
Clear the block migration indication for the VMs.
Create an affinity policy for the VMs and set the target host.
Shut down the VMs.
Manually migrate the VMs.
Ans C

In Prism Central, which Application Switcher function is LCM located in?
Admin Center
Self Service
Security Central
Infrastructure
Ans A

An administrator is using Application Discovery to monitor applications.
After having deployed a set of new workloads, including Web Servers, MS-SQL Servers and internally developed applications, the administrator is now observing the Discovered App table.
What are the two expected results? (Choose two.)
Internally developed applications are flagged as Unidentified.
Web and MS-SQL Severs become Published Apps.
Internally developed applications are ignored.
Web and MS-SQL Severs status is Identified and New.
Ans AD

## Session2
Which two conditions, when met, block Category deletion? (Choose two.)
Category is a system category.
Category is assigned to an entity.
Category has more than one key-value pair.
Category has only one key-value pair.
Ans AB

Which application must be selected from the Prism Central application switcher before configuring a VM template?
Apps and Marketplace
Infrastructure
Admin Center
Intelligent Operations
Ans B

Which bus types can be selected from the pull-down list when attaching a disk to a VM in a Nutanix environment?
IDE, SCSI, SATA
SCSI, IDE, NVMe
SCSI, SATA, NVMe
IDE, USB, SATA
Ans A

What is a Catalog Item?
A blueprint to deploy new applications.
A VM snapshot or image object for self-service.
A group of user roles for managing resource utilization.
A list of all the user-defined policies.
Ans B

An administrator is creating a VM for a new application workload within Prism Central. Which supported VM boot configurations should the administrator be aware of?
Legacy BIOS and Network Boot
UEFI and Legacy BIOS
UEFI and Network Boot
Legacy BIOS and Safe Mode
Ans B

When exporting a virtual machine as an OVA file, which two disk formats are supported? (Choose two.)
VDI
VMDK
VHD
QCOW2
Ans BD

An administrator needs to migrate several VMs from a legacy 3-tier VMware Virtual Infrastructure to a Nutanix AHV-based cluster.
Which action should the administrator take to satisfy this requirement in the most efficient way?
Present the AHV storage container to the VMware cluster.
Configure the AHV cluster to perform cross-hypervisor DR.
Create a migration plan with Nutanix Move.
Use Prism Element Protection Domains to import VMs.
Ans C

An administrator needs to ensure a VM starts on a specific set of hosts. How should the administrator satisfy this requirement?
Configure VM placement with a script.
Configure VM with Anti-Affinity Policy.
Configure VM options as Agent VM.
Configure VM with an Affinity Policy.
Ans D

Which two statements about Categories are true? (Choose two.)
Categories built into Prism Central can't be updated.
Categories are the building blocks of policies.
Categories are only used to group VM entities.
Categories consist of two parts: a key and a value.
Ans BD

Which attributes are copied from the source VMs when creating VM templates?
Host affinity attributes
HA priority attributes
Volume Group settings
Number of GPUs
Ans D

What status is displayed for VMs associated with an affinity policy when compliance status is not yet determined?
Unknown
Applied
In Progress
Pending
Ans D

##Session 3
An administrator is using Nutanix Disaster Recovery (DR) to protect business critical applications running on AHV. The current environment is as follows:
- Includes some vTPM-enabled VMs.
- Multiple remote sites are deployed with vSphere ESXi and AHV.
The company would like to evaluate any DR and Backup options available to enhance protection.
Which configuration or option provides support for requested setup?

Configure recovery using Nutanix DRaaS.
Protect all VMs using a third-party backup.
Perform cross-hypervisor disaster recovery to distribute workloads across all sites.
Configure recovery using on-prem AHV clusters and Nutanix Cloud Cluster (NC2) AZs.
Ans D

After a thorough design and deployment, an administrator has successfully configured a Protection Policy and its associated Recovery Plan. Recovery points are visible at both locations, Nutanix Guest Tools is installed on all the VMs, RPO is being met & there are no events logged or any indication of an issue.
The administrator wants to validate the recovery plan and schedule a time to do so. When the administrator logs into the production Prism Central, selects Recovery Plan, and then selects Validate, the number of VMs shows zero.
What must be done to successfully execute a Recovery Plan Validation?

Run Windows updates on production VMs.
Update Nutanix Guest Tools because they are out of date.
Engage a network engineer as this is indicative of a network failure or increased latency.
Log into Prism Central at the DR location and run Recovery Plan Validation from there.
Ans D

A company has deployed two ESXi-based Nutanix clusters in Site A and Site B and is now looking for a Disaster Recovery solution.
To protect some critical applications, the lowest possible RPO is required. An administrator would like to accomplish this with Metro Availability configuration, however, the company does not have a third site to deploy a Witness VM.
How should an administrator proceed?

Configure Metro Availability in Automatic or Manual mode.
Configure NearSync replication as it is the only feasible option with low RPO.
Deploy a Witness VM on Site A or Site B and enable Fault Tolerance.
Deploy a Witness VM on Site A or Site B and add it to a protection domain.
Ans A

An administrator has been tasked with developing the recovery of 100 VMs all being replicated by a single Prism Central Asynchronous Protection Policy.
Of these 100 VMs, 20 need to be brought online first, 75 brought online 5 minutes after the first group and the remaining 5 VMs brought online 10 minutes after the second group. All VMs will have their IP addresses changed during recovery and will need to have local DNS settings updated.
What is the most efficient solution to achieve this?

Create a single Recovery Plan with Stretch Networks enabled.
Create a separate Recovery Plan for each VM group and execute each at a given time via CLI.
Configure a Protection Domain for each VM group and schedule via Prism Element.
Use a single Recovery Plan with stages and scripting enabled.
Ans D

A company is currently designing a Disaster Recovery solution using Prism Central. The majority of workloads will utilize crash consistent snapshots while a subset will require an additional application consistent snapshot once a day at 1AM local time.
The company needs to achieve a 1-hour RPO.
How should the company accomplish this task?

Create a Protection Policy for the crash-consistent schedule and utilize API commands to take a daily application-consistent snapshot of the necessary VMs.
Create two Protection Policies, one containing an hourly crash-consistent schedule and the second containing a daily application-consistent schedule.
Create a Protection Policy for the crash-consistent schedules and also a Protection Domain for the application-consistent schedules.
Create a Protection Policy with a Recovery Point hourly crash-consistent schedule and also a Primary Location Recovery Point daily application-consistent schedule.
Ans D

A company decided to implement a Nutanix Metro Availability solution and tasked an HCI team to configure an ESXi-based Metro protection domain.
An administrator is looking for optimal configurations that will provide automatic failover without intervention and evaluate the Witness option.
In which two ways will Witness failure handling work in the Metro Availability environment in case of network interruption? (Choose two.)

If the standby protection domain obtains the lock, the system automatically promotes it to active.
The default automatic replication break timeout is 120 seconds.
A cluster attempts to obtain the witness lock against standby protection domains after 120 seconds.
A cluster attempts to obtain the witness lock against primary protection domains after 120 seconds.
Ans AC

A company requires the lowest possible Recovery Point Objective (RPO) and Recovery Time Objective (RTO). An administrator has been tasked with evaluating Nutanix Metro Availability. The initial configuration was completed successfully, and now failover tests must be conducted to ensure compliance with the company's business continuity requirements.
During the first failover test, the network connectivity was interrupted between sites. No failover happened and the workloads on both sites were affected.
An administrator rechecked the configuration but is not able to find the root cause for this behavior.
What configuration could lead to workload interruption?

Metro Availability lost connection to Witness VM.
Metro Availability is configured with Manual failure handling.
Metro Availability is configured with Automatic Resume option.
Metro Availability is configured with Witness option.
Ans B

An administrator needs to ensure that a performant and resilient architecture is in place for critical workloads. As such, Volume Groups are utilized for certain application tiers.
In staying aligned with business requirements, the administrator will also be creating a Protection Policy for these Volume Groups with the limitation that 5ms network latency cannot be assured.
Which Protection Policy configuration action is optimal and achievable for this scenario?

Utilize Synchronous replication for highest RPO.
Utilize a Witness VM for optimal RPO.
Assure NGT is installed and select the checkbox: “Take App-Consistent Recovery Points.”
Create a 1-hour asynchronous schedule utilizing crash-consistency.
Ans D

A company has deployed two AHV clusters and plans to setup a DR replication. Prism Central was deployed according to best practices on the third site. AHV clusters:
- Prism Element A
- Prism Element B
An administrator is configuring AHV Metro with the Witness service running on Prism Central. The administrator is concerned about Prism Central resiliency and possible impact in the case of Witness failure.
What are two recovery steps from Witness failure? (Choose two.)

When the Witness becomes operational again, the Witness workflow resumes automatically.
Prism Element A gets the lock first and the system pauses the synchronous replication to Prism Element B.
When Witness becomes operational again, you must manually resume the synchronous replication to Prism Element B.
Both Prism Element A and Prism Element B trigger an alert, but Metro availability remains unaffected.
Ans AD

An administrator is tasked with setting up and configuring Metro Availability in the company production environment.
An administrator has already configured protection policies and recovery plans that synchronize to the paired Availability Zones (AZs). However, failover and failback operations cannot be performed.
An administrator determined that Nutanix DR was not enabled.
Which two prerequisites must be met for Nutanix DR to be enabled? (Choose two.)

To perform DR to Nutanix clusters at the different on-prem AZs, Disaster Recovery on recovery AZs must be disabled.
Prism Element is hosting the Prism Central instance that it is registered to.
To perform DR to Nutanix clusters at the same on-prem AZ, Disaster Recovery on both the primary and recovery clusters must be enabled.
Data Services IP is set on Prism Element hosting Prism Central and is reachable on port 3260.
Ans BD

An administrator has been tasked with configuration and testing of Nutanix DR and has successfully setup and configured asynchronous Protection Policies and associated Recovery Plans.
The administrator has validated Recovery Plan execution by running a Validate against the Recovery Plan. It is now time to execute a planned Failover and the administrator has scheduled this and obtained approval.
Upon instantiating the failover, the administrator sees the option for Live Migrate Entities and determines it is the optimal methodology, as it will eliminate downtime. The administrator selects the checkbox and clicks on Failover. An error occurred and execution failed.

Why has this failure happened?
Live Migration is only supported with Linux VMs.
Live Migration requires layer 2 stretched subnets.
There is an active Replication occurring.
There is likely an issue with the Availability Zone.
Ans B

An administrator is looking for a cost-optimized solution for disaster recovery of their AHV cluster and has decided to use an ESXi-based Nutanix cluster as the replication target.
Which two actions are available to facilitate DR setup in this configuration? (Choose two.)

Install and configure NGT on all the VMs.
Protect VMs using Synchronous replication.
Configure Metro Availability.
Use CHDR for VM recovery.
Ans AD

After a successful cluster deployment, an administrator is asking for a data replication solution. A consultant recommends configuring a remote site for disaster recovery or backup operations. However, there is no physical cluster available as a destination.
Which action can the consultant take to provide this functionality?
Configure Azure as a remote site for disaster recovery operations.
Configure GCP as a remote site for backup and restore operations.
Use the Cloud Connect feature for backup and restore operations.
Use the Cloud Connect feature for disaster recovery operations.
Ans C

A company is looking for a Prism Central-based DR solution that will achieve a 5-minute RPO utilizing crash consistent snapshots. The company architecture is on-premises Availability Zone (AZ) to on-premises AZ and both clusters are running AHV.
What is the best way to meet this RPO?
Create a Protection Policy with an Asynchronous Replication Schedule.
Create a Protection Domain with a 5-minute snapshot frequency.
Create a Protection Policy with a Synchronous Replication Schedule.
Create a Protection Policy with a NearSync Replication Schedule.
Ans D

A company is looking for a Disaster Recovery solution to protect business-critical applications. Some of the apps comprising multiple VMs should remain on specific Nutanix hosts due to licensing constraints.
A Nutanix administrator responsible for DR configuration is now tasked to protect these VMs and setup replication to remote site.
Which two actions must an administrator take to accomplish this task without licensing violations? (Choose two.)

Configure Prism Central-based replication.
Configure Prism Element-based replication.
Define Affinity Policy using Prism Element.
Define Affinity Policy using Prism Central.
Ans AD

## Session4
An administrator was attempting to see what upgrades were available within Life Cycle Manager (LCM) and started an upgrade procedure by mistake.
What can the administrator do to cancel the upgrade procedure?
Use the Cancel Intent feature.
Use the Stop Update feature.
Restart the genesis service across the cluster.
Stop the cluster.
Ans B

An administrator has configured recovery plans and was about to conduct a planned failover as a part of deployment tests. Before conducting the test, NCC was started manually and one of the checks returned as FAIL.
Upon investigating, an administrator figured out that some recovery plans are conflicting.
Which two resolution steps could an administrator can take to fix the issue? (Choose two.)
Ensure that different IPs are not specified for the same VM in different RPs.
Ensure custom IP mapping is used if Nutanix Guest Tools are not installed.
Ensure that the same IP from a subnet is not specified for multiple VMs.
Ensure offset-based mapping is used if Nutanix Guest Tools are installed.
Ans AC

An administrator got a request to increase the number of vNIC queues for a VM with the following configuration:
- vCPU: 2  
- vRAM: 32  
- vDisks: 100 GB, 250GB  
- Volume Group: three 250 GB volumes
How many queues should be configured to maximize parallelism?
Twice the vRAM amount
Twice the number of vDisks
Equal to the number of vCPUs
Equal the number of Volume Groups
Ans C

An administrator received a NCC alert that there are default AOS passwords in use for multiple clusters.
An updated password needs to be set for the nutanix user across all clusters.
Where would bulk password changes be made?
Use ncli to change password across all clusters.
Use Local User Management in Prism Central Settings.
Use Local Account Passwords widget in Prism Central.
Use Security Configuration Management Automation (SCMA).
Ans C

Per the Security team, an administrator needs to monitor AHV hosts and CVMs weekly for unexpected changes and generate a log if any changes have been made.
Which feature can the administrator enable on the hosts and CVMs to accomplish this goal?
Advanced Intrusion Detection Environment (AIDE)
Peering Prism Central API Key (PPC-AK)
Role-based Access Control (RBAC)
Flow Network Security - Next Generation (FNS-NG)
Ans A

A company is leveraging Nutanix AHV Metro Availability to provide business continuity between two sites. The environment includes a third site which hosts Prism Central.
During a network failure between two sites configured with Nutanix AHV Metro, the organization experienced unexpected workload downtime.
Which configuration should be modified to avoid the above-mentioned behavior?
Configure Prism Central to act as a witness service.
Force entity synchronization between paired Availability Zones.
Change the Protection Policy failover handling to automatic.
Change the Recovery Plan failure execution mode to automatic.
Ans C

An administrator successfully configured Metro Availability and registered with the Witness.  During disaster recovery tests, one site was powered down but expected failover has not happened and Metro availability failure was not handled automatically.
An alert was raised in Prism Element:
Alert ID: 130123
Failed to update witness server with metro availability status for the protection domain '' to the remote site ''.
What are two possible root causes for this issue? (Choose two.)

Only the standby cluster involved in Metro Availability is able to contact the Witness VM.
The Witness VM admin password has been changed, and clusters in Metro Availability cannot authenticate the Witness server.
A proxy was configured on one or both clusters that prevents authentication to the Witness server.
Only the active cluster involved in Metro Availability is able to contact the Witness VM.
Ans BC

An administrator is concerned about possible MS SQL Server performance issues and recently set up Application Monitoring within Prism Central.
Which metrics are available to review in the Application Instance Summary Tab?
Number of Active Connections, Read Latency, Write Latency
CPU Usage, Target Server Memory, Buffer Cache Hit Ratio
VM Alert Count, Database Name, Buffer Page Life Expectancy
Total Server Memory, Write Latency, Available Physical Memory
Ans B

An administrator configured a Protection Policy for synchronous-replication, choosing RPO-0 as a category value for workloads.
After having assigned RPO-0 category value to a test VM to verify the workflow, replication is not starting.
Which configuration needs must be met?
AHV clusters must be in the same availability zone.
Both clusters must have identical CPU feature sets.
Stretch L2 networks across sites.
Storage container names must match between sites.
Ans D

An administrator is trying to conduct On-Demand Cross-Cluster Live Migration (CCLM) but is facing some issues and failures.
What two requirements for CCLM does an administrator need to meet? (Choose two.)
The source guest VMs are connected to a managed VLAN (IPAM-enabled).
The source and the destination storage containers must have the same name.
The source and the destination cluster must run on the same AHV version.
Maximum latency between the clusters must be a round-trip time of 15ms.
Ans BC

Refer to the exhibit.
An administrator has configured LCM, as shown in the exhibit.  When running an inventory, the administrator keeps seeing an error indicating a failure in downloading LCM Modules.
What is the most likely cause?
The dark site webserver is unreachable.
Port 80 is blocked by the firewall.
The dark site webserver cannot provide a secure connection.
Port 443 is blocked by the firewall.
Ans D

An organization is concerned with a ransomware attack that exploits CVM access via SSH passwords.
Which security feature can the administrator apply to best mitigate against this type of attack?
Set SSH Security Level to default.  
Set SSH Security Level to limited.  
Enable Cluster Lockdown.
Enable Advanced Intrusion Detection Environment.
Ans C

## Session 5
Which Predefined System Report would summarize Prism Central's default infrastructure?
Entity type "VM", report "VM Overview"
Entity type "Cluster", report "Cluster Configuration Summary"
Entity type "Dashboard", report "Main Dashboard"
Entity type "Cluster", report "Cluster Usage Summary"
Ans C

Which predefined Intelligent Operations report summarizes information about only VMs that are overprovisioned with vCPUs?
Overprovisioned VM List
Potential CPU Reclaim
Bully VM List
CPU Runway
Ans B

An administrator is concerned about the impact of host CPU usage on an AHV-hosted VM.
Which metric should the administrator chart to determine if host CPU contention is occurring?
Hypervisor I/O Latency
Hypervisor CPU Usage (%)
Hypervisor CPU Ready Time (%)
Hypervisor I/O Bandwidth
Ans C

An administrator is trying to run a Cluster Capacity and Reclaim Summary report to see the affects of cleaning up over-provisioned VMs from the VM Efficiencies widget.
Management requires a PDF copy of the report, and the administrator would like to be able to sort the data to compare to the report generated before resolving the over-provisioning.
The administrator has 2500 VMs and 9 columns of relevant data to be presented within data tables of the report.
Why would the CSV report fail to be generated?
Selected both PDF and CSV output for report.
Greater than 1500 entities in report.
Scheduled at same time as another report.
Greater than 9 columns in report.
Ans A

An administrator must collect information relevant to an event on a Nutanix cluster and share that data with other administrators.
What is the first step that the administrator should take to accomplish this task?
Review the Alerts dashboard in Prism Element.
Check the Capacity Runway for the impacted cluster.
Create a new Analysis Session in Prism Central.
Create Entity Charts for the impacted systems.
Ans C

An administrator would like to ensure there is sufficient RAM to run all VMs in the event of a node failure.
Where would the administrator reserve RAM for a degraded node within Prism Element?
Rebuild Capacity Reservation
Manage VM High Availability
Degraded Node Settings
Redundancy State
Ans B

What is the file size limit when uploading a custom logo for a report in Prism Central's Operations Dashboard?
1 MB
10 MB
100 MB
512 KB
Ans A

An administrator is concerned about the impact of host network utilization on an AHV-hosted VM.
Which two metrics should the administrator chart to determine any impact of host network contention? (Choose two.)
Hypervisor I/O Bandwidth - Write
Hypervisor I/O Bandwidth - Read
Network Tx Bytes
Network Rx Bytes
Ans CD

Capacity Runway requires time to calculate baseline runway estimates.
How much data is required to calculate baseline and monthly runway estimates?
Baseline 31 days; Monthly seasonality 90 days
Baseline 21 days; Monthly seasonality 91 days
Baseline 21 days; Monthly seasonality 90 days
Baseline 31 days; Monthly seasonality 91 days
Ans C

An administrator has recently enabled the Rebuild Capacity Reservation feature on an RF2 cluster.
What effect does this have on Capacity Planning?
To only modify Storage runway, Reserve Capacity for Failure must be set to Auto Detect.
Capacity Planning does not support Rebuild Capacity Reservation of the cluster.
Capacity Planning supports Rebuild Capacity Reservation of the cluster.
Compute, Storage and Memory runways will update to account for a single node failure.
Ans C

A service provider who offers Infrastructure as a Service services based on the Nutanix Cloud Platform needs to onboard a new customer who subscribed to a dedicated cloud plan.
The customer is planning to move current workloads in three waves in three different quarters and has identified a workload profile type for sizing purposes.
The service provider needs to estimate required resources to accommodate customer requirements.
How should the service provider best plan to meet the customer's requirements?
Create a scenario based on a new cluster, add workload using the specified VMs profile, select 9 months target, and then add three resources.
Create a scenario based on an existing cluster, add three workloads using the specified VMs profile with quarterly deferred power on, and then press Recommend.
Create a scenario based on a new cluster, add three workloads using the specified VM profile with quarterly deferred power on, and then press Recommend.
Create a scenario based on an existing cluster, add workload using the specified VMs profile, select 9 months target, and then add three resources.
Ans C

An administrator would like to create a Metric Chart to analyze performance of different entities within the Nutanix cluster.
Which metric is a valid option to monitor when creating a new Metric Chart?
Volume Group
Storage Pool
Disk IOPS
Disk
Ans C

Which built-in role in Prism Central provides users with only view privileges for reports?
Operator
Consumer
Objects Viewer
Prism Viewer
Ans D


```