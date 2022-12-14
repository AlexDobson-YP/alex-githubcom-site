@api
Feature: Checking Drupal logs

  Check the important Drupal logs to ensure they are empty.

  Background:
    Given I am logged in as a user with the "Administrator" role
    And I am at "admin/reports/dblog"

  Scenario: Emergency log messages
    When I select "Emergency" from "severity[]"
    And I press "Filter"
    Then the response should contain "No log messages available."

  Scenario: Alert log messages
    When I select "Alert" from "severity[]"
    And I press "Filter"
    Then the response should contain "No log messages available."

  Scenario: Critical log messages
    When I select "Critical" from "severity[]"
    And I press "Filter"
    Then the response should contain "No log messages available."
