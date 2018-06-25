// URLOBJECT will be 'undefined' during initialization 
// Execute code only after initialization
if (typeof URLOBJECT != 'undefined')
{
  ExtractFormattedTextBasedOnURL();
}

// Function to create temporary element on page to use for copying content to clipboard
function CopyTextToClipboard(text)
{
  const input = document.createElement('textarea');
  input.style.position = 'fixed';
  input.style.opacity = 0;
  input.value = text;
  document.body.appendChild(input);
  input.focus();
  input.select();
  document.execCommand('Copy');
  document.body.removeChild(input);
}

// Function to extract formatted information for MigrationWiz project and line item(s)
function ExtractFormattedTextFromMW() 
{
  var FormattedTextObject = {};
  var itemCount = 0;
  var txtProblemStatement, txtAccountName, txtStaticAccountName, txtStaticAccountNameLink, nodelistWorkGroup, txtStaticWorkGroupName, txtStaticWorkGroupNameBold, txtProjecName, txtStaticProjectName, txtStaticProjectNameBold, txtStaticItemNames, txtStaticItemNamesBold, txtStaticEndText, txtItemNameForInternal, txtItemNameForCustomer;

  var elmAccountName = document.getElementsByClassName("top-banner is-warning")[0];

  // If user has not impersonate account, there will not be account inforamtion, replace with "*"
  if (elmAccountName == null)
  {
    txtAccountName = "*******";
  } else
  {
    txtAccountName = elmAccountName.innerText.split(':')[1].trim();
  }
  txtProblemStatement = "**Problem Statement**\n\n**Customer Data**\n";

  txtStaticAccountNameLink = "Impersonation Account: " + txtAccountName + "\n";
  txtStaticAccountNameLink = txtStaticAccountNameLink + "Impersonation Link: " + "https://internal.bittitan.com/Impersonate/" + txtAccountName + "\n";
  txtStaticAccountName = "**Account Name:** " + txtAccountName + "\n";

  nodelistWorkGroup = document.querySelectorAll('.select-workgroup_current-workgroup');
  if (typeof nodelistWorkGroup[0] != 'undefined')
  {
    txtStaticWorkGroupName = "Workgroup Name: " + nodelistWorkGroup[0].innerHTML.trim() + "\n";
    txtStaticWorkGroupNameBold = "**Workgroup Name:** " + nodelistWorkGroup[0].innerHTML.trim() + "\n";
  }
  txtProjecName = document.getElementById("nav-breadcrumb").innerText.trim();
  txtStaticProjectName = "Project Name: " + txtProjecName + "\n";
  txtStaticProjectName = txtStaticProjectName + "Project Link: " + URLOBJECT.urlText + "\n";
  txtStaticProjectNameBold = "**Project Name:** " + "[" + txtProjecName + "]" + "(" + URLOBJECT.urlText + ")\n";

  // Extract all checked box elements (line item)
  var chkbox = document.querySelectorAll('.td:nth-child(1)'), x;
  txtItemNameForInternal = '';
  txtItemNameForCustomer = '';
  txtStaticItemNames = '';
  txtStaticItemNamesBold = '';
  itemCount = 0;

  // Format text for line items if not empty
  for (x = 0; x < chkbox.length; ++x)
  {
    
    if (chkbox[x].childNodes[2].checked == true)
    {
      itemCount++;
      var rows = document.querySelectorAll('.select-category+ .truncate .ember-view'), i;
      for (i = 0; i <= x; i++)
      {
        if (i === x)
        {
          txtItemNameForInternal = txtItemNameForInternal + rows[i].innerHTML.trim() + " - Link: " + rows[i].href.trim() + "\n";
          txtItemNameForCustomer = txtItemNameForCustomer + "[" + rows[i].innerHTML.trim() + "]" + "(" + rows[i].href.trim() + ")\n";
        }
      }
    }
  }
  
  // Singular / plural text formatting
  if (itemCount === 1)
  {
    txtStaticItemNames = "Item affected :\n" + txtItemNameForInternal;
    txtStaticItemNamesBold = "**Item affected :** " + txtItemNameForCustomer;
  } else if (itemCount > 1)
  {
    txtStaticItemNames = "Items affected :\n" + txtItemNameForInternal;
    txtStaticItemNamesBold = "**Items affected :**\n" + txtItemNameForCustomer;
  }

  txtStaticEndText = "\n**Previous Actions**\n\n**Current Actions**\n\n**Next Steps**\n"

  FormattedTextObject = {
    txtProblemStatement : txtProblemStatement, txtAccountName: txtAccountName, txtStaticAccountName : txtStaticAccountName, txtStaticAccountNameLink : txtStaticAccountNameLink, nodelistWorkGroup : nodelistWorkGroup, txtStaticWorkGroupName : txtStaticWorkGroupName, 
    txtStaticWorkGroupNameBold : txtStaticWorkGroupNameBold, txtProjecName : txtProjecName, txtStaticProjectName : txtStaticProjectName, txtStaticProjectNameBold : txtStaticProjectNameBold, txtStaticItemNames : txtStaticItemNames, txtStaticItemNamesBold : txtStaticItemNamesBold,
    txtStaticEndText : txtStaticEndText, txtItemNameForInternal : txtItemNameForInternal, txtItemNameForCustomer : txtItemNameForCustomer  
  }

  return FormattedTextObject;
}

// Function to extract formatted information for KBs, Diagnostic page or MW Project based on URL detected
function ExtractFormattedTextBasedOnURL()
{
  // For KBs
  if (URLOBJECT.urlText.indexOf('migrationwiz.bittitan.com') == -1)
  { 
    if (URLOBJECT.urlText.indexOf('community') !== -1)
    {
      titleText = document.getElementById("DeltaPlaceHolderPageTitleInTitleArea").innerText.trim();
    } else if (URLOBJECT.urlText.indexOf('help.bittitan') !== -1)
    {
      titleText = document.getElementsByClassName("article-title")[0].innerText.trim();
    } else
    {
      titleText = document.getElementsByClassName("single_overview")[0].innerText.split('\n')[0].trim();
    }

    escapedTitleText = titleText.replace(/\[/g, '\\[');
    escapedTitleText = escapedTitleText.replace(/\]/g, '\\]');
    escapedUrlText = URLOBJECT.urlText.replace(/\(/g, '\\(');
    escapedUrlText = escapedUrlText.replace(/\)/g, '\\)');

    if (DOUBLECLICKCOUNT === 1)
    {
      CopyTextToClipboard('---------------\n' + titleText + ' : \n' + URLOBJECT.urlText + '\n---------------');
    } else
    {
      CopyTextToClipboard('[' + escapedTitleText + ']' + '(' + escapedUrlText + ')');
    }

  } else
  { 
    // For MW projects
    var FTObject = ExtractFormattedTextFromMW();

    if (URLOBJECT.urlText.split("/").length - 1 === 5)
    { 
      // Project Level
      var completeMWInformationText = '';

      if (DOUBLECLICKCOUNT === 1)
      {
        completeMWInformationText = FTObject.txtStaticAccountName;
        completeMWInformationText = completeMWInformationText + FTObject.txtStaticWorkGroupNameBold;
        completeMWInformationText = completeMWInformationText + FTObject.txtStaticProjectNameBold;
        completeMWInformationText = completeMWInformationText + FTObject.txtStaticItemNamesBold;
        completeMWInformationText = completeMWInformationText + "**Issue:**";
      } else
      {
        completeMWInformationText = FTObject.txtProblemStatement;
        completeMWInformationText = completeMWInformationText + FTObject.txtStaticAccountNameLink;
        completeMWInformationText = completeMWInformationText + FTObject.txtStaticWorkGroupName;
        completeMWInformationText = completeMWInformationText + FTObject.txtStaticProjectName;
        completeMWInformationText = completeMWInformationText + FTObject.txtStaticItemNames;
        completeMWInformationText = completeMWInformationText + FTObject.txtStaticEndText;
      }
      CopyTextToClipboard(completeMWInformationText);
    }

    if (URLOBJECT.urlText.split("/").length - 1 === 6)
    { 
      // Item Level
      var regexToExtractProjectUrl = /(https\:\/\/.*\/.*\/.*\/.*\/).*(\?qp_currentWorkgroupId=.*)/;
      var matchesForProjectOptionPage = regexToExtractProjectUrl.exec(URLOBJECT.urlText);

      var regexToExtractLineItemUrl = /(https\:\/\/.*\/.*\/.*\/.*\/.*)(\?qp_currentWorkgroupId=.*)/;
      var matchesForItemOptionPage = regexToExtractLineItemUrl.exec(URLOBJECT.urlText);

      var regexToExtractMailboxDiagnosticUrl = /\/\/.*\/.*\/.*\/.*\/([^\?]+)\?/;
      var matchesForMailboxDiagnosticPage = regexToExtractMailboxDiagnosticUrl.exec(URLOBJECT.urlText);

      CopyTextToClipboard(matchesForMailboxDiagnosticPage[1]);

      // If double-clicks detected, open Option pages and Diagnostic page
      if (DOUBLECLICKCOUNT === 1)
      {
        var actionUrl;
        var actionUrl = "https://internal.bittitan.com/MailboxDiagnostic/ViewMailboxDiagnostic?mailboxId=" + matchesForMailboxDiagnosticPage[1];
        browser.runtime.sendMessage({ action: 'open_new_tab', tabURL: actionUrl });
        var actionUrl = matchesForProjectOptionPage[1] + 'advancedOptions' + matchesForProjectOptionPage[2] + '&returnRoute=project';
        browser.runtime.sendMessage({ action: 'open_new_tab', tabURL: actionUrl });
        var actionUrl = matchesForItemOptionPage[1] + '/edit' + matchesForItemOptionPage[2];
        browser.runtime.sendMessage({ action: 'open_new_tab', tabURL: actionUrl });
      }
    }

  }
}