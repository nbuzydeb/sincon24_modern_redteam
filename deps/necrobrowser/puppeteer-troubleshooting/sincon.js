/**
 * @name puppeteer temple to troubleshoot.
 *
 * @desc Logs into a web site and screenshot for proof.
 * Set your username, password.
 *
 */
const puppeteer = require('puppeteer')
const screenshot = 'sincon.png';
const USER = 'user1'; 
const PWD = 'password1'; 

(async () => {
const browser = await puppeteer.launch({headless: false})
const page = await browser.newPage()
const url = 'https://sincon.pwnwith.me/login'
await page.setViewport({ width: 1280, height: 800 });

const loadUrl = async function (page, url) {
    try {
        await page.goto(url, {
            timeout: 0,
            waitUntil: ['load', 'domcontentloaded', 'networkidle0', 'networkidle2']
        })
    } catch (error) {
        throw new Error("url " + url + " url not loaded -> " + error)
    }
}

/**
const cookies = []
var cookies = [ // cookie exported by google chrome plugin editthiscookie
await page.setCookie(...cookies);
//const cookiesSet = await page.cookies(url);
//console.log(JSON.stringify(cookiesSet));
**/

await page.goto(url, {
  // networkidle0 comes handy for SPAs that load resources with fetch requests.
  // networkidle2 comes handy for pages that do long-polling or any other side
  // activity
  timeout: 20000,
  waitUntil: ['load', 'domcontentloaded', 'networkidle0', 'networkidle2']
});

// Selector does not work anymore
  await page.click('');
  await page.keyboard.type(USER);

  await page.click('');
  await page.keyboard.type(PWD);

//  await page.click('#login > form > div.auth-form-body.mt-3 > input.btn.btn-primary.btn-block');
  await page.click('')

// Wait until the next page get loaded before to screenshot
  await page.waitForSelector('')
// Screenshot the page we reached.
  await page.screenshot({ path: screenshot })
  browser.close()
 // console.log('Screenshot has been taken!')
  console.log('See screenshot: ' + screenshot)
})()
