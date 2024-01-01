# Done by Hand
Notes on steps needed to be done by hand and am unsure how to automate right now. 


## Truesnas
1. Set up NFS and SMB shares
2. Set users for NFS to Root and Wheel
3. forced NFSv4 on NFS shares
4. Created necessary subfolders for K8s mounts (done through one of the nodes with `mkdir` command) DONE 

## Nodes
`chown` nfs mount to my user, mess with permissions DONE
changed DNS config in resolved.conf to fix issues with certain apps
