<?php

use Drupal\DrupalExtension\Context\RawDrupalContext;
use Behat\Behat\Context\SnippetAcceptingContext;

/**
 * Defines application features from the specific context.
 */
class FeatureContext extends RawDrupalContext implements SnippetAcceptingContext {

  /**
   * Initializes context.
   *
   * Every scenario gets its own context instance.
   * You can also pass arbitrary arguments to the
   * context constructor through behat.yml.
   */
  public function __construct() {}

  /**
   * Assert current page is specified path.
   *
   * Note that "<front>" is supported as path.
   *
   * @code
   * Then I should be in the "/about-us" path
   * Then I should be in the "<front>" path
   * @endcode
   *
   * @Then I should be in the :path path
   */
  public function pathAssertCurrent($path) {
    $current_path = $this->getSession()->getCurrentUrl();
    $current_path = parse_url($current_path, PHP_URL_PATH);
    $current_path = ltrim($current_path, '/');
    $current_path = $current_path == '' ? '<front>' : $current_path;

    if ($current_path != ltrim($path, '/')) {
      throw new \Exception(sprintf('Current path is "%s", but expected is "%s"', $current_path, $path));
    }
  }

  /**
   * Visit a path and assert the final destination.
   *
   * Useful for pages with redirects.
   *
   * @code
   * When I visit "/node/123" then the final URL should be "/about/us"
   * @endcode
   *
   * @When I visit :path then the final URL should be :alias
   */
  public function pathAssertWithRedirect($path, $alias) {
    $this->getSession()->visit($this->locatePath($path));
    $this->pathAssertCurrent($alias);
  }

  /**
   * Visit a path and assert the final destination is a user page.
   *
   * @code
   * I visit "/user/login" then the final path should be my user page
   * @endcode
   *
   * @When I visit :path then the final path should be my user page
   */
  public function iVisitThenIShouldBeRedirectedToMyUserPage($path) {
    $this->getSession()->visit($this->locatePath($path));

    $current_path = $this->getSession()->getCurrentUrl();
    $current_path = parse_url($current_path, PHP_URL_PATH);
    $current_path = ltrim($current_path, '/');
    $check_pattern = preg_match("/\buser\/[1-100]\b/i", $current_path);

    if ($check_pattern === FALSE) {
      throw new \Exception(sprintf('Current path is "%s", but expected pattern is "/user/<id>"', $current_path));
    }
  }

}
