# Salesforce Application Case Study

This project contains:

- An Experience Cloud (community) site with a partner-facing application form LWC (`applicationForm`)
- Apex services/controllers to process applications into either a `Lead` or `Opportunity`
- A public Apex REST endpoint for external submissions

## Prerequisites

- Node.js + npm (for linting/formatting and LWC Jest tests)
- Salesforce CLI (`sf`)
- A target org where you can deploy metadata

## Pre-Deployment steps

### 1. Enable Digital Experiences

If Digital Experiences is not enabled in your org:

1. Setup → search for **Digital Experiences** → **Settings**
2. Check **Enable Digital Experiences**
3. Click **Save**

Reference: https://help.salesforce.com/s/articleView?id=experience.networks_enable.htm&type=5

### 2. Enable ExperienceBundle Metadata API

1. Setup → search for **Digital Experiences** → **Settings**
2. Check **Enable ExperienceBundle Metadata API**
3. Click **Save**

### 3. Create the placeholder site

1. Setup → search for **All Sites**
2. Click **New**
3. Select **Build Your Own (Aura)**
4. Click **Get Started**
5. Name: **Partner Applications**
6. Click **Create**

## Deploy

Deploy the components:

**NOTE:** replace <YOUR_DEFAULT_ORG> with the org alieas you want to deploy.

```sh
sf project deploy start --source-dir force-app --target-org <YOUR_DEFAULT_ALIAS>
```

## Post-deployment

### Publish the site

1. Setup → search for **All Sites**
2. Click **Builder** for **Partner Applications**
3. Click **Publish**

### Activate the site

1. Setup → search for **All Sites**
2. Click **Workspaces** for **Partner Applications**
3. **Administration** → **Activate**

## How does the webhook works?

To execute the webhook, please follow these instructions:

Open Postman (or any other tool) and set:

1. Method: **POST**
2. URL: `https://<your-community-domain>/services/apexrest/external/applications`
3. Headers:
   - `Content-Type: application/json`
   - `Accept: application/json`
4. Body (raw JSON):

```json
{
  "companyName": "Acme Corp",
  "federalTaxId": "123456789",
  "contact": {
    "firstName": "Ivan",
    "lastName": "Ivanov",
    "email": "ivan@example.com",
    "phone": "+359888123456"
  },
  "annualRevenue": 500000
}
```

## Assumptions

- On the application form, all inputs are required except `annualRevenue`.

## How to access the form?

In order to access the Application form, you can just open refer to the following link:
`https://<your-community-domain>/s/application-form`

Here is an example:

https://mindful-hawk-k9alf-dev-ed.trailblaze.my.site.com/s/application-form
