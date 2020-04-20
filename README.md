# I18n to S3

ruby on jets project that takes your translation base file from a repository, generate the other languages with google translate and upload them to S3.

## Prerequisites

You can test this project locally with the following:
* Ruby 2.5.*
* `jets` gem
* AWS account with a S3 bucket
* Google Cloud Platform account

You have to set some ENV variables to make this work:
```bash
GOOGLE_CLOUD_KEY=-google cloud key- # to translate with google translate
BRANCHES=staging:master # all the branches you want to generate translation files separated by ":"
GITHUB_TOKEN=-github token- # to take the base file from your repo (add repo scope)
AWS_KEY=-aws key- # to upload and check existing translations
AWS_SECRET=-aws secret- # to upload and check existing translations
LANGUAGES=pt:es:fr # all the languages you want to generate translation files separated by ":"
S3_BUCKET=-s3 bucket name- # the bucket to upload translation files
AWS_REGION_DEFAULT=-aws default region- # region of S3 bucket
# if you want to have a custom domain
HOSTED_ZONE_NAME=-hosted zone- # available hosted zone on aws route 53
DOMAIN_NAME=-domain name- # subdomain (ex: i18n.mydomain.com)
CERT_ARN==-cert arn- # you can use a public certificate from aws
```
These variables need to be defined on an .env file at the root of the project to be set on the lamdba. If you want to test it locally, you can set them manually or use something like [direnv](https://direnv.net/)

After that, you can run `jets deploy` to deploy your app to AWS

## Settings

You have your base file on your Github repository (it can be either `yaml` or `json`)

Example: `en.json`

```
{
  "commons": {
    "next": "next",
    "previous": "previous",
    "skip": "skip"
  }
}
```

Example: `en.yml`
```
en:
  commons:
    next: next
    previous: previous
    skip: skip
```

It doesn't matter where the file is in the project's folder, you will pass that path as an parameter to the lambda (this is to reuse the lambda when necessary)

After that, go to the lambda on your AWS account, look out for `i18n-to-s3-ENV-translations_controller-new`, go there, and copy the URL of the API gateway trigger, as you'll use it to create the webhook on Github

![lambda api gateway](https://i.imgur.com/vTHovhn.jpg)

If you added a custom domain for your app, it will run directly the lambda function adding just `/new` to the custom domain

* `https://sub.mydomain.com/new`

Then, go to your Github repository > Settings > Webhooks, and add one with the URL you just copied; then, you have to add a query param for the path of the base file you have on your repository, such as:

* `https://lambda-api-gateway-url?path=translations/en.json`
* `https://lambda-api-gateway-url?path=config/locales/en.yaml`
* `https://sub.mydomain.com/new?path=translations/en.json`
* `https://sub.mydomain.com/new?path=config/locales/en.yaml`


![github webhook](https://i.imgur.com/tVkwPTj.png)

Your github access token needs to be created with repo hook activated

![github access token](https://i.imgur.com/YcRAGxh.png)

## How it works

Every time you push to the repo, Github will send a `POST` request to your lambda; this will check if the base file was created/modified during the latest push to generate or update translation files

The lambda will generate a translated file for every language on your S3 bucket with the following naming convention:

`GITHUBUSER/REPONAME/BRANCH/language.FORMAT`

 After that, you can use those translated files on your app

### Comments

* The app will run a lambda for every file that needs to be generated; if you have es, fr, and pt, it will run 3 lambdas, 1 to generate each file; this way you will have several small, dedicated processes, rather than a big one.

* If a translated file is already generated, it will be updated with the missing keys, as to avoid overwriting the previous ones.

## Todo 

* Visual editor for generated files, allowing future corrections if a translation isn't accurate or if it's wrong
* Testing
