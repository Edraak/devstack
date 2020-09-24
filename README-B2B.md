## Instructions
### Configuration changes

The following settings must be set:
```json
{
  // DISABLE MARKETING
  "MARKETING_BASE": "", // set to empty
  "MARKETING_SITE_ROOT": "", // set to empty
  "MKTG_URLS": {}, // set to empty object
  "MKTG_URL_LINK_MAP": {}, // set to empty object
  /////////
  "PLATFORM_ABOUT_EN": "Set your new platform about in English",
  "PLATFORM_ABOUT_AR": "Set your new platform about in Arabic",
  "PROGS_BASE": "Set your edraak programs url in your local, for example b2b.edraak.dev",
  "SITE_NAME": "b2b.edraak.dev",
  "SUPPORT_SITE_LINK": "Set to your support link if you have one",
  "LOGO_IMAGE": "name of your logo image file",
  "LMS_BASE": "", // set to empty
  "FOOTER_NAVIGATION_LINKS_EN": {},
  "FOOTER_NAVIGATION_LINKS_AR": {},
  "FOOTER_LEGAL_LINKS_EN": {},
  "FOOTER_LEGAL_LINKS_AR": {},
  "FOOTER_EDRAAK_URL": "",
  "FACEBOOK_APP_ID": "" // Make empty or use client's ID
  "FACEBOOK_API_VERSION": "", // Set to client's app version
  "ENABLE_DASHBOARD_ONBOARDING": false, // Must be empty
  //DISABLE EDX
  "ENABLE_EDX_AUTHENTICATION": false, // Must be empty
  "ENABLE_EDX_PARTIAL_AUTHENTICATION": false, // Must be empty
  //////
  "EMAIL_HOST": "",
  "EMAIL_HOST_PASSWORD": "",
  "EMAIL_HOST_USER": "",
  "ELIBRARY_URL": "" // set to client's Elibrary
  "ELIBRARY_INSTITUTION_ID": "Client elibrary institution ID",
  "ELIBRARY_SALT_KEY": "Client elibrary Salt Key",
  
  //SET THEMING
  "EDRAAK_THEME_ENABLED": true,
  "EDRAAK_THEME_PATH": "/edx/app/progs/themes/",
  "EDX_DRF_EXTENSIONS": {},
  //////
  "CORS_ORIGIN_WHITELIST": [
    //Add your platform url here
  ],}
```

#### Features
Add the following under `FEATURES`:
```json
{
    "EDRAAK_MKTG_LINKS": false,
    "ENABLE_AUTH_EXTERNAL_REDIRECT": true,
    "ENABLE_FOOTER_MOBILE_APP_LINKS": false,
    "ENABLE_MKTG_SITE": false,
    "ENABLE_MYPROGRAM_DISCOVERY": true,
    "PARENT_DASHBOARD": false,
    "TEACHER_DASHBOARD": false,
}
```
#### Databases:
Remove edX database. The MySQL databases should look something like this:
```json
{
    "DATABASES": {
        "default": {
            "ENGINE": "django.db.backends.mysql",
            "HOST": "mysql",
            "NAME": "edraakprograms",
            "PASSWORD": "",
            "PORT": "3306",
            "USER": "root"
        }
    }
}
```
#### Flags to set/unset
```json
  
```

