# yp_drupal8_theme
_This is our starter Drupal 8/9 theme. Some steps are outlined below to get this up and running._
\
&nbsp;

## Getting started
### Automated
Download the [custom bash script for automated theme setup](https://wiki.yellowpencil.com/download/attachments/123185317/fe_setup.sh).

This script may be placed anywhere — you just need to run it from the project directory. It may be run as follows:

```shell
./<path to script>/fe_setup.sh
```

This allows you to have a single copy of this script, so that you don't have to move it around for every project. If you get permission errors, try modifying permissions on the script file:

```shell
chmod +x fe_setup.sh
```

\
&nbsp;
You can also copy this script into `usr/bin/local` and make it executable with:

```shell
chmod a+rx usr/bin/local/fe_setup.sh
```

You will then be able to run `fe_setup.sh` from anywhere on your system.

1. Run the script in your project directory to clone the starter theme and replace all instances of 'yellowpencil' with the theme name you enter. This will also update the repository and homepage URLs for the theme.
1. Continue with step 4 below.
\
&nbsp;

### Manual
1. Move `yp_drupal8_theme` folder into your `/web/themes` folder.
1. When starting a new project: Search and replace `yellowpencil` with the new `theme_name` name. Ensure that all `yellowpencil` file names are updated, as well as instances of `yellowpencil` within the `*.info.yml`, `*libraries.yml`, `*.theme`, and `package.json`.
1. Update the `package.json` file with the proper repository and homepage URLs for your project.
1. Ensure you have [Node.js](https://nodejs.org/en/download/) installed globally on your system. If you require multiple versions of Node.js, consider using [n Node version managment](https://github.com/tj/n).
1. Run the command `npm install`.
1. If you have errors on install your npm version might be either old or to new. This is where `nvm` can help. Or you can try to update the `package.json` to the latest versions.
`npm install -g npm-check-updates`
`ncu -u`
`npm install`
1. Run the command `npm run build-dev` to compile CSS, JS, and SVG sprites, and to handle compression and loading of fonts and images. This command also launches a watch task on your files and starts a development server which auto-reloads changes as you make them.
1. Install theme and set as default.
1. Crush all your custom theming tasks!
\
&nbsp;

## Accordions
Basic accordions are included with this starter theme. These accordions are stateful, meaning that they retain their open/closed state across page loads.

JS functionality for this component may be found within `/js/source/scripts.js` under `/* ACCORDIONS */`.

Styles may be found within `/scss/7-components/_accordions.scss`.
\
&nbsp;

## CSS
The styles contained within `/scss/7-components/_hero.scss` and `/scss/6-skeleton/_navigation.scss` are included *for reference purposes only*. Write your own styles for these components — keeping mobile-first methodology, accessibility, and modularity top of mind.
### AJAX loader
AJAX loader style customizations may be found within `/scss/7-components/_ajax-loader.scss`.
### Image cover
The utility class `image-cover`, enables the following styles for images contained within an element that has this class name, along with a JS fallback for IE11 support. The JS fallback may be found within `/js/source/scripts.js` under `// IE11 workaround for CSS 'object-fit' support`.
```css
.image-cover img {
  display: block;
  object-fit: cover;
  width: 100%;
  height: 100%;
}
```
### Mobile menu toggle
Mobile menu toggle styles may be found within `/scss/7-components/_menu-toggle.scss`. For alternative toggle animation styles, [see here](https://jonsuh.com/hamburgers/). JS functionality for this component may be found within `/js/source/scripts.js` under `/* MOBILE MENU */`.
### Table wrapper
By default, all `table` tags within the `main` element are wrapped in a containing `<div class="table-wrapper">`. This wrapping `div` enables styles that allow tables to overflow on smaller screens, allowing horizontal scrolling — this is done for UI and accessibility purposes.

These styles may be found within `/scss/7-components/_tables.scss`. JS functionality for this component may be found within `/js/source/scripts.js` under `/* WRAP TABLES */`.
### CSS grid
For IE11 support of CSS grid, see the following resources. By default, the webpack configuration contains limited prefixing compatability for IE11, but your code does need to follow certain conventions to properly leverage these defaults.

- [Grid Autoplacement support in IE](https://github.com/postcss/autoprefixer#grid-autoplacement-support-in-ie)
- [CSS Grid in IE: Debunking Common IE Grid Misconceptions](https://css-tricks.com/css-grid-in-ie-debunking-common-ie-grid-misconceptions/)
\
&nbsp;

## Images
### Responsive images
Responsive images are supported in Drupal core by enabling the `Image` and `Responsive Image` modules. Configuration to import basic defaults for responsive image rendering [may be downloaded here](https://wiki.yellowpencil.com/download/attachments/123185317/Responsive%20image%20config.zip?api=v2), or may be included by starting a new project with the [YP Install Profile](https://git.yellowpencil.com/yellowpencil/drupal_yp_install_profile). This configuration includes view modes for output of responsive images, though the display output of each image field will need to be set to utilize one of the view modes in order to actually output `srcset` styles.
### Next-generation image formats
Output for high-compression image formats, such as `WEBP` may be included by installing the [WEBP](https://www.drupal.org/project/webp) module. With responsive images already set up, these modules require no additional configuration beyond installing and enabling them. This module is in a beta release states, so it may not work as expected.

The `WEBP` module is included by default in the YP Install Profile.

\*Note: The `WEBP` and `AVIF` Drupal modules *[do not currently work together](https://www.drupal.org/project/avif/issues/3188912)*.

The AVIF module does not appear to compress images beyond what would be expected for the default reduction in image quality (60% of the source image). It would be advisable to avoid this module until these issues are sorted out, and wider-spread support is available for this image format.

[This patch](https://www.drupal.org/files/issues/2021-05-07/webp-replace-file-exists-call-with-entity-load-to-fix-image-generation-3161795-16.patch) may be necessary for the WEBP module to ensure that it [successfully generates image derivatives](https://www.drupal.org/project/webp/issues/3161795) (as of 1.0-beta5).

### Image optimizations
By default, native HTML lazy loading loading is applied to iFrames and images. No custom configuration is required. There is a JS fallback in place for browsers that do not currently support native HTML lazy loading.

Read more details about optimizing images for the web here:

- [Maximally optimizing image loading for the web](https://www.industrialempathy.com/posts/image-optimizations/)
\
&nbsp;

## JS
### Helper functions
There are a few helper functions in place within `/js/source/scripts.js` that add support for certain features or functions that do not currently exist in JS.

Currently, these helper functions include the following:

- `getSiblings` (function) - gets the sibling elements of an element — taken from [The Vanilla JS Toolkit](https://vanillajstoolkit.com/helpers/getsiblings/)
- `debounce` (function) - limits function calls for events like scroll or window resize
- `lazyLoad` (function)
  - for images and iFrames already within the viewport on load:
    - removes the `loading` (`lazy`) attribute
    - removes the `img-lazy` class (applies to images only)
  - removes the `decoding` (`async`) attribute if not supported by the browser
  - subsequent anonymous functions handle removal of the following from elements — *once fully loaded*:
    - removes the `img-lazy` class from images
    - removes the `loading` (`lazy`) attribute from iFrames
### Polyfills
There are a few polyfills in place within `/js/source/scripts.js` that add support for certain features or functions that are not compatible with some older browsers, and are not included by default with the Babel es5 transpilation.

Currently, these polyfills include the following:

- `array.from` (method) — taken from the official MDN documentation on this method
- `forEach` (method) - this polyfill enables the use of the `forEach` method on `NodeList` objects
- `matches` (method) - enables this method for IE11 and older webkit powered browsers
- `closest` (method) - taken from the official MDN documentation on this method
- `coverImage` (function) - modified [from this source](https://stackoverflow.com/a/37792830) to enable `object-fit: cover;` style image treatment in IE11
- image lazy loading JS fallback — for browsers that don't support native HTML lazy loading but do support `IntersectionObserver`
\
&nbsp;

## Motion preferences
### Animations and transitions
For accessibility purposes, it is advised to implement animations and transitions within your styles in a conditional manner:

```css
@media (prefers-reduced-motion: reduce) {
  /* The user does not want animations. */
}

@media (prefers-reduced-motion: no-preference) {
  /* The user is okay with animations. */
}
```

For JavaScript, consider something like this:

```javascript
// Get prefers reduced media query.
const mediaQuery = window.matchMedia('(prefers-reduced-motion: reduce)');

// Check if media query matches or is not available.
if (!mediaQuery || mediaQuery.matches) {
  doSomethingWithoutAnimation();
} else {
  doSomethingWithAnimation();
}

// Add event listener to check for changes in media query value.
mediaQuery.addEventListener('change', () => {
  if (mediaQuery.matches) {
    doSomethingWithoutAnimation();
  } else {
    doSomethingWithAnimation();
  }
});
```
\
&nbsp;

## Progress bar (batch processing)
This starter theme includes customized scripts and styling for Drupal's native batch processing progress indicator. This customization may be enabled by uncommenting the following function, found within the `yellowpencil.theme` file. You will also need to uncomment `@import 'progress-bar';`, found within `/scss/7-components/__components.scss`.

Further customizations may be built upon this, by modifying the styles found within `/scss/7-components/_progress-bar_.scss`.

```php
/**
 * Implements hook_js_alter().
 */
function yellowpencil_js_alter(&$javascript) {
  if (array_key_exists('core/misc/progress.js', $javascript)) {
    // Override the default progress.js to include additional markup.
    $javascript['core/misc/progress.js']['data'] = \Drupal::theme()->getActiveTheme()->getPath() . '/js/source/progress.js';
  }
}
```
\
&nbsp;

## Scroll to top
This starter theme includes 'scroll to top' functionality and styling. This feature may be enabled by uncommenting the following:
- `<button id="scrollTop">{{ 'Back to top'|t }}</button>` found within `/templates/footer.html.twig`
- `@import 'scroll-top';`, found within `/scss/7-components/__components.scss`
- the code found under `/* SCROLL TOP LINK */` within `/js/source/scripts.js`
\
&nbsp;

## SVGs
### General use
#### Optimization
It is important to optimize all SVGs to be used on the site with a tool such as [ImageOptim](https://imageoptim.com/mac) or [SVGO](https://github.com/svg/svgo) (which can alternatively be [used on the web](https://jakearchibald.github.io/svgomg/)). Ensure that you manually remove any depreciated or extraneous properties or values from the SVG code that may have been missed by your optimization tool.
#### Tab and screen reader accessibility
If your SVG is an icon or and image that should not be tab-accessible (most icons should not be!) and/or hidden from screen readers, you will need to add the following parameters and their associated values to your `svg` tag within the source code of your SVG. If you are referencing an SVG sprite, these parameters and values should be placed within the `svg` tag of the _wrapper_ SVG.

```html
tabindex="-1" focusable="false" aria-hidden="true"
```
#### Accessible SVGs
Including an `alt` tag on an SVG is not a valid method of making the SVG accessible or available to accessibility technologies. SVGs should instead include descriptor text throught the following method. More reading on this [may be found here](https://css-tricks.com/accessible-svgs/#2-inline-svg).

- Inside the `<svg>`, add:
  - `<title>[A short title of the SVG]</title>`
    - must be the first child of it’s parent element
    - will be used as a tooltip as the pointing device moves over it
- A description may be added if needed
  - this is not read by screen readers
- Add the appropriate ID’s to the `<title>` and `<desc>`:
  - `<title id="[uniqueTitleID]">[The title of the SVG]</title>`
  - `<desc id="[uniqueDescID]">[A longer, more complete description for complex graphics.]</desc>`
- On the `<svg>` tag, add:
  - `aria-labelledby="[uniqueTitleID] [uniqueDescID]"` (use the title and description IDs)
    - both title and description are included in `aria-labelledby`, because it has better screen-reader support than `aria-describedby`
- On the `<svg>` tag, add: - `role="img"` (so that the SVG is not traversed by browsers that map the SVG to the group role)
### Sprites
A webpack build process for SVG sprites is included in the starter theme, along with some 'standard' icons that are commonly used. To add additional SVG sprites, simply add the SVG file of your icon or image to `/images/sprites` and trigger the webpack build. This will generate or update a SVG sprites file located at `/dist/sprites.svg`.
### Rendering SVG sprites
By default, the ID of your SVG within the SVG sprite will be the file name of the source SVG. E.g. `angle-left.svg` would be referenced by `#angle-left`.

To render SVGs from the SVG sprite file, use the following convention, making note of the points below on 'Tab and screen reader accessibility', and modifying the parameter values as appropriate for your implementation.

```html
<svg
  viewbox="0 0 [width in unitless pixels] [height in unitless pixels]"
  class="[custom class name, if required]"
>
  <use xlink:href="[sprite ID]"></use>
</svg>
```

E.g.

```html
<svg viewbox="0 0 18 16" class="home_icon">
  <use xlink:href="#home"></use>
</svg>
```
\
&nbsp;
