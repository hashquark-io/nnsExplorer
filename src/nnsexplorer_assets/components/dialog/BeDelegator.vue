<template>
  <el-dialog
    title="Become a Delegator"
    :visible.sync="beDelegator.beDelegatorDlgVisible"
    width="36%"
    center
  >
    <div class="nns-be-delegator">
      <el-form
        ref="delegator"
        :model="param"
        :rules="rules"
        label-position="left"
        label-width="160px"
      >
        <el-form-item label="Delegate To" class="nns-form-label" prop="account">
          <el-select
            v-model="param.toAddr"
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
        </el-form-item>
        <div class="nns-dele-desc">{{param.desc}}</div>
        <div>
          <el-row :gutter="20" class="nns-dele-info">
            <el-col :span="6">
              <el-card shadow="never" :body-style="{padding: '0px'}">
                <div class="dele-info-val">{{param.annaulizedYield}}</div>
                <div class="dele-info-key">7-day Annaulized Yield</div>
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card shadow="never" :body-style="{padding: '0px'}">
                <div class="dele-info-val">{{param.commission}}</div>
                <div class="dele-info-key">Comission</div>
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card shadow="never" :body-style="{padding: '0px'}">
                <div class="dele-info-val">{{param.totalVotes}}</div>
                <div class="dele-info-key">Total Votes</div>
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card shadow="never" :body-style="{padding: '0px'}">
                <div class="dele-info-val">{{param.totalDelegations}}</div>
                <div class="dele-info-key">Total Delegations</div>
              </el-card>
            </el-col>
          </el-row>
        </div>
        <el-form-item
          class="nns-staking-amount nns-form-label"
          label="Staking Amount"
          prop="amount"
        >
          <el-input
            class="nns-input"
            v-model.number="param.amount"
            oninput="if(value.length>18)value=value.slice(0,18)"
            placeholder="Amount (ICP)"
            autocomplete="off"
          ></el-input>
        </el-form-item>
        <div class="nns-balance">My Balance: {{param.balance}} ICP</div>
        <el-form-item>
          <el-button
            class="nns-delegator-btn"
            ref="delegateBtn"
            type="primary"
            @click="submitForm()"
            size="medium"
          >Commit</el-button>
          <el-button class="nns-delegator-btn" @click="cancel()" size="medium">Cancel</el-button>
        </el-form-item>
      </el-form>
    </div>
  </el-dialog>
</template>
<script>
import bus from "../common/bus";
import nnsexplorer from "ic:canisters/nnsexplorer";
export default {
  props: {
    beDelegator: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      param: {
        amount: "",
        toAddr: "",
        neuronList: {},
        annaulizedYield: "",
        desc: "",
        commission: "",
        totalVotes: "",
        totalDelegations: "",
        balance: "",
      },
      rules: {
        account: [
          {
            required: true,
            trigger: "blur",
          },
        ],
        amount: [
          {
            required: true,
            message: "Please enter the amount",
          },
          {
            type: "number",
            message: "Amount must be a number",
          },
        ],
      },
    };
  },
  methods: {
    delegateToChanged(val) {
      if (val) {
        const list = this.param.neuronList;
        const toAddr = val;

        for (var i = 0; i < list.length; i++) {
          if (toAddr.toLowerCase() === list[i].addr.toLowerCase()) {
            this.param.toAddr = list[i].addr;
            this.param.annaulizedYield = list[i].annaulizedYield;
            this.param.desc = list[i].desc;
            this.param.commission = list[i].commission;
            this.param.totalVotes = list[i].totalVotes;
            this.param.totalDelegations = list[i].totalDelegations;
            break;
          }
        }
      }
    },
    submitForm: async function () {
      const fromAddr = localStorage.getItem("nns_useraccount");
      if (fromAddr === "") {
        this.$message.error(
          "It seems that you don't have a valid private key!"
        );
        return false;
      }
      const toAddr = this.param.toAddr;
      const amount = Number(this.param.amount);

      this.$refs.delegateBtn.disabled = true;
      this.$message.info("Waiting to complete ...");
      if (await nnsexplorer.updateByDelegation(fromAddr, toAddr, amount)) {
        this.$message.success("New delegation successfully!");
        var newBeDelegator = this.beDelegator;
        newBeDelegator.beDelegatorDlgVisible = false;
        this.$emit("beDelegatorChanged", newBeDelegator);
      } else {
        this.$message.success("Delegation failed! Insufficient balance or you are already a neuron.");
        this.param.balance = await nnsexplorer.getBalance(fromAddr);
      }

      this.param.amount = "";

      this.$refs.delegateBtn.disabled = false;
    },
    cancel: function () {
      var newBeDelegator = this.beDelegator;
      newBeDelegator.beDelegatorDlgVisible = false;
      this.$emit("beDelegatorChanged", newBeDelegator);
    },
  },
  mounted() {
    this.param.toAddr = this.beDelegator.account;
    this.param.neuronList = this.beDelegator.neuronList;
    this.param.annaulizedYield = this.beDelegator.annaulizedYield;
    this.param.desc = this.beDelegator.desc;
    this.param.commission = this.beDelegator.commission;
    this.param.totalVotes = this.beDelegator.totalVotes;
    this.param.totalDelegations = this.beDelegator.totalDelegations;
    this.param.balance = this.beDelegator.balance.toString();
  },
};
</script>
<style scoped>
.nns-be-delegator {
  position: relative;
  left: 50%;
  top: 50%;
  width: 100%;
  margin: 0px 0px -20px -50%;
  border-radius: 5px;
  background: rgba(255, 255, 255, 0.3);
  overflow: hidden;
}
.nns-form-label {
  padding-left: 20px;
}
.el-select {
  width: 450px;
}
.nns-dele-info {
  padding-left: 25px;
  padding-right: 25px;
  padding-bottom: 20px;
}
.nns-dele-desc {
  font-size: 16px;
  font-weight: bold;
  padding-left: 25px;
  margin-top: -10px;
  padding-bottom: 10px;
  color: black;
}
.dele-info-val {
  padding-top: 10px;
  text-align: center;
  font-size: 16px;
  font-weight: bold;
  color: rgb(45, 140, 240);
}
.dele-info-key {
  text-align: center;
  font-size: 12px;
  color: #999;
  padding-bottom: 10px;
}
.nns-input {
  width: 95%;
}
.nns-staking-amount {
  padding-bottom: 15px;
  border-bottom: 2px solid #ccc;
  margin-bottom: 10px;
}
.nns-balance {
  text-align: right;
  font-size: 12px;
  font-weight: bold;
  color: #999;
  padding-bottom: 10px;
}
.nns-delegator-btn {
  width: 32%;
}
</style>