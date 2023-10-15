const axios = require("axios");
const { decodeJwt, jwtVerify, createRemoteJWKSet } = require("jose");

module.exports.handler = async (event) => {

  const identitySource = event?.identitySource?.[0];
  const tokenBearer = (identitySource || "").split("Bearer ")

  if (tokenBearer.length != 2) {
    console.info("Invalid Bearer token");
    return formatResponse("Deny", event?.routeArn, "");
  }

  const token = tokenBearer[1];
  const isValid = await validateToken(token);

  if (!isValid) {
    return formatResponse("Deny", event?.routeArn, "");
  }

  const userIdentifier = await getUser(token);

  if (!userIdentifier) {
    return formatResponse("Deny", event?.routeArn, "");
  }

  return formatResponse("Allow", event?.routeArn, userIdentifier);
  
};

var formatResponse = (effect, routeArn, userIdentifier) => {
  return {
    principalId: "user",
    policyDocument: {
      Version: "2012-10-17",
      Statement: [
        {
          Action: "execute-api:Invoke",
          Effect: effect,
          Resource: routeArn,
        },
      ],
    },
    context: {
      userIdentifier: userIdentifier,
    },
  };
};

var validateToken = async (token) => {

  const cognitoId = process.env.COGNITO_ID;
  const clientId = process.env.CLIENT_ID;
  const tokenUse = process.env.TOKEN_USE;
  const issuer = `https://cognito-idp.${process.env.AWS_REGION}.amazonaws.com/${cognitoId}`

  const splitToken = (token || "").split(".");

  if(splitToken.length != 3){
    console.info("Token different size");
    return false
  }

  const decodedToken = decodeJwt(token);

  if(issuer != decodedToken.iss){
    console.info("Invalid Issuer");
    return false
  }

  if(clientId != decodedToken.client_id){
    console.info("Invalid ClientId");
    return false
  }

  if(tokenUse != decodedToken.token_use){
    console.info("Invalid Token Use");
    return false
  }

  try {
    const jwksRemote = await createRemoteJWKSet(new URL(`${issuer}/.well-known/jwks.json`));
    await jwtVerify(token, jwksRemote);
  } catch (error) {
    console.info(error);
    return false
  }

  return true
};

var getUser = async (token) => {

  const config = {
    headers: {
      "X-Amz-Target": "AWSCognitoIdentityProviderService.GetUser",
      "Content-Type": "application/x-amz-json-1.1",
    },
    validateStatus: false,
  };

  const body = {
    AccessToken: token,
  };

  const request = await axios.post(
    `https://cognito-idp.${process.env.AWS_REGION}.amazonaws.com`,
    body,
    config
  );

  if (request.status != 200) {
    return undefined;
  }

  return request?.data?.Username;

};