module.exports = {
  // Scan every rendered deck: multiple presentations can be served at once
  // and they share this one stylesheet.
  content: ['./current.html', './current-*.html'],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      colors: {
        zenable: {
          bg: '#101828',
          'bg-light': '#1D2939',
          teal: '#00BAAE',
          'teal-dark': '#063D49',
          blue: '#0071DA',
        }
      }
    },
  },
}
