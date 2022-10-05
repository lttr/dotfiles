const backgroundColor = '#fdf6e3'
const foregroundColor = '#839496'
const cursorColor = 'rgba(204, 196, 176, 0.7)'
const borderColor = cursorColor

const colors = [
  backgroundColor,
  '#cb4b16', // red
  '#859900', // green
  '#b58900', // yellow
  '#268bd2', // blue
  '#6c71c4', // violet
  '#2aa198', // cyan
  '#657b83', // light gray
  '#586e75', // medium gray
  '#cb4b16', // red
  '#859900', // green
  '#b58900', // yellow
  '#268bd2', // blue
  '#6c71c4', // violet
  '#2aa198', // cyan
  '#ffffff', // white
  foregroundColor,
]

exports.decorateConfig = config => {
  return Object.assign({}, config, {
    foregroundColor,
    backgroundColor,
    borderColor,
    cursorColor,
    colors,
    termCSS: `
      ${config.termCSS || ''}
    `,
    css: `
      ${config.css || ''}
      * {
        -webkit-font-feature-settings: "liga" on, "calt" on, "dlig" on !important;
        text-rendering: optimizeLegibility !important;
      }
      .hyperterm_main {
      	border: transparent !important;
      }
      .cursor-node {
        width: .325rem !important;
      }
      .tabs_list {
        border-color: transparent !important;
      }
      .tab_tab {
        border: transparent !important;
        color: ${foregroundColor} !important;
        background-color: #e6dfcb;
      }
      .tabs_title {
        color: ${foregroundColor} !important;
      }
      .tab_tab.tab_active:before {
        border-bottom: transparent !important;
      }
      .tab_tab.tab_active {
        color: ${foregroundColor} !important;
        background-color: ${backgroundColor};
        border-bottom: none !important;
        font-weight: bold;
      }
      .tabs_nav {
      	background-color: #e6dfcb !important;
      }
      .tabs_borderShim {
      	border: transparent;
      }
      .splitpane_divider {
      	background-color: #e6dfcb !important;
      }
      .header_shape
      {
        color: #657b83;
      }
      .header_appTitle
      {
        color: #657b83;
      }
    `,
  })
}
