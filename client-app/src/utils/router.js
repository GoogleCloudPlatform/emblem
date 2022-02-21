import { Router } from '@vaadin/router';

export const initRouter = () => {
  const router = new Router(document.querySelector('main'));

  router.setRoutes([
    {
      path: '/',
      component: 'app-dashboard'
    },
    {
      path: 'campaigns/:campaignId',
      component: 'campaign-page',
      action: async () => {
        await import('../containers/campaign/campaign-page.js');
      }
    },
    {
      path: '(.*)',
      component: 'app-dashboard'
    }
  ]);
};

export default initRouter;

