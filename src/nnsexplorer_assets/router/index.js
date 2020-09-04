import Vue from 'vue';
import Router from 'vue-router';
import Home from '../components/common/Home.vue';
import Overview from '../components/page/Overview.vue';
import NeuronInfo from '../components/page/NeuronInfo.vue';
import Proposals from '../components/page/Proposals.vue';
import Profile from '../components/page/Profile.vue';
import I18n from '../components/page/I18n.vue';
import P404 from '../components/page/404.vue';

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
                    name: 'overview',
                    component: Overview,
                    meta: { title: 'Overview' }
                },
                {
                    path: '/neuronInfo',
                    name: 'neuronInfo',
                    component: NeuronInfo,
                    meta: { title: 'Neuron Details' }
                },
                {
                    path: '/profile',
                    name: 'profile',
                    component: Profile,
                    meta: { title: 'profile' }
                },
                {
                    path: '/proposals',
                    name: 'proposals',
                    component: Proposals,
                    meta: { title: 'proposals' }
                },
                // {
                //     // 中英文切换组件
                //     path: '/i18n',
                //     component: I18n,
                //     meta: { title: '中英文切换' }
                // },
                {
                    path: '/404',
                    component: P404,
                    meta: { title: '404' }
                },
            ]
        },
        {
            path: '*',
            redirect: '/404'
        }
    ]
});