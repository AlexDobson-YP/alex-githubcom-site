/**
 * Entry point for Webpack
 */

// Import CSS
import './scss/_styles.scss';

// Import JS
import './js/app.js';

// Import SVGs for sprites
function requireAll(r) {
  r.keys().forEach(r);
}

requireAll(require.context('./images/sprites/', true, /\.svg$/));
