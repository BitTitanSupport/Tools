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

chrome.browserAction.setIcon({path:"icon1.png"});

function updateIcon() {
  chrome.tabs.getSelected(null,function(ctab) {
    tab = ctab;
    urlObj = {urlText : tab.url};

    chrome.tabs.executeScript(tab.id, { code: 'var urlObj = ' + JSON.stringify(urlObj) + '; var cntDoubleClick = ' + cntDoubleClick + ';'}, function() { chrome.tabs.executeScript(tab.id, {file: 'contentscript.js'});});
    cntDoubleClick = '1';
  });

  chrome.browserAction.setIcon({path:"icon2.png"});
  timeoutID = window.setTimeout(function (){
    cntDoubleClick = '0';
    chrome.browserAction.setIcon({path:"icon1.png"});
  }, 1500);
}

chrome.browserAction.onClicked.addListener(updateIcon);

chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
    // sent from another content script, intended for opening new tab
    if(request.action === 'open_new_tab') {
        chrome.tabs.create({"url": request.tabURL});
    }
});
