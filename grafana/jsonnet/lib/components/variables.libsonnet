local core = import '../core.libsonnet';

{
  instance():: core.queryVariable(
    name='instance',
    label='Instance',
    query='label_values(node_uname_info, instance)',
  ),
}
