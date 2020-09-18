<template>
  <div class="neuron-info">
    <h4 class="content-title">
      <span>Neuron Details</span>
      <el-select
        class="account"
        v-model="param.account"
        placeholder="Choose an address"
        @change="delegateToChanged"
      >
        <el-option
          v-for="item in param.neuronList"
          :key="item.desc"
          :label="item.addr"
          :value="item.addr"
        ></el-option>
      </el-select>
    </h4>

    <div class="chart-wrap delegate-pie-chart">
      <delegate-chart :neuronInfo="curNeuronInfo" width="40%" />
      <div class="chart-info" v-if="curNeuronInfo">
        <div>
          <span class="label" style="font-size: 16px;">Total Votes：</span>
          <span v-html="formatNumStyle(curNeuronInfo.totalVotes, 18, 14)"></span>
          <span style="margin-left: 10px;">ICP</span>
        </div>
        <p class="legend-item">
          <span class="grey label">Self Votes</span>
          <span v-html="formatNumStyle((Number(curNeuronInfo.totalVotes) - Number(curNeuronInfo.totalDelegations)).toString(), 16, 14)"></span>
          <span style="margin-left: 10px;">ICP</span>
        </p>
        <p class="legend-item">
          <span class="grey label">Delegations</span>
          <span v-html="formatNumStyle(curNeuronInfo.totalDelegations, 16, 14)"></span>
          <span style="margin-left: 10px;">ICP</span>
        </p>
      </div>
    </div>

    <div class="neuron-info-wrap" v-if="curNeuronInfo">
      <div class="flex">
        <div class="item" v-if="curNeuronInfo.commission !== undefined">
          <p>Commission Rate</p>
          <p class="bold">{{ curNeuronInfo.commission }}</p>
        </div>
        <div class="item" v-if="curNeuronInfo.numDelegators !== undefined">
          <p>Delegators</p>
          <p class="bold">{{ curNeuronInfo.numDelegators }}</p>
        </div>
      </div>
    </div>

    <div class="chart-wrap">
      <daily-delegate :historyData="param.historyData" />
    </div>
    <div class="chart-wrap">
      <daily-rewards :historyData="param.historyData" />
    </div>
  </div>
</template>
<script>
import delegateChart from "../chart/delegateChart";
import dailyDelegate from "../chart/dailyDelegate";
import dailyRewards from "../chart/dailyRewards";
import nnsexplorer from "ic:canisters/nnsexplorer";
export default {
  data() {
    return {
      param: {
        account: "",
        neuronList: [],
        historyData: [
          {
            dailyIncome: 55.1212,
            incomeRate: 0.071,
            nodeTotalVotes: 946521.1212,
            voterNum: 396,
            gmtDate: "2020-08-27",
          },
          {
            dailyIncome: 57.1212,
            incomeRate: 0.073,
            nodeTotalVotes: 946531.1212,
            voterNum: 390,
            gmtDate: "2020-08-28",
          },
          {
            dailyIncome: 56.1212,
            incomeRate: 0.07,
            nodeTotalVotes: 946551.1212,
            voterNum: 386,
            gmtDate: "2020-08-29",
          },
          {
            dailyIncome: 53.1212,
            incomeRate: 0.071,
            nodeTotalVotes: 946511.1212,
            voterNum: 391,
            gmtDate: "2020-08-30",
          },
          {
            dailyIncome: 54.1212,
            incomeRate: 0.076,
            nodeTotalVotes: 946527.1212,
            voterNum: 393,
            gmtDate: "2020-08-31",
          },
        ],
      },
      chart: null,
    };
  },
  components: {
    delegateChart,
    dailyDelegate,
    dailyRewards,
  },
  computed: {
    curNeuronInfo() {
      return this.param.neuronList.find(
        (t) => String(t.addr) === this.param.account
      );
    },
    selfVotes() {
      return this.param.neuronList.find(
        (t) => String(t.addr) === this.param.account
      );
    },
  },
  methods: {
    delegateToChanged(val) {},
    async getNeuronList() {
      const results = await nnsexplorer.getNeuronList();
      var list = JSON.parse(results);
      this.param.neuronList = [];
      listloop: for (var i = 0; i < list.length; i++) {
        const accountAddr = list[i]["Account Address"];
        const description = list[i]["Description"];
        const commission = list[i]["Commission Rate"];
        const totalVotes = (
          Number(list[i]["Self Staking"]) + Number(list[i]["Total Delegations"])
        ).toString();
        const totalDelegations = list[i]["Total Delegations"];
        const delegators = list[i]["Delegators"];
        const annaulizedYield = "24%"; // TODO

        const neuronItem = {
          addr: accountAddr,
          desc: description,
          commission: commission,
          totalVotes: totalVotes,
          totalDelegations: totalDelegations,
          annaulizedYield: annaulizedYield,
          numDelegators: delegators,
        };
        this.param.neuronList.push(neuronItem);
      }
    },
    formatNumStyle(val, size1 = 16, size2 = 14) {
      if (isNaN(parseInt(val))) return "";
      //const [before, after] = String(val).split(".");
      const [before, after] = [toThousands(val), ""];
      return `<span><span style="font-size:${size1}px">${before}</span>${
        after
          ? `<span>.</span><span style="font-size:${size2}px">${after}</span></span>`
          : ""
      }`;
    },
  },
  mounted: async function () {
    await this.getNeuronList();
    if (this.$route.params.addr) {
      this.param.account = this.$route.params.addr;
    } else if (this.param.neuronList.length != 0) {
      this.param.account = this.param.neuronList[0].addr;
    }

    if (this.param.account === "") {
      if (this.param.neuronList.length != 0) {
        this.param.account = this.param.neuronList[0].addr;
      }
    }
  },
};

function toThousands(num) {
  return num.replace(/(\d)(?=(?:\d{3})+$)/g, "$1,");
}
</script>
<style scoped>
.neuron-info {
  position: relative;
  padding: 40px 40px 0;
  min-height: calc(100vh - 200px);
  background: #fff;
}

.content-title {
  display: flex;
  justify-content: space-between;
  padding: 0 0 40px;
}

.account {
  color: #6e93ef;
  width: 500px;
  text-align: left;
  font-size: 18px;
  padding-right: 50px;
}

.chart-wrap,
.neuron-info-wrap {
  display: inline-block;
  width: 48%;
  vertical-align: top;
}

.delegate-pie-chart > div {
  display: inline-block;
}

.delegate-pie-chart .chart-info {
  padding-top: 80px;
  width: 55%;
  height: 300px;
  font-size: 16px;
  font-weight: 700;
  text-align: right;
  color: rgba(0, 0, 0, 0.85);
  vertical-align: top;
}

.delegate-pie-chart .chart-info span {
  display: inline-block;
}

.delegate-pie-chart .chart-info .label {
  font-size: 14px;
  line-height: 20px;
  color: #7e8aa3;
}

.delegate-pie-chart .chart-info .grey {
  color: #7e8aa3;
}

.delegate-pie-chart .chart-info .legend-item {
  margin-top: 15px;
  padding-left: 30px;
  margin-left: auto;
  display: flex;
  justify-content: space-between;
  overflow: hidden;
  max-width: 340px;
}

.delegate-pie-chart .chart-info .legend-item:nth-of-type(1) {
  margin-top: 25px;
}

.content-title {
  display: flex;
  justify-content: space-between;
  padding: 0 0 40px;
}

.address {
  color: #6e93ef;
  text-align: center;
  font-weight: 400;
  font-size: 14px;
}

.neuron-info-wrap {
  padding: 30px 20px 0;
  height: 300px;
}

.neuron-info-wrap .flex {
  margin-top: 40px;
  display: flex;
  justify-content: space-around;
  align-items: center;
}

.neuron-info-wrap .item p {
  line-height: 40px;
}

.neuron-info-wrap .item .bold {
  font-size: 18px;
  font-weight: 600;
}

.chart-wrap {
  margin-bottom: 30px;
}
</style>