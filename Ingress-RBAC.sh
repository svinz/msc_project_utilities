#To set up ingress-nginx first time, run this first to get the cluster-admin
kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user $(gcloud config get-value account)