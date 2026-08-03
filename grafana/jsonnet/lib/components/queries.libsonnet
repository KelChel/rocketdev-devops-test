{
  networkReceive(instanceVariable='$instance')::
    'sum by (instance) (rate(node_network_receive_bytes_total{instance=~"%s",device!~"lo|veth.*|docker.*|br-.*"}[$__rate_interval])) * 8'
    % instanceVariable,

  networkTransmit(instanceVariable='$instance')::
    'sum by (instance) (rate(node_network_transmit_bytes_total{instance=~"%s",device!~"lo|veth.*|docker.*|br-.*"}[$__rate_interval])) * 8'
    % instanceVariable,

  rootFilesystemFree(instanceVariable='$instance')::
    '100 * node_filesystem_avail_bytes{instance=~"%s",mountpoint="/",fstype!~"tmpfs|overlay|squashfs"} / node_filesystem_size_bytes{instance=~"%s",mountpoint="/",fstype!~"tmpfs|overlay|squashfs"}'
    % [instanceVariable, instanceVariable],

  allocatedFileDescriptors(instanceVariable='$instance')::
    'node_filefd_allocated{instance=~"%s"}' % instanceVariable,

  maximumFileDescriptors(instanceVariable='$instance')::
    'node_filefd_maximum{instance=~"%s"}' % instanceVariable,

  cpuUtilization(instanceVariable='$instance')::
    '100 - (avg by (instance) (rate(node_cpu_seconds_total{instance=~"%s",mode="idle"}[$__rate_interval])) * 100)'
    % instanceVariable,

  memoryUtilization(instanceVariable='$instance')::
    '100 * (1 - node_memory_MemAvailable_bytes{instance=~"%s"} / node_memory_MemTotal_bytes{instance=~"%s"})'
    % [instanceVariable, instanceVariable],
}
