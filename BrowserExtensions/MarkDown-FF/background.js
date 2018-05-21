// Copyright (c) 2011 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

var tab;
var origTitleText = '';
var origUrlText = '';
var urlObj = {};
var tabId = 0;
var objChange = {};
var objTab = '';
var cntDoubleClick = '0';

browser.browserAction.setIcon({ path: "icon1.png" });

function updateIcon() {
  function logTabs(tabs) {
    for (let tab of tabs) {
      // tab.url requires the `tabs` permission
      urlObj = { urlText: tab.url };
      browser.tabs.executeScript(tab.id, { code: 'var urlObj = ' + JSON.stringify(urlObj) + '; var cntDoubleClick = ' + cntDoubleClick + ';' }, function () { browser.tabs.executeScript(tab.id, { file: 'contentscript.js' }); });
      cntDoubleClick = '1';
    }
  }

  function onError(error) {
    console.log(`Error: ${error}`);
  }

  var querying = browser.tabs.query({ currentWindow: true, active: true });
  querying.then(logTabs, onError);

  // browser.tabs.getSelected(null,function(ctab) {
  //   tab = ctab;
  //   urlObj = {urlText : tab.url};

  //   browser.tabs.executeScript(tab.id, { code: 'var urlObj = ' + JSON.stringify(urlObj) + '; var cntDoubleClick = ' + cntDoubleClick + ';'}, function() { browser.tabs.executeScript(tab.id, {file: 'contentscript.js'});});
  //   cntDoubleClick = '1';
  // });

  browser.browserAction.setIcon({ path: "icon2.png" });
  timeoutID = window.setTimeout(function () {
    cntDoubleClick = '0';
    browser.browserAction.setIcon({ path: "icon1.png" });
  }, 1500);
}

browser.browserAction.onClicked.addListener(updateIcon);

browser.runtime.onMessage.addListener(function (request, sender, sendResponse) {
  // sent from another content script, intended for opening new tab
  if (request.action === 'open_new_tab') {
    var creating = browser.tabs.create({ "url": request.tabURL });
  }
});
