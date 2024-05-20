/**
 * @name Github-SSHkey_persistence
 *
 * @desc Logs into Github, add ssh recovery key and screenshot for proof.
 * Set your username, password and ssh key.
 *
 */
const puppeteer = require('puppeteer')
const screenshot = 'github.png';
const GITHUB_USER = 'test-account';
const GITHUB_PWD = 'P@ssw0rd';

(async () => {
const browser = await puppeteer.launch({headless: false})
const page = await browser.newPage()
const url = 'https://github.com/login'
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
// Set Cookie instead to log-in
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

// Log-in on Github
// Use selectors
  await page.click('#login_field');
  await page.keyboard.type(GITHUB_USER);

  await page.click('#password');
  await page.keyboard.type(GITHUB_PWD);

//  await page.click('#login > form > div.auth-form-body.mt-3 > input.btn.btn-primary.btn-block');
  await page.click('input.btn')
/*
  // GOTO SSH new key page
  await page.goto('https://github.com/settings/ssh/new')
  await page.click('#ssh_key_title');
  //await page.click("body > div.application-main > main > div > div.Layout.Layout--flowRow-until-md.Layout--sidebarPosition-start.Layout--sidebarPosition-flowRow-start > div.Layout-main > div > div > form > dl:nth-child(2) > dd > input");
  await page.keyboard.type('recovery-key');

  await page.click('#ssh_key_key');
  //await page.click('body > div.application-main > main > div > div.Layout.Layout--flowRow-until-md.Layout--sidebarPosition-start.Layout--sidebarPosition-flowRow-start > div.Layout-main > div > div > form > dl:nth-child(4) > dd > textarea');
  await page.keyboard.type('ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmcG/kI8N+h2hU6BrRCqJf+EUY2EyblEy2sZR4bBuyCcNYuB3PojxokVYinHTdNQXQ/T1DYfiikaxt3/dlMT/53vgWPYk6AvzvmUPdg33SH+EFECo2trpkJbN/wYldFqMYssq2PrF1nE8Ey0H4z/aFw5Ih6S3c6m2gyKcCK38esbGhDlcYK2wj9/2L/AtvOZK2jTkL4GqEUOszzE9UgOq6Xy1NapUNrmzMoRtnnn8WlNnF6oBk2hFKo5A+Qc6vxsPC4YqAFbJ0JoQg5uL+eWh48Nzh4rCYuKljAHTBCTgzT3J30cq1a0dOzQPHaEFALLl/GKtluS36UjOQ+y2y08oL test_only');

  await page.click('#settings-frame > form > p > button');
  //await page.click("body > div.application-main > main > div > div.Layout.Layout--flowRow-until-md.Layout--sidebarPosition-start.Layout--sidebarPosition-flowRow-start > div.Layout-main > div > div > form > p > button");
//
//Consider to add WaitForSelector to be sure the page is loaded before the next action
*/
  await page.screenshot({ path: screenshot })
  browser.close()
 // console.log('SSH key added :p')
  console.log('See screenshot: ' + screenshot)
})()
