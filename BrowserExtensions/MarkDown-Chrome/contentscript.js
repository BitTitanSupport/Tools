/*
function executeCopy(text) {
  var input = document.createElement('textarea');
  document.body.appendChild(input);
  input.value = text;
  input.focus();
  input.select();
  document.execCommand('Copy');
  input.remove();
}
*/
function executeCopy(text) {
  const input = document.createElement('textarea');
  input.style.position = 'fixed';
  input.style.opacity = 0;
  input.value = text;
  document.body.appendChild(input);
  input.focus();
  input.select();
  document.execCommand('Copy');
  document.body.removeChild(input);
};

var titleText = '';
var impersonateLinkTxt = '';
var accountName = '';
var projectLinkTxt = '';
var projectName = '';
var itemLinkTxt = '';
var itemName = '';
var itemCount = 0;
var fullInfoTxt = '';
var txtProb, txtImpLink, txtAName, txtANameLink, txtWGNameRaw, txtWGName, txtWGNameBold, txtPName, txtPNameBold, txtItmNames, txtItmNamesBold, txtEndText, itemName;

if (typeof urlObj != 'undefined') {
  origUrlText = urlObj.urlText;
  urlObj.urlText = urlObj.urlText.replace(/\(/g, '\\(');
  urlObj.urlText = urlObj.urlText.replace(/\)/g, '\\)');

  if (urlObj.urlText.indexOf('migrationwiz.bittitan.com') !== -1) {
    var acctNameElm = document.getElementsByClassName("top-banner is-warning")[0];
    if (acctNameElm == null) {
      acctName = "*******";
    } else {
      acctName = acctNameElm.innerText.split(':')[1].trim();
    }
    txtProb = "**Problem Statement**\n\n**Customer Data**\n";
    // txtImpLink = "Impersonation Account: " + "https://internal.bittitan.com/Impersonate/" + acctName + "\n";
    // txtANameLink = "Impersonation Account: " + "[" + acctName + "]" + "(" + "https://internal.bittitan.com/Impersonate/" + acctName + ")\n";
    // txtAName = "**Account Name:** " + acctName + "\n";
    // txtPName = "Project Name: " + "[" + document.getElementById("nav-breadcrumb").innerText.trim() + "]" + "(" + origUrlText + ")\n";
    // txtPNameBold = "**Project Name:** " + "[" + document.getElementById("nav-breadcrumb").innerText.trim() + "]" + "(" + origUrlText + ")\n";

    txtANameLink = "Impersonation Account: " + acctName + "\n";
    txtANameLink = txtANameLink + "Impersonation Link: " + "https://internal.bittitan.com/Impersonate/" + acctName + "\n";
    txtAName = "**Account Name:** " + acctName + "\n";
    txtWGNameRaw = document.querySelectorAll('.select-workgroup_current-workgroup');
    if (typeof txtWGNameRaw[0] != 'undefined') {
      txtWGName = "Workgroup Name: " + txtWGNameRaw[0].innerHTML.trim() + "\n";
      txtWGNameBold = "**Workgroup Name:** " + txtWGNameRaw[0].innerHTML.trim() + "\n";
    }
    txtPName = "Project Name: " + document.getElementById("nav-breadcrumb").innerText.trim() + "\n";
    txtPName = txtPName + "Project Link: " + origUrlText + "\n";
    txtPNameBold = "**Project Name:** " + "[" + document.getElementById("nav-breadcrumb").innerText.trim() + "]" + "(" + origUrlText + ")\n";

    var chkbox = document.querySelectorAll('.td:nth-child(1)'), x;
    //var rows = document.querySelectorAll('.select-category+ .ember-view .ember-view'), i;
    itemName = '';
    itemNameForCust = '';
    txtItmNames = '';
    txtItmNamesBold = '';
    itemCount = 0;
    for (x = 0; x < chkbox.length; ++x) {
      //console.log(chkbox[x].childNodes[2]);
      if (chkbox[x].childNodes[2].checked == true) {
        itemCount++;
        var rows = document.querySelectorAll('.select-category+ .ember-view .ember-view'), i;
        for (i = 0; i <= x; i++) {
          if (i === x) {
            itemName = itemName + rows[i].innerHTML.trim() + " - Link: " + rows[i].href.trim() + "\n";
            itemNameForCust = itemNameForCust + "[" + rows[i].innerHTML.trim() + "]" + "(" + rows[i].href.trim() + ")\n";
          }
        }
      }
    }

    if (itemCount === 1) {
      txtItmNames = "Item affected :\n" + itemName;
      txtItmNamesBold = "**Item affected :** " + itemNameForCust;
    } else if (itemCount > 1) {
      txtItmNames = "Items affected :\n" + itemName;
      txtItmNamesBold = "**Items affected :**\n" + itemNameForCust;
    }

    txtEndText = "\n**Previous Actions**\n\n**Current Actions**\n\n**Next Steps**\n"

  } else if (urlObj.urlText.indexOf('community') !== -1) {
    titleText = document.getElementById("DeltaPlaceHolderPageTitleInTitleArea").innerText.trim();
  } else if (urlObj.urlText.indexOf('help.bittitan') !== -1) {
    titleText = document.getElementsByClassName("article-title")[0].innerText.trim();
  } else {
    titleText = document.getElementsByClassName("single_overview")[0].innerText.split('\n')[0].trim();
  }

  if (urlObj.urlText.indexOf('migrationwiz.bittitan.com') == -1) { // KBs
    origTitleText = titleText;

    titleText = titleText.replace(/\[/g, '\\[');
    titleText = titleText.replace(/\]/g, '\\]');

    if (cntDoubleClick === 1) {
      executeCopy('---------------\n' + origTitleText + ' : \n' + origUrlText + '\n---------------');
    } else {
      executeCopy('[' + titleText + ']' + '(' + urlObj.urlText + ')');
    }
  } else { // Projects

    if (urlObj.urlText.split("/").length - 1 === 5) { // Project Level
      fullInforTxt = '';
      if (cntDoubleClick === 1) {
        fullInfoTxt = txtAName;
        fullInfoTxt = fullInfoTxt + txtWGNameBold;
        fullInfoTxt = fullInfoTxt + txtPNameBold;
        fullInfoTxt = fullInfoTxt + txtItmNamesBold;
        fullInfoTxt = fullInfoTxt + "**Issue:**";
      } else {
        fullInfoTxt = txtProb;
        fullInfoTxt = fullInfoTxt + txtANameLink;
        fullInfoTxt = fullInfoTxt + txtWGName;
        fullInfoTxt = fullInfoTxt + txtPName;
        fullInfoTxt = fullInfoTxt + txtItmNames;
        fullInfoTxt = fullInfoTxt + txtEndText;
      }
      executeCopy(fullInfoTxt);
    }

    if (urlObj.urlText.split("/").length - 1 === 6) { // Item Level
      var regexProjOpt = /(https\:\/\/.*\/.*\/.*\/.*\/).*(\?qp_currentWorkgroupId=.*)/;
      var matchProjOpt =  regexProjOpt.exec(urlObj.urlText);

      var regexLineOpt = /(https\:\/\/.*\/.*\/.*\/.*\/.*)(\?qp_currentWorkgroupId=.*)/;
      var matchLineOpt = regexLineOpt.exec(urlObj.urlText);

      var regExp = /\/\/.*\/.*\/.*\/.*\/([^\?]+)\?/;
      var matches = regExp.exec(urlObj.urlText);

      executeCopy(matches[1]);

      if (cntDoubleClick === 1) {
        var action_url01 = "https://internal.bittitan.com/MailboxDiagnostic/ViewMailboxDiagnostic?mailboxId=" + matches[1];
        chrome.runtime.sendMessage({ action: 'open_new_tab', tabURL: action_url01 }, function (response) { });
        var action_url02 = matchProjOpt[1] + 'advancedOptions' + matchProjOpt[2] + '&returnRoute=project.index';
        chrome.runtime.sendMessage({ action: 'open_new_tab', tabURL: action_url02 }, function (response) { });
        var action_url03 = matchLineOpt[1] + '/edit' + matchLineOpt[2];
        chrome.runtime.sendMessage({ action: 'open_new_tab', tabURL: action_url03 }, function (response) { });
      }
    }

  }
}
