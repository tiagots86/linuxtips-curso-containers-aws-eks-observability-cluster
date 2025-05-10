resource "aws_efs_file_system" "grafana" {
  creation_token   = format("%s-efs-grafana", var.project_name)
  performance_mode = "generalPurpose"

  tags = {
    Name = format("%s-efs-grafana", var.project_name)
  }
}

resource "aws_efs_mount_target" "grafana" {
  count = length(data.aws_ssm_parameter.subnets)


  file_system_id = aws_efs_file_system.grafana.id
  subnet_id      = data.aws_ssm_parameter.subnets[count.index].value
  security_groups = [
    aws_security_group.efs.id
  ]
}

resource "kubectl_manifest" "grafana_efs_storage_class" {
  yaml_body = <<YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: efs-grafana
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: ${aws_efs_file_system.grafana.id}
  directoryPerms: "777"
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
YAML

  depends_on = [
    aws_eks_cluster.main,
    helm_release.karpenter
  ]
}