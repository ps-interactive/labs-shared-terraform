# Network Module

This network module was built for a secure AWS network deployment, including proper NACL configuration for ephemeral ports. 

**Important note:** It is assumed that the size of the public subnet is less than or equal to that of the DB and private subnets. This is to encorage minimizing the placement of resources in that subnet. The subneting is designed with **variable length subnetting** in mind so it begins by computing for the largest subnet first. This ensures no subnets are wasted during the computation. At the same time, *this stack should still work with fixed length subnetting.*
