apiVersion: v1
kind: Service
metadata:
    name: pelias-api-service
    annotations:
      {{ if .Values.privateAPILoadBalancer }}service.beta.kubernetes.io/aws-load-balancer-internal: 0.0.0.0/0{{ end }}
      {{ if .Values.externalAPIService }}service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"{{ end }}
      {{ if .Values.privateAPILoadBalancer }}service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: '3600'{{ end }}
      {{ if .Values.loadBalancerCertArn }}service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "{{ .Values.loadBalancerCertArn }}"{{ end }}
      {{ if .Values.loadBalancerCertArn }}service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "https"{{ end }}
spec:
    selector:
        app: pelias-api
    ports:
        - protocol: TCP
          port: {{ .Values.loadBalancerPort }}
    type:{{ if .Values.externalAPIService }} LoadBalancer {{ else }} ClusterIP {{ end }}
