import Vue from 'vue'
import VueRouter from 'vue-router'
import Session from '../components/session/NewSession'
// import Dashboard from '../components/Dashboard'
// import NewOrganization from '../components/org/NewOrganization'
import Campaign from '../components/campaign/Campaign'
import Campaigns from '../components/campaign/Campaigns'
// import NewCampaign from '../components/campaign/NewCampaign'
import Profile from '../components/profile/Profile'
import Profiles from '../components/profile/Profiles'
import Controls from '../components/control/Controls'
import Sources from '../components/Sources'
import Admin from '../components/admin/Admin'
import NotFound from '../components/shared/NotFound'

Vue.use(VueRouter)

const routes = [
  {
    path: '/signin',
    name: 'NewSession',
    component: Session
  },
  // {
  //   path: '/organizations/new',
  //   name: 'New Organization',
  //   component: NewOrganization
  // },
  // {
  //   path: '/campaigns/new',
  //   name: 'New Campaign',
  //   component: NewCampaign
  // },
  // {
  //   path: '/campaigns/:campaign_id/results',
  //   name: 'Issues',
  //   component: Issues
  // },
  // {
  //   path: '/campaigns/:campaign_id/profiles/:profile_id',
  //   name: 'CampaignProfile',
  //   component: Profile
  // },
  {
    path: '/campaigns/:campaign_id',
    name: 'campaign',
    component: Campaign
  },
  {
    path: '/campaigns',
    name: 'campaigns',
    component: Campaigns
  },
  {
    path: '/profiles/:profile_id',
    name: 'profile',
    component: Profile
  },
  {
    path: '/profiles',
    name: 'profiles',
    component: Profiles
  },
  {
    path: '/controls',
    name: 'controls',
    component: Controls
  },
  {
    path: '/sources',
    name: 'sources',
    component: Sources
  },
  {
    path: '/admin',
    name: 'admin',
    component: Admin
  },
  {
    path: '/',
    component: Profiles
  },
  { path: '*', component: NotFound }
]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
})

export default router
