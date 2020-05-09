@api @provisioning_api-app-required
Feature: disable user
  As an admin
  I want to be able to disable a user
  So that I can remove access to files and resources for a user, without actually deleting the files and resources

  Background:
    Given using OCS API version "1"

  @smokeTest
  Scenario: admin disables an user
    Given user "user0" has been created with default attributes and skeleton files
    When the administrator disables user "user0" using the provisioning API
    Then the OCS status code should be "100"
    And the HTTP status code should be "200"
    And user "user0" should be disabled

  @skipOnOcV10.3
  Scenario Outline: admin disables an user with special characters in the username
    Given these users have been created with skeleton files:
      | username   | email   |
      | <username> | <email> |
    When the administrator disables user "<username>" using the provisioning API
    Then the OCS status code should be "100"
    And the HTTP status code should be "200"
    And user "<username>" should be disabled
    Examples:
      | username | email               |
      | a@-+_.b  | a.b@example.com     |
      | a space  | a.space@example.com |

  @smokeTest
  Scenario: Subadmin should be able to disable an user in their group
    Given these users have been created with default attributes and skeleton files:
      | username |
      | user0    |
      | subadmin |
    And group "brand-new-group" has been created
    And user "subadmin" has been added to group "brand-new-group"
    And user "user0" has been added to group "brand-new-group"
    And user "subadmin" has been made a subadmin of group "brand-new-group"
    When user "subadmin" disables user "user0" using the provisioning API
    Then the OCS status code should be "100"
    And the HTTP status code should be "200"
    And user "user0" should be disabled

  Scenario: Subadmin should not be able to disable an user not in their group
    Given these users have been created with default attributes and skeleton files:
      | username |
      | user0    |
      | subadmin |
    And group "brand-new-group" has been created
    And group "another-group" has been created
    And user "subadmin" has been added to group "brand-new-group"
    And user "user0" has been added to group "another-group"
    And user "subadmin" has been made a subadmin of group "brand-new-group"
    When user "subadmin" disables user "user0" using the provisioning API
    Then the OCS status code should be "997"
    And the HTTP status code should be "401"
    And user "user0" should be enabled

  Scenario: Subadmins should not be able to disable users that have admin permissions in their group
    Given these users have been created with default attributes and skeleton files:
      | username |
      | subadmin |
      | newadmin |
    And group "brand-new-group" has been created
    And user "newadmin" has been added to group "admin"
    And user "subadmin" has been added to group "brand-new-group"
    And user "newadmin" has been added to group "brand-new-group"
    And user "subadmin" has been made a subadmin of group "brand-new-group"
    When user "subadmin" disables user "newadmin" using the provisioning API
    Then the OCS status code should be "997"
    And the HTTP status code should be "401"
    And user "newadmin" should be enabled

  Scenario: Admin can disable another admin user
    Given user "newadmin" has been created with default attributes and skeleton files
    And user "newadmin" has been added to group "admin"
    When the administrator disables user "newadmin" using the provisioning API
    Then the OCS status code should be "100"
    And the HTTP status code should be "200"
    And user "newadmin" should be disabled

  Scenario: Admin can disable subadmins in the same group
    Given user "subadmin" has been created with default attributes and skeleton files
    And group "brand-new-group" has been created
    And user "subadmin" has been added to group "brand-new-group"
    And the administrator has been added to group "brand-new-group"
    And user "subadmin" has been made a subadmin of group "brand-new-group"
    When the administrator disables user "subadmin" using the provisioning API
    Then the OCS status code should be "100"
    And the HTTP status code should be "200"
    And user "subadmin" should be disabled

  Scenario: Admin user cannot disable himself
    Given user "newadmin" has been created with default attributes and skeleton files
    And user "newadmin" has been added to group "admin"
    When user "newadmin" disables user "newadmin" using the provisioning API
    Then the OCS status code should be "101"
    And the HTTP status code should be "200"
    And user "newadmin" should be enabled

  Scenario: disable an user with a regular user
    Given these users have been created with default attributes and skeleton files:
      | username |
      | user0    |
      | user1    |
    When user "user0" disables user "user1" using the provisioning API
    Then the OCS status code should be "997"
    And the HTTP status code should be "401"
    And user "user1" should be enabled

  Scenario: Subadmin should not be able to disable himself
    Given user "subadmin" has been created with default attributes and skeleton files
    And group "brand-new-group" has been created
    And user "subadmin" has been added to group "brand-new-group"
    And user "subadmin" has been made a subadmin of group "brand-new-group"
    When user "subadmin" disables user "subadmin" using the provisioning API
    Then the OCS status code should be "101"
    And the HTTP status code should be "200"
    And user "subadmin" should be enabled

  @smokeTest
  Scenario: Making a web request with a disabled user
    Given user "user0" has been created with default attributes and skeleton files
    And user "user0" has been disabled
    When user "user0" sends HTTP method "GET" to URL "/index.php/apps/files"
    Then the HTTP status code should be "403"
