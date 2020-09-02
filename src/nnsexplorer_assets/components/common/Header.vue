<template>
  <div class="header">
    <!-- Sidebar collapse button -->
    <div class="collapse-btn" @click="collapseChage">
      <i v-if="!collapse" class="el-icon-s-fold" style="font-size: 24px;"></i>
      <i v-else class="el-icon-s-unfold" style="font-size: 24px;"></i>
    </div>
    <div class="logo">DFINITY NNS Explorer</div>
    <div class="header-right">
      <div class="header-user-con">
        <!-- Messages -->
        <div v-if="loggedin" class="btn-bell">
          <el-tooltip
            effect="dark"
            :content="message?`Unread messages(${message})`:`messages`"
            placement="bottom"
          >
            <router-link to="/tabs">
              <i class="el-icon-bell"></i>
            </router-link>
          </el-tooltip>
          <span class="btn-bell-badge" v-if="message"></span>
        </div>
        <!-- User avatar -->
        <div class="user-avator">
          <img v-if="loggedin" src="../../assets/img/img.jpg" />
        </div>
        <!-- Signup button -->
        <el-button
          v-if="!loggedin"
          type="text"
          size="medium"
          class="btn-login"
          @click="signupDialogVisible = true"
        >Sign Up</el-button>
        <!-- Login button -->
        <el-button
          v-if="!loggedin"
          type="text"
          size="medium"
          class="btn-login"
          @click="loginDialogVisible = true"
        >Login</el-button>
        <!-- Dropdown menu-->
        <el-dropdown v-if="loggedin" class="user-name" trigger="click" @command="handleCommand">
          <span class="el-dropdown-link">
            {{username}}
            <i class="el-icon-caret-bottom"></i>
          </span>
          <el-dropdown-menu slot="dropdown">
            <!-- <a href="https://github.com/hashquark-io/nnsExplorer" target="_blank">
              <el-dropdown-item command="profile">Profile</el-dropdown-item>
            </a>-->
            <el-dropdown-item command="profile">Profile</el-dropdown-item>
            <el-dropdown-item divided command="logout">Logout</el-dropdown-item>
          </el-dropdown-menu>
        </el-dropdown>
      </div>
    </div>

    <!-- Signup dialog-->
    <el-dialog title="Sign Up" :visible.sync="signupDialogVisible" width="20%" center>
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
    </el-dialog>

    <!-- Login dialog-->
    <el-dialog title="Login" :visible.sync="loginDialogVisible" width="20%" center>
      <div class="nns-login">
        <el-form :model="param" :rules="rules" ref="login" label-width="0px" class="nns-content">
          <el-form-item prop="username">
            <el-input v-model="param.username" placeholder="User Account">
              <el-button slot="prepend" tabindex="-1">
                <i class="el-icon-user" style="font-size: 18px; width: 16px;" />
              </el-button>
            </el-input>
          </el-form-item>
          <el-form-item prop="password">
            <el-input
              type="password"
              placeholder="Password"
              v-model="param.password"
              @keyup.enter.native="submitLoginForm()"
            >
              <el-button slot="prepend" tabindex="-1">
                <i class="el-icon-lock" style="font-size: 18px; width: 16px;" />
              </el-button>
            </el-input>
          </el-form-item>
          <div class="login-dlg-btn">
            <el-button type="primary" ref="loginBtn" @click="submitLoginForm()">Login</el-button>
          </div>
        </el-form>
      </div>
    </el-dialog>
  </div>
</template>
<script>
import bus from "./bus";
import nnsexplorer from "ic:canisters/nnsexplorer";
export default {
  data() {
    return {
      signupDialogVisible: false,
      loginDialogVisible: false,
      collapse: false,
      name: "visitor",
      message: 0,
      recompute: false,
      waiting: false,
      param: {
        useraccount: "",
        username: "",
        password: "",
        passwordCfm: "",
      },
      rules: {
        username: [
          {
            required: true,
            message: "Please enter a user name",
            trigger: "blur",
          },
        ],
        password: [
          {
            required: true,
            message: "Please enter a password",
            trigger: "blur",
          },
        ],
        passwordCfm: [
          {
            required: true,
            message: "Please enter the password again",
            trigger: "blur",
          },
        ],
      },
    };
  },
  computed: {
    loggedin() {
      let username = localStorage.getItem("nns_username");
      if (this.recompute) {
        this.recompute = false;
      }
      return username ? true : false;
    },
    username() {
      let username = localStorage.getItem("nns_username");
      if (this.recompute) {
        this.recompute = false;
      }
      return username ? username : this.name;
    },
  },
  methods: {
    // User account dropdown menu
    handleCommand(command) {
      if (command == "logout") {
        localStorage.removeItem("nns_username");
        this.recompute = true;
      } else if (command == "profile") {
        this.$router.push({ name: "profile", params: {} });
      }
    },
    // Sidebar collapse
    collapseChage() {
      this.collapse = !this.collapse;
      bus.$emit("collapse", this.collapse);
    },
    // Sign up creates a private key encrypted by specific user name with password (now it's not complete)
    submitSignupForm: async function () {
      this.$refs.signup.validate(async (valid) => {
        if (valid) {
          if (this.param.password !== this.param.passwordCfm) {
            this.$message.error("The confirm password should be the same!");
            return false;
          }

          this.$refs.signupBtn.disabled = true;
          this.$message.info("Waiting to complete ...");
          if (this.param.useraccount !== "") {
            if (await nnsexplorer.existAccount(this.param.useraccount)) {
              this.$message.error(
                "You have already signed up with the same private key!"
              );
              this.$refs.signupBtn.disabled = false;
              return false;
            }
          } else {
            this.$message.error(
              "It seems that you don't have a valid private key!"
            );
            this.$refs.signupBtn.disabled = false;
            return false;
          }

          const accountAddr = this.param.useraccount;
          const accountName = this.param.username;
          const signature = this.param.password; // use password rather than signature for test
          const balance = 20000 + Math.floor(Math.random() * 50000); // use random value for test
          const rewards = 0;
          const isDelegator = false;
          const res = await nnsexplorer.signup({
            accountAddr,
            signature,
            balance,
            rewards,
            isDelegator,
          });
          if (res) {
            this.$refs.signupBtn.disabled = false;
            this.signupDialogVisible = false;
            this.$message.success("Signed up successfully!");
            localStorage.setItem("nns_usersigned", this.param.username);

            // Automatically login
            localStorage.setItem("nns_username", this.param.username);
            this.recompute = true;

            this.param.username = "";
            this.param.password = "";
            this.param.passwordCfm = "";
          } else {
            this.$refs.signupBtn.disabled = false;
            this.$message.success("Failed to signed up!");
          }
        } else {
          this.$message.error("Please enter required value!");
          this.$refs.signupBtn.disabled = false;
          return false;
        }
      });
    },
    submitLoginForm: async function () {
      this.$refs.login.validate(async (valid) => {
        if (valid) {
          let usersigned = localStorage.getItem("nns_usersigned");
          if (this.param.username !== usersigned) {
            this.$message.error("Wrong user name or password!");
            return false;
          }

          this.$refs.loginBtn.disabled = true;
          if (this.param.useraccount !== "") {
            // use password rather than password instead for test
            if (
              (await nnsexplorer.verifyAccount(
                this.param.useraccount,
                this.param.password
              )) === false
            ) {
              this.$message.error("Wrong user name or password!");
              this.$refs.loginBtn.disabled = false;
              return false;
            }
          }

          this.loginDialogVisible = false;
          localStorage.setItem("nns_username", this.param.username);
          this.recompute = true;

          this.$message.success("Logged in successfully!");
          this.$refs.loginBtn.disabled = false;
          this.param.username = "";
          this.param.password = "";
        } else {
          this.$message.error("Please enter required value!");
          return false;
        }
      });
    },
  },
  created: async function () {
    this.param.useraccount = await nnsexplorer.getcid(); // Use cid rather than account address for test
    if (this.param.useraccount === "") {
      this.$message.error("It seems that you don't have a valid private key!");
    } else {
      localStorage.setItem("nns_useraccount", this.param.useraccount);

      const existaccount = await nnsexplorer.existAccount(
        this.param.useraccount
      );
      if (!existaccount) {
        localStorage.removeItem("nns_username");
        this.recompute = true;
      }
    }
  },
  mounted() {
    if (document.body.clientWidth < 1500) {
      this.collapseChage();
    }
  },
};
</script>
<style scoped>
.header {
  position: relative;
  box-sizing: border-box;
  width: 100%;
  height: 70px;
  font-size: 22px;
  color: #fff;
}
.collapse-btn {
  float: left;
  padding: 0 21px;
  cursor: pointer;
  line-height: 70px;
}
.header .logo {
  float: left;
  width: 250px;
  line-height: 70px;
}
.header-right {
  float: right;
  padding-right: 50px;
}
.header-user-con {
  display: flex;
  height: 70px;
  align-items: center;
}
.btn-bell {
  position: relative;
  width: 30px;
  height: 30px;
  text-align: center;
  border-radius: 15px;
  cursor: pointer;
}
.btn-bell-badge {
  position: absolute;
  right: 0;
  top: -2px;
  width: 8px;
  height: 8px;
  border-radius: 4px;
  background: #f56c6c;
  color: #fff;
}
.btn-bell .el-icon-bell {
  color: #fff;
}
.btn-login {
  color: #fff;
}
.user-name {
  margin-left: 10px;
}
.user-avator {
  margin-left: 20px;
}
.user-avator img {
  display: block;
  width: 40px;
  height: 40px;
  border-radius: 50%;
}
.el-dropdown-link {
  color: #fff;
  cursor: pointer;
}
.el-dropdown-menu__item {
  text-align: center;
}

.nns-login {
  position: relative;
  left: 50%;
  top: 50%;
  width: 350px;
  margin: 0px 0 0 -175px;
  border-radius: 5px;
  background: rgba(255, 255, 255, 0.3);
  overflow: hidden;
}
.nns-content {
  padding: 0px 30px;
}
.login-dlg-btn {
  text-align: center;
}
.login-dlg-btn button {
  width: 100%;
  height: 36px;
  margin-bottom: 10px;
  font-size: 15px;
  font-weight: bold;
}
</style>
