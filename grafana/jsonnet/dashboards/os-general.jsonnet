local panels = import '../lib/components/panels.libsonnet';
local variables = import '../lib/components/variables.libsonnet';
local core = import '../lib/core.libsonnet';

core.dashboard(
  title='OS General',
  uid='os-general',
  panels=[
    panels.networkReceived(1, core.grid(x=0, y=0)),
    panels.networkSent(2, core.grid(x=12, y=0)),
    panels.rootFilesystemFree(3, core.grid(x=0, y=8, h=7)),
    panels.fileDescriptors(4, core.grid(x=12, y=8, h=7)),
    panels.cpuUtilization(5, core.grid(x=0, y=15)),
    panels.memoryUtilization(6, core.grid(x=12, y=15)),
  ],
  variables=[variables.instance()],
)
