# Yellow Pencil Drupal 9 Composer

This repo contains the `composer.json` file used to create a Yellow Pencil Drupal 9 site. This mainly leverages the [drupal_yp_install_profile](https://git.yellowpencil.com/yellowpencil/drupal_yp_install_profile) to intialize the site and setup everything to get started on Drupal 9.

---

* [Getting Started](#gettingstarted)
* [Common Docker Tasks](#commondockertasks)
* [Front-end Development](#frontend)
* [Back-end Development](#backend)
* [Behat Tests](#behattests)

## <a name="gettingstarted"></a>Getting started

### Install Docker & Setup Docker development environment

Docker is a tool designed to make it easier to create, deploy, and run applications by using containers. You might already have Docker on your Mac. If not, you can get Docker from [Docker Store](https://download.docker.com/mac/stable/Docker.dmg).

### Install the docker development environment

[See documentation in the wiki](https://wiki.yellowpencil.com/display/YP/Global+Development+Environment+Setup).

After setting up the YP Global Docker development environment from the above instructions, you will always want to have that running in the background while working with YP Docker sites since that will manage your Pretty URLs.

### Create site with this repo

Navigate to the directory you want to store your project at, for example `~/sites`:
```
cd ~/sites
```

Run the `composer create-project` command to create a new project based on this repository:
```
composer create-project --stability=dev --repository="{\"type\": \"vcs\",\"url\": \"git@git.yellowpencil.com:yellowpencil/d9-site-setup-composer.git\"}" yellowpencil/drupal-9 new-site
```

Note: `new-site` should be replaced with the actual name of the site you are building.

### Process Docker script

After `composer create-project` is run the `composer.json` file in this repository will trigger a script to install a theme. NOTE: this functionality requires Composer 2. If you have Composer 1 you will receive a warning message and you will have to manually update some files to get your local environment working.

This steps this script takes are:

1. Choose the URL Slug you would like to use for your local environment. For example, choosing `yellow-pencil` as the URL slug would result in a local development URL of "https://yellow-pencil.dev.localhost".
2. Put in the slug of the GitHub repo for the project. For example. if the GitHub repository for the project is "https://git.yellowpencil.com/onpoint-webops/yp-onpoint-site" then you should put a repo slug of `yp-onpoint-site`.

And that's all you need to do. From there the script will run and replace the URL slug and repo slug throughout the project automatically so everything is setup correctly.

### Theme installation script

After `composer create-project` is run the `composer.json` file in this repository will trigger a script to install a theme after the process Docker script has run. NOTE: this functionality requires Composer 2. If you have Composer 1 you will receive a warning message - but again, this step is optional so if you do have Composer 1 don't worry about it. The theme can always be manually setup.

The steps the theme installation script takes are:

1. Choose the theme name, this will be used as file names as well as function hook prefixes.
2, Add in the GitHub repository of the project (ie. https://git.yellowpencil.com/onpoint-webops/project-name)

It is also worth noting that this script can be run anytime during the project lifecycle by running:

```
composer run-script install-starter-theme
```

So if you choose not to initialize a starter theme immediately you can always do so later with that command.

That's it! From there the script will run and create the theme for you. Everything will be ready for the front-end developers to start working on the theme.

#### If you were not able to run the process Docker script:

If you don't have Composer 2 installed and were not able to run the process Docker script you will now need to do some manual setup.

1. Create a settings.local.php file:

Download [settings.local.php](https://wiki.yellowpencil.com/download/attachments/86641121/settings.local.php?version=1&modificationDate=1643189488857&api=v2) from the Wiki and place that in the `web/sites/default` folder.

2. Replace placeholder slugs throughout the project:

- Replace `[app-slug]` in `docker-compose.yml`.
- Replace `[app-slug]` in `drush/sites/self.site.yml`.
- Replace `[repo-slug]` in `visual-regression-urls.json`.
- Replace `[repo-slug]` in `web/sites/default/settings.php`.

The `[app-slug]` is the URL Slug you would like to use for your local environment. For example, choosing `yellow-pencil` as the `[app-slug]` would result in a local development URL of "https://yellow-pencil.dev.localhost".

The `[repo-slug]` is the slug of the GitHub repository for the project. For example. if the GitHub repository for the project is "https://git.yellowpencil.com/onpoint-webops/yp-onpoint-site" then you should put a repo slug of `yp-onpoint-site`. This is needed along with the `[app-slug]` because the repository slug is used for a lot of the automated URLs and process in WebOps.

3. Update `HASH_SALT`

Please replace the default **HASH_SALT** value with a new hash salt in the `settings.php` file. You can create a hash salt by running:

```
./vendor/drush/drush/drush eval "var_dump(Drupal\Component\Utility\Crypt::randomBytesBase64(55))"
```

- Replace `[hash-salt]` in `web/sites/default/settings.php` with the output from the above command.

### Setup Docker Containers

Build:
```
docker compose build
```

Install front-end dependencies:
```
docker ocmpose run build npm install
```

Start up the containers:
```
docker compose up -d
```

Go into the Drupal container in order to execute the Install Profile installation command:
```
docker compose exec drupal /bin/bash
```

Install the site profile:
```
drush site-install yp_install_profile --site-name='Drupal 9 Site' --site-mail=do-not-reply@yellowpencil.com --account-name=admin --account-pass=password
```

Remember to switch out the `--site-name` with the actual site name for your project. Also remember as soon as you login to the site and create yourself an account to disable the default admin user created above.

### Login and start working

After the site profile installation completes - login and create yourself a user and start working. Note the default user you created with the profile should not be used when working on the site.

The local development site URL can be viewed in the `docker-compose.yml` file.

---

## <a name="commondockertasks"></a>Common Docker Tasks

Bring containers up:
```
docker compose up -d
```

Bring containers down:
```
docker compose down
```

Bring containers down and reset volumes:
```
docker compose down -v
```

## <a name="frontend"></a>Front-end Development

## <a name="backend"></a>Back-end Development

## <a name="behattests"></a>Behat Tests

[Behat](https://docs.behat.org/en/latest/) is an open source Behavior-Driven Development framework for PHP. It is a tool to support you in delivering software that matters through continuous communication, deliberate discovery and test-automation.

We use it on our sites to ease some of the work from QA - lots of our tests are mundane and can easily be run with automation. That's where we bring Behat tests in.

### How does it work?

When creating a Pull Request, our pipeline will look for the `behat.yml` file in the root of the project. If that file is there then the pipeline knows that it should be running behat tests.

We are leveraging the [Behat Drupal Extension module](https://www.drupal.org/project/drupalextension) to run the majority of our tests. The Drupal Extension is an integration layer between Behat, Mink Extension, and Drupal. It provides step definitions for common testing scenarios specific to Drupal sites. This project's [GitHub repository](https://github.com/jhedstrom/drupalextension) is also a great place for code samples should you need to write any custom tests.

If the pipeline detects it needs to run tests - then it will run the tests that are saved as `.feature` files in the `features/` folder. These files are written in Gherkin.

The language used by the Behat tool is Gherkin, which is a business readable and domain-specific language. Gherkin also serves as a living documentation and reports can be generated to document each test run. This simple whitespace-based language uses simple language words as keywords. Indentations (using space/tab) and line endings define the structure for the test case. Although writing and understanding the language is easy, the end result should focus on enabling better collaboration, efficiency, automation and traceability. Test cases should be written intuitively, focus on important elements, avoid checking duplicate records and use good grammar.

We will also be leveraging Mink in order to test some of our features. Mink is an open source browser controller that simulates a test scenario with the web application. Once the test cases are written, it needs to be executed and emulates user actions.

Behat tests are run as part of the preview builds and will need to be passed in order to merge your pull request.

### How do *I* work with Behat?

Behat is a composer dependency of our project and as such will be installed in the `vendor/bin/` folder. You can interact with it at:
```
vendor/bin/behat
```

Running the above command will run through all your tests (aka `.feature` files). You will get output depending on if the tests have passed or failed.

To get a list of all the available Gherkin statments run:
```
vendor/bin/behat -di
```

This will be extremely useful when you need to what kind of tests are already baked into the Behat Drupal Extension module.

#### Custom Tests

See an example of a custom test in `features/bootstrap/FeatureContext.php` with the function `iVisitThenIShouldBeRedirectedToMyUserPage`. This is a custom test written for the scenario:
```
Given I am logged in as a user with the "authenticated user" role
When I visit "/user/login" then the final path should be my user page
```

which is located in the file `features/sanity-checks.feature`. This should give you a good idea of how you could write a custom test. More information on writing custom tests can be found in this article:
- https://www.specbee.com/blogs/testing-your-drupal-website-just-got-easier-behat-comprehensive-tutorial

#### More Reading
- https://docs.behat.org/en/latest/
- https://docs.behat.org/en/latest/quick_start.html
- https://docs.behat.org/en/latest/guides.html
- https://www.drupal.org/project/drupalextension
- https://behat-drupal-extension.readthedocs.io/en/v4.0.1/
- https://www.specbee.com/blogs/testing-your-drupal-website-just-got-easier-behat-comprehensive-tutorial
- https://www.drupal.org/node/2271009
