module.exports = {
  content: [
    "./src/**/*.rs",
  ],
  theme: {
    extend: {
      keyframes: {
        highlight: {
          '0%': {
            background: '#8f8',
          },
          '100%': {
            background: 'auto',
          },
        }
      },
      animation: {
        highlight: 'highlight 1s',
      }
    },
  },
  plugins: [],
}
