locals {
  grafana = {
    values : <<-VALUES
adminUser: admin
adminPassword: linuxtips        
        
persistence:
    enabled: true
    size: 10Gi
    storageClassName: efs-grafana
service:
    type: NodePort
initChownData:
    enabled: false
    
    VALUES
  }

  loki = {
    values : <<-VALUES
loki:
    auth_enabled: false
    schemaConfig:
        configs:
        - from: "2024-04-01"
          store: tsdb
          object_store: s3
          schema: v13
          index:
            prefix: loki_index_
            period: 24h
    storage_config:
        aws:
            region: ${var.region}
            bucketnames: ${aws_s3_bucket.loki-chunks.id}
            s3forcepathstyle: false
    storage:
        type: s3
        bucketNames:
            chunks: ${aws_s3_bucket.loki-chunks.id}
            ruler: ${aws_s3_bucket.loki-ruler.id}
            admin: ${aws_s3_bucket.loki-admin.id}
    ingester:
        chunk_encoding: snappy
    querier:
        # Default is 4, if you have enough memory and CPU you can increase, reduce if OOMing
        max_concurrent: 4
    pattern_ingester:
        enabled: true
    limits_config:
        allow_structured_metadata: true
        volume_enabled: true
        retention_period: 672h
deploymentMode: SimpleScalable
backend:
    replicas: 3
    persistence:
        storageClass: gp3
read:
    replicas: 3
write:
    replicas: 3 # To ensure data durability with replication
    persistence:
        storageClass: gp3
# Enable minio for storage
minio:
    enabled: false
gateway:
    replicas: 3
    service:
        type: NodePort
    VALUES
  }

}