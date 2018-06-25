// IIFE to contain variables within NameSpace
(function ()
{
  // Function's global variable to detect double-click from callbacks
  var DOUBLECLICKCOUNT;

  // set icon in browser's toolbar
  browser.browserAction.setIcon({ path: "icon1.png" });

  function ClickActionListerner()
  {
    // Function to pass variables to Content script and execution of text formatting
    function CallContentScript(tabs)
    {
      for (let tab of tabs)
      {
        // Note : tab.url requires the `tabs` permission in manifest.json
        // Setup URLOBJECT to pass to Content script
        URLOBJECT = { urlText: tab.url };

        browser.tabs.executeScript(tab.id, { code: 'var URLOBJECT = ' + JSON.stringify(URLOBJECT) + '; var DOUBLECLICKCOUNT = ' + DOUBLECLICKCOUNT + ';' }).then(browser.tabs.executeScript(tab.id, { file: 'contentscript.js' }));

      }

      // Detect as double-click if next call comes in within time limit
      DOUBLECLICKCOUNT = '1';
    }

    function OnError(error)
    {
      console.log(`Error: ${error}`);
    }

    // Button / hotkey pressed, execute Content script to process text extraction and formatting
    var querying = browser.tabs.query({ currentWindow: true, active: true });
    querying.then(CallContentScript, OnError);

    // Set icon to 'white' as indicator that icon is 'pressed '
    browser.browserAction.setIcon({ path: "icon2.png" });

    // Set time limit to detect double-click as 1.5 seconds
    timeoutID = window.setTimeout(function ()
    {
      // Time limit expired
      DOUBLECLICKCOUNT = '0';

      // Set icon back to default 'black' color
      browser.browserAction.setIcon({ path: "icon1.png" });
    }, 1500);
  }

  // Main entry point - setting up event listener to detect for button click or hotkey for extension's icon
  browser.browserAction.onClicked.addListener(ClickActionListerner);

  // Listener to receive open tab messages from Content sript
  browser.runtime.onMessage.addListener(function (request, sender, sendResponse)
  {
    // Action sent from content script, intended for opening new tab
    if (request.action === 'open_new_tab')
    {
      var creating = browser.tabs.create({ "url": request.tabURL });
    }
  });
})();