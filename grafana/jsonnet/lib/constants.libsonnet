{
  datasource: {
    type: 'prometheus',
    uid: 'prometheus',
  },

  dashboard: {
    refresh: '15s',
    schemaVersion: 41,
    tags: ['linux', 'node-exporter', 'rocketdev'],
    timeFrom: 'now-6h',
  },

  units: {
    bitsPerSecond: 'bps',
    percent: 'percent',
    short: 'short',
  },

  thresholds: {
    default: [
      { color: 'green', value: null },
    ],
    freeSpace: [
      { color: 'red', value: null },
      { color: 'orange', value: 10 },
      { color: 'green', value: 20 },
    ],
    utilization: [
      { color: 'green', value: null },
      { color: 'orange', value: 70 },
      { color: 'red', value: 90 },
    ],
  },
}
