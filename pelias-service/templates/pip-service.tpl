apiVersion: v1
kind: Service
metadata:
    name: pelias-pip-service
spec:
    selector:
        app: pelias-pip
    ports:
        - protocol: TCP
          port: 3102
    type: LoadBalancer
    loadBalancerSourceRanges:
      - 12.220.146.0/24
      - 142.65.0.0/16
      - 158.184.0.0/16
      - 173.242.16.0/24
      - 205.166.175.0/24
      - 209.183.244.0/24
      - 8.42.65.0/24
      - 10.234.192.0/18
