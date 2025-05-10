locals {
    grafana = {
        values: <<-VALUES
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
}