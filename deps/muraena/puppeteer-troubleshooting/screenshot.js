/**
 * @name screenshots
 *
 * @desc Snaps a basic screenshot of website homepage and saves it a .png file.
 *
 * @see {@link https://github.com/GoogleChrome/puppeteer/blob/master/docs/api.md#screenshot}
 */

const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch()
  const page = await browser.newPage()
  await page.setViewport({ width: 1280, height: 800 })
  await page.goto('https://example.com/')
  await page.screenshot({ path: 'screenshot.png', fullPage: true })
  await browser.close()
})()
