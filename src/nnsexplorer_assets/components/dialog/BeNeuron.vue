<template>
  <el-dialog title="Become a Neuron" :visible.sync="beNeuron.beNeuronDlgVisible" width="36%" center>
    <div class="nns-be-neuron">
      <el-form
        ref="beNeuron"
        :model="param"
        :rules="rules"
        label-position="left"
        label-width="160px"
      >
        <el-form-item label="My Account" class="nns-form-label">
          <el-input class="nns-input" v-model="beNeuron.account" ref="accountInput" disabled></el-input>
        </el-form-item>
        <el-form-item label="Description" class="nns-form-label" prop="desc">
          <el-input
            class="nns-input"
            v-model="param.desc"
            placeholder="Description"
            autocomplete="off"
          ></el-input>
        </el-form-item>
        <el-form-item label="Commission Rate" class="nns-form-label" prop="commission">
          <el-input
            class="nns-input"
            v-model.number="param.commission"
            oninput="if(value.length>2)value=value.slice(0,2)"
            placeholder="Percent"
            autocomplete="off"
          ></el-input>
        </el-form-item>
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
            class="nns-beneuron-btn"
            ref="beNeuronBtn"
            type="primary"
            @click="submitForm()"
            size="medium"
          >Commit</el-button>
          <el-button class="nns-beneuron-btn" @click="resetForm()" size="medium">Reset</el-button>
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
    beNeuron: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      param: {
        desc: "",
        commission: "",
        amount: "",
        balance: "",
      },
      rules: {
        desc: [
          {
            required: true,
            message: "Please enter a descrition",
          },
        ],
        commission: [
          {
            required: true,
            message: "Please enter a commission rate",
          },
          {
            type: "number",
            message: "Commission rate must be a number",
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
    submitForm: async function () {
      const accountAddr = this.$refs.accountInput.value;
      const description = this.param.desc;
      const commissionRate = Number(this.param.commission);
      const selfStaking = Number(this.param.amount);

      this.$refs.beNeuronBtn.disabled = true;
      if (
        await nnsexplorer.createNeuron({
          accountAddr,
          description,
          commissionRate,
          selfStaking,
        })
      ) {
        this.$message.success("New neuron registered successfully!");
        var newBeNeuron = {
          beNeuronDlgVisible: false,
        };
        this.$emit("beNeuronChanged", newBeNeuron);
      } else {
        this.$message.error("New neuron registered failed! Insufficient balance or you are already a neuron or delegator.");
        this.param.balance = await nnsexplorer.getBalance(accountAddr);
      }

      this.param.desc = "";
      this.param.commission = "";
      this.param.amount = "";

      this.$refs.beNeuronBtn.disabled = false;
    },
    resetForm: function () {
      this.param.desc = "";
      this.param.commission = "";
      this.param.amount = "";
    },
  },
  mounted() {
    this.param.balance = this.beNeuron.balance.toString();
  },
};
</script>
<style scoped>
.nns-be-neuron {
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
.nns-beneuron-btn {
  width: 32%;
}
</style>