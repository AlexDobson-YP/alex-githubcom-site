@api
@smoke
Feature: Drupal Sanity Checks

  Sanity checks for the Drupal site.

  Scenario: The home page loads and is the front path
    Given I go to the homepage
    Then I should be in the "<front>" path

  Scenario: Drupal generates a 404 response
    Given I am an anonymous user
    And I am on "some-not-existing-page"
    Then the response status code should be 404

  Scenario: Drupal generates a 403 response
    Given I am an anonymous user
    And I am on "/admin"
    Then the response status code should be 403

  Scenario: I can log in and logout.
    Given I am an anonymous user
    And I am on "/user/login"
    Then I should see the button "Log in"
    And I should not see the link "Log out"

    Given I am logged in as a user with the "authenticated user" role
    When I visit "/user/login" then the final path should be my user page
