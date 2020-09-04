<template>
  <div class="proposal-page">
    <div class="search">
      <el-form :inline="true" :model="queryOptions" class="demo-form-inline" size="mini">
        <el-form-item label="Create Time">
          <el-date-picker
            v-model="dateRange"
            type="daterange"
            value-format="yyyy-MM-dd"
            range-separator="To"
            start-placeholder="Time Start"
            end-placeholder="Time End"
          ></el-date-picker>
        </el-form-item>
        <el-form-item label="Key Words" prop="param">
          <el-input
            v-model.trim="queryOptions.param"
            style="min-width: 200px;"
            placeholder="Title/Account"
          />
        </el-form-item>
        <el-form-item label="Status" class="form-more">
          <el-select v-model="queryOptions.status" placeholder="Choose">
            <el-option label="all" value></el-option>
            <el-option label="active" value="1"></el-option>
            <el-option label="passed" value="2"></el-option>
            <el-option label="failed" value="3"></el-option>
            <el-option label="excuted" value="4"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click.stop="handleSearch">Search</el-button>
          <el-button type="warning" @click.stop="handleReset">Reset</el-button>
        </el-form-item>
      </el-form>
    </div>
    <div class="title">
      <h2>Proposal List</h2>
      <el-button type="success" plain @click.stop="handleCreate">Create a Proposal</el-button>
    </div>
    <div class="proposal-content">
      <el-table
        ref="ProposalTable"
        :data="proposalData.list"
        v-loading="loading"
        :empty-text="proposalData.emptyText"
      >
        <el-table-column label="Title" prop="title" width="600"></el-table-column>
        <el-table-column label="Created By" prop="createdBy" width="500"></el-table-column>
        <el-table-column label="Create Time" prop="createTime" width="250" sortable>
          <template slot-scope="scope">
            <div v-html="formatTimestamp(scope.row.createTime)"></div>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="Status">
          <!-- <template slot-scope="scope">
            <span v-if="scope.row.status == 'passed'" style="color: #03b615;">passed</span>
            <span v-else>failed</span>
          </template>-->
        </el-table-column>
        <el-table-column align="right">
          <template slot-scope="scope">
            <el-button size="mini" type="primary" @click="showDetails(scope.row)">Open</el-button>
          </template>
        </el-table-column>
      </el-table>
      <div class="pagination">
        <el-pagination
          @size-change="getsize"
          @current-change="handlePageChange"
          background
          :current-page.sync="proposalData.page"
          :page-sizes="[10, 25, 50]"
          :page-size="proposalData.size"
          layout="total, prev, pager, next, sizes, jumper"
          :total="proposalData.totalRow"
        ></el-pagination>
      </div>
    </div>

    <!-- Create proposal dialog-->
    <!-- <el-dialog title="Sign Up" :visible.sync="signupDialogVisible" width="20%" center>
      <div class="nns-login">
        <el-form :model="param" :rules="rules" ref="signup" label-width="0px" class="nns-content">
          <el-form-item prop="username">
            <el-input v-model="param.username" placeholder="User Account">
              <el-button slot="prepend" tabindex="-1">
                <i class="el-icon-user" style="font-size: 18px; width: 16px;" />
              </el-button>
            </el-input>
          </el-form-item>
          <el-form-item prop="password">
            <el-input type="password" placeholder="Password" v-model="param.password">
              <el-button slot="prepend" tabindex="-1">
                <i class="el-icon-lock" style="font-size: 18px; width: 16px;" />
              </el-button>
            </el-input>
          </el-form-item>
          <el-form-item prop="passwordCfm">
            <el-input
              type="password"
              placeholder="Confirm Password"
              v-model="param.passwordCfm"
              @keyup.enter.native="submitSignupForm()"
            >
              <el-button slot="prepend" tabindex="-1">
                <i class="el-icon-lock" style="font-size: 18px; width: 16px;" />
              </el-button>
            </el-input>
          </el-form-item>
          <div class="login-dlg-btn">
            <el-button type="primary" ref="signupBtn" @click="submitSignupForm()">Sigh Up</el-button>
          </div>
        </el-form>
      </div>
    </el-dialog>-->
  </div>
</template>

<script>
import moment from "moment";
import nnsexplorer from "ic:canisters/nnsexplorer";
import nnsexplorerSim from "ic:canisters/nnsexplorer_sim";
export default {
  components: {},
  data() {
    return {
      loading: false,
      dateRange: "",
      queryOptions: {
        param: "",
        page: 1,
        size: 10,
        startDate: "",
        endDate: "",
        status: "",
      },
      proposalData: {
        page: 1,
        size: 10,
        totalRow: 0,
        list: [],
        emptyText: "No Data",
      },
      dialogVisible: false,
      dialogContent: {},
      selectList: [],
      rowId: "",
    };
  },
  computed: {},
  watch: {
    dateRange(val) {
      this.queryOptions.startDate = val ? val[0] : "";
      this.queryOptions.endDate = val ? val[1] : "";
    },
  },
  created() {
    const end = moment().format("YYYY-MM-DD");
    const start = moment().subtract("months", 3).format("YYYY-MM-DD");
    this.dateRange = [start, end];
    this.queryOptions.startDate = start;
    this.queryOptions.endDate = end;
  },
  methods: {
    formatTimestamp(timeUnix) {
      return moment.unix(timeUnix).format("YYYY-MM-DD hh:mm:ss");
    },
    dialogReset() {
      this.dialogContent = {};
      this.dialogVisible = false;
    },
    getsize(size) {
      this.queryOptions.size = size;
      this.queryOptions.page = 1;
      this.requestList("search");
    },
    async requestList(tag) {
      this.loading = true;
      const results = await nnsexplorer.getProposalList();
      var list = JSON.parse(results);
      this.proposalData.list = [];
      for (var i = 0; i < list.length; i++) {
        const title = list[i]["Title"];
        const createdBy = list[i]["Created By"];
        const createTime = list[i]["Create Time"];
        const status = list[i]["Status"];
        const proposalID = list[i]["Proposal ID"];
        const excutionTime = list[i]["Excution Time"];

        const proposalItem = {
          title: title,
          createdBy: createdBy,
          createTime: createTime,
          status: status,
          proposalID: proposalID,
          excutionTime: excutionTime,
        };
        this.proposalData.list.push(proposalItem);
      }

      this.loading = false;
    },
    handlePageChange(val) {
      if (!val) return;
      this.queryOptions.page = val;
      this.requestList("search");
    },
    handleSearch() {
      // TODO
      this.$message.info("Not complete !");
      //this.handlePageChange(1);
    },
    async handleCreate() {
      let username = localStorage.getItem("nns_username");
      if (username) {
        // TODO
        this.$message.info("Waiting to complete ...");
        const ret = await nnsexplorerSim.createTestProposal();
        this.requestList();
        this.$message.success("A RANDOM proposal created for test!");
      } else {
        this.$message.error("You should login first!");
      }
    },
    handleReset() {
      this.queryOptions = this.$options.data().queryOptions;
      this.dateRange = "";
      this.requestList();
    },
    showDetails(item) {
      // TODO
      this.$message.info("Not complete !");
      //   this.dialogContent = item
      //   this.dialogVisible = true
      //   this.rowId = item.id
      //   if (item.status) return
      //   changeStatus({
      //     contactId: item.id,
      //   })
      //   item.status = !item.status
    },
    addkeyWordsColor(list) {
      list.forEach((dataRow) => {
        return Object.keys(dataRow).forEach((key) => {
          if (["index", "createTime", "status", "id"].includes(key)) return;
          if (
            String(dataRow[key]).toLowerCase().includes(this.queryOptions.param)
          ) {
            dataRow[key] = String(dataRow[key]).replace(
              this.queryOptions.param,
              `<font color="#409eff">${this.queryOptions.param}</font>`
            );
          }
        });
      });
    },
  },
  mounted() {
    this.requestList();
  },
};
</script>

<style scoped>
.proposal-page {
  background: #ffffff;
  padding: 20px 0;
}

.proposal-page .search {
  padding: 20px 30px;
}

.proposal-page .title {
  display: flex;
  width: 96%;
  height: 32px;
  line-height: 40px;
  padding: 10px 30px;
  border-bottom: 1px solid #eeeeee;
  justify-content: space-between;
  margin-bottom: 20px;
}

.proposal-page .title h2 {
  font-size: 20px;
}

.proposal-page .proposal-content {
  padding: 0 30px;
  position: relative;
}

.proposal-page .dialog-btn {
  display: flex;
  justify-content: center;
}

.pagination {
  margin-top: 15px;
  text-align: right;
}
</style>