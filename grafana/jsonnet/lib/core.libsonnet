local constants = import 'constants.libsonnet';

local defaultTimeseriesCustom = {
  axisCenteredZero: false,
  axisColorMode: 'text',
  axisLabel: '',
  axisPlacement: 'auto',
  barAlignment: 0,
  drawStyle: 'line',
  fillOpacity: 15,
  gradientMode: 'none',
  hideFrom: {
    legend: false,
    tooltip: false,
    viz: false,
  },
  lineInterpolation: 'linear',
  lineWidth: 2,
  pointSize: 5,
  scaleDistribution: { type: 'linear' },
  showPoints: 'never',
  spanNulls: false,
  stacking: {
    group: 'A',
    mode: 'none',
  },
  thresholdsStyle: { mode: 'off' },
};

local basePanel(id, title, panelType, gridPos, targets) = {
  datasource: constants.datasource,
  fieldConfig: {
    defaults: {},
    overrides: [],
  },
  gridPos: gridPos,
  id: id,
  targets: targets,
  title: title,
  type: panelType,
};

{
  grid(x, y, w=12, h=8):: {
    h: h,
    w: w,
    x: x,
    y: y,
  },

  prometheusTarget(refId, expr, legendFormat, range=true, instant=false):: {
    datasource: constants.datasource,
    editorMode: 'code',
    expr: expr,
    instant: instant,
    legendFormat: legendFormat,
    range: range,
    refId: refId,
  },

  timeseriesPanel(
    id,
    title,
    gridPos,
    targets,
    unit=constants.units.short,
    min=null,
    max=null,
    thresholds=constants.thresholds.default
  )::
    basePanel(id, title, 'timeseries', gridPos, targets) + {
      fieldConfig+: {
        defaults: {
                    color: { mode: 'palette-classic' },
                    custom: defaultTimeseriesCustom,
                    mappings: [],
                    thresholds: {
                      mode: 'absolute',
                      steps: thresholds,
                    },
                    unit: unit,
                  } + (if min == null then {} else { min: min })
                  + (if max == null then {} else { max: max }),
      },
      options: {
        legend: {
          calcs: ['lastNotNull', 'max'],
          displayMode: 'table',
          placement: 'bottom',
          showLegend: true,
        },
        tooltip: {
          mode: 'multi',
          sort: 'desc',
        },
      },
    },

  statPanel(
    id,
    title,
    gridPos,
    targets,
    unit=constants.units.short,
    thresholdMode='absolute',
    thresholds=constants.thresholds.default
  )::
    basePanel(id, title, 'stat', gridPos, targets) + {
      fieldConfig+: {
        defaults: {
          color: { mode: 'thresholds' },
          mappings: [],
          thresholds: {
            mode: thresholdMode,
            steps: thresholds,
          },
          unit: unit,
        },
      },
      options: {
        colorMode: 'value',
        graphMode: 'area',
        justifyMode: 'auto',
        orientation: 'auto',
        percentChangeColorMode: 'standard',
        reduceOptions: {
          calcs: ['lastNotNull'],
          fields: '',
          values: false,
        },
        showPercentChange: false,
        textMode: 'auto',
        wideLayout: true,
      },
    },

  queryVariable(name, label, query, multi=false, includeAll=false):: {
    current: {},
    datasource: constants.datasource,
    definition: query,
    hide: 0,
    includeAll: includeAll,
    label: label,
    multi: multi,
    name: name,
    options: [],
    query: {
      query: query,
      refId: 'PrometheusVariableQueryEditor-VariableQuery',
    },
    refresh: 1,
    regex: '',
    skipUrlSync: false,
    sort: 1,
    type: 'query',
  },

  dashboard(title, uid, panels, variables=[]):: {
    annotations: { list: [] },
    editable: false,
    fiscalYearStartMonth: 0,
    graphTooltip: 1,
    id: null,
    links: [],
    liveNow: false,
    panels: panels,
    refresh: constants.dashboard.refresh,
    schemaVersion: constants.dashboard.schemaVersion,
    tags: constants.dashboard.tags,
    templating: { list: variables },
    time: {
      from: constants.dashboard.timeFrom,
      to: 'now',
    },
    timepicker: {},
    timezone: 'browser',
    title: title,
    uid: uid,
    version: 1,
    weekStart: '',
  },
}
