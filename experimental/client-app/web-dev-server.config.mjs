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
const isFlaskProxy = process.env.FLASK_PROXY;


export default /** @type {import('@web/dev-server').DevServerConfig} */ ({
  open: '/',
  watch: !hmr,
  /** Resolve bare module imports */
  nodeResolve: {
exportConditions: ['browser', 'development']
  },
  plugins: [
    replace({
      include: ['src/utils/config.js'],
      preventAssignment: false,
      '__env__': env || 'development',
      '__api_url__': isFlaskProxy ? 'http://127.0.0.1:5000/api/v1' : 'http://localhost:3000'
    }),
  ]
});
