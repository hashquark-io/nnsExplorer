<template>
  <div :class="className" :style="{ height: height, width: width }" />
</template>

<script>
import echarts from 'echarts';
import resize from './resize';

export default {
  mixins: [resize],
  props: {
    neuronInfo: {
      type: Object | undefined,
      require: true,
    },
    units: {
      type: String,
      default: 'USD',
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
      selfVotes: "",
    }
  },
  mounted() {
    this.$nextTick(() => {
      this.initChart();
    })
  },
  beforeDestroy() {
    if (!this.chart) {
      return;
    }
    this.chart.dispose();
    this.chart = null;
  },
  methods: {
    initChart() {
      if (!this.neuronInfo) return;
      this.chart = echarts.init(this.$el);
      const { totalDelegations, totalVotes } = this.neuronInfo;
      this.selfVotes = (Number(totalVotes) - Number(totalDelegations)).toString();
      let rate;
      if (totalDelegations !== undefined && totalVotes !== undefined) {
        rate = Number(totalVotes) ? (Number(this.selfVotes) * 100) / Number(totalVotes) : 0;
      }

      const option = {
        title: {
          show: rate !== undefined,
          left: '48%',
          top: '38%',
          textAlign: 'center',
          text: ['{a|Self Votes }\n', `{b| ${rate && rate.toFixed(2)}% }`].join(''),
          textStyle: {
            rich: {
              a: {
                fontSize: 14,
                fontWeight: 600,
                color: 'rgba(0,0,0,0.42)',
                lineHeight: 30,
              },
              b: {
                fontSize: 20,
                color: 'rgba(0,0,0,0.85)',
                lineHeight: 30,
              },
            },
          },
        },
        grid: {
          left: 20,
          top: 0,
        },
        tooltip: {
          confine: true,
          show: true,
        },
        color: ['#4B72F0', '#00C5D1'],

        series: {
          radius: ['45%', '65%'],
          center: ['50%', '50%'],
          type: 'pie',
          data: [],
          label: {
            show: false,
            position: 'center',
          },
          itemStyle: {
            borderWidth: 5,
            borderColor: '#fff',
          },
        },
      }
      if (totalDelegations !== undefined && totalVotes !== undefined) {
        option.series.data = [
          {
            value: this.selfVotes,
            name: 'Self Votes',
          },
          {
            value: totalDelegations,
            name: 'Delegations',
          },
        ]
        this.chart.setOption(option);
      } else if (totalVotes) {
        option.series.data = [
          {
            name: 'Total Votes',
            value: totalVotes,
          },
        ]
        this.chart.setOption(option);
      }
    },
  },
  watch: {
    neuronInfo: {
      handler: 'initChart',
      deep: true,
    },
  },
}
</script>
