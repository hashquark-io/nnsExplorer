<template>
  <div class="daily-rewards-chart">
    <div class="chart-title">
      <div>Daily Rewards (ICP)</div>
      <div class="btn-groups">
        <span :class="[activeInd === 0 ? 'active' : '']" @click="changeDateRange(0)">7 dyas</span>
        <span :class="[activeInd === 1 ? 'active' : '']" @click="changeDateRange(1)">30 days</span>
      </div>
    </div>
    <div :class="className" ref="chart" :style="{ height: height, width: width }" />
  </div>
</template>

<script>
import resize from './resize';
import { initChart, Mathfloor, thousandth } from '../common/utils';

export default {
  mixins: [resize],
  props: {
    historyData: {
      type: Array,
      default: function () {
        return []
      },
    },
    className: {
      type: String,
      default: 'chart',
    },
    width: {
      type: String,
      default: '100%',
    },
    height: {
      type: String,
      default: '300px',
    },
  },
  data() {
    return {
      chart: null,
      option: null,
      activeInd: 0,
    }
  },
  computed: {
    dateRange() {
      return this.activeInd === 0 ? 7 : 30
    },
  },
  mounted() {
    this.$nextTick(() => {
      this.initChart()
    })
  },
  updated() {
    this.initChart()
  },
  beforeDestroy() {
    if (!this.chart) {
      return
    }
    this.chart.dispose()
    this.chart = null
  },
  methods: {
    changeDateRange(activeInd) {
      this.activeInd = activeInd;
    },
    initChart() {
      if (this.historyData.length === 0) return;
      this.updateOption();
      this.chart = initChart(this.option);
    },
    updateOption() {
      const code = this.code;
      const chartOpt = {
        color: ['#4B72F0', '#00C5D1'],
        tooltip: {
          confine: true,
          show: true,
          trigger: 'axis',
          backgroundColor: '#FFF',
          textStyle: {
            color: '#7E8AA3',
          },
          extraCssText: 'box-shadow:0px 6px 10px 0px rgba(0,0,0,0.2);',
          formatter: function (params) {
            const { axisValue } = params[0]
            return params.reduce((a, t) => {
              let { seriesName, marker, data } = t
              if (seriesName === 'Daily Rewards') data = thousandth(data, 6)
              return `${a}<br />${marker} ${seriesName}: ${data}${seriesName === 'Rewards Rate' ? '%' : ''}`
            }, `${axisValue}`)
          },
        },
        legend: {
          right: 20,
          bottom: 10,
          icon: 'circle',
        },
        grid: {
          top: '30',
          left: '30',
          right: '30',
          bottom: '70',
          containLabel: true,
        },
        xAxis: {
          offset: 20,
          axisLine: {
            show: false,
          },
          axisTick: {
            show: false,
          },
          type: 'category',
          boundaryGap: false,
          data: [],
        },
        yAxis: [
          {
            axisTick: {
              show: false,
            },
            splitLine: {
              show: true,
              lineStyle: {
                type: 'dashed',
              },
            },
            axisLine: {
              show: false,
            },
            axisLabel: {
              formatter(value) {
                if (Math.abs(value) >= 1000000) {
                  return `${(value / 1000000).toFixed(2)}m`
                }
                if (Math.abs(value) / 1000 >= 1) {
                  return `${(value / 1000).toFixed(0)}k`
                }
                if (['DASH', 'DOT'].includes(code)) {
                  return value.toFixed(2)
                }
                return value.toFixed(0)
              },
            },
            type: 'value',
          },
          {
            axisTick: {
              show: false,
            },
            splitLine: {
              show: true,
              lineStyle: {
                type: 'dashed',
              },
            },
            axisLine: {
              show: false,
            },
            axisLabel: {
              formatter(val) {
                return val.toFixed(2) + '%'
              },
            },
            type: 'value',
          },
        ],
        series: [
          {
            yAxisIndex: 0,
            type: 'line',
            data: [],
            showSymbol: false,
            smooth: true,
          },
          {
            yAxisIndex: 1,
            type: 'line',
            data: [],
            showSymbol: false,
            smooth: true,
          },
        ],
      }
      this.option = {
        data: this.historyData.slice(-this.dateRange),
        dataOpt: {
          xAxis: 'gmtDate',
          dataKey: {
            y1: ['dailyIncome'],
            y2: ['incomeRate'],
            y1MinZero: false,
            y2MinZero: false,
          },
          format: {
            gmtDate: (val) => val.slice(5),
            incomeRate: (val) => Mathfloor(val * 100, 2),
          },
          legend: ['Daily Rewards', 'Rewards Rate'],
        },
        dom: this.$refs.chart,
        chartOpt,
      }
    },
  },
  watch: {
    historyData: {
      handler: 'initChart',
      deep: true,
    },
  },
}
</script>

<style scoped>
.daily-rewards-chart {
  font-size: 14px;
}

.chart-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 30px;
}

.btn-groups {
  display: flex;
  justify-content: center;
  align-items: center;
  color: #8593b3;
  cursor: pointer;
}

.btn-groups > span {
  text-align: center;
  width: 60px;
  border: 1px solid #bec4d1;
  border-radius: 4px;
}

.btn-groups > span.active {
  color: #fff;
  background: #5d89e6;
  border-color: #5d89e6;
}

.btn-groups span:first-child {
  border-radius: 4px 0 0 4px;
}

.btn-groups span:last-child {
  border-left: none;
  border-radius: 0 4px 4px 0;
}
</style>
