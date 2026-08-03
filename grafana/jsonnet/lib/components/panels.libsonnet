local constants = import '../constants.libsonnet';
local core = import '../core.libsonnet';
local queries = import 'queries.libsonnet';

{
  networkReceived(id, gridPos):: core.timeseriesPanel(
    id=id,
    title='Network received traffic',
    gridPos=gridPos,
    targets=[core.prometheusTarget('A', queries.networkReceive(), '{{instance}} received')],
    unit=constants.units.bitsPerSecond,
  ),

  networkSent(id, gridPos):: core.timeseriesPanel(
    id=id,
    title='Network sent traffic',
    gridPos=gridPos,
    targets=[core.prometheusTarget('A', queries.networkTransmit(), '{{instance}} sent')],
    unit=constants.units.bitsPerSecond,
  ),

  rootFilesystemFree(id, gridPos):: core.statPanel(
    id=id,
    title='Root filesystem free space',
    gridPos=gridPos,
    targets=[core.prometheusTarget('A', queries.rootFilesystemFree(), '{{instance}} free')],
    unit=constants.units.percent,
    thresholdMode='percentage',
    thresholds=constants.thresholds.freeSpace,
  ),

  fileDescriptors(id, gridPos):: core.statPanel(
    id=id,
    title='File descriptors',
    gridPos=gridPos,
    targets=[
      core.prometheusTarget('A', queries.allocatedFileDescriptors(), '{{instance}} allocated'),
      core.prometheusTarget('B', queries.maximumFileDescriptors(), '{{instance}} limit'),
    ],
  ),

  cpuUtilization(id, gridPos):: core.timeseriesPanel(
    id=id,
    title='CPU utilization',
    gridPos=gridPos,
    targets=[core.prometheusTarget('A', queries.cpuUtilization(), '{{instance}} CPU')],
    unit=constants.units.percent,
    min=0,
    max=100,
    thresholds=constants.thresholds.utilization,
  ),

  memoryUtilization(id, gridPos):: core.timeseriesPanel(
    id=id,
    title='Memory utilization',
    gridPos=gridPos,
    targets=[core.prometheusTarget('A', queries.memoryUtilization(), '{{instance}} RAM')],
    unit=constants.units.percent,
    min=0,
    max=100,
    thresholds=constants.thresholds.utilization,
  ),
}
