const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  future: {
    removeDeprecatedGapUtilities: true,
    purgeLayersByDefault: true
  },
  purge: ['./src/**/*.html', './src/**/*.vue'],
  theme: {
    extend: {
      scale: {
        mirror: '-1'
      },
      maxWidth: {
        '4': '4rem'
      },
      spacing: {
        '72': '18rem',
        '80': '20rem'
      },
      padding: {
        '5/6': '83.3333%'
      },
      fontFamily: {
        // sans: ['Inter var', ...defaultTheme.fontFamily.sans]
        sans: ['Nunito', ...defaultTheme.fontFamily.sans]
      }
    }
  },
  variants: {
    visibility: ['group-hover']
  },
  plugins: [
    require('@tailwindcss/ui')({
      layout: 'sidebar'
    })
  ]
}
