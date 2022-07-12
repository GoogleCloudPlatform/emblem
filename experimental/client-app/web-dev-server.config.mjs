// Copyright 2022 Google LLC
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

import { fromRollup } from '@web/dev-server-rollup';
import rollupReplace from '@rollup/plugin-replace';

const replace = fromRollup(rollupReplace);
const hmr = process.argv.includes('--hmr');
const env = process.env.NODE_ENV;
const theme = process.env.THEME;

export default /** @type {import('@web/dev-server').DevServerConfig} */ ({
  open: '/',
  watch: !hmr,
  nodeResolve: {
    exportConditions: ['browser', 'development']
  },
  plugins: [
    replace({
      include: ['src/utils/config.js'],
      preventAssignment: false,
      '__env__': env || 'development',
      '__theme__': theme || 'default', // one of cymbal or default
      '__api_url__': process.env.API_URL,
      '__auth_api_url__': process.env.AUTH_API_URL,
      '__client_id__': process.env.CLIENT_ID,
      '__client_secret__': process.env.CLIENT_SECRET,
      '__site_url__': process.env.SITE_URL,
      '__redirect_uri__': process.env.REDIRECT_URI
    }),
  ]
});
