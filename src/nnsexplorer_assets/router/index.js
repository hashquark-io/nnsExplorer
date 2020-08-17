import Vue from 'vue';
import Router from 'vue-router';
import Home from '../components/common/Home.vue';
import Overview from '../components/page/Overview.vue';
import BaseForm from '../components/page/BaseForm.vue';
import Markdown from '../components/page/Markdown.vue';
import I18n from '../components/page/I18n.vue';
import P404 from '../components/page/404.vue';
import P403 from '../components/page/403.vue';

Vue.use(Router);

export default new Router({
    routes: [{
            path: '/',
            redirect: '/overview'
        },
        {
            path: '/',
            component: Home,
            meta: { title: '自述文件' },
            children: [{
                    path: '/overview',
                    component: Overview,
                    meta: { title: 'Overview' }
                },
                {
                    path: '/form',
                    component: BaseForm,
                    meta: { title: '基本表单' }
                },
                {
                    // markdown组件
                    path: '/markdown',
                    component: Markdown,
                    meta: { title: 'markdown编辑器' }
                },
                {
                    // 国际化组件
                    path: '/i18n',
                    component: I18n,
                    meta: { title: '国际化' }
                },
                {
                    path: '/404',
                    component: P404,
                    meta: { title: '404' }
                },
                {
                    path: '/403',
                    component: P403,
                    meta: { title: '403' }
                }
            ]
        },
        {
            path: '*',
            redirect: '/404'
        }
    ]
});