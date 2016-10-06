module IntegrationHelper

  private

  def login_as(user, ref_path = nil)
    employee = user.is_a?(Employee) ? user : employees(user)
    employee.update_passwd!('foobar')
    visit login_path(ref: ref_path)
    fill_in 'user', with: employee.shortname
    fill_in 'pwd', with: 'foobar'
    click_button 'Login'
  end

  # catch some errors occuring now and then in capybara tests
  def timeout_safe
    yield
  rescue Errno::ECONNREFUSED,
    Timeout::Error,
    Capybara::FrozenInTime,
    Capybara::ElementNotFound,
    Selenium::WebDriver::Error::StaleElementReferenceError => e
    skip e.message || e.class.name
  end

  def open_selectize(id, options = {})
    element = find("##{id} + .selectize-control")
    element.find('.selectize-input').click
    element.find('.selectize-input input').set(options[:term]) if options[:term].present?
    if options[:assert_empty]
      page.assert_no_selector('.selectize-dropdown-content')
    else
      page.assert_selector('.selectize-dropdown-content')
      find('.selectize-dropdown-content')
    end
  end

  def selectize(id, value, options = {})
    open_selectize(id, options).find('.selectize-option,.option', text: value).click
  end

  def drag(from_node, *to_node)
    mouse_driver = page.driver.browser.mouse
    mouse_driver.down(from_node.native)
    to_node.each { |node| mouse_driver.move_to(node.native) }
    mouse_driver.up
  end

  def accept_confirmation(expected_message = nil)
    if expected_message.present?
      assert_equal expected_message, page.driver.browser.switch_to.alert.text
    end
    page.driver.browser.switch_to.alert.accept
  end

  def dismiss_confirmation(expected_message = nil)
    if expected_message.present?
      assert_equal expected_message, page.driver.browser.switch_to.alert.text
    end
    page.driver.browser.switch_to.alert.dismiss
  end

  Capybara.add_selector(:name) do
    xpath { |name| XPath.descendant[XPath.attr(:name).contains(name)] }
  end

end
