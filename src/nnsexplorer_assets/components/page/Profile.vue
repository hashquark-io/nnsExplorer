<template>
  <div>
    <el-row :gutter="20">
      <el-col :span="8">
        <el-card shadow="hover" class="mgb20" style="height:252px;">
          <div class="user-info">
            <img src="../../assets/img/img.jpg" class="user-avator" alt />
            <div class="user-info-cont">
              <div>{{username}}</div>
              <div>
                <p>{{useraccount}}</p>
              </div>
            </div>
          </div>
          <div class="user-info-assets">
            Total Assets：
            <span
              class="user-info-total-assets"
              v-html="formatNumStyle(thousandth(balance+votingPower+rewards, 4), 16, 14)"
            ></span>
            <span style="margin-left: 10px;">ICP</span>
            <p style="font-size: 12px;" class="grey">
              ≈
              <span>
                {{
                thousandth((balance+votingPower+rewards)*curCoinMarketInfo.usdPrice, 2)
                }}
              </span>
              <span style="margin-left: 5px;">{{ priceUnit }}</span>
            </p>
          </div>
        </el-card>
        <el-card shadow="hover" style="height:252px;">
          <div slot="header">
            <span>Latest Price</span>
          </div>
          <p style="text-align: right; margin-bottom: 20px;">ICP</p>
          <transition>
            <div>
              <p class="price">
                <span>USD Pice</span>
                <span v-if="curCoinMarketInfo.usdPrice">$ {{ curCoinMarketInfo.usdPrice }}</span>
              </p>
              <div class="flex">
                <div>
                  <span>24 hours</span>
                  <span
                    :class="[formatNumClass(curCoinMarketInfo.daysQuoteChangeUsd)]"
                  >{{ formatPer(curCoinMarketInfo.daysQuoteChangeUsd) }}</span>
                </div>
                <div>
                  <span>7 days</span>
                  <span
                    :class="[formatNumClass(curCoinMarketInfo.weekQuoteChangeUsd)]"
                  >{{ formatPer(curCoinMarketInfo.weekQuoteChangeUsd) }}</span>
                </div>
              </div>
              <p class="price">
                <span>BTC Price</span>
                <span v-if="curCoinMarketInfo.btcPrice">฿ {{ curCoinMarketInfo.btcPrice }}</span>
              </p>
              <div class="flex">
                <div>
                  <span>24 hours</span>
                  <span
                    :class="[formatNumClass(curCoinMarketInfo.daysQuoteChangeBtc)]"
                  >{{ formatPer(curCoinMarketInfo.daysQuoteChangeBtc) }}</span>
                </div>
                <div>
                  <span>7 days</span>
                  <span
                    :class="[formatNumClass(curCoinMarketInfo.weekQuoteChangeBtc)]"
                  >{{ formatPer(curCoinMarketInfo.weekQuoteChangeBtc) }}</span>
                </div>
              </div>
            </div>
          </transition>
        </el-card>
      </el-col>

      <el-col :span="16">
        <el-row :gutter="20" class="mgb20">
          <el-col :span="8">
            <el-card shadow="hover" :body-style="{padding: '0px'}">
              <div class="grid-content grid-con-1">
                <i class="el-icon-lx-people grid-con-icon"></i>
                <div class="grid-cont-right">
                  <div class="grid-num">{{ balance }}</div>
                  <div>Available Balance (ICP)</div>
                </div>
              </div>
            </el-card>
          </el-col>
          <el-col :span="8">
            <el-card shadow="hover" :body-style="{padding: '0px'}">
              <div class="grid-content grid-con-2">
                <i class="el-icon-lx-notice grid-con-icon"></i>
                <div class="grid-cont-right">
                  <div class="grid-num">{{ votingPower }}</div>
                  <div>Voting Power (ICP)</div>
                </div>
              </div>
            </el-card>
          </el-col>
          <el-col :span="8">
            <el-card shadow="hover" :body-style="{padding: '0px'}">
              <div class="grid-content grid-con-3">
                <i class="el-icon-lx-goods grid-con-icon"></i>
                <div class="grid-cont-right">
                  <div class="grid-num">{{ rewards }}</div>
                  <div>Rewards (ICP)</div>
                </div>
              </div>
            </el-card>
          </el-col>
        </el-row>
        <el-card shadow="hover" style="height:403px;">
          <div slot="header">
            <span>Historical Rewards</span>
          </div>
          <div class="chart-wrap">
            <daily-rewards :historyData="historyData" />
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row>
      <el-card v-if="showDelegationList" shadow="hover" :body-style="{padding: '0px'}">
        <div slot="header">
          <span>My Delegations</span>
        </div>
        <el-table
          :data="delegations"
          style="width: 100%"
          empty-text="No Data"
          @cell-click="openNeuronDetails"
        >
          <el-table-column label="Neuron ID" prop="addr" sortable width="500"></el-table-column>
          <el-table-column label="Description" prop="desc" width="400"></el-table-column>
          <el-table-column
            label="Commision Rate"
            prop="commission"
            sortable
            :sort-method="(a, b) => sortMethod(a, b, 'commission')"
          ></el-table-column>
          <el-table-column
            label="Delegate Amount"
            prop="amount"
            sortable
            :sort-method="(a, b) => sortMethod(a, b, 'amount')"
          ></el-table-column>
          <el-table-column align="right">
            <template slot="header">
              <el-button
                size="mini"
                type="primary"
                ref="withdrawBtn"
                @click="handleWithdraw()"
              >Withdraw Rewards</el-button>
            </template>
            <template slot-scope="scope">
              <el-button
                size="mini"
                type="primary"
                ref="unDelegateBtn"
                @click="handleUnDelegate(scope.$index, scope.row)"
              >UnDelegate</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-card>
    </el-row>

    <!-- UnDelegation dialog-->
    <el-dialog title="UnDelegation" :visible.sync="unDeleDlgVisible" width="20%" center>
      <div class="nns-balance">My Balance: ICP</div>
      <div>
        <el-button
          class="nns-delegator-btn"
          type="primary"
          @click="confirmUnDelegate()"
          size="medium"
        >Confirm</el-button>
        <el-button class="nns-delegator-btn" @click="cancel()" size="medium">Cancel</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import bus from "../common/bus";
import { thousandth, Mathfloor } from "../common/utils";
import dailyRewards from "../charts/dailyRewards";
import nnsexplorer from "ic:canisters/nnsexplorer";
export default {
  name: "dashboard",
  data() {
    return {
      username: localStorage.getItem("nns_username"),
      useraccount: localStorage.getItem("nns_useraccount"),
      balance: 0,
      rewards: 0,
      delegations: {},
      votingPower: 0,
      priceUnit: "USD",
      curCoinMarketInfo: {
        usdPrice: 23.16,
        daysQuoteChangeUsd: -3.32,
        weekQuoteChangeUsd: 100.47,
        btcPrice: 0.002,
        daysQuoteChangeBtc: -3.06,
        weekQuoteChangeBtc: 100.38,
      },
      showDelegationList: false,
      historyData: [
        {
          dailyIncome: 55.1212,
          incomeRate: 0.071,
          gmtDate: "2020-08-27",
        },
        {
          dailyIncome: 57.1212,
          incomeRate: 0.073,
          gmtDate: "2020-08-28",
        },
        {
          dailyIncome: 56.1212,
          incomeRate: 0.07,
          gmtDate: "2020-08-29",
        },
        {
          dailyIncome: 53.1212,
          incomeRate: 0.071,
          gmtDate: "2020-08-30",
        },
        {
          dailyIncome: 54.1212,
          incomeRate: 0.076,
          gmtDate: "2020-08-31",
        },
      ],
      unDeleDlgVisible: false,
    };
  },
  components: {
    dailyRewards,
  },
  computed: {},
  mounted: async function () {
    await this.update();
  },
  methods: {
    async update() {
      this.balance = Number(await nnsexplorer.getBalance(this.useraccount));
      this.rewards = Number(await nnsexplorer.getRewards(this.useraccount));

      var delegationsRet = await nnsexplorer.getDelegations(this.useraccount);
      var list = JSON.parse(delegationsRet);
      this.showDelegationList = false;
      this.delegations = [];
      this.votingPower = 0;
      if (list.length > 0) {
        listloop: for (var i = 0; i < list.length; i++) {
          const accountAddr = list[i]["Neuron Account"];
          const description = list[i]["Description"];
          const commission = list[i]["Commission Rate"];
          const amount = list[i]["Amount"];

          const delegationItem = {
            addr: accountAddr,
            desc: description,
            commission: commission,
            amount: amount,
          };
          this.delegations.push(delegationItem);

          this.votingPower += Number(amount);
        }

        this.showDelegationList = true;
      }
    },
    formatNumStyle(val, size1 = 16, size2 = 14) {
      if (isNaN(parseInt(val))) return "";
      const [before, after] = String(val).split(".");
      return `<span><span style="font-size:${size1}px">${before}</span>${
        after
          ? `<span>.</span><span style="font-size:${size2}px">${after}</span></span>`
          : ""
      }`;
    },
    formatNumClass(val) {
      if (val === undefined || val === null) return "";
      return val > 0 ? "green" : val < 0 ? "red" : "";
    },
    formatPer(val) {
      if (val === undefined || val === null) return "--";
      const per = val !== 0 ? "%" : "";
      return val > 0
        ? `+${Mathfloor(val, 2)}${per}`
        : val < 0
        ? Mathfloor(val, 2) + per
        : "0.00%";
    },
    openNeuronDetails(row, column, cell, event) {
      if (column.property === "addr") {
        this.$router.push({
          name: "neuronInfo",
          params: { addr: row[column.property] },
        });
      }
    },
    async handleWithdraw() {
      this.$message.info("Waiting to complete ...");
      this.$refs.withdrawBtn.disabled = true;

      const ret = await nnsexplorer.withdrawRewards(this.useraccount);
      if (ret) {
        this.$message.success("Withdraw rewards successfully!");
      } else {
        this.$message.error("Failed to withdraw rewards!");
      }

      this.$refs.withdrawBtn.disabled = false;
      await this.update();
    },
    async unDelegate(from, to, amount) {
      this.$message.info("Waiting to complete ...");
      this.$refs.unDelegateBtn.disabled = true;
      const ret = await nnsexplorer.updateByUnDelegation(from, to, amount);
      if (ret) {
        this.$message.success("Undelegated successfully!");
      } else {
        this.$message.error("Failed to undelegate!");
      }

      this.$refs.unDelegateBtn.disabled = false;
      await this.update();
    },
    handleUnDelegate(index, row) {
      for (var i = 0; i < this.delegations.length; i++) {
        if (this.delegations[i].addr.toLowerCase() === row.addr.toLowerCase()) {
          const amount = Number(this.delegations[i].amount);
          this.$confirm("", {
            title: "UnDelegate",
            message: `Confirm to undelegate from: ${row.addr} ?`,
            confirmButtonText: "Confirm",
            cancelButtonText: "Cancel",
            customClass: "confirm-dialog",
            confirmButtonClass: "confirm-btn-confirm",
            cancelButtonClass: "confirm-btn-cancel",
          })
            .then((_) => {
              this.unDelegate(this.useraccount, row.addr, amount);
            })
            .catch((_) => {});
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
    confirmUnDelegate() {},
    cancel() {
      this.unDeleDlgVisible = false;
    },
  },
};
</script>

<style scoped>
.el-row {
  margin-bottom: 20px;
}

.grid-content {
  display: flex;
  align-items: center;
  height: 100px;
}

.grid-cont-right {
  flex: 1;
  text-align: center;
  font-size: 14px;
  color: #999;
}

.grid-num {
  font-size: 30px;
  font-weight: bold;
}

.grid-con-icon {
  font-size: 50px;
  width: 100px;
  height: 100px;
  text-align: center;
  line-height: 100px;
  color: #fff;
}

.grid-con-1 .grid-con-icon {
  background: rgb(75, 110, 240);
}

.grid-con-1 .grid-num {
  color: rgb(75, 114, 240);
}

.grid-con-2 .grid-con-icon {
  background: rgb(0, 197, 209);
}

.grid-con-2 .grid-num {
  color: rgb(0, 197, 209);
}

.grid-con-3 .grid-con-icon {
  background: rgb(245, 188, 137);
}

.grid-con-3 .grid-num {
  color: rgb(245, 188, 137);
}

.user-info {
  display: flex;
  align-items: center;
  padding-bottom: 20px;
  border-bottom: 2px solid #ccc;
  margin-bottom: 20px;
}

.user-avator {
  width: 120px;
  height: 120px;
  border-radius: 50%;
}

.user-info-cont {
  padding-left: 50px;
  flex: 1;
  font-size: 14px;
  color: #999;
}

.user-info-cont div:first-child {
  font-size: 30px;
  color: #222;
}

.user-info-cont p {
  padding-top: 10px;
  word-wrap: break-word;
  word-break: break-all;
  overflow: hidden;
}

.user-info-assets {
  font-size: 16px;
  line-height: 25px;
}

.user-info-assets .user-info-total-assets {
  margin-left: 65px;
}

.user-info-assets p {
  margin-left: 160px;
}

.mgb20 {
  margin-bottom: 20px;
}

.chart-wrap {
  display: inline-block;
  width: 100%;
  vertical-align: top;
}

.price {
  margin-bottom: 5px;
  display: flex;
  justify-content: space-between;
}

.flex {
  margin-bottom: 30px;
  display: flex;
  justify-content: space-between;
  font-size: 14px;
}

.red {
  padding-left: 10px;
  color: red;
}

.green {
  padding-left: 10px;
  color: #4dcb73;
}
</style>

<style>
.confirm-btn-cancel {
  width: 100px !important;
}

.confirm-btn-confirm {
  width: 100px !important;
  background: rgb(64, 158, 255) !important;
}

.confirm-dialog {
  width: 600px !important;
}
</style>