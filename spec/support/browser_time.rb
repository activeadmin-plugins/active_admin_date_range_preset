# Every preset the plugin offers is derived from one "now", read once when
# date_range_ext_preset() runs. Pinning that value is the only way to assert a
# specific calendar day, so install the stub through CDP before any of the
# page's own scripts run rather than after the plugin has already read the
# clock.
module BrowserTime
  def freeze_browser_time(iso)
    source = <<~JS
      (function () {
        var Real = Date;
        var frozen = #{iso.to_json};
        function Frozen() {
          if (arguments.length === 0) { return new Real(frozen); }
          return new (Function.prototype.bind.apply(Real, [null].concat(Array.prototype.slice.call(arguments))))();
        }
        Frozen.prototype = Real.prototype;
        Frozen.now = function () { return new Real(frozen).getTime(); };
        Frozen.parse = Real.parse;
        Frozen.UTC = Real.UTC;
        window.Date = Frozen;
      })();
    JS

    @frozen_time_script = cdp_page.command(
      'Page.addScriptToEvaluateOnNewDocument', source: source
    )['identifier']
  end

  def unfreeze_browser_time
    return if @frozen_time_script.nil?

    cdp_page.command(
      'Page.removeScriptToEvaluateOnNewDocument', identifier: @frozen_time_script
    )
    @frozen_time_script = nil
  end

  private

  def cdp_page
    page.driver.browser.page
  end
end

RSpec.configure do |config|
  config.include BrowserTime, type: :feature
  config.after(:each, type: :feature) { unfreeze_browser_time }
end
