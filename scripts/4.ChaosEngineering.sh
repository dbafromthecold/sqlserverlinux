############################################################################
############################################################################
#
# SQL Server on Linux - Andrew Pruski
# @dbafromthecold
# dbafromthecold@gmail.com
# https://github.com/dbafromthecold/sqlserverlinux
# Chaos Engineering
#
############################################################################
############################################################################



# switch context to cluster
kubectl config use-context kubeinvaders1



# confirm connection to local cluster
kubectl get nodes



# deploy one pod 
kubectl create deployment demo --image=nginx



# view deployment
kubectl get deployment



# view pod
kubectl get pods -o wide



# delete pod
kubectl delete pod -l app=demo



# view new pod
kubectl get pods -o wide



# scale deployment
kubectl scale deployment demo --replicas=20



# view pods
kubectl get pods -o wide



# watch pods
kubectl get pods --watch



# delete deployment
kubectl delete deployment demo
