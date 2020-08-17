<template>
  <div>
    <el-row :gutter="20" class="mgb20">
      <el-col :span="12">
        <el-card shadow="hover" :body-style="{padding: '0px'}">
          <div class="grid-content grid-con-1">
            <i class="grid-con-icon"></i>
            <div class="grid-cont-btn">
              <div class="grid-hint">Stake ICP to participate network governance and earn rewards</div>
              <el-button
                class="grid-btn"
                @click="showBeNeuronDlg()"
                plain
                size="small"
              >Become a Neuron</el-button>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card shadow="hover" :body-style="{padding: '0px'}">
          <div class="grid-content grid-con-2">
            <i class="grid-con-icon"></i>
            <div class="grid-cont-btn">
              <div class="grid-hint">Delegate ICP to a neuron and earn rewards</div>
              <el-button
                class="grid-btn"
                @click="showBeDelegatorDlg(0)"
                plain
                size="small"
              >Become a Delegator</el-button>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row>
      <h3 class="h3-title">Network</h3>
    </el-row>

    <el-row :gutter="20" class="mgb20">
      <el-col :span="6">
        <el-card shadow="always" :body-style="{padding: '0px'}">
          <div class="grid-kvpair">
            <div>
              <div class="grid-key">TOTAL PROPOSALS PROCESSED</div>
              <div class="grid-val">75</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="always" :body-style="{padding: '0px'}">
          <div class="grid-kvpair">
            <div>
              <div class="grid-key">LAST PROPOSAL PROCESSED</div>
              <div class="grid-val">14 hours before</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="always" :body-style="{padding: '0px'}">
          <div class="grid-kvpair">
            <div>
              <div class="grid-key">TOTAL NEURONS</div>
              <div class="grid-val">68</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="always" :body-style="{padding: '0px'}">
          <div class="grid-kvpair">
            <div>
              <div class="grid-key">TOTAL REWARD DISTRIBUTED</div>
              <div class="grid-val">5,263,574 ICP</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
    <el-row :gutter="20" class="mgb20">
      <el-col :span="6">
        <el-card shadow="always" :body-style="{padding: '0px'}">
          <div class="grid-kvpair">
            <div>
              <div class="grid-key">ONGOING PROPOSALS</div>
              <div class="grid-val">3</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="always" :body-style="{padding: '0px'}">
          <div class="grid-kvpair">
            <div>
              <div class="grid-key">AVG PROPOSAL INTERVAL</div>
              <div class="grid-val">2 days</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="always" :body-style="{padding: '0px'}">
          <div class="grid-kvpair">
            <div>
              <div class="grid-key">TOTAL VOTED BY NEURONS</div>
              <div class="grid-val">33,762,787 ICP</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="always" :body-style="{padding: '0px'}">
          <div class="grid-kvpair">
            <div>
              <div class="grid-key">TOTAL DELEGATED</div>
              <div class="grid-val">12,554,952 ICP</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row>
      <h3 class="h3-title">Neurons</h3>
    </el-row>

    <el-row>
      <el-card shadow="always" :body-style="{padding: '0px'}">
        <el-table
          :data="nnsNeuronList.filter(data => !search || data.addr.toLowerCase().includes(search.toLowerCase()) || 
          data.desc.toLowerCase().includes(search.toLowerCase()))"
          style="width: 100%"
          empty-text="No Data"
        >
          <el-table-column label="Neuron ID" prop="addr" sortable width="600"></el-table-column>
          <el-table-column
            label="Total Votes"
            prop="totalVotes"
            sortable
            :sort-method="(a, b) => sortMethod(a, b, 'totalVotes')"
          ></el-table-column>
          <el-table-column label="Description" prop="desc"></el-table-column>
          <el-table-column
            label="Commision Rate"
            prop="commission"
            sortable
            :sort-method="(a, b) => sortMethod(a, b, 'commission')"
          ></el-table-column>
          <el-table-column
            label="Performance"
            prop="performance"
            sortable
            :sort-method="(a, b) => sortMethod(a, b, 'performance')"
          ></el-table-column>
          <el-table-column align="right">
            <template slot="header">
              <el-input v-model="search" size="mini" placeholder="Search" />
            </template>
            <template slot-scope="scope">
              <el-button
                size="mini"
                type="primary"
                @click="handleDelegate(scope.$index, scope.row)"
              >Delegate</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-card>
    </el-row>

    <!-- Become a Neuron dialog-->
    <div v-if="beNeuronParam.beNeuronDlgVisible">
    <beNeuron :beNeuron="beNeuronParam" v-on:beNeuronChanged="handleBeNeuronChanged"></beNeuron>
    </div>

    <!-- Become a Delegator dialog-->
    <div v-if="beDelegatorParam.beDelegatorDlgVisible">
    <beDelegator :beDelegator="beDelegatorParam" v-on:beDelegatorChanged="handleBeDelegatorChanged"></beDelegator>
    </div>
  </div>
</template>

<script>
import Schart from "vue-schart";
import bus from "../common/bus";
import vBeNeuron from "../dialog/BeNeuron.vue";
import vBeDelegator from "../dialog/BeDelegator.vue";
import nnsexplorer from "ic:canisters/nnsexplorer";
export default {
  name: "Overview",
  data() {
    return {
      beNeuronParam: {
        beNeuronDlgVisible: false,
        account: "",
        balance: 0,
      },
      beDelegatorParam: {
        beDelegatorDlgVisible: false,
        account: "",
        desc: "",
        commission: "",
        totalVotes: "",
        totalDelegations: "",
        performance: "",
        balance: 0,
        neuronList: {},
      },
      nnsNeuronList: [],
      search: "",
    };
  },
  components: {
    beNeuron: vBeNeuron,
    beDelegator: vBeDelegator,
  },
  methods: {
    showBeNeuronDlg() {
      let username = localStorage.getItem("nns_username");
      if (username) {
        this.beNeuronParam.beNeuronDlgVisible = true;
        this.beNeuronParam.account = localStorage.getItem("nns_useraccount");
        this.beNeuronParam.balance = 10000; // TODO
      } else {
        this.$message.error("You should login first!");
      }
    },
    getNeuronList: async function () {
      const results = await nnsexplorer.getList();
      var list = JSON.parse(results);
      listloop: for (var i = 0; i < list.length; i++) {
        const accountAddr = list[i]["Account Address"];
        const description = list[i]["Description"];
        const commission = list[i]["Commission Rate"];
        const totalVotes = (
          Number(list[i]["Self Staking"]) + Number(list[i]["Total Delegations"])
        ).toString();
        const totalDelegations = list[i]["Total Delegations"];
        const performance = "100%"; // TODO

        for (var j = 0; j < this.nnsNeuronList.length; j++) {
          if (
            this.nnsNeuronList[j].addr.toLowerCase() ===
            accountAddr.toLowerCase()
          ) {
            this.nnsNeuronList[j].desc = description;
            this.nnsNeuronList[j].commission = commission;
            this.nnsNeuronList[j].totalVotes = totalVotes;
            this.nnsNeuronList[j].totalDelegations = totalDelegations;
            this.nnsNeuronList[j].performance = performance;
            continue listloop;
          }
        }

        const neuronItem = {
          addr: accountAddr,
          desc: description,
          commission: commission,
          totalVotes: totalVotes,
          totalDelegations: totalDelegations,
          performance: performance,
        };
        this.nnsNeuronList.push(neuronItem);
      }
    },
    handleBeNeuronChanged(e) {
      this.beNeuronParam = e;
      this.getNeuronList();
    },
    handleBeDelegatorChanged(e) {
      this.beDelegatorParam = e;
      this.getNeuronList();
    },
    showBeDelegatorDlg(modelIdx) {
      let username = localStorage.getItem("nns_username");
      if (username) {
        if (this.nnsNeuronList.length > 0) {
          this.beDelegatorParam.balance = 10000; // TODO

          this.beDelegatorParam.neuronList = this.nnsNeuronList;
          this.setDeleParamForDlg(modelIdx);

          this.beDelegatorParam.beDelegatorDlgVisible = true;
        } else {
          this.$message.error("There is no any neuron to delegate!");
        }
      } else {
        this.$message.error("You should login first!");
      }
    },
    setDeleParamForDlg(modelIdx) {
      this.beDelegatorParam.account = this.nnsNeuronList[modelIdx].addr;
      this.beDelegatorParam.desc = this.nnsNeuronList[modelIdx].desc;
      this.beDelegatorParam.commission = this.nnsNeuronList[
        modelIdx
      ].commission;
      this.beDelegatorParam.totalVotes = this.nnsNeuronList[
        modelIdx
      ].totalVotes;
      this.beDelegatorParam.totalDelegations = this.nnsNeuronList[
        modelIdx
      ].totalDelegations;
      this.beDelegatorParam.performance = this.nnsNeuronList[
        modelIdx
      ].performance;
    },
    handleDelegate(index, row) {
      for (var i = 0; i < this.nnsNeuronList.length; i++) {
        if (
          this.nnsNeuronList[i].addr.toLowerCase() === row.addr.toLowerCase()
        ) {
          this.showBeDelegatorDlg(i);
        }
      }
    },
    sortMethod(a, b, type) {
      let val1 = 0;
      let val2 = 0;
      let c = type === "totalVotes" ? "," : "%";
      let str1 = replaceAll(a[type].toString(), c);
      val1 = Number(str1);
      let str2 = replaceAll(b[type].toString(), c);
      val2 = Number(str2);

      return val1 - val2;
    },
  },
  mounted() {
    this.getNeuronList();

    if (this.timer) {
      clearInterval(this.timer);
    } else {
      this.timer = setInterval(() => {
        this.getNeuronList();
      }, 300000); // Refresh neuron list for every 5 minutes
    }
  },
  destroyed() {
    clearInterval(this.timer);
  },
};

function replaceAll(str, c) {
  let tempArr = [];
  tempArr = str.split(c);
  return tempArr.join("");
}
</script>

<style scoped>
.el-row {
  margin-bottom: 20px;
}

.grid-content {
  display: flex;
  align-items: center;
  height: 120px;
}

.grid-cont-btn {
  flex: 1;
  font-size: 14px;
  color: #999;
}

.grid-cont {
  flex: 1;
  text-align: center;
  font-size: 14px;
  color: #999;
}

.grid-hint {
  font-size: 20px;
  font-weight: bold;
  padding-bottom: 15px;
  padding-left: 15px;
}

.grid-btn {
  font-weight: bold;
  margin-left: 15px;
  width: 160px;
}

.grid-con-1 {
  background: rgb(45, 140, 240);
}

.grid-con-1 .grid-hint {
  color: rgb(255, 255, 255);
}

.grid-con-2 {
  background: rgb(45, 140, 240);
}

.grid-con-2 .grid-hint {
  color: rgb(255, 255, 255);
}

.h3-title {
  margin-top: 10px;
  margin-bottom: 0px;
}

.user-avator {
  width: 100px;
  height: 100px;
  border-radius: 50%;
}

.mgb20 {
  margin-bottom: 20px;
}

.grid-kvpair {
  display: flex;
  align-items: center;
  height: 100px;
}

.grid-key {
  font-size: 12px;
  font-weight: bold;
  color: #999;
  padding-bottom: 12px;
  padding-left: 15px;
}

.grid-val {
  font-size: 16px;
  font-weight: bold;
  padding-left: 15px;
  color: black;
}
</style>
