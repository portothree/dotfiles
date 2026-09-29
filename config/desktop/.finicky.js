module.exports = {
  defaultBrowser: "Google Chrome",      
  handlers: [
    {
      match: /^https:\/\/gitlab\..*\.com\/.*$/,
      browser: "Google Chrome Canary"
    }
  ]
}
