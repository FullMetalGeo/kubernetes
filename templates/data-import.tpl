apiVersion: extensions/v1beta1
kind: Job
metadata:
  name: pelias-import
  annotations:
    # This is what defines this resource as a hook. Without this line, the
    # job is considered part of the release.
    "helm.sh/hook": post-install
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": hook-succeeded

spec:
  template:
    metadata:
      labels:
        app: pelias-import
    spec:
      restartPolicy: Never
      containers:
        - name: wof-import
          image: pelias/pip-service:{{ .Values.pipDockerTag | default "latest" }}
          workingDir: /data
          command: ["npm", "run", "download"]
          volumeMounts:
            - name: config-volume
              mountPath: /etc/config
            - name: data-volume
              mountPath: /data
          env:
            - name: PELIAS_CONFIG
              value: "/etc/config/pelias.json"
          resources:
            limits:
              memory: 3Gi
              cpu: 4
            requests:
              memory: 1Gi
              cpu: 0.1
        - name: openaddresses-import
          image: pelias/openaddresses:{{ .Values.pipDockerTag | default "latest" }}
          workingDir: /data
          command: ["sh", "-c", "npm run download && npm start"]
          volumeMounts:
            - name: config-volume
              mountPath: /etc/config
            - name: data-volume
              mountPath: /data
          env:
            - name: PELIAS_CONFIG
              value: "/etc/config/pelias.json"
          resources:
            limits:
              memory: 3Gi
              cpu: 4
            requests:
              memory: 1Gi
              cpu: 0.1
        - name: openaddresses-import
          image: pelias/openstreetmap:{{ .Values.pipDockerTag | default "latest" }}
          workingDir: /data
          command: ["sh", "-c", "npm run download && npm start"]
          volumeMounts:
            - name: config-volume
              mountPath: /etc/config
            - name: data-volume
              mountPath: /data
          env:
            - name: PELIAS_CONFIG
              value: "/etc/config/pelias.json"
          resources:
            limits:
              memory: 3Gi
              cpu: 4
            requests:
              memory: 1Gi
              cpu: 0.1
      volumes:
        - name: config-volume
          configMap:
            name: pelias-json-configmap
            items:
              - key: pelias.json
                path: pelias.json
        - name: data-volume
          persistentVolumeClaim:
            claimName: pelias-data-volume
