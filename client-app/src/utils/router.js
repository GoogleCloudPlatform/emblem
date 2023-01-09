// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import { Router } from '@vaadin/router';
import auth from './auth.js';

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
      path: 'campaigns/:campaignId/donate',
      component: 'donation-page',
      action: async () => {
        await import('../containers/donation/donation-page.js');
      }
    },
    {
      path: '/auth/:authPath',
      component: 'app-dashboard',
      action: async ({ params }) => {
        auth[params.authPath]();
      }
    },
    {
      path: '(.*)',
      component: 'app-dashboard'
    }
  ]);
};

export default initRouter;

