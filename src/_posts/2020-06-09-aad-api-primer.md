---
layout: post
title:  A Primer for Calling Azure Active Directory Secured APIs
date:   2020-06-09
image: /images/2020-05-23-winget.png
categories: published aad security api tsi adt
---

Calling APIs is easy, right? Well, maybe.  A simple `curl` request is easy, and reading an API spec is easy, but getting an access token to that API can be pretty hard sometimes.  Gone are the days of long-lived static access tokens we just bury in headers.  For security we need strictly scoped access tokens with specific permissions to specific services that rotate frequently, and that actually makes things pretty tough. In this post I'll cover how to effectively use and develop against APIs that are secured with Azure Active Directory - things like Azure Resource Manager, Azure KeyVault, Time Series Insights, Azure Digital Twins, etc, though most of the concepts can apply to any modern API!

## It's all open.

Nothing of the underlying technologies I'll talk about in this post are prorietary to Microsoft.  Azure Active Directory is buit on open source cloud native authentication technologies such as OAuth, Open ID Connect, SAML, etc.  There are a lot of tools we've built to make leveraging these things *easy*, especially in Azure, but the underlying foundations are all the same open source protocols you'd see in any modern web or desktop application.

## The Token

Before I dive into how to get one, I think it's good to understand what an access token is. Understanding what a token is made up of provides a good foundation for why the whole process works.

At first glance, a token is just a blob of data.  Let's take a look at one that I generated for my user to access Time Series Insights:

```
eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IlNzWnNCTmhaY0YzUTlTNHRycFFCVEJ5TlJSSSIsImtpZCI6IlNzWnNCTmhaY0YzUTlTNHRycFF
CVEJ5TlJSSSJ9.eyJhdWQiOiJodHRwczovL2FwaS50aW1lc2VyaWVzLmF6dXJlLmNvbS8iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5O
DhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWF0IjoxNTkxNzE4MjMyLCJuYmYiOjE1OTE3MTgyMzIsImV4cCI6MTU5MTcyMjEzMiwiYWNy
IjoiMSIsImFpbyI6IkFWUUFxLzhQQUFBQU83bDlQY0E4YllhMkNOcXY4cWkvVHpycjUxbTJzbHg5YzlsajN4dDRTeUsrb1VxWEVrcGVjMkExRUQ3OWxVOFp
5QUIvd2ZiOUxEeGxzY0syUFZhNWdEaGFQY1ZPRHVXeWY4Tm5oN3MzQnh3PSIsImFtciI6WyJ3aWEiLCJtZmEiXSwiYXBwaWQiOiIwNGIwNzc5NS04ZGRiLT
Q2MWEtYmJlZS0wMmY5ZTFiZjdiNDYiLCJhcHBpZGFjciI6IjAiLCJmYW1pbHlfbmFtZSI6IkxvcmljaCIsImdpdmVuX25hbWUiOiJKb2V5IiwiaW5fY29yc
CI6InRydWUiLCJpcGFkZHIiOiIxOTguOTAuMTI3LjY1IiwibmFtZSI6IkpvZXkgTG9yaWNoIiwib2lkIjoiMDcxNmQ4YmMtNjYxNC00YmNjLWJjYjUtMTEz
YzIyMThmZjBkIiwib25wcmVtX3NpZCI6IlMtMS01LTIxLTEyNDUyNTA5NS03MDgyNTk2MzctMTU0MzExOTAyMS0xODIxNzgwIiwicHVpZCI6IjEwMDMzRkZ
GQUExOUQ0QTAiLCJyaCI6IjAuQVJvQXY0ajVjdkdHcjBHUnF5MTgwQkhiUjVWM3NBVGJqUnBHdS00Qy1lR19lMFlhQUJZLiIsInNjcCI6InVzZXJfaW1wZX
Jzb25hdGlvbiIsInN1YiI6IjVtYWtRVHNjVmNhMjQ5SXJOVWFzT1VSWkxZeWJLVW1UZll2QW1IUjZ5eVEiLCJ0aWQiOiI3MmY5ODhiZi04NmYxLTQxYWYtO
TFhYi0yZDdjZDAxMWRiNDciLCJ1bmlxdWVfbmFtZSI6ImpvbG9yaWNoQG1pY3Jvc29mdC5jb20iLCJ1cG4iOiJqb2xvcmljaEBtaWNyb3NvZnQuY29tIiwi
dXRpIjoiYU1TMk5uR3R1MG1HWk9ydnpaa2hBQSIsInZlciI6IjEuMCJ9.RnCB9s9jHNUjQChXHR-HXIukwpqZ9cGsrxIZ8vYIeul07hboNKi00ISjHf47uF
WrY-FDfJnUSIrtGvOsokgiwbiS0boFmfZ8_TLYXm5WWuP3ZT0YmdeK_jQzLM8DYp1KeppACyz2f5FyroHsfQQb0SzpxquItqSknUDHeHWpQsxQ01C-_6Yl6
ZvFW9vEHqcxp1dLbYUbyDm9hFFmg6i3BaSWaUpKAqwQVKy3_-oYqCD0iRglfASXqYkEGxv-M6handSG2GR-E_s-HIewbZfHq8hWCBQeoqLVCWoQsYYnjGXt
4Ge7WdNt46pnJIx9PkKhYJtLddnd8Z6OmdMLAzz_Xg
```

A clever developer might look at that and go: "hey! that looks like base64" and they'd be right.  Access tokens generated by OIDC and hence AAD conform to the JWT (JSON Web Token) standard, and as such are mostly just base64 encoded JSON.  If we slap that token into a base64 decoder we can see the results:

```
{
    "typ": "JWT",
    "alg": "RS256",
    "x5t": "SsZsBNhZcF3Q9S4trpQBTByNRRI",
    "kid": "SsZsBNhZcF3Q9S4trpQBTByNRRI"
}
{
    "aud": "https://api.timeseries.azure.com/",
    "iss": "https://sts.windows.net/72f988bf-86f1-41af-91ab-2d7cd011db47/",
    "iat": 1591718232,
    "nbf": 1591718232,
    "exp": 1591722132,
    "acr": "1",
    "aio": "AVQAq/8PAAAAO7l9PcA8bYa2CNqv8qi/Tzrr51m2slx9c9lj3xt4SyK+oUqXEkpec2A1ED79lU8ZyAB/wfb9LDxlscK2PVa5gDhaPcVODu",
    "amr": [
        "wia",
        "mfa"
    ],
    "appid": "04b07795-8ddb-461a-bbee-02f9e1bf7b46",
    "appidacr": "0",
    "family_name": "Lorich",
    "given_name": "Joey",
    "in_corp": "true",
    "ipaddr": "198.90.127.65",
    "name": "Joey Lorich",
    "oid": "0716d8bc-6614-4bcc-bcb5-113c2218ff0d",
    "onprem_sid": "S-1-5-21-124525095-708259637-1543119021-1821780",
    "puid": "10033FFFAA19D4A0",
    "rh": "0.ARoAv4j5cvGGr0GRqy180BHbR5V3sATbjRpGu-4C-eG_e0YaABY.",
    "scp": "user_impersonation",
    "sub": "5makQTscVca249IrNUasOURZLYybKUmTfYvAmHR6yyQ",
    "tid": "72f988bf-86f1-41af-91ab-2d7cd011db47",
    "unique_name": "jolorich@microsoft.com",
    "upn": "jolorich@microsoft.com",
    "uti": "aMS2NnGtu0mGZOrvzZkhAA",
    "ver": "1.0"
}
Fpc#@(W\zt4Є;UcC|HH"Ѻ|2^nVZe=׊43,bJz@,r},ƫ@xuBPP%[1WKm9QfiJJT %|3ZԆd~>mǫV	
j'egYmg$}>B`Ku񞎙<^
```

There's a lot of information in here, but what's really important to notice is the audience (`aud`), the application (`appid`), the issuer (`iss`), and that random bit of gibberish down towards the end.  This token effectively is saying the `issuer` (The Microsoft Azure AD Employee Tenant) has approved access to the `audience` (the Time Series Insights API) via the `application` (in my example that's the ID for the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure)), and that approval is proved by a cryptographic signature at the end (the "random" seeming gibberish, which is really RSA SHA-256 output).

Every `issuer` in an OIDC infrastructure has a Public/Private key pair (see [PKI](https://en.wikipedia.org/wiki/Public_key_infrastructure)).  Tokens are signed with a private key, and can be validated with corresponding public key. This allows an application like Time Series Insights to look at that access token and go "hey, I've been configured to trust that application and issuer, I'll let this request in!".


There are some great tools out there for parsing/debugging JWTs.  Take a look at [jwt.io](https://jwt.io/#debugger-io?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IlNzWnNCTmhaY0YzUTlTNHRycFFCVEJ5TlJSSSIsImtpZCI6IlNzWnNCTmhaY0YzUTlTNHRycFFCVEJ5TlJSSSJ9.eyJhdWQiOiJodHRwczovL2FwaS50aW1lc2VyaWVzLmF6dXJlLmNvbS8iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWF0IjoxNTkxNzE4MjMyLCJuYmYiOjE1OTE3MTgyMzIsImV4cCI6MTU5MTcyMjEzMiwiYWNyIjoiMSIsImFpbyI6IkFWUUFxLzhQQUFBQU83bDlQY0E4YllhMkNOcXY4cWkvVHpycjUxbTJzbHg5YzlsajN4dDRTeUsrb1VxWEVrcGVjMkExRUQ3OWxVOFp5QUIvd2ZiOUxEeGxzY0syUFZhNWdEaGFQY1ZPRHVXeWY4Tm5oN3MzQnh3PSIsImFtciI6WyJ3aWEiLCJtZmEiXSwiYXBwaWQiOiIwNGIwNzc5NS04ZGRiLTQ2MWEtYmJlZS0wMmY5ZTFiZjdiNDYiLCJhcHBpZGFjciI6IjAiLCJmYW1pbHlfbmFtZSI6IkxvcmljaCIsImdpdmVuX25hbWUiOiJKb2V5IiwiaW5fY29ycCI6InRydWUiLCJpcGFkZHIiOiIxOTguOTAuMTI3LjY1IiwibmFtZSI6IkpvZXkgTG9yaWNoIiwib2lkIjoiMDcxNmQ4YmMtNjYxNC00YmNjLWJjYjUtMTEzYzIyMThmZjBkIiwib25wcmVtX3NpZCI6IlMtMS01LTIxLTEyNDUyNTA5NS03MDgyNTk2MzctMTU0MzExOTAyMS0xODIxNzgwIiwicHVpZCI6IjEwMDMzRkZGQUExOUQ0QTAiLCJyaCI6IjAuQVJvQXY0ajVjdkdHcjBHUnF5MTgwQkhiUjVWM3NBVGJqUnBHdS00Qy1lR19lMFlhQUJZLiIsInNjcCI6InVzZXJfaW1wZXJzb25hdGlvbiIsInN1YiI6IjVtYWtRVHNjVmNhMjQ5SXJOVWFzT1VSWkxZeWJLVW1UZll2QW1IUjZ5eVEiLCJ0aWQiOiI3MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDciLCJ1bmlxdWVfbmFtZSI6ImpvbG9yaWNoQG1pY3Jvc29mdC5jb20iLCJ1cG4iOiJqb2xvcmljaEBtaWNyb3NvZnQuY29tIiwidXRpIjoiYU1TMk5uR3R1MG1HWk9ydnpaa2hBQSIsInZlciI6IjEuMCJ9.RnCB9s9jHNUjQChXHR-HXIukwpqZ9cGsrxIZ8vYIeul07hboNKi00ISjHf47uFWrY-FDfJnUSIrtGvOsokgiwbiS0boFmfZ8_TLYXm5WWuP3ZT0YmdeK_jQzLM8DYp1KeppACyz2f5FyroHsfQQb0SzpxquItqSknUDHeHWpQsxQ01C-_6Yl6ZvFW9vEHqcxp1dLbYUbyDm9hFFmg6i3BaSWaUpKAqwQVKy3_-oYqCD0iRglfASXqYkEGxv-M6handSG2GR-E_s-HIewbZfHq8hWCBQeoqLVCWoQsYYnjGXt4Ge7WdNt46pnJIx9PkKhYJtLddnd8Z6OmdMLAzz_Xg&publicKey=-----BEGIN%20PUBLIC%20KEY-----%0AMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuHPewhg4WC3eLVPkEFlj%0A7RDtaKYWXCI5G%2BLPVzsMKOuIu7qQQbeytIA6P6HT9%2FiIRt8zNQvuw4P9vbNjgUCp%0AI6vfZGsjk3XuCVoB%2FbAIhvuBcQh9ePH2yEwS5reR%2BNrG1PsqzobnZZuigKCoDmuO%0Ab%2FUDx1DiVyNCbMBlEG7UzTQwLf5NP6HaRHx027URJeZvPAWY7zjHlSOuKoS%2Fd1yU%0AveaBFIgZqPWLCg44ck4gvik45HsNVWT9zYfT74dvUSSrMSR%2BSHFT7Hy1XjbVXpHJ%0AHNNAXpPoGoWXTuc0BxMsB4cqjfJqoftFGOG4x32vEzakArLPxAKwGvkvu0jToAyv%0ASQIDAQAB%0A-----END%20PUBLIC%20KEY-----%0A) to explore this token in depth!



## Getting an access token


#### The easy way

So you need an access token.  That means you'll need an issuer, application, audience, and public and private keys. Complicated right? Not so much.  If you're an Azure user you actually have everything you need already.  The Issuer is going to be your Azure Active Directory tenant and it already has a key pair generated, the audience is whatever you're trying to get an access token for, and the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure) is a registered application ready to give you a token back!

Let's take a look at how easy it is to get an access token scoped to Time Series Insights:

```bash
> az account get-access-token --resource https://api.timeseries.azure.com/
```

```
{
  "accessToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IlNzWnNCTmhaY0YzUT.......",
  "expiresOn": "2020-06-09 10:51:01.598327",
  "subscription": "e97d8b6e-d05b-4507-9c06-f7b528f65f7d",
  "tenant": "e118c529-5bfd-4769-99f5-ff702eb1ef5f",
  "tokenType": "Bearer"
}
```

With just a single command we've had Azure AD issue a new access token for us we can use to call the Time Series Insights APIS.  We just need to add the access token as a Bearer in Authorization field of our API request as follows:

```bash
> curl \
    -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsI...." \
    https://api.timeseries.azure.com/environments?api-version=2016-12-12
```

```
{
    "environments": [
        {
            "displayName": "jl-demo-tsi",
            "environmentId": "1ef23c90-fc07-401f-9bc5-307e879186fe",
            "environmentFqdn": "1ef23c90-fc07-401f-9bc5-307e879186fe.env.timeseries.azure.com",
            "resourceId": "/subscriptions/2033cb47-dd48-4b84-a45d-a58da7fd163a/resourcegroups...",
            "roles": [
                "Reader",
                "Contributor"
            ]
        },
        {
            "displayName": "demo-connected-factory-fit3a-31d648a3da",
            "environmentId": "7266c9ba-7f1e-4fb1-bae3-e24392239f5a",
            "environmentFqdn": "7266c9ba-7f1e-4fb1-bae3-e24392239f5a.env.timeseries.azure.com",
            "resourceId": "/subscriptions/2033cb47-dd48-4b84-a45d-a58da7fd163a/resourcegroups/...x",
            "roles": [
                "Contributor"
            ]
        }
    ]
}
```

Here you can see my two TSI instances I have access to!

#### A more mature way

As you saw you can use the Azure CLI to generate an access token in no time, however in your applications you're often not going to be using the CLI and you sometimes don't want to use a *user's* identity.  Thankfully there's a way to do that too.

Within Azure AD we have the option to *register* an application that we want to be able to Authorize against, we call these App Registrations.  These app registrations are the same OIDC applications I talked about earlier, and Azure AD provides all the standard APIs required for an OIDC provider.  These registrations can be created right from the Azure Portal, or we can use the Azure CLI:

```
>az ad app create --display-name "My Test OIDC App"
```

```
{
  "acceptMappedClaims": null,
  "addIns": [],
  "allowGuestsSignIn": null,
  "allowPassthroughUsers": null,
  "appId": "52c09601-0afd-4823-9b68-0f9973d55462",
  "appLogoUrl": null,
  "appPermissions": null,
  "appRoles": [],
  "applicationTemplateId": null,
  "availableToOtherTenants": false,
  "deletionTimestamp": null,
  "displayName": "My Test OIDC App",
  "errorUrl": null,
  "groupMembershipClaims": null,
  "homepage": null,
  "identifierUris": [],
  "informationalUrls": {
    "marketing": null,
    "privacy": null,
    "support": null,
    "termsOfService": null
  },
  "isDeviceOnlyAuthSupported": null,
  "keyCredentials": [],
  "knownClientApplications": [],
  "logo@odata.mediaContentType": "application/json;odata=minimalmetadata; charset=utf-8",
  "logo@odata.mediaEditLink": "directoryObjects/702b903c-27ef-4090-ad1b-92002050c9d1/Microsoft.DirectoryServices.Application/logo",
  "logoUrl": null,
  "logoutUrl": null,
  "mainLogo@odata.mediaEditLink": "directoryObjects/702b903c-27ef-4090-ad1b-92002050c9d1/Microsoft.DirectoryServices.Application/mainLogo",
  "oauth2AllowIdTokenImplicitFlow": true,
  "oauth2AllowImplicitFlow": false,
  "oauth2AllowUrlPathMatching": false,
  "oauth2Permissions": [
    {
      "adminConsentDescription": "Allow the application to access My Test OIDC App on behalf of the signed-in user.",
      "adminConsentDisplayName": "Access My Test OIDC App",
      "id": "56a20534-63a6-464e-8d94-bda7a19ab63b",
      "isEnabled": true,
      "type": "User",
      "userConsentDescription": "Allow the application to access My Test OIDC App on your behalf.",
      "userConsentDisplayName": "Access My Test OIDC App",
      "value": "user_impersonation"
    }
  ],
  "oauth2RequirePostResponse": false,
  "objectId": "702b903c-27ef-4090-ad1b-92002050c9d1",
  "objectType": "Application",
  "odata.metadata": "https://graph.windows.net/72f988bf-86f1-41af-91ab-2d7cd011db47/$metadata#directoryObjects/@Element",
  "odata.type": "Microsoft.DirectoryServices.Application",
  "optionalClaims": null,
  "orgRestrictions": [],
  "parentalControlSettings": {
    "countriesBlockedForMinors": [],
    "legalAgeGroupRule": "Allow"
  },
  "passwordCredentials": [],
  "preAuthorizedApplications": null,
  "publicClient": null,
  "publisherDomain": "microsoft.onmicrosoft.com",
  "recordConsentConditions": null,
  "replyUrls": [],
  "requiredResourceAccess": [],
  "samlMetadataUrl": null,
  "signInAudience": "AzureADMyOrg",
  "tokenEncryptionKeyId": null,
  "wwwHomepage": null
}
```

Now we have an Issuer (with keys), Application, and Audience - however Azure AD doesn't just let anyone in to any application.  Within Azure we have roles and permissions we need to set to enable someone to use the application.  This is an internal feature to Azure AD and not something specific to OIDC, but it's something commonly implemented at indentity providers.  Thankfully as the apps creator you already have permission to use it.

## App Permissions

Once you have your app created, we'll need to approve Azure AD to sign access tokens for TSI for this application.  This requirement is there because not all administrators want tenants signing tokens for anyone.  You may run need additional approval from an Azure AD Administrator to grant access to these once they've been added.

First query the TSI App ID in your tenant (this was automatically registered when you first stood up TSI from the Azure Portal)

```
> az ad app list --display-name "Time Series Insights" --query [0].appId
```

```
"b9c64278-dd8f-41c6-a5af-d0b83837e5fb"
```

Then query the TSI app read role:

```
> az ad app list --display-name "Time Series Insights" --query [0].oauth2Permissions[0].id
```

```
"e44527c3-994f-43fd-bad6-540797af5227"
```

Now add this role and permission to our application

```
> az ad app permission add \
    --id 52c09601-0afd-4823-9b68-0f9973d55462 \
    --api b9c64278-dd8f-41c6-a5af-d0b83837e5fb \
    --api-permissions e44527c3-994f-43fd-bad6-540797af5227=Scope
```

Note that's *my* app id from earlier, and the API and Role for TSI in *my* tenant.  These won't work for you unless you work at Microsoft :)  Also the =Scope is required on the end of the permission, even though that isn't super clearly documented.

With this Azure AD should be ready to sign our access tokens!

## Getting the access token

As this is OIDC, there's about a million SDKs and programs for getting access tokens.  A great walk through on requesting a token over HTTP is available [here](https://docs.microsoft.com/en-us/graph/auth-v2-user), though Microsoft provides [a robust set of libraries](https://docs.microsoft.com/en-us/azure/active-directory/develop/msal-overview) that will make it super easy.  You'll just need the application id!

## What about non-users?

Often you'll want an application to be able to access data outside of the context of a user, and in Azure you can do that by creating a Service Principal.  You can do that via:

```
> az ad sp create-for-rbac
```

```
{
  "appId": "04476a2b-7a5f-45d7-8168-33e50d5766e3",
  "displayName": "azure-cli-2020-06-10-03-56-12",
  "name": "http://azure-cli-2020-06-10-03-56-12",
  "password": "REDACTED",
  "tenant": "72f988bf-86f1-41af-91ab-2d7cd011db47"
}
```

Once created, you can assign permissions to that app id from anywhere in the Azure Portal you'd typically see permissions.  If we create an access policy on our Time Series Insights database, we can use that appId and password to get a valid access token.  Unline a user flow, which will require a redirect and hopefully two-factor authentication, an [implicit flow](https://oauth.net/2/grant-types/implicit/) can be used where the token will be returned directly.

## Making it easier

While the MSAL libraries are great for *client* login, if we're in a place where we already have Service Principal credentials (or even another way to generate an access token, like [Managed Identities](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview) or the Azure CLI), we can leverage the Azure.Identity SDKs to easily get what we need.  In fact, the Azure.Identity SDK integrates natively with most of the Azure SDKs making access super easy.  You can find you relevant SDKs here:

- [.NET](https://github.com/Azure/azure-sdk-for-net/tree/master/sdk/identity/Azure.Identity)
- [Java](https://search.maven.org/artifact/com.azure/azure-identity)
- [JavaScript/TypeScript](https://www.npmjs.com/package/@azure/identity)
- [Python](https://pypi.org/project/azure-identity/)

This integration makes things so easy that for any enviornment with Managed Identities, a Service Principal ID set in the environment variables, or even locally with the Azure CLI signed in all we have to do to reach out to an AAD authorized services like KeyVault is as follows:

```
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

// Create a secret client using the DefaultAzureCredential
var client = new SecretClient(new Uri("https://myvault.azure.vaults.net/"), new DefaultAzureCredential());
```

Or get a raw access token to a service like TSI as such

```
using System;
using Azure.Core;
using Azure.Identity;


var cred = new DefaultAzureCredential(true);
var options = new TokenRequestContext(
    new[] { "https://api.timeseries.azure.com/" }
);

var accessToken = cred.GetToken(options);
```