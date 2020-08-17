import Vue from 'vue';
import App from './App.vue';
import router from './router';
import ElementUI from 'element-ui';
import VueI18n from 'vue-i18n';
import { messages } from './components/common/i18n';
import 'element-ui/lib/theme-chalk/index.css';
// import './assets/css/theme-green/index.css';
import './assets/css/icon.css';
import 'babel-polyfill';

//Vue.config.productionTip = false;
Vue.use(VueI18n);
Vue.use(ElementUI, {
    size: 'small'
});
const i18n = new VueI18n({
    locale: 'zh',
    messages
});

router.beforeEach((to, from, next) => {
    document.title = `${to.meta.title} | DFINITY NNS Explorer`;
    // const role = localStorage.getItem('nns_useraccount');
    // if (!role && to.path !== '/login') {
    //     next('/login');
    // } else if (to.meta.permission) {
    //     // TODO
    //     role === 'admin' ? next() : next('/403');
    // } else {
    //     if (navigator.userAgent.indexOf('MSIE') > -1 && to.path === '/editor') {
    //         Vue.prototype.$alert('vue-quill-editor组件不兼容IE10及以下浏览器，请使用更高版本的浏览器查看', '浏览器不兼容通知', {
    //             confirmButtonText: '确定'
    //         });
    //     } else {
    //         next();
    //     }
    // }
    if (navigator.userAgent.indexOf('MSIE') > -1 && to.path === '/editor') {
        Vue.prototype.$alert('vue-quill-editor组件不兼容IE10及以下浏览器，请使用更高版本的浏览器查看', '浏览器不兼容通知', {
            confirmButtonText: '确定'
        });
    } else {
        next();
    }
});

new Vue({
    router,
    i18n,
    render: h => h(App)
}).$mount('#app');