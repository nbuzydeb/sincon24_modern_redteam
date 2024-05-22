const aws = require("aws-sdk");
const fs = require("fs");

// Your S3 bucket from earlier. Make sure you use the same name
// used in serverless.yml
const BUCKET = process.env.BUCKET_NAME;

// hardcoded 
//const BUCKET = "pwnppeteer";


// uploadScreenshot takes a temporary file path and returns a URL
exports.uploadScreenshot = async function uploadScreenshot(
    path,
    screenshot,
    resize = false 
) {
		// aws-sdk is all callback-based so we have to wrap in Promises, yuck
    return new Promise((resolve, reject) => {
        const s3 = new aws.S3({
            apiVersion: "2006-03-01"
        });

            (async function() {
                const buffer = await new Promise((resolve, reject) => {
		                // reading the file
                    fs.readFile(path, (err, data) => {
                        if (err) reject(err);
                        resolve(data);
                    });
                });

								// uploading the file buffer
                const { Location } = await s3
                    .upload({
                        Bucket: BUCKET,
                        Key: `${screenshot}-${new Date().getTime()}.png`,
                        Body: buffer,
                      // Set the approriate ACL that fit your need
                        ACL: "public-read"
                    })
                    .promise();

                resolve(Location);
            })();
    });
};
